import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// iOS-style scroll wheel for picking an integer value.
class WheelPicker extends StatefulWidget {
  const WheelPicker({
    super.key,
    required this.label,
    required this.unit,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String unit;
  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<WheelPicker> createState() => _WheelPickerState();
}

class _WheelPickerState extends State<WheelPicker> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        FixedExtentScrollController(initialItem: widget.value - widget.min);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (widget.label.isNotEmpty) const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: 52,
                perspective: 0.003,
                diameterRatio: 1.9,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  widget.onChanged(widget.min + i);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: widget.max - widget.min + 1,
                  builder: (context, i) {
                    final number = widget.min + i;
                    final selected = number == widget.value;
                    return Center(
                      child: Text(
                        '$number',
                        style: TextStyle(
                          fontSize: selected ? 24 : 18,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.unit,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
