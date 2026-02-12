class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}
