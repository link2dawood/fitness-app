import 'package:flutter/material.dart';

/// Large cutout artwork and a colored surface, matching the reference video.
/// The top inset belongs to the layout, so scroll viewports cannot clip heads.
class ChallengePosterCard extends StatelessWidget {
  const ChallengePosterCard({
    super.key,
    required this.title,
    required this.kicker,
    required this.description,
    required this.image,
    required this.color,
    required this.actionLabel,
    required this.onTap,
    this.metadata,
  });
  final String title, kicker, description, image, actionLabel;
  final String? metadata;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(16) > 22;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 332.0;
        final figureWidth = width * .52;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DecoratedBox(
                key: const ValueKey('challenge-poster-surface'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, Color.lerp(color, Colors.black, .22)!],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 144),
                        child: Padding(
                          padding: EdgeInsets.only(right: figureWidth - 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 14),
                              Text(
                                kicker,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                title.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: title.startsWith('CALISTHENICS')
                                      ? (width < 300 ? 16 : 19)
                                      : (width < 300 ? 19 : 22),
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 36),
                        child: Text(
                          description,
                          maxLines: large ? null : 2,
                          overflow: large ? null : TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                      if (metadata != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          metadata!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: color,
                            minimumSize: const Size(0, 42),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              Expanded(
                                child: Text(
                                  actionLabel,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_circle_right, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 4,
              width: figureWidth,
              height: 190,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0, .76, 1],
                    ).createShader(rect),
                    child: Image.asset(
                      image,
                      key: const ValueKey('challenge-poster-avatar'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      cacheWidth: 600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
