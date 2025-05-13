import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'dart:math';

class Question {
  final int num1;
  final int num2;
  final String operation;
  final List<int> options;
  final int correctAnswer;

  Question({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.options,
    required this.correctAnswer,
  });
}

class NumberActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;

  NumberActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
  });
}

class NumbersTo10Screen extends StatefulWidget {
  const NumbersTo10Screen({super.key});

  @override
  State<NumbersTo10Screen> createState() => _NumbersTo10ScreenState();
}

class _NumbersTo10ScreenState extends State<NumbersTo10Screen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  int currentNumber = 1;
  List<Question> questions = [];

  final List<NumberActivity> activities = [
    NumberActivity(
      title: 'Count Objects',
      description: 'Learn to count objects from 1 to 10',
      visual: _buildCountingVisual(5),
      instruction: 'Count the objects and select the correct number',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Number Line',
      description: 'Understand number sequence from 1 to 10',
      visual: _buildNumberLine(),
      instruction: 'Find the missing number in the sequence',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Number Words',
      description: 'Match numbers with their written form',
      visual: _buildNumberWords(),
      instruction: 'Match the number with its word',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Before and After',
      description: 'Learn numbers that come before and after',
      visual: _buildBeforeAfterVisual(5),
      instruction: 'What number comes before and after?',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Number Comparison',
      description: 'Compare numbers using greater than and less than',
      visual: _buildComparisonVisual(3, 7),
      instruction: 'Which number is greater?',
      options: ['7', '3', '6', '8', '9'],
    ),
  ];

  static Widget _buildCountingVisual(int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final dotSize = maxWidth > 300 ? 40.0 : 30.0;
        final spacing = maxWidth > 300 ? 5.0 : 3.0;
        
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            count,
            (index) => Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    );
  }

  static Widget _buildNumberLine() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            10,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildNumberWords() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Five',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '5',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildBeforeAfterVisual(int number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${number - 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${number + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildComparisonVisual(int num1, int num2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$num1',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Text(
          '?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$num2',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      // Create a list of 5 random questions
      questions = List.generate(5, (index) {
        final num1 = Random().nextInt(10) + 1;
        final num2 = Random().nextInt(10) + 1;
        final operation = Random().nextBool() ? '+' : '-';
        final answer = operation == '+' ? num1 + num2 : num1 - num2;
        
        // Generate options including the correct answer
        final options = <int>[];
        options.add(answer);
        while (options.length < 4) {
          final option = Random().nextInt(20) - 5; // Range from -5 to 14
          if (!options.contains(option)) {
            options.add(option);
          }
        }
        options.shuffle();
        
        return Question(
          num1: num1,
          num2: num2,
          operation: operation,
          options: options,
          correctAnswer: answer,
        );
      });
    });
  }

  void _checkAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == questions[currentQuestion].correctAnswer;
      if (isCorrect) {
        score++;
        _speakText('Correct! ${questions[currentQuestion].num1} ${questions[currentQuestion].operation} ${questions[currentQuestion].num2} equals $answer');
      } else {
        _speakText('Try again! The correct answer is ${questions[currentQuestion].correctAnswer}');
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
      });
      _speakText('Next question!');
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final percentage = (score / questions.length) * 100;
    final isPassed = percentage >= 50.0;
    
    // Save game progress
    SharedPreferenceService.saveGameProgress('numbers_to_10', score, questions.length);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isPassed ? 'Congratulations!' : 'Keep Practicing!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPassed)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            const SizedBox(height: 16),
            Text(
              'Your score: $score out of ${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            if (isPassed)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'You completed this section!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to home screen
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isGameMode ? 'Numbers to 10 Game' : 'Learn Numbers to 10'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!isGameMode)
            IconButton(
              icon: const Icon(Icons.games),
              onPressed: _startGame,
              tooltip: 'Start Game',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
              Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Question ${currentQuestion + 1}/${questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: LinearProgressIndicator(
                      value: (currentQuestion + 1) / questions.length,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Visual
            Container(
              height: 200,
              width: double.infinity,
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.contain,
                child: _buildVisual(questions[currentQuestion]),
              ),
            ),
            const SizedBox(height: 24),
            // Answer options
            ...questions[currentQuestion].options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = showResult && option == questions[currentQuestion].correctAnswer;
              final isIncorrect = showResult && isSelected && option != questions[currentQuestion].correctAnswer;
              
              Color backgroundColor;
              if (isCorrect) {
                backgroundColor = Colors.green.shade100;
              } else if (isIncorrect) {
                backgroundColor = Colors.red.shade100;
              } else if (isSelected) {
                backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
              } else {
                backgroundColor = Colors.white;
              }

              Color borderColor;
              if (isCorrect) {
                borderColor = Colors.green;
              } else if (isIncorrect) {
                borderColor = Colors.red;
              } else if (isSelected) {
                borderColor = Theme.of(context).colorScheme.primary;
              } else {
                borderColor = Colors.grey.shade300;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: isSelected ? 4 : 1,
                  child: InkWell(
                    onTap: showResult ? null : () => _checkAnswer(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: borderColor,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green, size: 20)
                          else if (isIncorrect)
                            const Icon(Icons.cancel, color: Colors.red, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            // Next button
            if (showResult)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  currentQuestion < questions.length - 1 ? 'Next Question' : 'Finish Game',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Numbers to 10',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
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
                children: [
                  // Introduction
                  Text(
                    'Understanding Numbers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about numbers from 1 to 10:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Number Concepts
                  ...activities.map((activity) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: activity.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              activity.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Practice Section
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready to Practice?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Test your understanding by playing the game! You\'ll need to:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text('• Count objects correctly'),
                          const Text('• Identify numbers in sequence'),
                          const Text('• Compare numbers'),
                          const Text('• Get at least half the questions right to complete the game'),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _startGame,
                              icon: const Icon(Icons.games),
                              label: const Text('Start Game'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisual(Question question) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${question.num1} ${question.operation} ${question.num2}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '= ?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
} 