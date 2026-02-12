import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../controllers/game_controller.dart';

class HintOverlay extends StatelessWidget {
  final GameController gameController;

  const HintOverlay({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    final hint = gameController.hintMessage;
    if (hint == null) return const SizedBox.shrink();

    // ✅ Niveau (1..N) -> index (0..5)
    final levelIndex = (gameController.currentLevel - 1).clamp(0, 5);
    final catAssetUi = AssetPaths.ui(AssetPaths.cats[levelIndex]);

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                catAssetUi,
                width: 80,
                height: 80,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(height: 12),
              Text(
                'Indice débloqué !',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.brown.shade800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                hint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.brown.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => gameController.closeHint(),
                child: const Text('Fermer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
