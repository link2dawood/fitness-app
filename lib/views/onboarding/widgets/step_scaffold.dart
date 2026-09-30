import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Common layout: title, subtitle and an expanding content area.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 28),
          Expanded(child: child),
        ],
      ),
    );
  }
}
