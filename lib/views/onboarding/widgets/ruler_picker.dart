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
    this.decimalValue,
    this.onDecimalChanged,
    this.step = 1,
    this.labelInterval = 10,
    this.visualTicksPerStep = 1,
    this.stepWidth = 12.0,
  });

  final int min;
  final int max;
  final int value;
  final double? decimalValue;
  final ValueChanged<int> onChanged;
  final ValueChanged<double>? onDecimalChanged;
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
  double _currentDecimalValue = 0.0;

  double get _subTickWidth =>
      widget.stepWidth / (widget.visualTicksPerStep > 0 ? widget.visualTicksPerStep : 1);

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _currentDecimalValue = widget.decimalValue ?? widget.value.toDouble();
    final activeVal = widget.decimalValue ?? widget.value.toDouble();
    final initialOffset = ((activeVal - widget.min) / widget.step) * widget.stepWidth;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.decimalValue != null) {
      final factor = widget.visualTicksPerStep > 0 ? widget.visualTicksPerStep.toDouble() : 10.0;
      final threshold = 0.5 / factor;
      if ((widget.decimalValue! - _currentDecimalValue).abs() > threshold) {
        _currentDecimalValue = widget.decimalValue!;
        _currentValue = widget.decimalValue!.round();
        final offset =
            ((_currentDecimalValue - widget.min) / widget.step) * widget.stepWidth;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
    } else if (widget.value != _currentValue) {
      _currentValue = widget.value;
      _currentDecimalValue = widget.value.toDouble();
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
    if (widget.onDecimalChanged != null) {
      final subIndex = (offset / _subTickWidth).round();
      final newDecimal = (widget.min + (subIndex / widget.visualTicksPerStep) * widget.step)
          .clamp(widget.min.toDouble(), widget.max.toDouble());
      final factor = widget.visualTicksPerStep > 0 ? widget.visualTicksPerStep.toDouble() : 10.0;
      final roundedDecimal = (newDecimal * factor).round() / factor;
      final threshold = 0.5 / factor;
      if ((roundedDecimal - _currentDecimalValue).abs() >= threshold) {
        _currentDecimalValue = roundedDecimal;
        _currentValue = roundedDecimal.round();
        HapticFeedback.selectionClick();
        widget.onDecimalChanged!(roundedDecimal);
        widget.onChanged(_currentValue);
      }
    } else {
      final index = (offset / widget.stepWidth).round();
      final newValue = (widget.min + index * widget.step).clamp(widget.min, widget.max);
      if (newValue != _currentValue) {
        setState(() => _currentValue = newValue);
        HapticFeedback.selectionClick();
        widget.onChanged(_currentValue);
      }
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
                    final double targetOffset;
                    if (widget.onDecimalChanged != null) {
                      final subIndex = (_scrollController.offset / _subTickWidth).round();
                      targetOffset = subIndex * _subTickWidth;
                    } else {
                      final index = (_scrollController.offset / widget.stepWidth).round();
                      targetOffset = index * widget.stepWidth;
                    }
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
                              left: -25, // Center a 50px wide box over x=0
                              top: -4,
                              width: 50,
                              child: Text(
                                '$val',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                softWrap: false,
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
