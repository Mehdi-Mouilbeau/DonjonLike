import 'package:flutter/material.dart';

class SpriteFrameRect extends StatelessWidget {
  final String assetPath;
  final int columns;
  final int rows;
  final int frameIndex;

  final double displayWidth;
  final double displayHeight;

  const SpriteFrameRect({
    super.key,
    required this.assetPath,
    required this.columns,
    required this.rows,
    required this.frameIndex,
    required this.displayWidth,
    required this.displayHeight,
  });

  @override
  Widget build(BuildContext context) {
    final col = frameIndex % columns;
    final row = frameIndex ~/ columns;

    // Alignment attend -1..1
    final ax = (columns == 1) ? 0.0 : (-1.0 + 2.0 * (col / (columns - 1)));
    final ay = (rows == 1) ? 0.0 : (-1.0 + 2.0 * (row / (rows - 1)));

    return SizedBox(
      width: displayWidth,
      height: displayHeight,
      child: ClipRect(
        child: Align(
          alignment: Alignment(ax, ay),
          child: Image.asset(
            assetPath,
            filterQuality: FilterQuality.none,
            // ✅ FORCE l'image complète à la taille "sheet"
            width: displayWidth * columns,
            height: displayHeight * rows,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
