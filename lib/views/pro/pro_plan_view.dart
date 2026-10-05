import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen Pro Plan / Paywall page matching the reference design.
///
/// Sections:
///  1. Before / After hero image with a tab overlay
///  2. "Unlock Your Personalized Plan!" heading
///  3. Monthly + Newcomer Discount plan tiles (radio selection)
///  4. "Enable 7 days free trial" toggle
///  5. "More You Can Get" feature list
///  6. "Join 100M+ Happy Users" review carousel
///  7. Legal disclaimer + Terms / Privacy links
///  8. Sticky "START →" bottom CTA
class ProPlanView extends StatefulWidget {
  const ProPlanView({super.key});

  @override
  State<ProPlanView> createState() => _ProPlanViewState();
}

class _ProPlanViewState extends State<ProPlanView> {
  /// 0 = monthly, 1 = yearly (newcomer discount)
  int _selectedPlan = 1;
  bool _freeTrialEnabled = false;

  // ── Review carousel state ────────────────────────────────────────────────
  late final PageController _reviewController;
  int _reviewPage = 0;

  static const _reviews = [
    _Review(
      image: 'assets/images/reviews/user_1.jpg',
      stars: 5,
      title: 'Lose 10kg in just 1 month',
      body:
          'I love the intuitive animations! It also keeps track of my progress, '
          'and I can see myself losing weight so fast. And the best part, no '
          'equipment needed.',
      author: 'Bennett',
      date: '2025/02/14',
    ),
    _Review(
      image: 'assets/images/reviews/user_2.jpg',
      stars: 5,
      title: 'Boost vitality and confidence',
      body:
          'It tailors plans for me and keeps me motivated. The exercises are '
          'easy and intuitive, and they change every day. Very easy to stick to!',
      author: 'Leon',
      date: '2024/11/26',
    ),
    _Review(
      image: 'assets/images/reviews/user_3.jpg',
      stars: 5,
      title: 'Super helpful home workout app',
      body:
          "I've been using it for 3 years, and it has really changed my life. "
          'I pumped up my muscles and have stayed in great shape for years. '
          'Plus I rarely get sick now.',
      author: 'Nora',
      date: '2024/05/12',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _reviewController = PageController(viewportFraction: 0.82);
    _reviewController.addListener(() {
      final page = _reviewController.page?.round() ?? 0;
      if (page != _reviewPage) setState(() => _reviewPage = page);
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(context),
                _buildPlanSection(),
                _buildTrialToggle(),
                _buildFeaturesSection(),
                _buildReviewSection(),
                _buildLegalSection(),
                const SizedBox(height: 100), // room for sticky button
              ],
            ),
          ),

          // ── Top bar: close + restore ────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Restore',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky bottom CTA ──────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              color: Colors.white,
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pro Plan Activated!')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0062FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'START',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HERO — Before / After
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 300 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Full-width before/after image
          Image.asset(
            'assets/images/ui/pro_before_after.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.3),
          ),
          // Gradient scrim at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),
          ),
          // BEFORE / AFTER tab overlay
          Positioned(
            bottom: 10,
            left: 24,
            right: 24,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0062FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // BEFORE tab (left, transparent)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'BEFORE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // AFTER tab (right, filled blue)
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'AFTER',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. PLAN SELECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPlanSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unlock Your Personalized\nPlan!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.2,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),

          // Monthly option
          _planTile(
            index: 0,
            title: 'Monthly',
            price: 'Rs 1,400.00/month',
          ),
          const SizedBox(height: 12),

          // Newcomer discount
          _planTile(
            index: 1,
            title: 'Newcomer Discount',
            price: 'Just Rs 5,600.00/year',
            oldPrice: 'Rs16800.0/year',
            badge: 'Save 67%',
          ),
        ],
      ),
    );
  }

  Widget _planTile({
    required int index,
    required String title,
    required String price,
    String? oldPrice,
    String? badge,
  }) {
    final selected = _selectedPlan == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0062FF) : const Color(0xFFE5E7EB),
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0062FF).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // Radio circle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF0062FF)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    color: selected
                        ? const Color(0xFF0062FF)
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                // Text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            oldPrice,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Badge
            if (badge != null)
              Positioned(
                top: -6,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0062FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. FREE TRIAL TOGGLE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTrialToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Enable 7 days free trial',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          Switch.adaptive(
            value: _freeTrialEnabled,
            activeTrackColor: const Color(0xFF0062FF),
            onChanged: (v) => setState(() => _freeTrialEnabled = v),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. FEATURES LIST
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturesSection() {
    const features = [
      _Feature(Icons.lock_open_rounded, 'Unlimited targeted workouts'),
      _Feature(Icons.local_fire_department_rounded,
          '300+ workouts for fat burning'),
      _Feature(Icons.thumb_up_alt_rounded, 'Visible results in just 4 weeks'),
      _Feature(Icons.auto_awesome_rounded, 'Add new workouts constantly'),
      _Feature(Icons.block_rounded, 'Remove Ads'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More You Can Get',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(f.icon, size: 22, color: const Color(0xFF6B7280)),
                  const SizedBox(width: 14),
                  Text(
                    f.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. REVIEWS CAROUSEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 14),
          child: Text(
            'Join 100M+ Happy Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ),

        // Swipeable review cards
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _reviewController,
            itemCount: _reviews.length,
            padEnds: true,
            itemBuilder: (context, i) {
              final r = _reviews[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.asset(
                          r.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stars
                            Row(
                              children: List.generate(
                                5,
                                (s) => Icon(
                                  s < r.stars
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 20,
                                  color: const Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Title
                            Text(
                              r.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Body (max 4 lines)
                            Text(
                              r.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Author
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '- ${r.author}, ${r.date}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _reviews.length,
            (i) => Container(
              width: i == _reviewPage ? 10 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == _reviewPage
                    ? const Color(0xFF374151)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. LEGAL SECTION
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLegalSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
      child: Column(
        children: [
          const Text(
            'The subscription will auto-renew unless you cancel it '
            'at least 24 hours before your trial or current period '
            'ends. You can cancel anytime during the trial.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Terms of Use',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text(
                ' | ',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _Feature {
  const _Feature(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _Review {
  const _Review({
    required this.image,
    required this.stars,
    required this.title,
    required this.body,
    required this.author,
    required this.date,
  });
  final String image;
  final int stars;
  final String title;
  final String body;
  final String author;
  final String date;
}
