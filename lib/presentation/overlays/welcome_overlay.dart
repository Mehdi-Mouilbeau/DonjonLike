import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/services/storage_service.dart';
import '../../game/rpg_game.dart';

class WelcomeOverlay extends StatelessWidget {
  final RPGGame game;

  const WelcomeOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final name = StorageService.getPlayerName() ?? 'Aventurière';

    // Niveau 1 → chat1
    final catAssetUi = AssetPaths.ui(AssetPaths.cat1);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 140,
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 🐱 Chat à gauche
                Image.asset(
                  catAssetUi,
                  width: 90,
                  height: 90,
                  filterQuality: FilterQuality.none,
                ),

                const SizedBox(width: 12),

                // 💬 Bulle de dialogue
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6D4C41),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      'Bienvenue, $name !\n'
                      'Avance jusqu’à la porte au bout du couloir.',
                      style: const TextStyle(
                        color: Color(0xFF4E342E),
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ✅ Bouton OK
                FilledButton(
                  onPressed: () => game.overlays.remove(OverlayKeys.welcome),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
