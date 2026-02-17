import 'package:flame/components.dart';
import 'package:julie_rpg/game/levels/level_layout.dart';

import '../../core/constants/asset_paths.dart';
import '../../domain/entities/door.dart';
import '../components/door_component.dart';
import '../components/player_component.dart';
import '../components/wall_component.dart';
import '../input/input_controller.dart';
import '../rpg_game.dart';

class CorridorScene extends Component with HasGameReference<RPGGame> {
  final LevelLayout layout;
  final List<Door> doors; // ✅ 1 seule porte par level normalement
  final InputController inputController;

  late PlayerComponent player;

  CorridorScene({
    required this.layout,
    required this.doors,
    required this.inputController,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final W = layout.width;
    final H = layout.height;

    // ✅ Sol en sprite (si tu veux garder ton floorSheet)
    add(_FloorSprite(
      position: Vector2.zero(),
      size: Vector2(W, H),
    ));

    // ✅ Murs = sprites + collisions
    for (final w in layout.walls) {
      add(
        WallComponent(
          position: Vector2(w.x, w.y),
          size: Vector2(w.w, w.h),
          type: _wallTypeFromSize(w.w, w.h),
          flipX: false,
          flipY: false,
        ),
      );
    }

    // ✅ 1 porte par niveau -> on prend la 1ère DoorPlacement
    final doorPlacement = layout.doorPlacements.first;

    // ✅ Door associée au niveau (chez toi: doors contient déjà la bonne)
    final door = doors.isNotEmpty ? doors.first : null;

    if (door != null) {
      add(DoorComponent(
        door: door,
        position: Vector2(doorPlacement.x, doorPlacement.y),
      ));
    }

    // ✅ Player spawn
    player = PlayerComponent(
      inputController: inputController,
      position: layout.playerSpawn.clone(),
    );
    add(player);

    game.camera.viewfinder.anchor = const Anchor(0.5, 0.75);
    game.camera.follow(player);

  }

  /// Choisit un sprite wall horizontal/vertical (simple)
  WallSpriteType _wallTypeFromSize(double w, double h) {
    // Si c'est plutôt horizontal -> topLeft
    if (w >= h) return WallSpriteType.topLeft;
    // Sinon vertical -> bottomLeft
    return WallSpriteType.bottomLeft;
  }
}

/// ✅ Sol sprite (image unique)
class _FloorSprite extends SpriteComponent with HasGameReference<RPGGame> {
  _FloorSprite({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, priority: 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(AssetPaths.floorSheet);
  }
}
