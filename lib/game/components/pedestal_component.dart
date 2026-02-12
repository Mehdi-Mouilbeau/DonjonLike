import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_rpg/core/constants/asset_paths.dart';

import '../../core/constants/game_constants.dart';
import '../rpg_game.dart';
import 'player_component.dart';

/// Book on a pedestal at the center of a room.
class PedestalComponent extends PositionComponent
    with HasGameReference<RPGGame>, CollisionCallbacks {
  bool _playerNearby = false;

  Sprite? _sprite;

  PedestalComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConstants.pedestalSize),
          anchor: Anchor.center,
          priority: 3,
          );

  bool get isPlayerNearby => _playerNearby;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ charge le sprite (assets/images/pedestal_book.png)
    final image = await game.images.load(AssetPaths.pedestalSprite);
    _sprite = Sprite(image);

    // ✅ hitbox (souvent mieux un peu plus petite que l'image)
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.75, size.y * 0.75),
        anchor: Anchor.center,
      )..collisionType = CollisionType.passive,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final sprite = _sprite;
    if (sprite == null) return;

    // rendu pixel-crisp
    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: size,
      overridePaint: Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      _playerNearby = true;
      game.onPlayerNearPedestal();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlayerComponent) {
      _playerNearby = false;
      game.onPlayerLeftPedestal();
    }
  }
}
