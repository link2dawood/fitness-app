import 'package:flutter/material.dart';

/// Keeps custom card artwork while providing Material focus/keyboard behavior.
class AppAction extends StatefulWidget {
  const AppAction({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
    this.selected,
    this.behavior,
  });
  final VoidCallback? onTap;
  final Widget child;
  final String? label;
  final bool? selected;
  final HitTestBehavior? behavior;

  @override
  State<AppAction> createState() => _AppActionState();
}

class _AppActionState extends State<AppAction> {
  bool focused = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.onTap != null,
    selected: widget.selected,
    label: widget.label,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: focused
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            onFocusChange: (value) => setState(() => focused = value),
            borderRadius: BorderRadius.circular(20),
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
