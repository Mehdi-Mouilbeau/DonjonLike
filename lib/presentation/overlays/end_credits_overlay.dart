import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_rpg/core/routing/app_router.dart';
import 'package:flutter_rpg/core/services/storage_service.dart';
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

  // Durée du générique
  static const _duration = Duration(seconds: 84);

  bool _musicStarted = false;

  @override
  void initState() {
    super.initState();

    //  Lance la musique du générique
    _startEndingMusic();

    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward();
  }

  Future<void> _startEndingMusic() async {
    if (_musicStarted) return;
    _musicStarted = true;

    // Stop la musique actuelle (stage)
    await FlameAudio.bgm.stop();

    // Lance la musique du générique
    await FlameAudio.bgm.play(
      'dance_on_your_graves.mp3',
      volume: 0.8,
    );
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
    // stop musique générique
    FlameAudio.bgm.stop();

    //  reset pour revenir à l'accueil
    await StorageService.setPlayerName('');
    await StorageService.setWelcomeShown(false);

    widget.game.overlays.remove(OverlayKeys.endCredits);

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.nameEntry,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Texte du crawl (à toi de modifier)
    const title = "VICTOIRE";
    const subtitle = "Le sanctuaire a cédé...";
    const crawl = """
Dans les couloirs oubliés du château,
une aventurière a défié les portes,
les énigmes et les pièges.

Grâce à son courage,
les indices ont été révélés un à un.

Et au terme de la dernière épreuve,
la vérité s’est enfin dévoilée.

────────────────────────

RÉCAPITULATIF DES INDICES

1 : Cherche un endroit ; on peut laisser le pain dehors,
ou le mettre dans un endroit pour ne pas qu’il sèche.

2 : Un meuble paternel.
3 sur 3, trouve l’endroit et tu auras.

3 : Fin des cadeaux à partir d’aujourd’hui,
regroupe les mots et trouve la phrase :
« tu sauras »

4 : « lorsque »

5 : « quoi faire »

6 : « plus tard »

7 : « départ »

8 : « tu entendras »

9 : « 2 heures »

10 : « la musique »

11 : Une musique et 2h plus tard le départ.

────────────────────────

Lorsque tu entendras la musique,
tu sauras quoi faire.

Que ton oreille soit prête.

────────────────────────

Merci d’avoir joué.

À bientôt pour de nouveaux mystères...
""";

    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // Bouton skip
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: TextButton(
                onPressed: _close,
                child: const Text(
                  'Passer',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),

          // Crawl
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
                        child: const DefaultTextStyle(
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 22,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 16),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                crawl,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 200),
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

          // Auto-fin
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
