import 'package:flutter/material.dart';

class ProButton extends StatelessWidget {
  const ProButton({super.key, required this.onPressed, this.expanded = false});

  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF332512);
    return Semantics(
      button: true,
      label: 'Pro plans',
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Pro plans',
        excludeFromSemantics: true,
        child: SizedBox(
          width: expanded ? double.infinity : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(expanded ? 18 : 24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFEDB8),
                  Color(0xFFF5CE76),
                  Color(0xFFE8B64E),
                ],
                stops: [0, .55, 1],
              ),
              border: Border.all(color: const Color(0xFFFFF0C6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB17A19).withValues(alpha: .22),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                foregroundColor: ink,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 20 : 12,
                  vertical: expanded ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(expanded ? 18 : 24),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: expanded ? 15 : 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 22),
                  SizedBox(width: expanded ? 12 : 6),
                  if (expanded)
                    const Expanded(child: Text('GO PREMIUM'))
                  else
                    const Text('PRO'),
                  if (expanded) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
