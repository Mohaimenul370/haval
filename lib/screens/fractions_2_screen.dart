import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedFraction {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final double value;
  final List<String> options;

  AdvancedFraction({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.value,
    required this.options,
  });
}

class Fractions2Screen extends StatefulWidget {
  const Fractions2Screen({super.key});

  @override
  State<Fractions2Screen> createState() => _Fractions2ScreenState();
}

class _Fractions2ScreenState extends State<Fractions2Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<AdvancedFraction> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  final List<AdvancedFraction> fractions = [
    AdvancedFraction(
      name: 'Two Thirds',
      description: 'Two parts out of three equal parts',
      visual: _buildFractionVisual(2, 3),
      example: 'If you eat 2 slices of a pizza cut into 3 equal parts, you ate two thirds',
      value: 2/3,
      options: ['Two Thirds', 'Three Fourths', 'Four Fifths', 'Five Sixths', 'Seven Eighths'],
    ),
    AdvancedFraction(
      name: 'Three Fourths',
      description: 'Three parts out of four equal parts',
      visual: _buildFractionVisual(3, 4),
      example: 'If you color 3 parts of a square divided into 4 equal parts, you colored three fourths',
      value: 3/4,
      options: ['Three Fourths', 'Two Thirds', 'Four Fifths', 'Five Sixths', 'Seven Eighths'],
    ),
    AdvancedFraction(
      name: 'Four Fifths',
      description: 'Four parts out of five equal parts',
      visual: _buildFractionVisual(4, 5),
      example: 'If you have 4 pieces of a chocolate bar divided into 5 equal parts, you have four fifths',
      value: 4/5,
      options: ['Four Fifths', 'Two Thirds', 'Three Fourths', 'Five Sixths', 'Seven Eighths'],
    ),
    AdvancedFraction(
      name: 'Five Sixths',
      description: 'Five parts out of six equal parts',
      visual: _buildFractionVisual(5, 6),
      example: 'If you complete 5 parts of a puzzle with 6 pieces, you completed five sixths',
      value: 5/6,
      options: ['Five Sixths', 'Two Thirds', 'Three Fourths', 'Four Fifths', 'Seven Eighths'],
    ),
    AdvancedFraction(
      name: 'Seven Eighths',
      description: 'Seven parts out of eight equal parts',
      visual: _buildFractionVisual(7, 8),
      example: 'If you have 7 slices of a cake cut into 8 equal parts, you have seven eighths',
      value: 7/8,
      options: ['Seven Eighths', 'Two Thirds', 'Three Fourths', 'Four Fifths', 'Five Sixths'],
    ),
  ];

  static Widget _buildFractionVisual(int numerator, int denominator) {
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
      child: CustomPaint(
        painter: AdvancedFractionPainter(numerator: numerator, denominator: denominator),
      ),
    );
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
      final savedScore = await PreferenceService.getInt('fractions_2_score') ?? 0;
      final savedQuestion = await PreferenceService.getInt('fractions_2_question') ?? 0;
      final savedGameMode = await PreferenceService.getBool('fractions_2_game_mode') ?? false;

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
      await PreferenceService.setInt('fractions_2_score', score);
      await PreferenceService.setInt('fractions_2_question', currentQuestion);
      await PreferenceService.setBool('fractions_2_game_mode', isGameMode);
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
      shuffledConcepts = List.from(fractions)..shuffle();
      for (var concept in shuffledConcepts) {
        concept.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledConcepts[currentQuestion].name;
      if (isCorrect) {
        score++;
        _speakText('Correct! ${shuffledConcepts[currentQuestion].description}');
      } else {
        _speakText('Try again! Think about the concept.');
      }
    });
  }

  void _nextQuestion() async {
    if (currentQuestion < shuffledConcepts.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
      });
      _speakText('Next question!');
    } else {
      // Save final score and progress using SharedPreferenceService (uses Hive)
      await SharedPreferenceService.saveGameProgress('fractions_2', score, shuffledConcepts.length);
      
      // Show completion dialog
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                score >= shuffledConcepts.length / 2 ? 'Congratulations!' : 'Keep Practicing!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (score >= shuffledConcepts.length / 2)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Your score: $score out of ${shuffledConcepts.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (score >= shuffledConcepts.length / 2)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'You completed this section!',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Return to home screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go to Home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isGameMode ? 'Fractions-2 Game' : 'Learn Fractions-2'),
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

  Widget _buildLearningMode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Fractions-2',
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
                    'Understanding Fractions-2',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about more complex fractions:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Fraction Concepts
                  ...fractions.map((fraction) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fraction.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: fraction.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fraction.description,
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
                          const Text('• Identify different fractions'),
                          const Text('• Match fractions with their names'),
                          const Text('• Understand fraction properties'),
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
                      'Question ${currentQuestion + 1}/${fractions.length}',
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
                      value: (currentQuestion + 1) / fractions.length,
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
              shuffledConcepts[currentQuestion].description,
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
                child: shuffledConcepts[currentQuestion].visual,
              ),
            ),
            const SizedBox(height: 24),
            // Answer options
            ...shuffledConcepts[currentQuestion].options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = showResult && option == shuffledConcepts[currentQuestion].name;
              final isIncorrect = showResult && isSelected && option != shuffledConcepts[currentQuestion].name;
              
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
                              option,
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
                  currentQuestion < fractions.length - 1 ? 'Next Question' : 'Finish Game',
                ),
              ),
          ],
        ),
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

class AdvancedFractionPainter extends CustomPainter {
  final int numerator;
  final int denominator;

  AdvancedFractionPainter({required this.numerator, required this.denominator});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw dividing lines
    for (int i = 0; i < denominator; i++) {
      final angle = (i * 2 * 3.14159) / denominator;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    // Fill selected parts
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numerator; i++) {
      final startAngle = (i * 2 * 3.14159) / denominator;
      final endAngle = ((i + 1) * 2 * 3.14159) / denominator;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
        fillPaint,
      );
    }

    // Draw fraction text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$numerator/$denominator',
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius + 10,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 