import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../widgets/rate_collection_dialog.dart';
import '../../settings/feature_suggestions_sheet.dart';
import '../../settings/language_options_dialog.dart';
import '../../../core/settings/general_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showUnavailable(String feature, String reason) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(feature),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupAndRestoreModal(BuildContext context) {
    _showUnavailable(
      'Backup & Restore',
      'Cloud backup is not available yet. Your profile is stored only on this device.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // ── 1. Main Settings Card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Backup & Restore Header (Clickable)
                GestureDetector(
                  onTap: () => _showBackupAndRestoreModal(context),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Backup & Restore',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF4285F4),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.sync_rounded,
                              color: Color(0xFF0066FF),
                              size: 22,
                            ),
                            onPressed: () =>
                                _showBackupAndRestoreModal(context),
                          ),
                        ],
                      ),
                      const Text(
                        'Cloud backup is not available yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // GO PREMIUM Button
                _buildGoPremiumButton(context),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFF3F4F6), height: 1),
                const SizedBox(height: 8),

                // Menu items inside Card 1
                _buildSettingTile(
                  iconBgColor: const Color(0xFF4CAF50),
                  icon: Icons.water_drop_rounded,
                  title: 'Workout Settings',
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.workoutSettings);
                    if (!context.mounted) return;
                    await vm.load();
                  },
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFF2196F3),
                  icon: Icons.settings_rounded,
                  title: 'General Settings',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.generalSettings),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFFFFA000),
                  icon: Icons.mic_rounded,
                  title: 'Voice Options (TTS)',
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.voiceOptions),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFF00BCD4),
                  icon: Icons.chat_bubble_rounded,
                  title: 'Suggest Other Features',
                  onTap: () => showFeatureSuggestions(context),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                ListenableBuilder(
                  listenable: GeneralSettings.instance,
                  builder: (context, _) => _buildSettingTile(
                    iconBgColor: const Color(0xFF7E57C2),
                    icon: Icons.public_rounded,
                    title: 'Language Options',
                    subtitle: GeneralSettings.instance.language.label,
                    onTap: () => showLanguageOptions(context),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── 2. Social & App Info Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  iconBgColor: const Color(0xFF607D8B),
                  icon: Icons.share_rounded,
                  title: 'Share with friends',
                  onTap: () => _showUnavailable(
                    'Share with friends',
                    'Sharing requires a published app store link.',
                  ),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFF607D8B),
                  icon: Icons.star_rounded,
                  title: 'Rate us',
                  onTap: () => showRateCollectionDialog(context),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFF607D8B),
                  icon: Icons.edit_rounded,
                  title: 'Feedback',
                  onTap: () => _showUnavailable(
                    'Feedback',
                    'Feedback requires a configured support contact.',
                  ),
                ),
                const Divider(color: Color(0xFFF9FAFB), height: 1),
                _buildSettingTile(
                  iconBgColor: const Color(0xFF607D8B),
                  icon: Icons.block_rounded,
                  title: 'Remove Ads',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.pro);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // App Version Text
          const Center(
            child: Text(
              'Version 1.7.91',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Reset Onboarding Option
          Center(
            child: TextButton.icon(
              onPressed: () async {
                try {
                  await vm.resetOnboarding();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not reset your profile. Please retry.',
                        ),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(
                Icons.restart_alt_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              label: const Text(
                'Reset Onboarding Data',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoPremiumButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).pushNamed(AppRoutes.pro);
      },
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0066FF),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066FF).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.block_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'GO PREMIUM',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required Color iconBgColor,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD1D5DB),
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy),
      radius: radius - strokeWidth / 2,
    );

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw 4 color arcs
    canvas.drawArc(rect, -2.35, 1.4, false, redPaint);
    canvas.drawArc(rect, -0.95, 1.2, false, yellowPaint);
    canvas.drawArc(rect, 0.25, 1.3, false, greenPaint);
    canvas.drawArc(rect, 1.55, 1.5, false, bluePaint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(cx - 2, cy - strokeWidth / 2, radius * 0.9, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
