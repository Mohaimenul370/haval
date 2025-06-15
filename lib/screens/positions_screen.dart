import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/shared_preference_service.dart';

class PositionConcept {
  final String name;
  final String description;
  final IconData icon;

  PositionConcept({required this.name, required this.description, required this.icon});
}

class PositionGameQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final IconData? icon;

  PositionGameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.icon,
  });
}

final List<PositionConcept> concepts = [
  PositionConcept(
    name: 'Above and Below',
    description: 'Learn about positions above and below objects',
    icon: Icons.arrow_upward,
  ),
  PositionConcept(
    name: 'Left and Right',
    description: 'Learn about positions to the left and right of objects',
    icon: Icons.arrow_forward,
  ),
  PositionConcept(
    name: 'In Front and Behind',
    description: 'Learn about positions in front of and behind objects',
    icon: Icons.compare_arrows,
  ),
  PositionConcept(
    name: 'Inside and Outside',
    description: 'Learn about positions inside and outside of objects',
    icon: Icons.crop_square,
  ),
];

final List<PositionGameQuestion> positionGameQuestions = [
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Above',
    options: ['Above', 'Below', 'Left', 'Right'],
    icon: Icons.arrow_upward,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Below',
    options: ['Above', 'Below', 'Left', 'Right'],
    icon: Icons.arrow_downward,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Left',
    options: ['Left', 'Right', 'Above', 'Below'],
    icon: Icons.arrow_back,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Right',
    options: ['Left', 'Right', 'Above', 'Below'],
    icon: Icons.arrow_forward,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Inside',
    options: ['Inside', 'Outside', 'Above', 'Below'],
    icon: Icons.crop_square,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'In Front',
    options: ['In Front', 'Behind', 'Left', 'Right'],
    icon: Icons.visibility,
  ),
  PositionGameQuestion(
    question: 'What position does this icon represent?',
    correctAnswer: 'Behind',
    options: ['In Front', 'Behind', 'Left', 'Right'],
    icon: Icons.visibility_off,
  ),
];

class PositionsScreen extends StatefulWidget {
  final bool isGameMode;
  const PositionsScreen({super.key, this.isGameMode = false});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  int currentQuestion = 0;
  int score = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool quizFinished = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6A1B9A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF6A1B9A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isGameMode ? 'Positions Game' : 'Learn Positions',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF6A1B9A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
          ),
        ),
        child: SafeArea(
          child: widget.isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    if (quizFinished) {
      // Show popup dialog instead of full screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF6A1B9A),
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quiz Finished!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your score: $score / ${positionGameQuestions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            setState(() {
                              currentQuestion = 0;
                              score = 0;
                              selectedAnswer = null;
                              showResult = false;
                              quizFinished = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Play Again'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Return to main menu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Main Menu',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
      // Return empty container while dialog is showing
      return const SizedBox.shrink();
    }
    final q = positionGameQuestions[currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${positionGameQuestions.length}',
            style: const TextStyle(fontSize: 18, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 16),
          if (q.icon != null)
            Icon(q.icon, color: const Color(0xFF6A1B9A), size: 48),
          const SizedBox(height: 16),
          Text(
            q.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...q.options.map((option) {
            final isSelected = selectedAnswer == option;
            final isCorrect = showResult && option == q.correctAnswer;
            final isIncorrect = showResult && isSelected && option != q.correctAnswer;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..scale(showResult && (isCorrect || isIncorrect) ? 1.05 : 1.0),
                child: Card(
                  elevation: showResult && (isCorrect || isIncorrect) ? 8 : 2,
                  color: isCorrect
                      ? Colors.green.shade100
                      : isIncorrect
                          ? Colors.red.shade100
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCorrect
                          ? Colors.green
                          : isIncorrect
                              ? Colors.red
                              : Colors.grey.shade300,
                      width: showResult && (isCorrect || isIncorrect) ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isCorrect
                            ? Colors.green.shade900
                            : isIncorrect
                                ? Colors.red.shade900
                                : Colors.black87,
                        fontWeight: showResult && (isCorrect || isIncorrect)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: showResult && (isCorrect || isIncorrect)
                        ? Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          )
                        : null,
                    onTap: showResult || selectedAnswer != null
                        ? null
                        : () {
                            setState(() {
                              selectedAnswer = option;
                              showResult = true;
                              if (option == q.correctAnswer) score++;
                            });
                            // Move to next question after animation
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (currentQuestion < positionGameQuestions.length - 1) {
                                setState(() {
                                  currentQuestion++;
                                  selectedAnswer = null;
                                  showResult = false;
                                });
                              } else {
                                setState(() {
                                  quizFinished = true;
                                });
                                // Save score to SharedPreferenceService
                                SharedPreferenceService.saveGameProgress('positions', score, positionGameQuestions.length);
                              }
                            });
                          },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Positions',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: concepts.map((concept) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Icon(
                              concept.icon,
                              color: const Color(0xFF6A1B9A),
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            concept.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            concept.description,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF6A1B9A)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 