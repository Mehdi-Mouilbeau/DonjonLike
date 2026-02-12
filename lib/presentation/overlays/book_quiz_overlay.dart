import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';
import '../controllers/game_controller.dart';

/// Overlay that displays 3 quiz questions, one at a time.
class BookQuizOverlay extends StatefulWidget {
  final GameController gameController;

  const BookQuizOverlay({super.key, required this.gameController});

  @override
  State<BookQuizOverlay> createState() => _BookQuizOverlayState();
}

class _BookQuizOverlayState extends State<BookQuizOverlay> {
  int _currentQuestion = 0;
  final List<int> _answers = [];

  List<Question> get questions =>
      widget.gameController.activeDoor?.questions ?? [];

  void _selectAnswer(int index) {
    _answers.add(index);

    if (_currentQuestion < questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      // All questions answered — submit.
      widget.gameController.submitQuiz(_answers);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) return const SizedBox.shrink();

    final question = questions[_currentQuestion];

    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Le Grand Livre',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_currentQuestion + 1}/${questions.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Question text
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Options
              ...List.generate(question.options.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _selectAnswer(i),
                      child: Text(question.options[i]),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.gameController.closeQuiz,
                child: const Text('Quitter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
