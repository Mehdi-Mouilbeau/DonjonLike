import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rpg/presentation/overlays/end_credits_overlay.dart';
import 'package:flutter_rpg/presentation/overlays/welcome_overlay.dart';

import '../../game/rpg_game.dart';
import '../controllers/game_controller.dart';
import '../controllers/providers.dart';
import '../overlays/book_quiz_overlay.dart';
import '../overlays/dpad_overlay.dart';
import '../overlays/hint_overlay.dart';
import '../overlays/interact_button_overlay.dart';
import '../overlays/lock_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late GameController _gameController;
  RPGGame? _game;

  @override
  void initState() {
    super.initState();
    _gameController = GameController(
      enterDoorUseCase: ref.read(enterDoorUseCaseProvider),
      submitQuizUseCase: ref.read(submitQuizUseCaseProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doorsAsync = ref.watch(doorsProvider);

    return Scaffold(
      body: doorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (doors) {
          _game ??= RPGGame(
            doors: doors,
            inputController: ref.read(inputControllerProvider),
            onDoorInteract: _gameController.onDoorInteract,
            onPedestalInteract: _gameController.onPedestalInteract,
          );

          _gameController.setGame(_game!);

          return GameWidget(
            game: _game!,
            overlayBuilderMap: {
              OverlayKeys.welcome: (context, game) =>
                  WelcomeOverlay(game: game as RPGGame),
              OverlayKeys.dpad: (context, game) => DPadOverlay(
                    inputController: ref.read(inputControllerProvider),
                  ),
              OverlayKeys.interact: (context, game) => InteractButtonOverlay(
                    onInteract: () {
                      if (_game!.currentScene == GameScene.corridor) {
                        _game!.interactWithNearbyDoor();
                      } else {
                        _game!.interactWithPedestal();
                      }
                    },
                  ),
              OverlayKeys.lock: (context, game) => LockOverlay(
                    gameController: _gameController,
                  ),
              OverlayKeys.quiz: (context, game) => BookQuizOverlay(
                    gameController: _gameController,
                  ),
              OverlayKeys.hint: (context, game) => HintOverlay(
                    gameController: _gameController,
                  ),
              OverlayKeys.endCredits: (context, game) =>
                  EndCreditsOverlay(game: game as RPGGame),
            },
          );
        },
      ),
    );
  }
}
