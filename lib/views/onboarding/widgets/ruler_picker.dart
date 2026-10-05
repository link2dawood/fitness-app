import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class RulerPicker extends StatefulWidget {
  const RulerPicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.labelInterval = 10,
    this.visualTicksPerStep = 1,
    this.stepWidth = 12.0,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int labelInterval;
  final int visualTicksPerStep;
  final double stepWidth;

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late ScrollController _scrollController;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    final initialOffset = ((_currentValue - widget.min) / widget.step) * widget.stepWidth;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _currentValue) {
      _currentValue = widget.value;
      final offset = ((_currentValue - widget.min) / widget.step) * widget.stepWidth;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final index = (offset / widget.stepWidth).round();
    final newValue = (widget.min + index * widget.step).clamp(widget.min, widget.max);
    if (newValue != _currentValue) {
      setState(() => _currentValue = newValue);
      HapticFeedback.selectionClick();
      widget.onChanged(_currentValue);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = ((widget.max - widget.min) / widget.step).floor() + 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        return SizedBox(
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  if (notif is ScrollEndNotification) {
                    final index = (_scrollController.offset / widget.stepWidth).round();
                    final targetOffset = index * widget.stepWidth;
                    Future.microtask(() {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          targetOffset,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: count,
                  padding: EdgeInsets.symmetric(horizontal: halfWidth),
                  itemBuilder: (context, index) {
                    final val = widget.min + index * widget.step;
                    final isLabel = val % widget.labelInterval == 0;
                    final isHalfLabel = val % (widget.labelInterval / 2) == 0 && !isLabel;

                    return SizedBox(
                      width: widget.stepWidth,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Render visual ticks inside this step
                          for (int i = 0; i < widget.visualTicksPerStep; i++)
                            Builder(builder: (context) {
                              // Only draw the first tick if it's the last item and we have visual sub-ticks
                              if (index == count - 1 && i > 0) return const SizedBox();

                              final tickOffset = i * (widget.stepWidth / widget.visualTicksPerStep);
                              final isMainTick = i == 0;
                              final isMiddleTick = i == widget.visualTicksPerStep ~/ 2;

                              double height = 24;
                              if (isMainTick) {
                                height = isLabel ? 40 : (isHalfLabel ? 32 : 24);
                              } else if (isMiddleTick) {
                                height = 32;
                              }

                              return Positioned(
                                left: tickOffset - 1, // center the 2px tick
                                bottom: 0,
                                child: Container(
                                  width: 2,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              );
                            }),

                          // Render the text label
                          if (isLabel || (val == widget.min) || (val == widget.max))
                            Positioned(
                              left: -20, // Center a 40px wide box over x=0
                              top: -4,
                              width: 40,
                              child: Text(
                                '$val',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Center indicator
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 3,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
