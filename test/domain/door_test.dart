import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_rpg/domain/entities/door.dart';
import 'package:flutter_rpg/domain/entities/question.dart';

Door _makeDoor({
  DoorStatus status = DoorStatus.locked,
  DateTime? lastAttemptDate,
  DateTime? lastSuccessDate,
}) {
  return Door(
    id: 'test_door',
    label: 'Test Door',
    code4: '1234',
    hint: 'Test hint',
    status: status,
    lastAttemptDate: lastAttemptDate,
    lastSuccessDate: lastSuccessDate,
    questions: const [
      Question(
        questionText: 'Q1?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
      ),
      Question(
        questionText: 'Q2?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 1,
      ),
      Question(
        questionText: 'Q3?',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 2,
      ),
    ],
  );
}

void main() {
  group('Door code validation', () {
    test('correct code returns true', () {
      final door = _makeDoor();
      expect(door.validateCode('1234'), isTrue);
    });

    test('incorrect code returns false', () {
      final door = _makeDoor();
      expect(door.validateCode('0000'), isFalse);
    });

    test('partial code returns false', () {
      final door = _makeDoor();
      expect(door.validateCode('12'), isFalse);
    });

    test('empty code returns false', () {
      final door = _makeDoor();
      expect(door.validateCode(''), isFalse);
    });
  });

  group('Door quiz validation', () {
    test('all correct answers returns true', () {
      final door = _makeDoor();
      expect(door.validateQuiz([0, 1, 2]), isTrue);
    });

    test('one wrong answer returns false', () {
      final door = _makeDoor();
      expect(door.validateQuiz([0, 1, 3]), isFalse);
    });

    test('all wrong answers returns false', () {
      final door = _makeDoor();
      expect(door.validateQuiz([3, 3, 3]), isFalse);
    });

    test('wrong number of answers returns false', () {
      final door = _makeDoor();
      expect(door.validateQuiz([0, 1]), isFalse);
    });

    test('empty answers returns false', () {
      final door = _makeDoor();
      expect(door.validateQuiz([]), isFalse);
    });
  });
}
