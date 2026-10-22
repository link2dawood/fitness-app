import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/training_recommendations.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../viewmodels/home_viewmodel.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/discover_catalog.dart';
import '../../workouts/training_workout_page.dart';
import '../../workouts/training_history_sheet.dart';
import 'training_collection_page.dart';

void openDiscoverCollection(BuildContext context, String id) {
  final collection = DiscoverCatalog.collection(id);
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      settings: RouteSettings(name: '/discover/collection/$id'),
      builder: (_) => TrainingCollectionPage(
        title: collection.title,
        workouts: collection.workouts,
      ),
    ),
  );
}

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 20,
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'DISCOVER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Search workouts',
                icon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF111827),
                  size: 26,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pushNamed(AppRoutes.search);
                },
              ),
              IconButton(
                tooltip: 'Workout history',
                icon: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF111827),
                  size: 26,
                ),
                onPressed: () => showPersistedTrainingHistory(context),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── 1. Hero Banner ───────────────────────────────────────
                _HeroBanner(),

                const SizedBox(height: 28),

                const _DiscoverPicksSection(key: ValueKey('picks-section')),

                const SizedBox(height: 28),

                // ── 3. Stay Active Promo Banner ──────────────────────────
                _PromoBanner(),

                const SizedBox(height: 28),

                // ── 4. For Beginners ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'For beginners',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BeginnersList(),

                const SizedBox(height: 28),

                // ── 5. Fast Workout ──────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Fast workout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FastWorkoutList(),

                const SizedBox(height: 28),

                // ── 6. Challenge ─────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Challenge',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ChallengeList(),

                const SizedBox(height: 28),

                // ── 7. With Equipment ────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'With Equipment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _WithEquipmentCard(),

                const SizedBox(height: 28),

                // ── 8. Stretch ───────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Stretch',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _StretchGrid(),

                const SizedBox(height: 28),

                // ── 9. Body focus ────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Body focus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BodyFocusGrid(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// One semantic action and one keyboard focus target per card.
class _DiscoverAction extends StatefulWidget {
  const _DiscoverAction({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.radius = 16,
  });
  final String label;
  final VoidCallback onTap;
  final Widget child;
  final double radius;
  @override
  State<_DiscoverAction> createState() => _DiscoverActionState();
}

class _DiscoverActionState extends State<_DiscoverAction> {
  bool focused = false;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    focusable: true,
    focused: focused,
    label: widget.label,
    onTap: widget.onTap,
    child: ExcludeSemantics(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          excludeFromSemantics: true,
          onTap: widget.onTap,
          onFocusChange: (value) => setState(() => focused = value),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              border: focused
                  ? Border.all(color: const Color(0xFF0062FF), width: 3)
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

// Horizontal content has natural height, including at large text sizes.
class _DiscoverCarousel extends StatelessWidget {
  const _DiscoverCarousel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          children[i],
        ],
      ],
    ),
  );
}

class _DiscoverPhotoAction extends StatelessWidget {
  const _DiscoverPhotoAction({
    required this.actionKey,
    required this.image,
    required this.label,
    required this.onTap,
    required this.child,
    required this.minHeight,
  });
  final Key actionKey;
  final String image, label;
  final VoidCallback onTap;
  final Widget child;
  final double minHeight;
  @override
  Widget build(BuildContext context) => _DiscoverAction(
    key: actionKey,
    label: label,
    onTap: onTap,
    radius: 20,
    child: Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xDD000000)],
              ),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ],
    ),
  );
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workout = DiscoverCatalog.workout(DiscoverCatalog.heroWorkoutId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _DiscoverPhotoAction(
        actionKey: const ValueKey('discover-hero'),
        image: 'assets/images/workouts/hiit_fat_burning.jpg',
        label: 'Open workout: ${workout.title}. ${workout.summary}',
        onTap: () => openTrainingWorkout(context, workout),
        minHeight: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              workout.summary,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutPairCarousel extends StatelessWidget {
  const _WorkoutPairCarousel({required this.groups});
  final List<List<DiscoverWorkoutCard>> groups;
  @override
  Widget build(BuildContext context) => _DiscoverCarousel(
    children: [
      for (final group in groups)
        SizedBox(
          width: (MediaQuery.sizeOf(context).width - 56).clamp(240.0, 420.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < group.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFF3F4F6),
                    ),
                  _WorkoutListCard(card: group[i]),
                ],
              ],
            ),
          ),
        ),
    ],
  );
}

class _WorkoutListCard extends StatelessWidget {
  const _WorkoutListCard({required this.card});
  final DiscoverWorkoutCard card;
  @override
  Widget build(BuildContext context) {
    final workout = card.workout;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        card.image,
        width: 80,
        height: 64,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
      ),
    );
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          workout.durationAndLevel,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
    return _DiscoverAction(
      key: ValueKey('discover-workout-${card.workoutId}'),
      label: 'Open workout: ${workout.title}. ${workout.summary}',
      onTap: () => openTrainingWorkout(context, workout),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: MediaQuery.textScalerOf(context).scale(14) > 20
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [image, const SizedBox(height: 12), text],
              )
            : Row(
                children: [
                  image,
                  const SizedBox(width: 12),
                  Expanded(child: text),
                ],
              ),
      ),
    );
  }
}

class _DiscoverPicksSection extends StatefulWidget {
  const _DiscoverPicksSection({super.key});
  @override
  State<_DiscoverPicksSection> createState() => _DiscoverPicksSectionState();
}

class _DiscoverPicksSectionState extends State<_DiscoverPicksSection>
    with WidgetsBindingObserver {
  Future<UserProfile?>? loading;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && loading != null) retry();
  }

  void retry() {
    setState(() {
      loading = OnboardingRepository().loadProfile();
    });
  }

  Widget section(UserProfile? profile, {Widget? status}) {
    final ranked = TrainingRecommendations.forProfile(profile).take(7).toList();
    final personalized = ranked.isNotEmpty;
    final cards = ranked
        .map((w) => DiscoverWorkoutCard(w.id, w.image))
        .toList();
    final groups = personalized
        ? <List<DiscoverWorkoutCard>>[
            for (var i = 0; i < cards.length; i += 2)
              cards.sublist(i, (i + 2).clamp(0, cards.length)),
          ]
        : DiscoverCatalog.picks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personalized ? 'Picks for you' : 'Featured workouts',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              if (!personalized && status == null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Complete your fitness profile for personalized picks.',
                ),
              ],
              if (status != null) ...[const SizedBox(height: 8), status],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _WorkoutPairCarousel(groups: groups),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel?>();
    if (home != null && !home.isLoading) {
      return section(home.profile);
    }
    return FutureBuilder<UserProfile?>(
      future: loading ??= OnboardingRepository().loadProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return section(
            null,
            status: const LinearProgressIndicator(
              semanticsLabel: 'Loading workout recommendations',
            ),
          );
        }
        if (snapshot.hasError) {
          return section(
            null,
            status: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personalized picks could not be loaded. Showing featured workouts.',
                ),
                TextButton(
                  onPressed: retry,
                  child: const Text('Retry personalized picks'),
                ),
              ],
            ),
          );
        }
        return section(snapshot.data);
      },
    );
  }
}

class _FastWorkoutList extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const _WorkoutPairCarousel(groups: DiscoverCatalog.fast);
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = DiscoverCatalog.collection('stay_active');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _DiscoverPhotoAction(
        actionKey: const ValueKey('discover-collection-stay_active'),
        image: 'assets/images/workouts/stretch_warmup.jpg',
        label:
            'Open collection: ${collection.title}. ${collection.workouts.length} workouts',
        onTap: () => openDiscoverCollection(context, collection.id),
        minHeight: 170,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stay active,\nstay in shape',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${collection.workouts.length} workouts',
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutPhotoCard extends StatelessWidget {
  const _WorkoutPhotoCard({required this.card});
  final DiscoverWorkoutCard card;
  @override
  Widget build(BuildContext context) {
    final workout = card.workout;
    return SizedBox(
      width: MediaQuery.textScalerOf(context).scale(14) > 20 ? 220 : 150,
      child: _DiscoverPhotoAction(
        actionKey: ValueKey('discover-workout-${card.workoutId}'),
        image: card.image,
        label: 'Open workout: ${workout.title}. ${workout.summary}',
        onTap: () => openTrainingWorkout(context, workout),
        minHeight: 170,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeginnersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _DiscoverCarousel(
    children: [
      for (final card in DiscoverCatalog.beginners)
        _WorkoutPhotoCard(card: card),
    ],
  );
}

class _ChallengeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _DiscoverCarousel(
    children: [
      for (final card in DiscoverCatalog.challenges)
        _WorkoutPhotoCard(card: card),
    ],
  );
}

class _WithEquipmentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collection = DiscoverCatalog.collection('with_equipment');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _DiscoverPhotoAction(
        actionKey: const ValueKey('discover-collection-with_equipment'),
        image: 'assets/images/workouts/massive_body.jpg',
        label:
            'Open collection: ${collection.title}. ${collection.workouts.length} workouts',
        onTap: () => openDiscoverCollection(context, collection.id),
        minHeight: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boost your results with added resistance for faster, better gains.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                "Let's Go! →",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StretchGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _DiscoverCarousel(
    children: [
      for (final group in DiscoverCatalog.stretch)
        SizedBox(
          width: MediaQuery.textScalerOf(context).scale(13) > 20 ? 220 : 165,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < group.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _StretchCard(card: group[i]),
              ],
            ],
          ),
        ),
    ],
  );
}

class _StretchCard extends StatelessWidget {
  const _StretchCard({required this.card});
  final DiscoverWorkoutCard card;
  @override
  Widget build(BuildContext context) {
    final workout = card.workout;
    return _DiscoverAction(
      key: ValueKey('discover-workout-${card.workoutId}'),
      label: 'Open workout: ${workout.title}. ${workout.summary}',
      onTap: () => openTrainingWorkout(context, workout),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              card.image,
              width: double.infinity,
              height: 105,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              workout.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyFocusGrid extends StatelessWidget {
  static const items = [
    ('focus_chest', 'chest'),
    ('focus_arm_shoulder', 'arm'),
    ('focus_glutes_leg', 'leg'),
    ('focus_abs', 'abs'),
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: LayoutBuilder(
      builder: (context, box) {
        final single =
            box.maxWidth < 400 &&
            MediaQuery.textScalerOf(context).scale(16) > 24;
        final width = single ? box.maxWidth : (box.maxWidth - 14) / 2;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final (id, type) in items)
              SizedBox(
                width: width,
                child: _BodyFocusCard(collectionId: id, type: type),
              ),
          ],
        );
      },
    ),
  );
}

class _BodyFocusCard extends StatelessWidget {
  const _BodyFocusCard({required this.collectionId, required this.type});
  final String collectionId, type;
  @override
  Widget build(BuildContext context) {
    final collection = DiscoverCatalog.collection(collectionId);
    return _DiscoverAction(
      key: ValueKey('discover-collection-$collectionId'),
      label:
          'Open collection: ${collection.title}. ${collection.workouts.length} workouts',
      onTap: () => openDiscoverCollection(context, collectionId),
      radius: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C364F), Color(0xFF1E2638)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomPaint(
                size: const Size(60, 50),
                painter: MuscleSilhouettePainter(type: type),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              collection.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MuscleSilhouettePainter extends CustomPainter {
  MuscleSilhouettePainter({required this.type});

  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    if (type == 'chest') {
      // Draw Chest Pectoral Muscles Silhouette
      final pathLeft = Path()
        ..moveTo(cx - 3, cy - 12)
        ..cubicTo(cx - 16, cy - 14, cx - 24, cy - 6, cx - 22, cy + 6)
        ..cubicTo(cx - 20, cy + 14, cx - 10, cy + 14, cx - 3, cy + 9)
        ..close();

      final pathRight = Path()
        ..moveTo(cx + 3, cy - 12)
        ..cubicTo(cx + 16, cy - 14, cx + 24, cy - 6, cx + 22, cy + 6)
        ..cubicTo(cx + 20, cy + 14, cx + 10, cy + 14, cx + 3, cy + 9)
        ..close();

      canvas.drawPath(pathLeft, paint);
      canvas.drawPath(pathRight, paint);
    } else if (type == 'arm') {
      // Draw Flexed Bicep Arm Silhouette
      final path = Path()
        ..moveTo(cx - 20, cy + 14)
        ..cubicTo(cx - 16, cy + 4, cx - 10, cy - 2, cx - 3, cy - 12)
        ..cubicTo(cx + 6, cy - 18, cx + 18, cy - 10, cx + 18, cy + 2)
        ..cubicTo(cx + 18, cy + 10, cx + 10, cy + 14, cx - 2, cy + 14)
        ..close();

      canvas.drawPath(path, paint);
    } else if (type == 'leg') {
      // Draw Athletic Legs Silhouette
      final pathLeft = Path()
        ..moveTo(cx - 10, cy - 16)
        ..cubicTo(cx - 18, cy - 6, cx - 16, cy + 6, cx - 8, cy + 16)
        ..lineTo(cx - 3, cy + 16)
        ..cubicTo(cx - 8, cy + 4, cx - 8, cy - 6, cx - 4, cy - 16)
        ..close();

      final pathRight = Path()
        ..moveTo(cx + 10, cy - 16)
        ..cubicTo(cx + 18, cy - 6, cx + 16, cy + 6, cx + 8, cy + 16)
        ..lineTo(cx + 3, cy + 16)
        ..cubicTo(cx + 8, cy + 4, cx + 8, cy - 6, cx + 4, cy - 16)
        ..close();

      canvas.drawPath(pathLeft, paint);
      canvas.drawPath(pathRight, paint);
    } else if (type == 'abs') {
      // Draw Six Pack Abs Silhouette
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 6, cy - 9), width: 9, height: 6),
        const Radius.circular(2),
      );
      final r2 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy - 9), width: 9, height: 6),
        const Radius.circular(2),
      );
      final r3 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 6, cy), width: 9, height: 6),
        const Radius.circular(2),
      );
      final r4 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy), width: 9, height: 6),
        const Radius.circular(2),
      );
      final r5 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 6, cy + 9), width: 9, height: 6),
        const Radius.circular(2),
      );
      final r6 = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 6, cy + 9), width: 9, height: 6),
        const Radius.circular(2),
      );

      canvas.drawRRect(r, paint);
      canvas.drawRRect(r2, paint);
      canvas.drawRRect(r3, paint);
      canvas.drawRRect(r4, paint);
      canvas.drawRRect(r5, paint);
      canvas.drawRRect(r6, paint);

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final leftBracket = Path()
        ..moveTo(cx - 16, cy - 12)
        ..lineTo(cx - 13, cy + 12);

      final rightBracket = Path()
        ..moveTo(cx + 16, cy - 12)
        ..lineTo(cx + 13, cy + 12);

      canvas.drawPath(leftBracket, linePaint);
      canvas.drawPath(rightBracket, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
