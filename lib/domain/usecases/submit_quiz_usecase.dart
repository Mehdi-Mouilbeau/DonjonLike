import '../../core/services/time_service.dart';
import '../entities/door.dart';
import '../repositories/door_repository.dart';

sealed class SubmitQuizResult {}

class QuizSuccess extends SubmitQuizResult {
  final String hint;
  QuizSuccess(this.hint);
}

class QuizFailed extends SubmitQuizResult {}

class SubmitQuizUseCase {
  final DoorRepository _doorRepository;
  final TimeService _timeService;

  SubmitQuizUseCase({
    required DoorRepository doorRepository,
    required TimeService timeService,
  })  : _doorRepository = doorRepository,
        _timeService = timeService;

  /// Submit answers for a door's quiz. Returns success with hint or failure.
  Future<SubmitQuizResult> execute(Door door, List<int> answers) async {
    final now = _timeService.now;

    if (door.validateQuiz(answers)) {
      door.status = DoorStatus.succeeded;
      door.lastSuccessDate = now;
      await _doorRepository.saveDoorStatus(door);
      await _doorRepository.setLastDoorEntryDate(now);
      await _doorRepository.unlockHint(door.id);
      return QuizSuccess(door.hint);
    } else {
      door.status = DoorStatus.failed;
      door.lastAttemptDate = now;
      await _doorRepository.saveDoorStatus(door);
      return QuizFailed();
    }
  }
}
