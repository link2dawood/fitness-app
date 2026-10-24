import 'dart:async';
import 'dart:convert';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const durableKey = 'flutter.${TrainingHistoryRepository.storageKey}';

class HistoryStore extends InMemorySharedPreferencesStore {
  HistoryStore(super.data) : super.withData();
  bool failWrites = false, throwWrites = false, failReads = false;
  bool failRecoveryRead = false;
  int writes = 0;
  Completer<void>? gate, started;

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key != durableKey) return super.setValue(type, key, value);
    writes++;
    started?.complete();
    started = null;
    await gate?.future;
    if (failRecoveryRead) failReads = true;
    if (throwWrites) throw StateError('Storage write failed');
    if (failWrites) return false;
    return super.setValue(type, key, value);
  }

  @override
  Future<Map<String, Object>> getAll() async {
    if (failReads) throw StateError('Storage read failed');
    return super.getAll();
  }
}

TrainingCompletion completion(String id, DateTime date, int seconds) =>
    TrainingCompletion(
      id: id,
      workoutId: 'routine',
      title: 'Routine',
      finishedAt: date,
      seconds: seconds,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HistoryStore store;
  final today = DateTime(2026, 10, 24, 12);
  final existing = completion('existing', DateTime(2026, 10, 23, 12), 90);
  final added = completion('retry-session', today, 60);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = HistoryStore({
      durableKey: jsonEncode([existing.toJson()]),
    });
    SharedPreferencesStorePlatform.instance = store;
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  for (final throws in [false, true]) {
    test(
      '${throws ? 'Thrown' : 'False'} write cannot create a phantom completion; retry survives a fresh cache',
      () async {
        final repo = TrainingHistoryRepository();
        addTearDown(repo.dispose);
        await repo.load();
        var notifications = 0;
        repo.addListener(() => notifications++);
        store.failWrites = !throws;
        store.throwWrites = throws;
        await expectLater(repo.complete(added), throwsStateError);
        expect(notifications, 0);
        expect(repo.entries.map((e) => e.id), ['existing']);
        final prefs = await SharedPreferences.getInstance();
        expect(
          jsonDecode(prefs.getString(TrainingHistoryRepository.storageKey)!)
              as List,
          hasLength(1),
        );
        await repo.load();
        expect(repo.entries.map((e) => e.id), ['existing']);
        expect(repo.weeklyDays(today), 1);
        expect(repo.streak(today), 1);
        store.failWrites = false;
        store.throwWrites = false;
        await repo.complete(added);
        await repo.complete(added);
        expect(store.writes, 2); // One failed attempt and one durable retry.
        expect(repo.entries.map((e) => e.id), ['existing', 'retry-session']);
        expect(repo.entries.fold(0, (sum, e) => sum + e.seconds), 150);
        expect(repo.weeklyDays(today), 2);
        expect(repo.streak(today), 2);

        // Discard the preferences singleton/cache and rehydrate only durable data.
        final durable = await store.getAll();
        SharedPreferences.setMockInitialValues({});
        store = HistoryStore(durable);
        SharedPreferencesStorePlatform.instance = store;
        final reopened = TrainingHistoryRepository();
        addTearDown(reopened.dispose);
        await reopened.load();
        expect(reopened.entries.map((e) => e.id), [
          'existing',
          'retry-session',
        ]);
        expect(reopened.entries.last.seconds, 60);
      },
    );
  }

  test(
    'retry without an intervening load is durable and preserves other sessions',
    () async {
      final repo = TrainingHistoryRepository();
      addTearDown(repo.dispose);
      store.failWrites = true;
      await expectLater(repo.complete(added), throwsStateError);
      store.failWrites = false;
      await Future.wait([
        repo.complete(added),
        repo.complete(added),
        repo.complete(completion('other', today, 30)),
        repo.load(),
      ]);
      expect(store.writes, 3);
      expect(repo.entries.map((e) => e.id), [
        'existing',
        'retry-session',
        'other',
      ]);
      expect(
        jsonDecode((await store.getAll())[durableKey] as String) as List,
        hasLength(3),
      );
    },
  );

  test(
    'load waits for a pending write and cannot expose its optimistic cache',
    () async {
      final repo = TrainingHistoryRepository();
      addTearDown(repo.dispose);
      await repo.load();
      store.gate = Completer<void>();
      final started = store.started = Completer<void>();
      final write = repo.complete(added);
      await started.future;
      var loaded = false;
      final load = repo.load().then((_) => loaded = true);
      await Future<void>.delayed(Duration.zero);
      expect(loaded, isFalse);
      expect(repo.entries.map((e) => e.id), ['existing']);
      store.gate!.complete();
      await write;
      await load;
      expect(repo.entries.map((e) => e.id), ['existing', 'retry-session']);
    },
  );

  test(
    'failed recovery reload never allows a cached ID to bypass a durable retry',
    () async {
      final repo = TrainingHistoryRepository();
      addTearDown(repo.dispose);
      await repo.load();
      store.failWrites = true;
      store.failRecoveryRead = true;
      await expectLater(repo.complete(added), throwsStateError);
      expect(repo.entries.map((e) => e.id), ['existing']);
      await expectLater(repo.load(), throwsStateError);
      await expectLater(repo.complete(added), throwsStateError);
      expect(store.writes, 1);
      expect(repo.entries.map((e) => e.id), ['existing']);
      store.failWrites = false;
      store.failReads = false;
      store.failRecoveryRead = false;
      await repo.complete(added);
      expect(store.writes, 2);
      expect(
        jsonDecode((await store.getAll())[durableKey] as String) as List,
        hasLength(2),
      );
    },
  );

  test(
    'deduplication refreshes observable state from durable history',
    () async {
      final repo = TrainingHistoryRepository();
      addTearDown(repo.dispose);
      await repo.complete(existing);
      expect(store.writes, 0);
      expect(repo.entries.single.id, 'existing');
    },
  );

  test(
    'malformed durable history is preserved rather than replaced by a completion',
    () async {
      SharedPreferences.setMockInitialValues({});
      store = HistoryStore({durableKey: 'broken'});
      SharedPreferencesStorePlatform.instance = store;
      final repo = TrainingHistoryRepository();
      addTearDown(repo.dispose);
      await expectLater(repo.load(), throwsFormatException);
      await expectLater(repo.complete(added), throwsFormatException);
      expect(store.writes, 0);
      expect((await store.getAll())[durableKey], 'broken');
    },
  );
}
