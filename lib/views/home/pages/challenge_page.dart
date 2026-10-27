import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/training_challenges.dart';
import '../../../data/models/user_profile.dart';
import '../../../widgets/training_feature_cards.dart';
import '../../workouts/challenge_day_page.dart';
import 'training_profile_builder.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key, this.profile});
  final UserProfile? profile;
  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  String category = 'All';
  static const double _cardHeight = 210;
  static const colors = [
    Color(0xFF7E22CE),
    Color(0xFFF97316),
    Color(0xFF279C88),
    Color(0xFF0062FF),
  ];
  Color _cardColor(TrainingChallenge item) => item.customized
      ? trainingCardBlue
      : colors[(TrainingChallenges.catalog.indexWhere(
                      (entry) => entry.workoutId == item.workoutId,
                    ) -
                    1)
                .abs() %
            colors.length];

  @override
  Widget build(BuildContext context) => TrainingProfileBuilder(
    profile: widget.profile,
    builder: (context, profile) {
      final all = TrainingChallenges.forProfile(profile);
      final cards = all.where((item) => item.matches(category)).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    for (final filter in TrainingChallenges.filters)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          key: ValueKey('challenge-filter-$filter'),
                          label: Text(filter),
                          selectedColor: AppColors.primary,
                          selected: category == filter,
                          labelStyle: TextStyle(
                            color: category == filter
                                ? AppColors.onPrimary
                                : AppColors.textPrimary,
                          ),
                          onSelected: (_) => setState(() => category = filter),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    '${cards.length} ${cards.length == 1 ? 'challenge' : 'challenges'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
            if (cards.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No challenges match this category. Choose another badge.',
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  final item = cards[index];
                  final scaler = MediaQuery.textScalerOf(context);
                  // Very large accessibility text switches the card to a
                  // stacked layout, so let it size naturally there.
                  final largeText = scaler.scale(16) > 22;
                  final Widget card = item.referenceDay
                      ? const ReferenceChallengeCard()
                      : TrainingChallengeCard(
                          workout: item.workout,
                          customized: item.customized,
                          compact: true,
                          color: _cardColor(item),
                        );
                  return Padding(
                    key: ValueKey('challenge-card-${item.workoutId}'),
                    padding: const EdgeInsets.only(bottom: 14),
                    child: largeText
                        ? card
                        : SizedBox(
                            height: scaler.scale(_cardHeight),
                            child: card,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
