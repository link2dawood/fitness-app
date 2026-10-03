import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Horizontal option card (icon + title + description + check).
///
/// Pass [iconColor] to give each option its own vibrant identity.
/// - Unselected: pastel background tint + [iconColor] icon.
/// - Selected  : solid [iconColor] background + white icon, with green border.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  /// Optional per-item accent color for the icon container.
  /// Falls back to [AppColors.primary] / [AppColors.surfaceLight] when null.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppColors.primary;

    // Icon container colors
    final iconBg = selected
        ? effectiveColor                            // solid accent when selected
        : effectiveColor.withValues(alpha: 0.12);  // soft pastel when idle
    final iconFg = selected
        ? Colors.white                              // white icon on solid bg
        : effectiveColor;                           // colored icon on pastel bg

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Icon box ──────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconFg),
            ),

            const SizedBox(width: 16),

            // ── Title + subtitle ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Selection indicator ───────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? const Icon(Icons.check_circle_rounded,
                      key: ValueKey('on'), color: AppColors.primary)
                  : const Icon(Icons.radio_button_unchecked_rounded,
                      key: ValueKey('off'), color: AppColors.border),
            ),
          ],
        ),
      ),
    );
  }
}
