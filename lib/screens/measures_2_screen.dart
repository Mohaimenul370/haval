import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class Measure {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final String unit;
  final List<String> options;

  Measure({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.unit,
    required this.options,
  });
}

class Measures2Screen extends StatefulWidget {
  const Measures2Screen({super.key});

  @override
  State<Measures2Screen> createState() => _Measures2ScreenState();
}

class _Measures2ScreenState extends State<Measures2Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Measure> shuffledMeasures = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Measure> measures = [
    Measure(
      name: 'Longer/Shorter',
      description: 'Comparing lengths of objects',
      visual: _buildLengthComparisonVisual(),
      example: 'A pencil is shorter than a ruler',
      unit: 'cm',
      options: [
        'A pencil is shorter than a ruler',
        'A ruler is shorter than a pencil',
        'Both are the same length',
        'Cannot compare lengths',
      ],
    ),
    Measure(
      name: 'Taller/Shorter',
      description: 'Comparing heights of objects',
      visual: _buildHeightComparisonVisual(),
      example: 'A tree is taller than a flower',
      unit: 'cm',
      options: [
        'A tree is taller than a flower',
        'A flower is taller than a tree',
        'Both are the same height',
        'Cannot compare heights',
      ],
    ),
    Measure(
      name: 'Heavier/Lighter',
      description: 'Comparing weights of objects',
      visual: _buildWeightComparisonVisual(),
      example: 'A book is heavier than a feather',
      unit: 'kg',
      options: [
        'A book is heavier than a feather',
        'A feather is heavier than a book',
        'Both weigh the same',
        'Cannot compare weights',
      ],
    ),
    Measure(
      name: 'More/Less',
      description: 'Comparing amounts of liquid',
      visual: _buildCapacityComparisonVisual(),
      example: 'A jug has more water than a cup',
      unit: 'ml',
      options: [
        'A jug has more water than a cup',
        'A cup has more water than a jug',
        'Both have the same amount',
        'Cannot compare amounts',
      ],
    ),
    Measure(
      name: 'Longer/Shorter Time',
      description: 'Comparing durations',
      visual: _buildTimeComparisonVisual(),
      example: 'An hour is longer than a minute',
      unit: 'min',
      options: [
        'An hour is longer than a minute',
        'A minute is longer than an hour',
        'Both are the same duration',
        'Cannot compare durations',
      ],
    ),
  ];

  static Widget _buildLengthComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        Container(
          width: 50,
          height: 20,
          color: Colors.red,
        ),
      ],
    );
  }

  static Widget _buildHeightComparisonVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 100,
          color: Colors.green,
        ),
        const SizedBox(height: 20),
        Container(
          width: 20,
          height: 50,
          color: Colors.orange,
        ),
      ],
    );
  }

  static Widget _buildWeightComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Icon(Icons.book, size: 40, color: Colors.brown),
            const Text('Heavy'),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            const Icon(Icons.air, size: 40, color: Colors.grey),
            const Text('Light'),
          ],
        ),
      ],
    );
  }

  static Widget _buildCapacityComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: Border.all(color: Colors.blue),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: Border.all(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  static Widget _buildTimeComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            const Icon(Icons.timer, size: 40, color: Colors.purple),
            const Text('Longer'),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            const Icon(Icons.timer_3, size: 40, color: Colors.purple),
            const Text('Shorter'),
          ],
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
      shuffledMeasures = List.from(measures)..shuffle();
      for (var measure in shuffledMeasures) {
        measure.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledMeasures[currentQuestion].example;
      if (isCorrect) {
        score++;
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${shuffledMeasures[currentQuestion].example} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the measurement');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledMeasures.length - 1) {
        SharedPreferenceService.saveGameProgress('measures_2', score, shuffledMeasures.length);
      }
    });
  }

  void _nextQuestion() async {
    if (currentQuestion < shuffledMeasures.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
      });
      _speakText('Next question!');
    } else {
      // Save game progress using SharedPreferenceService
      await SharedPreferenceService.saveGameProgress('measures_2', score, shuffledMeasures.length);
      
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
                score >= shuffledMeasures.length / 2 ? 'Congratulations!' : 'Keep Practicing!',
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
                    if (score >= shuffledMeasures.length / 2)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                    const SizedBox(height: 20),
                    Text(
                      'Your score: $score out of ${shuffledMeasures.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (score >= shuffledMeasures.length / 2)
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
        title: Text(isGameMode ? 'Measures-2 Game' : 'Learn Measures-2'),
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
            'Learn Measures-2',
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
                    'Understanding Measures-2',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about more complex measures:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Measure Concepts
                  ...measures.map((measure) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              measure.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: measure.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              measure.description,
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
                          const Text('• Identify different measures'),
                          const Text('• Match measures with their names'),
                          const Text('• Understand measure properties'),
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
                      'Question ${currentQuestion + 1}/${shuffledMeasures.length}',
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
                      value: (currentQuestion + 1) / shuffledMeasures.length,
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
              shuffledMeasures[currentQuestion].description,
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
                child: shuffledMeasures[currentQuestion].visual,
              ),
            ),
            const SizedBox(height: 24),
            // Answer options
            ...shuffledMeasures[currentQuestion].options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = showResult && option == shuffledMeasures[currentQuestion].example;
              final isIncorrect = showResult && isSelected && option != shuffledMeasures[currentQuestion].example;
              
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
                  currentQuestion < shuffledMeasures.length - 1 ? 'Next Question' : 'Finish Game',
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _saveGameState() async {
    // Implementation of _saveGameState method
  }
} 