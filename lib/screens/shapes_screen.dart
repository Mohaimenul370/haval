import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class ShapeConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;

  ShapeConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
  });
}

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<ShapeConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  final List<ShapeConcept> concepts = [
    ShapeConcept(
      name: 'Circle',
      visual: _buildShapeVisual('⭕', 'Circle'),
      description: 'A round shape with no corners',
      options: ['Circle', 'Square', 'Triangle', 'Rectangle', 'Star'],
    ),
    ShapeConcept(
      name: 'Square',
      visual: _buildShapeVisual('⬛', 'Square'),
      description: 'A shape with four equal sides',
      options: ['Square', 'Circle', 'Triangle', 'Rectangle', 'Star'],
    ),
    ShapeConcept(
      name: 'Triangle',
      visual: _buildShapeVisual('🔺', 'Triangle'),
      description: 'A shape with three sides',
      options: ['Triangle', 'Circle', 'Square', 'Rectangle', 'Star'],
    ),
    ShapeConcept(
      name: 'Rectangle',
      visual: _buildShapeVisual('📏', 'Rectangle'),
      description: 'A shape with four sides, two longer and two shorter',
      options: ['Rectangle', 'Circle', 'Square', 'Triangle', 'Star'],
    ),
    ShapeConcept(
      name: 'Star',
      visual: _buildShapeVisual('⭐', 'Star'),
      description: 'A shape with five points',
      options: ['Star', 'Circle', 'Square', 'Triangle', 'Rectangle'],
    ),
  ];

  static Widget _buildShapeVisual(String emoji, String shape) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ],
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
    setState(() {
      isGameMode = false;  // Ensure lesson mode is shown first
      _isLoading = false;
    });
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
      final savedScore = await PreferenceService.getInt('shapes_score') ?? 0;
      final savedQuestion = await PreferenceService.getInt('shapes_question') ?? 0;
      final savedGameMode = await PreferenceService.getBool('shapes_game_mode') ?? false;

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
      await PreferenceService.setInt('shapes_score', score);
      await PreferenceService.setInt('shapes_question', currentQuestion);
      await PreferenceService.setBool('shapes_game_mode', isGameMode);
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
      shuffledConcepts = List.from(concepts)..shuffle();
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
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${shuffledConcepts[currentQuestion].name} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the shape');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledConcepts.length - 1) {
        SharedPreferenceService.saveGameProgress('shapes', score, shuffledConcepts.length);
      }
    });
  }

  void _nextQuestion() async {
    if (currentQuestion < shuffledConcepts.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        shuffledConcepts = List.from(concepts)..shuffle();
        for (var concept in shuffledConcepts) {
          concept.options.shuffle();
        }
        _animationController.reset();
        _animationController.forward();
        _speakText('Great job! Let\'s try another one!');
      });
    } else {
      _showCompletionDialog();
    }
    await _saveGameState();
  }

  void _showCompletionDialog() {
    final percentage = (score / concepts.length) * 100;
    final isPassed = percentage >= 50.0;
    
    // Save game progress
    SharedPreferenceService.saveGameProgress('shapes', score, concepts.length);
    
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
              'Your score: $score out of ${concepts.length}',
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
        title: Text(isGameMode ? 'Shapes Game' : 'Learn Shapes'),
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
                      'Question ${currentQuestion + 1}/${shuffledConcepts.length}',
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
                      value: (currentQuestion + 1) / shuffledConcepts.length,
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
                  currentQuestion < shuffledConcepts.length - 1 ? 'Next Question' : 'Finish Game',
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
            'Learn Shapes',
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
                    'Understanding Shapes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about different shapes:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Shape Concepts
                  ...concepts.map((shape) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shape.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: shape.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              shape.description,
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
                          const Text('• Identify different shapes'),
                          const Text('• Match shapes with their names'),
                          const Text('• Understand shape properties'),
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

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
} 