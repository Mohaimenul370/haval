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
  final String example;
  final List<String> options;

  NumberActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.example,
    required this.options,
  });
}

class NumbersTo20Screen extends StatefulWidget {
  const NumbersTo20Screen({super.key});

  @override
  State<NumbersTo20Screen> createState() => _NumbersTo20ScreenState();
}

class _NumbersTo20ScreenState extends State<NumbersTo20Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;
  List<Question> questions = [];

  final List<NumberActivity> activities = [
    NumberActivity(
      title: 'Count Objects',
      description: 'Count the number of objects shown',
      visual: _buildCountingVisual(5),
      example: 'Count the stars in the sky',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Number Line',
      description: 'Find the missing number in the sequence',
      visual: _buildNumberLineVisual([1, 2, 3, 4, 5]),
      example: 'What number comes after 4?',
      options: ['5', '4', '6', '7', '8'],
    ),
    NumberActivity(
      title: 'Number Comparison',
      description: 'Which number is greater or smaller?',
      visual: _buildComparisonVisual(7, 4),
      example: 'Is 7 greater than 4?',
      options: ['7', '4', '6', '8', '9'],
    ),
    NumberActivity(
      title: 'Number Patterns',
      description: 'Complete the number pattern',
      visual: _buildPatternVisual([2, 4, 6, 8]),
      example: 'What number comes next in 2, 4, 6, 8?',
      options: ['10', '9', '11', '12', '13'],
    ),
    NumberActivity(
      title: 'Number Words',
      description: 'Match the number with its word',
      visual: _buildWordMatchVisual(3),
      example: 'Match "three" with the number 3',
      options: ['3', '2', '4', '5', '6'],
    ),
  ];

  static Widget _buildCountingVisual(int count) {
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
            'Count the stars:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(
              count,
              (index) => const Icon(
                Icons.star,
                color: Colors.amber,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNumberLineVisual(List<int> numbers) {
    return Container(
      width: double.infinity,
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
            'Complete the sequence:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: numbers.map((number) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildComparisonVisual(int num1, int num2) {
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
            'Which is greater?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberBox(num1),
              const Text(
                'vs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildNumberBox(num2),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildPatternVisual(List<int> pattern) {
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
            'What comes next?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: pattern.map((number) {
              return _buildNumberBox(number);
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildWordMatchVisual(int number) {
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
            'Match the number:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          _buildNumberBox(number),
          const SizedBox(height: 10),
          Text(
            _getNumberWord(number),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNumberBox(int number) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static String _getNumberWord(int number) {
    switch (number) {
      case 1: return 'One';
      case 2: return 'Two';
      case 3: return 'Three';
      case 4: return 'Four';
      case 5: return 'Five';
      case 6: return 'Six';
      case 7: return 'Seven';
      case 8: return 'Eight';
      case 9: return 'Nine';
      case 10: return 'Ten';
      case 11: return 'Eleven';
      case 12: return 'Twelve';
      case 13: return 'Thirteen';
      case 14: return 'Fourteen';
      case 15: return 'Fifteen';
      case 16: return 'Sixteen';
      case 17: return 'Seventeen';
      case 18: return 'Eighteen';
      case 19: return 'Nineteen';
      case 20: return 'Twenty';
      default: return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _initializeStorage();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _initializeStorage() async {
    try {
      await PreferenceService.initialize();
      await _loadGameState();
    } catch (e) {
      developer.log('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameState() async {
    try {
      final savedScore = await PreferenceService.getInt('numbers_to_20_score') ?? 0;
      final savedQuestion = await PreferenceService.getInt('numbers_to_20_question') ?? 0;
      final savedGameMode = await PreferenceService.getBool('numbers_to_20_game_mode') ?? false;

      setState(() {
        score = savedScore;
        currentQuestion = savedQuestion;
        isGameMode = savedGameMode;
        _isLoading = false;
      });

      if (isGameMode) {
        _startGame();
      }
    } catch (e) {
      developer.log('Error loading game state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGameState() async {
    try {
      await PreferenceService.setInt('numbers_to_20_score', score);
      await PreferenceService.setInt('numbers_to_20_question', currentQuestion);
      await PreferenceService.setBool('numbers_to_20_game_mode', isGameMode);
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      
      // Create questions based on the lesson activities
      questions = [
        // Count Objects question
        Question(
          num1: 5,
          num2: 0,
          operation: '+',
          options: [5, 4, 6, 7],
          correctAnswer: 5,
        ),
        // Number Line question
        Question(
          num1: 4,
          num2: 1,
          operation: '+',
          options: [5, 4, 6, 7],
          correctAnswer: 5,
        ),
        // Number Comparison question
        Question(
          num1: 7,
          num2: 4,
          operation: '-',
          options: [3, 2, 4, 5],
          correctAnswer: 3,
        ),
        // Number Patterns question
        Question(
          num1: 8,
          num2: 2,
          operation: '+',
          options: [10, 9, 11, 12],
          correctAnswer: 10,
        ),
        // Number Words question
        Question(
          num1: 3,
          num2: 0,
          operation: '+',
          options: [3, 2, 4, 5],
          correctAnswer: 3,
        ),
      ];
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
    SharedPreferenceService.saveGameProgress('numbers_to_20', score, questions.length);
    
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
        title: Text(isGameMode ? 'Numbers to 20 Game' : 'Learn Numbers to 20'),
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
            // Question
            Text(
              '${questions[currentQuestion].num1} ${questions[currentQuestion].operation} ${questions[currentQuestion].num2}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
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
            'Learn Numbers to 20',
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
                    'Let\'s learn about numbers from 1 to 20:',
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
                            const SizedBox(height: 8),
                            Text(
                              'Example: ${activity.example}',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
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
    _animationController.dispose();
    super.dispose();
  }
} 