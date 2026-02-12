import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_rpg/core/services/time_service.dart';
import 'package:flutter_rpg/domain/entities/door.dart';
import 'package:flutter_rpg/domain/entities/question.dart';
import 'package:flutter_rpg/domain/repositories/door_repository.dart';
import 'package:flutter_rpg/domain/usecases/enter_door_usecase.dart';

/// Fake door repository for testing (no Hive dependency).
class FakeDoorRepository implements DoorRepository {
  DateTime? _lastDoorEntryDate;
  final Map<String, bool> _hints = {};

  @override
  DateTime? getLastDoorEntryDate() => _lastDoorEntryDate;

  @override
  Future<void> setLastDoorEntryDate(DateTime date) async {
    _lastDoorEntryDate = date;
  }

  @override
  Future<void> unlockHint(String doorId) async {
    _hints[doorId] = true;
  }

  @override
  bool isHintUnlocked(String doorId) => _hints[doorId] ?? false;

  @override
  Future<List<Door>> loadDoors() async => [];

  @override
  Future<void> saveDoorStatus(Door door) async {}
}

Door _makeDoor({
  DoorStatus status = DoorStatus.locked,
  DateTime? lastAttemptDate,
}) {
  return Door(
    id: 'door_1',
    label: 'Test Door',
    code4: '1234',
    hint: 'Hint',
    status: status,
    lastAttemptDate: lastAttemptDate,
    questions: const [
      Question(
          questionText: 'Q?',
          options: ['A', 'B'],
          correctIndex: 0),
    ],
  );
}

void main() {
  group('Global cooldown (rolling 7 days)', () {
    test('allows entry when no previous entry exists', () {
      final now = DateTime(2025, 6, 15);
      final timeService = TimeService(clock: () => now);
      final repo = FakeDoorRepository();

      final useCase = EnterDoorUseCase(
        doorRepository: repo,
        timeService: timeService,
      );

      final door = _makeDoor();
      final result = useCase.execute(door, '1234');
      expect(result, isA<EnterDoorSuccess>());
    });

    test('blocks entry within 7 days of last entry', () {
      final lastEntry = DateTime(2025, 6, 10);
      final now = DateTime(2025, 6, 14); // 4 days later
      final timeService = TimeService(clock: () => now);
      final repo = FakeDoorRepository();
      repo._lastDoorEntryDate = lastEntry;

      final useCase = EnterDoorUseCase(
        doorRepository: repo,
        timeService: timeService,
      );

      final door = _makeDoor();
      final result = useCase.execute(door, '1234');
      expect(result, isA<EnterDoorGlobalCooldown>());
      expect((result as EnterDoorGlobalCooldown).daysRemaining, 3);
    });

    test('allows entry after exactly 7 days', () {
      final lastEntry = DateTime(2025, 6, 10);
      final now = DateTime(2025, 6, 17); // exactly 7 days
      final timeService = TimeService(clock: () => now);
      final repo = FakeDoorRepository();
      repo._lastDoorEntryDate = lastEntry;

      final useCase = EnterDoorUseCase(
        doorRepository: repo,
        timeService: timeService,
      );

      final door = _makeDoor();
      final result = useCase.execute(door, '1234');
      expect(result, isA<EnterDoorSuccess>());
    });
  });

  group('Per-door failed cooldown', () {
    test('blocks failed door within 7 days', () {
      final failDate = DateTime(2025, 6, 10);
      final now = DateTime(2025, 6, 13); // 3 days later
      final timeService = TimeService(clock: () => now);
      final repo = FakeDoorRepository();

      final useCase = EnterDoorUseCase(
        doorRepository: repo,
        timeService: timeService,
      );

      final door = _makeDoor(
        status: DoorStatus.failed,
        lastAttemptDate: failDate,
      );

      final result = useCase.execute(door, '1234');
      expect(result, isA<EnterDoorFailedCooldown>());
      expect((result as EnterDoorFailedCooldown).daysRemaining, 4);
    });

    test('resets failed door after 7 days and allows entry', () {
      final failDate = DateTime(2025, 6, 10);
      final now = DateTime(2025, 6, 17); // exactly 7 days
      final timeService = TimeService(clock: () => now);
      final repo = FakeDoorRepository();

      final useCase = EnterDoorUseCase(
        doorRepository: repo,
        timeService: timeService,
      );

      final door = _makeDoor(
        status: DoorStatus.failed,
        lastAttemptDate: failDate,
      );

      final result = useCase.execute(door, '1234');
      expect(result, isA<EnterDoorSuccess>());
      expect(door.status, DoorStatus.locked); // reset
    });
  });

  group('TimeService', () {
    test('hasCooldownExpired returns true when date is null', () {
      final ts = TimeService();
      expect(ts.hasCooldownExpired(null), isTrue);
    });

    test('hasCooldownExpired returns false within period', () {
      final now = DateTime(2025, 6, 15);
      final ts = TimeService(clock: () => now);
      expect(
        ts.hasCooldownExpired(DateTime(2025, 6, 12), days: 7),
        isFalse,
      );
    });

    test('hasCooldownExpired returns true after period', () {
      final now = DateTime(2025, 6, 20);
      final ts = TimeService(clock: () => now);
      expect(
        ts.hasCooldownExpired(DateTime(2025, 6, 12), days: 7),
        isTrue,
      );
    });
  });
}
