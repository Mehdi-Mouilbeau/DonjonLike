import 'dart:math' as math;
import 'dart:ui';

import 'package:julie_rpg/core/routing/app_router.dart';
import 'package:julie_rpg/core/services/storage_service.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../game/rpg_game.dart';

class EndCreditsOverlay extends StatefulWidget {
  final RPGGame game;
  const EndCreditsOverlay({super.key, required this.game});

  @override
  State<EndCreditsOverlay> createState() => _EndCreditsOverlayState();
}

class _EndCreditsOverlayState extends State<EndCreditsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _duration = Duration(seconds: 84);
  bool _musicStarted = false;
  List<Map<String, dynamic>> _foundClues = [];

  final List<Map<String, dynamic>> allClues = [
    {
      "id": "door_1",
      "level": 1,
      "hint":
          "Cherche un endroit; on peut laisser le pain dehors, ou le mettre dans un endroit pour ne pas qu’il sèche."
    },
    {
      "id": "door_2",
      "level": 2,
      "hint": "Un meuble paternel. 3 sur 3, trouve l’endroit et tu auras."
    },
    {
      "id": "door_3",
      "level": 3,
      "hint":
          "Fin des cadeaux à partir d’aujourd’hui, regroupe les mots et trouve la phrase. « tu sauras »"
    },
    {"id": "door_4", "level": 4, "hint": "« lorsque »"},
    {"id": "door_5", "level": 5, "hint": "« quoi faire »"},
    {"id": "door_6", "level": 6, "hint": "« plus tard »"},
    {"id": "door_7", "level": 7, "hint": "« départ »"},
    {"id": "door_8", "level": 8, "hint": "« tu entendras »"},
    {"id": "door_9", "level": 9, "hint": "« 2 heures »"},
    {"id": "door_10", "level": 10, "hint": "« la musique »"},
    {
      "id": "door_11",
      "level": 11,
      "hint":
          "Une musique et 2h plus tard le départ. Lorsque tu entendras la musique, tu sauras quoi faire. Que ton oreille soit prête."
    }
  ];

  @override
  void initState() {
    super.initState();
    _startEndingMusic();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward();
    _loadFoundClues();
  }

  Future<void> _loadFoundClues() async {
    final found = <Map<String, dynamic>>[];

    for (var clue in allClues) {
      final successDate = StorageService.getDoorLastSuccessDate(clue['id']);

      if (successDate != null) {
        found.add(clue);
      }
    }

    setState(() {
      _foundClues = found;
    });
  }

  Future<void> _startEndingMusic() async {
    if (_musicStarted) return;
    _musicStarted = true;
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play('dance_on_your_graves.mp3', volume: 0.8);
  }

  Future<void> _stopEndingMusic() async {
    await FlameAudio.bgm.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopEndingMusic();
    super.dispose();
  }

  void _close() async {
    FlameAudio.bgm.stop();
    await StorageService.setPlayerName('');
    await StorageService.setWelcomeShown(false);
    widget.game.overlays.remove(OverlayKeys.endCredits);
    if (mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.nameEntry, (route) => false);
    }
  }

  String get crawlText {
    final buffer = StringBuffer();

    buffer.writeln("Dans les couloirs oubliés du château,");
    buffer.writeln("une aventurière a défié les portes,");
    buffer.writeln("les énigmes et les pièges.\n");

    buffer.writeln("Grâce à son courage,");
    buffer.writeln("les indices ont été révélés un à un.\n");

    buffer.writeln("Et au terme de la dernière épreuve,");
    buffer.writeln("la vérité s’est enfin dévoilée.\n");

    buffer.writeln("────────────────────────\n");
    buffer.writeln("RÉCAPITULATIF DES INDICES TROUVÉS\n");

    if (_foundClues.isEmpty) {
      buffer.writeln("Aucun indice trouvé...");
    } else {
      for (var clue in _foundClues) {
        buffer.writeln("${clue['level']} : ${clue['hint']}");
      }
    }

    buffer.writeln("\n────────────────────────\n");
    buffer.writeln("Lorsque tu entendras la musique,");
    buffer.writeln("tu sauras quoi faire.\n");
    buffer.writeln("Merci d’avoir joué.");
    buffer.writeln("À bientôt pour de nouveaux mystères...");

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    const title = "VICTOIRE";
    const subtitle = "Le sanctuaire a cédé...";

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: _close,
                child: const Text('Passer',
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final w = constraints.maxWidth;
              return AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  final t = _controller.value;
                  final y = lerpDouble(h * 1.2, -h * 2.2, t)!;
                  final scale = lerpDouble(1.0, 0.35, t)!;
                  final tilt = -math.pi / 5.5;

                  return Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..translate(w * 0.0, y)
                        ..rotateX(tilt)
                        ..scale(scale, scale),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 22,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const Text(title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2)),
                              const SizedBox(height: 6),
                              const Text(subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 20),
                              Text(crawlText, textAlign: TextAlign.center),
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) {
                  if (_controller.isCompleted) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _close());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
