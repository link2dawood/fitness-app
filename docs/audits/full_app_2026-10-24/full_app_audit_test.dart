import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:fitness_pro/core/settings/general_settings.dart';
import 'package:fitness_pro/core/settings/reminder_repository.dart';
import 'package:fitness_pro/data/models/user_profile.dart';
import 'package:fitness_pro/data/models/training_calendar.dart';
import 'package:fitness_pro/data/models/training_workout.dart';
import 'package:fitness_pro/data/repositories/training_history_repository.dart';
import 'package:fitness_pro/data/repositories/custom_workout_repository.dart';
import 'package:fitness_pro/data/repositories/onboarding_repository.dart';
import 'package:fitness_pro/viewmodels/home_viewmodel.dart';
import 'package:fitness_pro/viewmodels/onboarding_viewmodel.dart';
import 'package:fitness_pro/views/onboarding/onboarding_view.dart';
import 'package:fitness_pro/views/plan/plan_ready_view.dart';
import 'package:fitness_pro/views/plan/plan_generation_view.dart';
import 'package:fitness_pro/views/pro/pro_plan_view.dart';
import 'package:fitness_pro/views/workouts/training_workout_page.dart';
import 'package:fitness_pro/views/workouts/challenge_day_page.dart';
import 'package:fitness_pro/views/workouts/challenge_session_page.dart';
import 'package:fitness_pro/views/home/home_view.dart';
import 'package:fitness_pro/views/settings/workout_settings_view.dart';

class FailStore extends InMemorySharedPreferencesStore {
  FailStore(super.data):super.withData();
  String? failing;
  int writes = 0;
  @override Future<bool> setValue(String type, String key, Object value) async {
    writes++;
    if (key == failing) return false;
    return super.setValue(type, key, value);
  }
}
final results = <String, dynamic>{};
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (File('C:/Windows/Fonts/arial.ttf').existsSync()) {
      await (FontLoader('AuditReal')..addFont(Future.value(ByteData.sublistView(File('C:/Windows/Fonts/arial.ttf').readAsBytesSync())))).load();
    }
  });
  tearDownAll(() { File('build/full-app-audit-results-2026-10-24.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results)); });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    binding.defaultBinaryMessenger.setMockMethodCallHandler(GeneralSettings.channel, (_) async=>null);
    final messenger=binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers.global'), (_) async=>null);
    messenger.setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers.global/events'), (_) async=>null);
    messenger.setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'), (call) async {
      if(call.method=='create') {
        final id=(call.arguments as Map)['playerId'];
        messenger.setMockStreamHandler(EventChannel('xyz.luan/audioplayers/events/$id'),MockStreamHandler.inline(onListen:(_,sink){}));
      }
      if(call.method=='getDuration'||call.method=='getCurrentPosition') return 0;
      return null;
    });
  });
  test('failed history write and retry evidence', () async {
    final store = FailStore({})..failing='flutter.${TrainingHistoryRepository.storageKey}';
    SharedPreferencesStorePlatform.instance=store;
    final repo=TrainingHistoryRepository();
    final entry=TrainingCompletion(id:'audit-failed',workoutId:'audit',title:'Audit',finishedAt:DateTime.now(),seconds:60);
    await expectLater(repo.complete(entry), throwsStateError);
    await repo.load();
    final loaded=repo.entries.length;
    store.failing=null;
    await repo.complete(entry);
    final persisted=await store.getAll();
    results['historyFailedWrite']={'loadedAfterFailure':loaded,'retryWrites':store.writes,'durableHistory':persisted['flutter.${TrainingHistoryRepository.storageKey}']};
  });
  test('corrupt profile failure state', () async {
    SharedPreferences.setMockInitialValues({'user_profile':'broken'});
    final vm=HomeViewModel(OnboardingRepository());
    Object? failure;
    try {await vm.load();}catch(e){failure=e;}
    results['corruptProfile']={'failure':failure.runtimeType.toString(),'stillLoading':vm.isLoading,'historyError':vm.historyError};
    vm.dispose();
  });
  test('failed keep-screen-on and unit writes', () async {
    final store=FailStore({})..failing='flutter.general_keep_screen_on';
    SharedPreferencesStorePlatform.instance=store;
    GeneralSettings.instance.keepScreenOn=false;
    Object? failure;
    try {await GeneralSettings.instance.setKeepScreenOn(true);}catch(e){failure=e;}
    results['screenOnFailedWrite']={'threw':failure!=null,'observable':GeneralSettings.instance.keepScreenOn,'persisted':(await store.getAll())['flutter.general_keep_screen_on']};
    store.failing='flutter.general_height_imperial';
    GeneralSettings.instance.weightImperial=false;GeneralSettings.instance.heightImperial=false;
    try{await GeneralSettings.instance.setUnits(weight:true,height:true);}catch(_){}
    results['unitPartialWrite']={'observableWeight':GeneralSettings.instance.weightImperial,'durable':await store.getAll()};
  });
  test('onboarding accepts unsupported week-start value', () async {
    final vm=OnboardingViewModel(OnboardingRepository());
    vm.selectFirstDayOfWeek('TUESDAY');
    await vm.complete();
    final profile=await OnboardingRepository().loadProfile();
    final week=TrainingCalendar.week(DateTime(2026,10,24),profile!.firstDayOfWeek);
    results['unsupportedWeekStart']={'saved':profile.firstDayOfWeek,'renderedFirstWeekday':week.first.weekday,'renderedFirstDate':week.first.toIso8601String()};
    vm.dispose();
  });
  testWidgets('workout settings failed write and action semantics', (tester) async {
    final store=FailStore({})..failing='flutter.settings_prep';
    SharedPreferencesStorePlatform.instance=store;
    await tester.pumpWidget(const MaterialApp(home:WorkoutSettingsView()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prep timer'));
    await tester.pumpAndSettle();
    final wheel=tester.widget<ListWheelScrollView>(find.byType(ListWheelScrollView));
    wheel.onSelectedItemChanged!(4);
    await tester.pump();
    final semantics=tester.ensureSemantics();
    results['workoutDoneSemantics']=tester.getSemantics(find.text('Done')).toString();
    semantics.dispose();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    results['workoutSettingsFailedWrite']={'displayed25':find.text('25 secs >').evaluate().isNotEmpty,'errorShown':find.text('Could not save settings. Please try again.').evaluate().isNotEmpty,'durablePrep':(await store.getAll())['flutter.settings_prep']};
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('reference challenge ignores Off rest mode', (tester) async {
    SharedPreferences.setMockInitialValues({'settings_prep':0,'settings_rest_mode':'Off'});
    await tester.pumpWidget(const MaterialApp(home:ChallengeDayPage(enableMedia:false)));
    await tester.pumpAndSettle();
    final buttons=find.widgetWithText(FilledButton,'Start');
    final candidates=find.byType(FilledButton);
    results['challengeButtons']=tester.widgetList<FilledButton>(candidates).map((b)=>b.child.toString()).toList();
    final button=buttons.evaluate().isNotEmpty?buttons:candidates.last;
    await tester.ensureVisible(button);
    tester.widget<FilledButton>(button).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds:600));
    final session=tester.widget<ChallengeSessionPage>(find.byType(ChallengeSessionPage));
    results['challengeOffRest']={'restSeconds':session.rest,'prep':session.prep};
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds:2));
  });
  testWidgets('generic session does not use saved preparation settings', (tester) async {
    SharedPreferences.setMockInitialValues({'settings_prep':45,'settings_rest_mode':'Off','settings_music':true,'settings_voice':true});
    await tester.pumpWidget(MaterialApp(home:TrainingSessionPage(workout:trainingWorkouts.first)));
    await tester.pump(const Duration(milliseconds:300));
    results['genericSettings']={'exerciseStartedImmediately':find.text(trainingWorkouts.first.exercises.first.name).evaluate().isNotEmpty,'configuredPrep':45,'catalogRest':trainingWorkouts.first.restAfter(0),'savedRestMode':'Off'};
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('leaving plan generator during an inter-step delay', (tester) async {
    await tester.pumpWidget(const MaterialApp(home:PlanGenerationView()));
    await tester.pump(const Duration(milliseconds:450));
    await tester.pump(const Duration(milliseconds:1));
    await tester.pump(const Duration(milliseconds:700));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds:600));
    final error=tester.takeException();
    results['planGenerationAfterDispose']=error?.toString();
  });
  for(final config in [(390.0,844.0,1.0),(320.0,640.0,2.0),(844.0,390.0,1.0)]) {
    testWidgets('remaining screen layout matrix $config', (tester) async {
      tester.view.physicalSize=Size(config.$1,config.$2);tester.view.devicePixelRatio=1;
      addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
      final original=FlutterError.onError;
      final errors=<String>[];
      FlutterError.onError=(d){errors.add(d.exceptionAsString());};
      final all=<String,dynamic>{};
      Widget app(Widget home)=>MaterialApp(theme:ThemeData(fontFamily:'AuditReal'),builder:(context,child)=>MediaQuery(data:MediaQuery.of(context).copyWith(textScaler:TextScaler.linear(config.$3)),child:child!),home:home);
      Future<void> inspect(String name,Widget page) async {
        errors.clear();
        await tester.pumpWidget(app(page));
        await tester.pump(const Duration(milliseconds:500));
        all[name]=List<String>.from(errors);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds:2));
      }
      try {
        const profile=UserProfile(weightKg:80,heightCm:180);
        await inspect('planReady',const PlanReadyView(profile:profile));
        await inspect('pro',const ProPlanView());
        final onboard=OnboardingViewModel(OnboardingRepository());
        for(var i=0;i<8;i++) {
          errors.clear();
          await tester.pumpWidget(app(ChangeNotifierProvider.value(value:onboard,child:const OnboardingView())));
          await tester.pump(const Duration(milliseconds:500));
          all['onboarding-${onboard.currentStep.name}']=List<String>.from(errors);
          if(i<7) await onboard.skip();
        }
        await tester.pumpWidget(const SizedBox());onboard.dispose();
        await tester.pump(const Duration(seconds:1));
        await inspect('genericSession',TrainingSessionPage(workout:trainingWorkouts.first));
        SharedPreferences.setMockInitialValues({'user_profile':jsonEncode(profile.toJson()),'onboarding_completed':true});
        final home=HomeViewModel(OnboardingRepository());
        await tester.runAsync(home.load);
        await inspect('homeAllTabs',MultiProvider(providers:[Provider(create:(_)=>OnboardingRepository()),ChangeNotifierProvider.value(value:home)],child:const HomeView()));
        home.dispose();
        for(final label in ['Music','Rest timer','Prep timer','Sound options']) {
          errors.clear();
          await tester.pumpWidget(app(const WorkoutSettingsView()));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          all['settings-$label']=List<String>.from(errors);
          await tester.pumpWidget(const SizedBox());
          await tester.pump(const Duration(seconds:1));
        }
        results['layouts-${config.$1}-${config.$2}-${config.$3}']=all;
      }finally{ FlutterError.onError=original; }
    });
  }
}
