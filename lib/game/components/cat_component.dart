import 'package:flame/components.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_constants.dart';
import '../rpg_game.dart';

/// A cat sprite that appears after a successful quiz.
/// Each cat is a separate image: chat1.png, chat2.png, etc.
class CatComponent extends SpriteComponent with HasGameReference<RPGGame> {
  /// Niveau (0 = chat1, 1 = chat2, ...)
  final int levelIndex;

  /// Optionnel : forcer un chat précis (chemin Flame : 'sprites/chatX.png')
  final String? catAsset;

  CatComponent({
    required Vector2 position,
    required this.levelIndex,
    this.catAsset,
  }) : super(
          position: position,
          anchor: Anchor.center,
          priority: 1000,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final i = levelIndex.clamp(0, 5);
    final assetPath = catAsset ?? AssetPaths.cats[i];

    // ✅ Flame path (sprites/...)
    sprite = await game.loadSprite(assetPath);

    size = Vector2.all(48) * GameConstants.catScale;

    opacity = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (opacity < 1.0) {
      opacity = (opacity + dt * 2).clamp(0.0, 1.0);
    }
  }
}
