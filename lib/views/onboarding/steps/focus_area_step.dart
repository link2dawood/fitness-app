import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../viewmodels/onboarding_viewmodel.dart';

import '../widgets/step_scaffold.dart';

/// Focus area selection.
///
/// Matches the reference layout:
///  * Arms   -> straight line to the shoulder dot
///  * Chest  -> line goes right, then bends UP to the chest dot
///  * Abs    -> line goes right, then bends UP to the abs dot
///  * Legs   -> straight line to the thigh dot
///  * Full body has no line (selecting it lights up every dot)
class FocusAreaStep extends StatefulWidget {
  const FocusAreaStep({super.key});

  @override
  State<FocusAreaStep> createState() => _FocusAreaStepState();
}

class _FocusAreaStepState extends State<FocusAreaStep> {
  /// Pill order for male: Full Body → Arms → Chest → Abs → Legs
  static const List<FocusArea> _maleOrder = [
    FocusArea.fullBody,
    FocusArea.arms,
    FocusArea.chest,
    FocusArea.abs,
    FocusArea.legs,
  ];

  /// Pill order for female: Full Body → Arms → Abs → Butt → Legs (no Chest)
  static const List<FocusArea> _femaleOrder = [
    FocusArea.fullBody,
    FocusArea.arms,
    FocusArea.abs,
    FocusArea.butt,
    FocusArea.legs,
  ];

  /// Dot positions (fraction of visible figure) for the male avatar.
  static const Map<FocusArea, Offset> _maleAnchors = {
    FocusArea.arms: Offset(0.21, 0.225), // left shoulder / sleeve
    FocusArea.chest: Offset(0.40, 0.245), // left chest
    FocusArea.abs: Offset(0.52, 0.420), // abdomen
    FocusArea.legs: Offset(0.30, 0.680), // left thigh
  };

  /// Dot positions for the female avatar.
  static const Map<FocusArea, Offset> _femaleAnchors = {
    FocusArea.arms: Offset(0.24, 0.220), // left shoulder
    FocusArea.abs: Offset(0.50, 0.400), // abdomen
    FocusArea.butt: Offset(0.90, 0.500), // right glute / hip
    FocusArea.legs: Offset(0.32, 0.720), // left thigh
  };

  static const double _pillHeight = 52;

  /// Per-asset cache keyed by image path so male and female are stored
  /// independently and switching gender shows the correct figure instantly.
  static final Map<String, _Figure> _cache = {};
  _Figure? _figure;
  String? _loadedAsset;

  String _avatarAsset(Gender? gender) => gender == Gender.female
      ? 'assets/images/avatars/female/avatar.png'
      : 'assets/images/avatars/male/avatar.png';

  void _loadFigure(String asset) {
    if (_loadedAsset == asset) {
      return; // already loaded / loading for this asset
    }
    _loadedAsset = asset;
    if (_cache.containsKey(asset)) {
      setState(() => _figure = _cache[asset]);
      return;
    }
    _Figure.measure(asset).then((f) {
      _cache[asset] = f;
      if (mounted && _loadedAsset == asset) setState(() => _figure = f);
    });
  }

  @override
  void initState() {
    super.initState();
    // initState cannot call context.read yet; defer to didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gender = context.read<OnboardingViewModel>().profile.gender;
    _loadFigure(_avatarAsset(gender));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final selected = vm.profile.focusAreas;
    final gender = vm.profile.gender;
    final asset = _avatarAsset(gender);
    final isFemale = gender == Gender.female;
    final order = isFemale ? _femaleOrder : _maleOrder;
    final anchors = isFemale ? _femaleAnchors : _maleAnchors;

    // Reload the figure whenever the selected gender changes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFigure(asset);
    });

    final figure = _figure;

    return StepScaffold(
      title: 'Please choose your focus area',
      subtitle: 'Pick one or more body parts you want to train the most.',
      child: figure == null
          ? const SizedBox.shrink()
          : LayoutBuilder(
              builder: (context, c) => _buildStage(
                c.maxWidth,
                c.maxHeight,
                asset,
                figure,
                order,
                anchors,
                selected,
                vm,
              ),
            ),
    );
  }

  Widget _buildStage(
    double w,
    double h,
    String avatarAsset,
    _Figure figure,
    List<FocusArea> order,
    Map<FocusArea, Offset> anchors,
    Set<FocusArea> selected,
    OnboardingViewModel vm,
  ) {
    bool isActive(FocusArea a) =>
        selected.contains(a) || selected.contains(FocusArea.fullBody);

    // ---- Character placement (right side) --------------------------------
    final tileW = w * 0.48;
    final boxLeft = tileW + 10;
    final boxW = w - boxLeft;

    final figH = math.min(h * 0.98, boxW / figure.aspect);
    final figW = figH * figure.aspect;
    final figLeft = boxLeft + (boxW - figW) / 2;
    final figTop = (h - figH) / 2;

    // The PNG may contain transparent padding, so scale/position the full
    // image such that its visible part lands exactly on [figLeft, figTop].
    final imgW = figW / figure.norm.width;
    final imgH = figH / figure.norm.height;
    final imgLeft = figLeft - figure.norm.left * imgW;
    final imgTop = figTop - figure.norm.top * imgH;

    // Convert a relative anchor to an absolute canvas Offset.
    Offset dot(FocusArea a) =>
        Offset(figLeft + anchors[a]!.dx * figW, figTop + anchors[a]!.dy * figH);

    // ---- Pill placement ---------------------------------------------------
    // Arms pill is level with the shoulder dot and Legs pill is level with
    // the thigh dot. Pills in between are evenly spaced.
    final armY = dot(FocusArea.arms).dy;
    final legY = dot(FocusArea.legs).dy;
    // 3 gaps for 5 pills (fullBody, arms, middle1, middle2, legs)
    final step = ((legY - armY) / 3).clamp(_pillHeight + 10, _pillHeight + 40);

    // Build centers for every pill in the current order.
    final centers = <FocusArea, double>{};
    for (var i = 0; i < order.length; i++) {
      centers[order[i]] = armY + (i - 1) * step;
    }

    // Keep the whole pill column inside the available height.
    var shift = 0.0;
    final colTop = centers[order.first]! - _pillHeight / 2;
    final colBottom = centers[order.last]! + _pillHeight / 2;
    if (colTop < 0) shift = -colTop;
    if (colBottom + shift > h) shift = h - colBottom;
    if (shift != 0) {
      for (final k in centers.keys.toList()) {
        centers[k] = centers[k]! + shift;
      }
    }

    // ---- Connector lines --------------------------------------------------
    final links = <_Link>[
      for (final area in order)
        if (anchors.containsKey(area)) // skip fullBody which has no anchor
          _Link(
            start: Offset(tileW, centers[area]!),
            end: dot(area),
            active: isActive(area),
          ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1) Character
        Positioned(
          left: imgLeft,
          top: imgTop,
          width: imgW,
          height: imgH,
          child: IgnorePointer(
            child: Image.asset(avatarAsset, fit: BoxFit.fill),
          ),
        ),

        // 2) Lines + dots (drawn ABOVE the character so dots are visible)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _ConnectorPainter(links)),
          ),
        ),

        // 3) Pills
        for (final area in order)
          Positioned(
            left: 0,
            top: centers[area]! - _pillHeight / 2,
            width: tileW,
            height: _pillHeight,
            child: _FocusAreaTile(
              label: area.label,
              selected: selected.contains(area),
              onTap: () => vm.toggleFocusArea(area),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Character measurement (finds the visible part of the PNG)
// ─────────────────────────────────────────────────────────────────────────────

class _Figure {
  const _Figure({required this.aspect, required this.norm});

  /// width / height of the VISIBLE character in pixels.
  final double aspect;

  /// Visible character bounds as fractions (0..1) of the full image.
  final Rect norm;

  static Future<_Figure> measure(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final w = image.width;
    final h = image.height;
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    var minX = w, minY = h, maxX = -1, maxY = -1;
    if (bytes != null) {
      final px = bytes.buffer.asUint8List();
      for (var y = 0; y < h; y += 2) {
        for (var x = 0; x < w; x += 2) {
          if (px[(y * w + x) * 4 + 3] > 40) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          }
        }
      }
    }
    image.dispose();
    codec.dispose();

    // No transparency found (or nothing visible): use the whole image.
    final noAlpha =
        maxX < 0 || ((maxX - minX) / w > 0.98 && (maxY - minY) / h > 0.98);
    if (noAlpha) {
      return _Figure(aspect: w / h, norm: const Rect.fromLTRB(0, 0, 1, 1));
    }

    final norm = Rect.fromLTRB(
      minX / w,
      minY / h,
      math.min(1.0, (maxX + 2) / w),
      math.min(1.0, (maxY + 2) / h),
    );
    return _Figure(aspect: (norm.width * w) / (norm.height * h), norm: norm);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _Link {
  const _Link({required this.start, required this.end, required this.active});

  final Offset start; // right edge of the pill
  final Offset end; // dot on the body
  final bool active;
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter(this.links);

  final List<_Link> links;

  /// Horizontal from the pill, then a rounded 90° turn up/down to the dot.
  /// If the dot is already level with the pill the line stays straight.
  Path _path(Offset s, Offset e) {
    final path = Path()..moveTo(s.dx, s.dy);
    final dy = e.dy - s.dy;

    if (dy.abs() < 1.5) {
      path.lineTo(e.dx, s.dy);
      return path;
    }

    final r = math.min(14.0, math.min(dy.abs(), (e.dx - s.dx).abs()));
    final dir = dy > 0 ? 1.0 : -1.0;
    path
      ..lineTo(e.dx - r, s.dy)
      ..quadraticBezierTo(e.dx, s.dy, e.dx, s.dy + dir * r)
      ..lineTo(e.dx, e.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final link in links) {
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = link.active ? 2.0 : 1.2
        ..color = link.active ? AppColors.primary : Colors.black38;

      canvas.drawPath(_path(link.start, link.end), linePaint);

      // Dot
      if (link.active) {
        canvas.drawCircle(
          link.end,
          11,
          Paint()..color = AppColors.primary.withValues(alpha: 0.25),
        );
      }
      canvas.drawCircle(
        link.end,
        6,
        Paint()..color = link.active ? AppColors.primary : Colors.white,
      );
      canvas.drawCircle(
        link.end,
        6,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = link.active ? Colors.white : Colors.black87,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill
// ─────────────────────────────────────────────────────────────────────────────

class _FocusAreaTile extends StatelessWidget {
  const _FocusAreaTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            // Short tick marking where the line leaves the pill.
            Container(
              width: 10,
              height: 2,
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
