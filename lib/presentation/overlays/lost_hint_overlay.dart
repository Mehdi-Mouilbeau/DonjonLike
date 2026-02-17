import 'package:flutter/material.dart';
import '../../game/rpg_game.dart';

class LostHintOverlay extends StatelessWidget {
  final RPGGame game;

  const LostHintOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Indice perdu définitivement…",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image(
                      image: AssetImage(
                          'assets/images/sprites/juliepascontente.png'),
                      width: 96),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  game.overlays.remove(OverlayKeys.lostHint);
                  await game.goToNextLevel();
                },
                child: const Text("Continuer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
