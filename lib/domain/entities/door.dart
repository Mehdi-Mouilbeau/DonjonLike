import 'question.dart';

enum DoorStatus { locked, opened, succeeded, failed }

class Door {
  final String id;
  final String label;
  final String code4;
  final List<Question> questions;
  final String hint;
  DoorStatus status;
  DateTime? lastAttemptDate;
  DateTime? lastSuccessDate;

  Door({
    required this.id,
    required this.label,
    required this.code4,
    required this.questions,
    required this.hint,
    this.status = DoorStatus.locked,
    this.lastAttemptDate,
    this.lastSuccessDate,
  });

  bool get isSucceeded => status == DoorStatus.succeeded;
  bool get isFailed => status == DoorStatus.failed;
  bool get isLocked => status == DoorStatus.locked;
  bool get isOpened => status == DoorStatus.opened;

  /// Validate 4-digit code.
  bool validateCode(String input) => input == code4;

  /// Validate all quiz answers. Returns true only if ALL are correct.
  bool validateQuiz(List<int> answers) {
    if (answers.length != questions.length) return false;
    for (int i = 0; i < questions.length; i++) {
      if (!questions[i].isCorrect(answers[i])) return false;
    }
    return true;
  }
}
