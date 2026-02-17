import 'package:flutter/material.dart';
import 'package:julie_rpg/presentation/views/intro_screen.dart';

import '../../presentation/views/name_entry_screen.dart';
import '../../presentation/views/game_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String nameEntry = '/';
  static const String game = '/game';
  static const intro = '/intro';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.nameEntry:
        return MaterialPageRoute(
          builder: (_) => const NameEntryScreen(),
        );
      case AppRoutes.game:
        return MaterialPageRoute(
          builder: (_) => const GameScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
    }
  }
}
