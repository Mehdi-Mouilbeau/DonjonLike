import '../../domain/entities/door.dart';
import '../../domain/entities/question.dart';

/// DTO for parsing doors from JSON.
class DoorModel {
  final String id;
  final String label;
  final String code4;
  final List<QuestionModel> questions;
  final String hint;

  DoorModel({
    required this.id,
    required this.label,
    required this.code4,
    required this.questions,
    required this.hint,
  });

  factory DoorModel.fromJson(Map<String, dynamic> json) {
    return DoorModel(
      id: json['id'] as String,
      label: json['label'] as String,
      code4: json['code4'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      hint: json['hint'] as String,
    );
  }

  Door toEntity() {
    return Door(
      id: id,
      label: label,
      code4: code4,
      questions: questions.map((q) => q.toEntity()).toList(),
      hint: hint,
    );
  }
}

class QuestionModel {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  QuestionModel({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questionText: json['questionText'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: json['correctIndex'] as int,
    );
  }

  Question toEntity() {
    return Question(
      questionText: questionText,
      options: options,
      correctIndex: correctIndex,
    );
  }
}
