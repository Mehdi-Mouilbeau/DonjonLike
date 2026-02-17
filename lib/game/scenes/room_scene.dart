import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:julie_rpg/core/constants/asset_paths.dart';

import '../../core/constants/game_constants.dart';
import '../../domain/entities/door.dart';
import '../components/cat_component.dart';
import '../components/pedestal_component.dart';
import '../components/player_component.dart';
import '../components/wall_component.dart';
import '../components/portrait_component.dart';
import '../input/input_controller.dart';
import '../rpg_game.dart';

class RoomScene extends Component with HasGameReference<RPGGame> {
  final Door door;
  final InputController inputController;

  late PlayerComponent player;
  late PedestalComponent pedestal;

  PortraitComponent? _portrait;
  bool _pedestalRevealed = false;

  RoomScene({
    required this.door,
    required this.inputController,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const roomS = GameConstants.roomSize * 1.5;
    const wallT = GameConstants.wallThickness;

    final isFinalRoom = game.currentLevel == 11;

    // Floor
    add(_RoomFloor(position: Vector2.zero(), size: Vector2(roomS, roomS)));

    // Background image
    add(RoomBackground(position: Vector2.zero(), size: Vector2(roomS, roomS)));

    // Walls
    add(WallComponent(
      position: Vector2(0, 0),
      size: Vector2(roomS, wallT),
      type: WallSpriteType.topLeft,
    ));
    add(WallComponent(
      position: Vector2(0, roomS - wallT),
      size: Vector2(roomS, wallT),
      type: WallSpriteType.topLeft,
      flipY: true,
    ));
    add(WallComponent(
      position: Vector2(0, 0),
      size: Vector2(wallT, roomS),
      type: WallSpriteType.bottomLeft,
    ));
    add(WallComponent(
      position: Vector2(roomS - wallT, 0),
      size: Vector2(wallT, roomS),
      type: WallSpriteType.bottomLeft,
      flipX: true,
    ));

    // Pedestal 
    pedestal = PedestalComponent(
      position: Vector2(roomS / 2, roomS * 0.65),
    );

    if (!isFinalRoom) {
      add(pedestal);
      _pedestalRevealed = true;
    } else {
      //  Portrait placé haut-gauche
      final portraitPos = Vector2(
        roomS * 0.28, // plus à gauche/droite
        roomS * 0.28, // plus haut/bas
      );

      _portrait = PortraitComponent(
        position: portraitPos,
        size: Vector2(120, 120),
        onSecondTap: () => _revealPedestalWithFX(
          revealAt: pedestal.position, // poussière à l’endroit du pedestal
        ),
      );

      add(_portrait!);
    }

    // Player near entrance
    player = PlayerComponent(
      inputController: inputController,
      position: Vector2(roomS / 2, roomS - wallT - 40),
    );
    add(player);

    game.camera.viewfinder.anchor = const Anchor(0.5, 0.75);
    game.camera.follow(player);
  }

  void _revealPedestalWithFX({required Vector2 revealAt}) {
    if (_pedestalRevealed) return;
    _pedestalRevealed = true;

    // 1) Son 
    FlameAudio.play('secret_reveal.mp3', volume: 0.9);

    // 2) Poussière
    _spawnDust(revealAt);

    // 3) Switch portrait -> pedestal
    _portrait?.removeFromParent();
    _portrait = null;

    add(pedestal);
  }

  void _spawnDust(Vector2 at) {
    // Petite explosion de poussière (20 particules)
    add(
      ParticleSystemComponent(
        position: at,
        priority: 999, // au-dessus
        particle: Particle.generate(
          count: 20,
          lifespan: 0.6,
          generator: (i) {
            final angle = (i / 20) * 6.28318530718;
            final speed = 30 + (i % 5) * 8;

            final vx = mathCos(angle) * speed;
            final vy = mathSin(angle) * speed;

            return AcceleratedParticle(
              acceleration: Vector2(0, 40), // tombe légèrement
              speed: Vector2(vx, vy),
              child: CircleParticle(
                radius: 2.0,
                paint: Paint()
                  ..color = const Color(0xFFFFF3E0).withOpacity(0.8),
              ),
            );
          },
        ),
      ),
    );
  }

  void spawnCat() {
    const wallT = GameConstants.wallThickness;
    const roomS = GameConstants.roomSize;

    final desired = player.position + Vector2(50, 0);
    final clamped = Vector2(
      desired.x.clamp(wallT + 20, roomS - wallT - 20).toDouble(),
      desired.y.clamp(wallT + 20, roomS - wallT - 20).toDouble(),
    );

    add(CatComponent(position: clamped, levelIndex: game.currentLevel));
  }
}

double mathCos(double v) => (v).cos();
double mathSin(double v) => (v).sin();

extension _TrigExt on double {
  double cos() => math.cos(this);
  double sin() => math.sin(this);
}

class _RoomFloor extends PositionComponent {
  _RoomFloor({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF455A64));
  }
}

class RoomBackground extends SpriteComponent with HasGameReference<RPGGame> {
  RoomBackground({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final level = (game.currentLevel - 1).clamp(0, AssetPaths.rooms.length - 1);
    final asset = AssetPaths.rooms[level];
    sprite = Sprite(await game.images.load(asset));
  }
}
