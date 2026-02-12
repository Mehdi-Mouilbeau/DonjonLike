import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/time_service.dart';
import '../../data/repositories/door_repository_impl.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../domain/entities/door.dart';
import '../../domain/repositories/door_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/enter_door_usecase.dart';
import '../../domain/usecases/submit_quiz_usecase.dart';
import '../../game/input/input_controller.dart';

// ── Services ────────────────────────────────────────────────────

final timeServiceProvider = Provider<TimeService>((_) => TimeService());

// ── Repositories ────────────────────────────────────────────────

final doorRepositoryProvider = Provider<DoorRepository>(
    (_) => DoorRepositoryImpl());

final playerRepositoryProvider = Provider<PlayerRepository>(
    (_) => PlayerRepositoryImpl());

// ── Use Cases ───────────────────────────────────────────────────

final enterDoorUseCaseProvider = Provider<EnterDoorUseCase>((ref) {
  return EnterDoorUseCase(
    doorRepository: ref.read(doorRepositoryProvider),
    timeService: ref.read(timeServiceProvider),
  );
});

final submitQuizUseCaseProvider = Provider<SubmitQuizUseCase>((ref) {
  return SubmitQuizUseCase(
    doorRepository: ref.read(doorRepositoryProvider),
    timeService: ref.read(timeServiceProvider),
  );
});

// ── Input ───────────────────────────────────────────────────────

final inputControllerProvider = Provider<InputController>(
    (_) => InputController());

// ── Doors state ─────────────────────────────────────────────────

final doorsProvider = FutureProvider<List<Door>>((ref) async {
  final repo = ref.read(doorRepositoryProvider);
  return repo.loadDoors();
});
