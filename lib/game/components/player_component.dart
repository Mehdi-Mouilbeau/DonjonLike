import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_constants.dart';
import '../components/wall_component.dart';
import '../input/input_controller.dart';
import '../rpg_game.dart';

class PlayerComponent extends SpriteAnimationGroupComponent<PlayerAnimationState>
    with HasGameReference<RPGGame>, CollisionCallbacks {
  final InputController inputController;

  late SpriteAnimation _walkRight;
  late SpriteAnimation _walkLeft;
  late SpriteAnimation _idleRight;
  late SpriteAnimation _idleLeft;

  PlayerAnimationState _lastFacingState = PlayerAnimationState.idleRight;

  // Positions précédentes par axe
  double _prevX = 0;
  double _prevY = 0;

  // Pendant une frame, est-ce qu'on a bougé sur l'axe X/Y ?
  bool _movedX = false;
  bool _movedY = false;

  PlayerComponent({
    required this.inputController,
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final spriteImage = await game.images.load(AssetPaths.julieSpritesheet);

    final frameWidth = spriteImage.width / GameConstants.spriteColumns;
    final frameHeight = spriteImage.height / GameConstants.spriteRows;

    size = Vector2(frameWidth.toDouble(), frameHeight.toDouble()) *
        GameConstants.playerScale;

    final texSize = Vector2(frameWidth.toDouble(), frameHeight.toDouble());

    _walkRight = SpriteAnimation.fromFrameData(
      spriteImage,
      SpriteAnimationData.sequenced(
        amount: GameConstants.spriteColumns,
        stepTime: GameConstants.animationStepTime,
        textureSize: texSize,
        texturePosition: Vector2.zero(),
      ),
    );

    _walkLeft = SpriteAnimation.fromFrameData(
      spriteImage,
      SpriteAnimationData.sequenced(
        amount: GameConstants.spriteColumns,
        stepTime: GameConstants.animationStepTime,
        textureSize: texSize,
        texturePosition: Vector2(0, frameHeight.toDouble()),
      ),
    );

    _idleRight = SpriteAnimation.fromFrameData(
      spriteImage,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: texSize,
        texturePosition: Vector2.zero(),
      ),
    );

    _idleLeft = SpriteAnimation.fromFrameData(
      spriteImage,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: texSize,
        texturePosition: Vector2(0, frameHeight.toDouble()),
      ),
    );

    animations = {
      PlayerAnimationState.walkRight: _walkRight,
      PlayerAnimationState.walkLeft: _walkLeft,
      PlayerAnimationState.idleRight: _idleRight,
      PlayerAnimationState.idleLeft: _idleLeft,
    };

    current = PlayerAnimationState.idleRight;

    // ✅ Hitbox plus petite (meilleure sensation)
    add(
      RectangleHitbox(
        size: Vector2(size.x * 0.55, size.y * 0.70),
        anchor: Anchor.center,
      )..collisionType = CollisionType.active,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _movedX = false;
    _movedY = false;

    // Sauvegarde de position
    _prevX = position.x;
    _prevY = position.y;

    if (inputController.isMoving) {
      final movement = inputController.movementVector;
      if (movement.length2 > 0) movement.normalize();
      final delta = movement * GameConstants.playerSpeed * dt;

      // ✅ Déplacement X puis Y (important)
      if (delta.x != 0) {
        _movedX = true;
        position.x += delta.x;
      }
      if (delta.y != 0) {
        _movedY = true;
        position.y += delta.y;
      }

      if (inputController.lastHorizontalDirection == LogicalDirection.left) {
        current = PlayerAnimationState.walkLeft;
        _lastFacingState = PlayerAnimationState.idleLeft;
      } else {
        current = PlayerAnimationState.walkRight;
        _lastFacingState = PlayerAnimationState.idleRight;
      }
    } else {
      current = _lastFacingState;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is! WallComponent) return;

    // ✅ Si on collisionne après un mouvement sur un axe, on annule cet axe
    if (_movedX) {
      position.x = _prevX;
      _movedX = false;
    }
    if (_movedY) {
      position.y = _prevY;
      _movedY = false;
    }
  }

  @override
  void onCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollision(intersectionPoints, other);

    // Même logique si la collision continue
    if (other is! WallComponent) return;

    if (_movedX) {
      position.x = _prevX;
      _movedX = false;
    }
    if (_movedY) {
      position.y = _prevY;
      _movedY = false;
    }
  }
}

enum PlayerAnimationState { walkRight, walkLeft, idleRight, idleLeft }
