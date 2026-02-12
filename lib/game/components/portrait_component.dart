import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import '../../core/constants/asset_paths.dart';
import '../rpg_game.dart';

class PortraitComponent extends SpriteComponent
    with HasGameReference<RPGGame>, TapCallbacks {
  final VoidCallback onSecondTap;
  int _tapCount = 0;

  PortraitComponent({
    required Vector2 position,
    required Vector2 size,
    required this.onSecondTap,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
          priority: 20,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite(AssetPaths.portraitSprite);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _tapCount++;

    if (_tapCount == 1) {
      _shake();
    } else {
      onSecondTap();
    }

    event.continuePropagation = false;
  }

  void _shake() {
    children.whereType<Effect>().toList().forEach((e) => e.removeFromParent());

    final rand = math.Random();

    final List<Effect> steps = [];

    for (int i = 0; i < 10; i++) {
      final dx = (rand.nextDouble() * 2 - 1) * 6;
      final dy = (rand.nextDouble() * 2 - 1) * 6;

      steps.add(
        MoveByEffect(
          Vector2(dx, dy),
          EffectController(duration: 0.03),
        ),
      );
    }

    // Retour à la position d'origine
    steps.add(
      MoveToEffect(
        position,
        EffectController(duration: 0.04),
      ),
    );

    add(SequenceEffect(steps));
  }
}
