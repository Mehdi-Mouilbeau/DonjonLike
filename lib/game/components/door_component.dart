
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/door.dart';
import '../rpg_game.dart';
import 'player_component.dart';

class DoorComponent extends SpriteComponent
    with HasGameReference<RPGGame>, CollisionCallbacks {
  final Door door;
  bool _playerNearby = false;

  DoorComponent({
    required this.door,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(GameConstants.doorWidth *1.5, GameConstants.doorHeight*1.5),
          anchor: Anchor.center,
        );

  bool get isPlayerNearby => _playerNearby;

  @override
  Future<void> onLoad() async {
    final doorSpritesheet = await game.images.load(AssetPaths.doorSprite);

    final frameWidth = doorSpritesheet.width / 4; // 4 colonnes
    final frameHeight = doorSpritesheet.height / 2; // 2 rangées

    // Choisir le sprite approprié en fonction de l'état de la porte
    int row = 0;
    int col = 0;

    if (door.isSucceeded) {
      // Porte réussie : par exemple, rangée 0, colonne 0
      row = 0;
      col = 0;
    } else if (door.isFailed) {
      // Porte échouée : par exemple, rangée 0, colonne 1
      row = 0;
      col = 1;
    } else {
      // Porte verrouillée/neutre : par exemple, rangée 0, colonne 2
      row = 0;
      col = 2;
    }

    // Créer le sprite à partir de la position calculée
    sprite = Sprite(
      doorSpritesheet,
      srcPosition: Vector2(
        col * frameWidth,
        row * frameHeight,
      ),
      srcSize: Vector2(frameWidth, frameHeight),
    );

    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      _playerNearby = true;
      game.onPlayerNearDoor(this);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is PlayerComponent) {
      _playerNearby = false;
      game.onPlayerLeftDoor();
    }
  }

  /// Méthode pour mettre à jour le sprite quand l'état de la porte change
  void updateDoorSprite() async {
    final doorSpritesheet = await game.images.load(AssetPaths.doorSprite);
    final frameWidth = doorSpritesheet.width / 4;
    final frameHeight = doorSpritesheet.height / 2;

    int row = 0;
    int col = 0;

    if (door.isSucceeded) {
      row = 0;
      col = 0;
    } else if (door.isFailed) {
      row = 0;
      col = 1;
    } else {
      row = 0;
      col = 2;
    }

    sprite = Sprite(
      doorSpritesheet,
      srcPosition: Vector2(col * frameWidth, row * frameHeight),
      srcSize: Vector2(frameWidth, frameHeight),
    );
  }
}