import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/door.dart';
import '../../domain/usecases/enter_door_usecase.dart';
import '../../domain/usecases/submit_quiz_usecase.dart';
import '../../game/rpg_game.dart';

class GameController extends ChangeNotifier {
  final EnterDoorUseCase enterDoorUseCase;
  final SubmitQuizUseCase submitQuizUseCase;
  RPGGame? _game;

  Door? _activeDoor;
  String? _lockErrorMessage;
  String? _hintMessage;
  bool _showQuiz = false;
  bool _showLock = false;
  bool _showHint = false;

  bool _goNextAfterHint = false;

  GameController({
    required this.enterDoorUseCase,
    required this.submitQuizUseCase,
  });

  Door? get activeDoor => _activeDoor;
  String? get lockErrorMessage => _lockErrorMessage;
  String? get hintMessage => _hintMessage;
  bool get showQuiz => _showQuiz;
  bool get showLock => _showLock;
  bool get showHint => _showHint;

  /// ✅ Niveau courant (1..N)
  int get currentLevel => _game?.currentLevel ?? 1;

  void setGame(RPGGame game) {
    _game = game;
  }

  void onDoorInteract(Door door) {
    _activeDoor = door;

    if (door.isSucceeded) {
      _hintMessage = door.hint;
      _showHint = true;
      _goNextAfterHint = false;
      _game?.overlays.add(OverlayKeys.hint);
      notifyListeners();
      return;
    }

    _lockErrorMessage = null;
    _showLock = true;
    _game?.overlays.add(OverlayKeys.lock);
    notifyListeners();
  }

  void submitCode(String code) {
    if (_activeDoor == null) return;

    final result = enterDoorUseCase.execute(_activeDoor!, code);

    switch (result) {
      case EnterDoorSuccess():
        FlameAudio.play('door_unlock.mp3');
        _showLock = false;
        _game?.overlays.remove(OverlayKeys.lock);
        _game?.loadRoomScene(_activeDoor!);
        break;

      case EnterDoorGlobalCooldown(daysRemaining: final days):
        _lockErrorMessage = 'Reviens dans $days jour${days > 1 ? 's' : ''} !';
        break;

      case EnterDoorFailedCooldown(daysRemaining: final days):
        _lockErrorMessage =
            'Cette porte est verrouillee. Reviens dans $days jour${days > 1 ? 's' : ''}.';
        break;

      case EnterDoorAlreadySucceeded():
        _showLock = false;
        _game?.overlays.remove(OverlayKeys.lock);
        _hintMessage = _activeDoor!.hint;
        _showHint = true;
        _goNextAfterHint = false;
        _game?.overlays.add(OverlayKeys.hint);
        break;

      case EnterDoorWrongCode():
        _lockErrorMessage = 'Code incorrect !';
        break;
    }

    notifyListeners();
  }

  void closeLock() {
    _showLock = false;
    _lockErrorMessage = null;
    _game?.overlays.remove(OverlayKeys.lock);
    notifyListeners();
  }

  void onPedestalInteract(Door door) {
    _activeDoor = door;
    _showQuiz = true;
    _game?.overlays.add(OverlayKeys.quiz);
    notifyListeners();
  }

  Future<void> submitQuiz(List<int> answers) async {
    if (_activeDoor == null) return;

    final result = await submitQuizUseCase.execute(_activeDoor!, answers);

    switch (result) {
      case QuizSuccess(hint: final hint):
        _showQuiz = false;
        _game?.overlays.remove(OverlayKeys.quiz);

        _game?.spawnCatInRoom();

        _hintMessage = hint;
        _showHint = true;
        _goNextAfterHint = true;
        _game?.overlays.add(OverlayKeys.hint);
        break;

      case QuizFailed():
        _showQuiz = false;
        _game?.overlays.remove(OverlayKeys.quiz);
        _lockErrorMessage = 'Mauvaises reponses ! La porte se referme...';
        _goNextAfterHint = false;
        _game?.returnToCorridor();
        break;
    }

    notifyListeners();
  }

  void closeQuiz() {
    _showQuiz = false;
    _game?.overlays.remove(OverlayKeys.quiz);
    notifyListeners();
  }

  Future<void> closeHint() async {
    _showHint = false;
    _hintMessage = null;
    _game?.overlays.remove(OverlayKeys.hint);

    final shouldGoNext = _goNextAfterHint;
    _goNextAfterHint = false;

    if (shouldGoNext) {
      //  Si dernier niveau => générique
      if ((_game?.currentLevel ?? 1) >= (_game?.totalLevels ?? 11)) {
        _game?.showEndCredits();
      } else {
        await _game?.goToNextLevel();
      }
    } else {
      if (_game?.currentScene == GameScene.room) {
        await _game?.returnToCorridor();
      }
    }

    notifyListeners();
  }
}
