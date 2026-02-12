import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum WallSpriteType {
  topLeft,     // mur horizontal
  topRight,
  bottomLeft,  // mur vertical
  bottomMid,
  bottomRight,
}

class WallComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  final WallSpriteType type;
  final bool flipX;
  final bool flipY;

  Sprite? _sprite;

  WallComponent({
    required Vector2 position,
    required Vector2 size,
    required this.type,
    this.flipX = false,
    this.flipY = false,
  }) : super(position: position, size: size);

  String get _assetPath {
    switch (type) {
      case WallSpriteType.topLeft:
        return 'walls/wall_top_left.png';
      case WallSpriteType.topRight:
        return 'walls/wall_top_right.png';
      case WallSpriteType.bottomLeft:
        return 'walls/wall_bottom_left.png';
      case WallSpriteType.bottomMid:
        return 'walls/wall_bottom_mid.png';
      case WallSpriteType.bottomRight:
        return 'walls/wall_bottom_right.png';
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()..collisionType = CollisionType.passive);

    final image = await game.images.load(_assetPath);
    _sprite = Sprite(image);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = _sprite;
    if (sprite == null) return;

    canvas.save();

    // Flip autour du centre du composant
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);
    canvas.translate(-size.x / 2, -size.y / 2);

    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: size,
      overridePaint: Paint()..filterQuality = FilterQuality.none,
    );

    canvas.restore();
  }
}
