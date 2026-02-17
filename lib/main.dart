import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await StorageService.init();

  // if (kDebugMode) {
  //   //  l'intro se rejouera à chaque run en debug
  //   // (ça clears tout)
  //   await StorageService.clearAll();
  // }

  runApp(
    const ProviderScope(
      child: RPGApp(),
    ),
  );
}

class RPGApp extends StatelessWidget {
  const RPGApp({super.key});

  @override
  Widget build(BuildContext context) {
    final introShown = StorageService.getIntroShown();
    final initial = introShown ? AppRoutes.nameEntry : AppRoutes.intro;

    return MaterialApp(
      title: 'RPG Julie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6B4E9B),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      initialRoute: initial,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
