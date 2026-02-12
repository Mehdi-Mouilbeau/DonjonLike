import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rpg/core/constants/game_constants.dart';
import 'package:flutter_rpg/core/services/storage_service.dart';
import 'package:flutter_rpg/game/levels/level_layout.dart';

import '../domain/entities/door.dart';
import 'components/door_component.dart';
import 'input/input_controller.dart';
import 'scenes/corridor_scene.dart';
import 'scenes/room_scene.dart';

class OverlayKeys {
  static const String dpad = 'DPadOverlay';
  static const String interact = 'InteractOverlay';
  static const String lock = 'LockOverlay';
  static const String quiz = 'BookQuizOverlay';
  static const String hint = 'HintOverlay';
  static const String welcome = 'WelcomeOverlay';
  static const String endCredits = 'EndCreditsOverlay';
}

enum GameScene { corridor, room }

class RPGGame extends FlameGame with HasCollisionDetection, KeyboardEvents {
  final List<Door> doors;
  final InputController inputController;
  final void Function(Door door)? onDoorInteract;
  final void Function(Door door)? onPedestalInteract;

  GameScene _currentScene = GameScene.corridor;
  CorridorScene? _corridorScene;
  RoomScene? _roomScene;

  String? _currentMusic;

  Door? _currentDoor;
  DoorComponent? _nearbyDoor;

  int _levelIndex = 0;

  int get currentLevel => _levelIndex + 1;
  int get totalLevels => allLevels.length;
  int get levelIndex => _levelIndex;

  RPGGame({
    required this.doors,
    required this.inputController,
    this.onDoorInteract,
    this.onPedestalInteract,
  });

  Door? get currentDoor => _currentDoor;
  GameScene get currentScene => _currentScene;

  LevelLayout get _activeLayout => allLevels[_levelIndex];

  Door get _activeDoor {
    final i = _levelIndex.clamp(0, doors.length - 1);
    return doors[i];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    //  Préload du son
    await FlameAudio.audioCache.load('door_unlock.mp3');
    for (int i = 1; i <= 11; i++) {
      await FlameAudio.audioCache.load('stage$i.mp3');
    }
    await FlameAudio.audioCache.load('dance_on_your_graves.mp3');

    camera.viewfinder.zoom = GameConstants.cameraZoom;

    await _loadCorridorScene();
  }

  void _playLevelMusic() {
    final musicName = 'stage${currentLevel}.mp3';

    if (_currentMusic == musicName) return;

    FlameAudio.bgm.stop();
    FlameAudio.bgm.play(musicName, volume: 0.6);

    _currentMusic = musicName;
  }

  Future<void> _loadCorridorScene() async {
    _currentScene = GameScene.corridor;

    // Clear the world
    world.children.toList().forEach((c) => c.removeFromParent());
    _nearbyDoor = null;

    overlays.remove(OverlayKeys.interact);
    
    camera.viewfinder.zoom = GameConstants.cameraZoom;
    camera.viewfinder.anchor = Anchor.center;

    _corridorScene = CorridorScene(
      layout: _activeLayout,
      doors: [_activeDoor],
      inputController: inputController,
    );
    await world.add(_corridorScene!);
    _playLevelMusic();

    overlays.add(OverlayKeys.dpad);

    // Affiche la bulle UNE SEULE FOIS au niveau 1
    await _maybeShowWelcomeOverlay();
  }

  Future<void> _maybeShowWelcomeOverlay() async {
    // seulement niveau 1
    if (currentLevel != 1) return;

    // déjà montré ?
    final alreadyShown = StorageService.getWelcomeShown();
    if (alreadyShown) return;

    overlays.add(OverlayKeys.welcome);
    await StorageService.setWelcomeShown(true);
  }

  Future<void> loadRoomScene(Door door) async {
    _currentScene = GameScene.room;
    _currentDoor = door;

    world.children.toList().forEach((c) => c.removeFromParent());
    _nearbyDoor = null;
    overlays.remove(OverlayKeys.interact);

    _roomScene = RoomScene(
      door: door,
      inputController: inputController,
    );
    await world.add(_roomScene!);

    overlays.add(OverlayKeys.dpad);
  }

  Future<void> returnToCorridor() async {
    _currentDoor = null;
    _roomScene = null;
    await _loadCorridorScene();
  }

  Future<void> goToNextLevel() async {
    if (_levelIndex < totalLevels - 1) {
      _levelIndex++;
      _currentDoor = null;
      _roomScene = null;
      await _loadCorridorScene();
    } else {
      // Fin (tu peux mettre un écran victoire plus tard)
      await _loadCorridorScene();
    }
  }

  void spawnCatInRoom() {
    _roomScene?.spawnCat();
  }

  // ── Door interaction callbacks ──────────────────────────────

  void onPlayerNearDoor(DoorComponent doorComponent) {
    _nearbyDoor = doorComponent;
    overlays.add(OverlayKeys.interact);
  }

  void onPlayerLeftDoor() {
    _nearbyDoor = null;
    overlays.remove(OverlayKeys.interact);
  }

  void interactWithNearbyDoor() {
    final d = _nearbyDoor;
    if (d != null) {
      onDoorInteract?.call(d.door);
    }
  }

  // ── Pedestal interaction callbacks ─────────────────────────

  void onPlayerNearPedestal() => overlays.add(OverlayKeys.interact);
  void onPlayerLeftPedestal() => overlays.remove(OverlayKeys.interact);

  void interactWithPedestal() {
    final d = _currentDoor;
    if (d != null) {
      onPedestalInteract?.call(d);
    }
  }

  // ── Keyboard support ──────────────────────────────────────

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final mapping = {
      LogicalKeyboardKey.keyW: LogicalDirection.up,
      LogicalKeyboardKey.arrowUp: LogicalDirection.up,
      LogicalKeyboardKey.keyS: LogicalDirection.down,
      LogicalKeyboardKey.arrowDown: LogicalDirection.down,
      LogicalKeyboardKey.keyA: LogicalDirection.left,
      LogicalKeyboardKey.arrowLeft: LogicalDirection.left,
      LogicalKeyboardKey.keyD: LogicalDirection.right,
      LogicalKeyboardKey.arrowRight: LogicalDirection.right,
    };

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final dir = mapping[event.logicalKey];
      if (dir != null) {
        inputController.press(dir);
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      final dir = mapping[event.logicalKey];
      if (dir != null) {
        inputController.release(dir);
        return KeyEventResult.handled;
      }
    }

    // Space / Enter = interact
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      if (_currentScene == GameScene.corridor) {
        interactWithNearbyDoor();
      } else {
        interactWithPedestal();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  bool get isLastLevel => currentLevel == totalLevels;

  void showEndCredits() {
    // optionnel: couper la musique de fond
    FlameAudio.bgm.stop();

    // masquer overlays gênants
    overlays.remove(OverlayKeys.dpad);
    overlays.remove(OverlayKeys.interact);
    overlays.remove(OverlayKeys.lock);
    overlays.remove(OverlayKeys.quiz);
    overlays.remove(OverlayKeys.hint);

    overlays.add(OverlayKeys.endCredits);
  }
}
