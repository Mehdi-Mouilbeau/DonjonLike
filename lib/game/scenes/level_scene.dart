import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg/game/levels/level_layout.dart';

import '../../domain/entities/door.dart';
import '../components/door_component.dart';
import '../components/player_component.dart';
import '../components/wall_component.dart';
import '../input/input_controller.dart';
import '../rpg_game.dart';// <-- là où tu mets tes LevelLayout/WallDef/etc

/// Scene générique: construit un niveau à partir d'un LevelLayout.
class LevelScene extends Component with HasGameReference<RPGGame> {
  final Door door;
  final InputController inputController;
  final LevelLayout layout;

  late PlayerComponent player;
  late DoorComponent doorComponent;

  LevelScene({
    required this.door,
    required this.inputController,
    required this.layout,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- SOL (pas de hitbox => aucune collision) ---
    add(_FloorComponent(
      position: Vector2.zero(),
      size: Vector2(layout.width, layout.height),
      color: layout.floorColor,
    ));

    // --- MURS (Hitbox passive via WallComponent si tu l'as déjà) ---
    for (final w in layout.walls) {
      add(WallComponent(
        position: Vector2(w.x, w.y),
        size: Vector2(w.w, w.h),
        type: WallSpriteType.bottomLeft,
        // si ton WallComponent utilise des sprites, tu peux choisir un type
        // type: WallSpriteType.bottomMid,
      ));
    }

    // --- PORTE (1 seule: on prend la première) ---
    final dp = layout.doorPlacements.first;
    doorComponent = DoorComponent(
      door: door,
      position: Vector2(dp.x, dp.y),
    );
    add(doorComponent);

    // --- PLAYER ---
    player = PlayerComponent(
      inputController: inputController,
      position: layout.playerSpawn.clone(),
    );
    add(player);
game.camera.viewfinder.anchor = const Anchor(0.5, 0.75);
game.camera.follow(player);

  }
}

/// Sol simple couleur (si tu veux un sprite tiled, je te le fais après).
class _FloorComponent extends PositionComponent {
  final Color color;

  _FloorComponent({
    required Vector2 position,
    required Vector2 size,
    required this.color,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = color);
  }
}
