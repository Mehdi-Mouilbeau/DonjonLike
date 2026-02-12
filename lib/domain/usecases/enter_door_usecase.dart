import '../../core/constants/game_constants.dart';
import '../../core/services/time_service.dart';
import '../entities/door.dart';
import '../repositories/door_repository.dart';

/// Result of attempting to enter a door.
sealed class EnterDoorResult {}

class EnterDoorSuccess extends EnterDoorResult {}

class EnterDoorGlobalCooldown extends EnterDoorResult {
  final int daysRemaining;
  EnterDoorGlobalCooldown(this.daysRemaining);
}

class EnterDoorFailedCooldown extends EnterDoorResult {
  final int daysRemaining;
  EnterDoorFailedCooldown(this.daysRemaining);
}

class EnterDoorAlreadySucceeded extends EnterDoorResult {}

class EnterDoorWrongCode extends EnterDoorResult {}

class EnterDoorUseCase {
  final DoorRepository _doorRepository;
  final TimeService _timeService;

  EnterDoorUseCase({
    required DoorRepository doorRepository,
    required TimeService timeService,
  })  : _doorRepository = doorRepository,
        _timeService = timeService;

  /// Attempt to enter a door with the given code.
  EnterDoorResult execute(Door door, String code) {
    // Already succeeded — show hint directly.
    if (door.isSucceeded) {
      return EnterDoorAlreadySucceeded();
    }

    // Global cooldown: 1 door per 7 days.
    final lastEntry = _doorRepository.getLastDoorEntryDate();
    if (!_timeService.hasCooldownExpired(lastEntry,
        days: GameConstants.cooldownDays)) {
      final daysElapsed = _timeService.now.difference(lastEntry!).inDays;
      return EnterDoorGlobalCooldown(
          GameConstants.cooldownDays - daysElapsed);
    }

    // Per-door failed cooldown.
    if (door.isFailed) {
      if (!_timeService.hasCooldownExpired(door.lastAttemptDate,
          days: GameConstants.cooldownDays)) {
        final daysElapsed =
            _timeService.now.difference(door.lastAttemptDate!).inDays;
        return EnterDoorFailedCooldown(
            GameConstants.cooldownDays - daysElapsed);
      } else {
        // Reset door after cooldown expires.
        door.status = DoorStatus.locked;
      }
    }

    // Validate code.
    if (!door.validateCode(code)) {
      return EnterDoorWrongCode();
    }

    return EnterDoorSuccess();
  }
}
