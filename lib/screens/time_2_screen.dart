import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/game_progress_service.dart';
import '../services/shared_preference_service.dart';

class TimeConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final List<String> options;

  TimeConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.options,
  });
}

class Time2Screen extends StatefulWidget {
  final bool isGameMode;
  
  const Time2Screen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<Time2Screen> createState() => _Time2ScreenState();
}

class _Time2ScreenState extends State<Time2Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;  // Initialize as false to show lesson mode first
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<TimeConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];

  final List<TimeConcept> concepts = [
    TimeConcept(
      name: 'Morning Time',
      description: 'What we do in the morning',
      visual: _buildDailyActivityVisual('🌅'),
      example: 'Wake up',
      options: [
        'Wake up',
        'Go to school',
        'Have lunch',
        'Go to bed',
        'Play games',
      ],
    ),
    TimeConcept(
      name: 'School Time',
      description: 'What we do at school',
      visual: _buildDailyActivityVisual('🏫'),
      example: 'Learn',
      options: [
        'Learn',
        'Eat breakfast',
        'Sleep',
        'Watch TV',
        'Play outside',
      ],
    ),
    TimeConcept(
      name: 'Lunch Time',
      description: 'What we do at lunch',
      visual: _buildDailyActivityVisual('🍎'),
      example: 'Eat lunch',
      options: [
        'Eat lunch',
        'Take a bath',
        'Do homework',
        'Play with toys',
        'Brush teeth',
      ],
    ),
    TimeConcept(
      name: 'Play Time',
      description: 'What we do in the afternoon',
      visual: _buildDailyActivityVisual('🎮'),
      example: 'Play',
      options: [
        'Play',
        'Go to school',
        'Sleep',
        'Eat dinner',
        'Do homework',
      ],
    ),
    TimeConcept(
      name: 'Bed Time',
      description: 'What we do at night',
      visual: _buildDailyActivityVisual('🌙'),
      example: 'Go to bed',
      options: [
        'Go to bed',
        'Go to school',
        'Eat breakfast',
        'Play games',
        'Do homework',
      ],
    ),
  ];

  static Widget _buildDailyActivityVisual(String emoji) {
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
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimations();
    if (isGameMode) {
      _startGame();
    }
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  List<String> _getShuffledOptions(TimeConcept concept) {
    // Create a list of options including the correct answer
    final List<String> options = List.from(concept.options);
    
    // Shuffle the options to randomize their order
    options.shuffle();
    
    return options;
  }

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledConcepts = List.from(concepts)..shuffle();
      _currentOptions = _getShuffledOptions(shuffledConcepts[0]);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _initializeAnimations() {
    // Question transition animation
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

    // Answer feedback animation
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answerScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _answerColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green,
    ).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledConcepts[currentQuestion].example;
      _answerAnimationController.forward().then((_) {
        _answerAnimationController.reverse();
      });
      if (isCorrect) {
        score++;
        _speakText('Yay! You got it right! ${shuffledConcepts[currentQuestion].example} is correct!');
      } else {
        _speakText('Oops! Try again! Think about what we do ${shuffledConcepts[currentQuestion].name.toLowerCase()}');
      }
      if (currentQuestion == shuffledConcepts.length - 1) {
        SharedPreferenceService.saveGameProgress('time_2', score, shuffledConcepts.length);
      }
      if (currentQuestion < shuffledConcepts.length - 1) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _nextQuestion();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          _showCompletionDialog();
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestion < shuffledConcepts.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _currentOptions = _getShuffledOptions(shuffledConcepts[currentQuestion]);
        _animationController.reset();
        _animationController.forward();
        _speakText('Next question!');
      } else {
        SharedPreferenceService.saveGameProgress('time_2', score, shuffledConcepts.length);
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledConcepts.length) * 100;
    final isPassed = percentage >= 50.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Header with Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPassed 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.school,
                size: 48,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                isPassed ? 'Congratulations!' : 'Keep Practicing!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
            const SizedBox(height: 16),
              // Score Display
            Text(
                'Score: $score/${shuffledConcepts.length} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              // Message
              Text(
                isPassed
                  ? 'You\'ve completed the Time-2 practice!'
                  : 'You\'re making progress! Keep practicing to improve.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
        ),
              const SizedBox(height: 24),
              // Buttons
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to home screen
            },
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      setState(() {
                        score = 0;
                        currentQuestion = 0;
                        showResult = false;
                        selectedAnswer = null;
                        shuffledConcepts = List.from(concepts)..shuffle();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
          ),
        ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGameMode ? 'Time Game' : 'Learn Time',
          style: const TextStyle(
            color: Color(0xFF7B2FF2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF7B2FF2)),
        actions: [
          if (!isGameMode)
            IconButton(
              icon: const Icon(Icons.games, color: Color(0xFF7B2FF2)),
              onPressed: _startGame,
              tooltip: 'Start Game',
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
            'Learn Time',
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF7B2FF2),
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
                    'Understanding Time',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2FF2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about different times of the day:',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7B2FF2)),
                  ),
                  const SizedBox(height: 16),

                  // Time Concepts
                  ...concepts.map((concept) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concept.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B2FF2),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: concept.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              concept.description,
                              style: const TextStyle(fontSize: 16, color: Color(0xFF7B2FF2)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
            Text(
              'Question ${currentQuestion + 1} of ${shuffledConcepts.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2FF2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2FF2),
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _animation,
              child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: shuffledConcepts[currentQuestion].visual,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getQuestionText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7B2FF2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: _currentOptions.map((option) {
                final isSelected = selectedAnswer == option;
                final isCorrectOption = showResult && option == shuffledConcepts[currentQuestion].example;
                final isIncorrect = showResult && isSelected && !isCorrect;
                Color backgroundColor;
                if (isCorrectOption) {
                  backgroundColor = Colors.green;
                } else if (isIncorrect) {
                  backgroundColor = Colors.red;
                } else if (isSelected) {
                  backgroundColor = const Color(0xFF7B2FF2);
                } else {
                  backgroundColor = const Color(0xFF7B2FF2).withOpacity(0.1);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedBuilder(
                    animation: _answerAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _answerScaleAnimation.value : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: backgroundColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: showResult ? null : () => _checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: isSelected || isCorrectOption ? Colors.white : const Color(0xFF7B2FF2),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                        child: Text(
                          option,
                          textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected || isCorrectOption ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected || isCorrectOption ? Colors.white : const Color(0xFF7B2FF2),
                                ),
                              ),
                            ),
                            if (isCorrectOption)
                              const Icon(Icons.check_circle, color: Colors.white)
                            else if (isIncorrect)
                              const Icon(Icons.cancel, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getQuestionText() {
    final currentConcept = shuffledConcepts[currentQuestion];
    switch (currentConcept.name) {
      case 'Morning Time':
        return 'What do we do in the morning?';
      case 'School Time':
        return 'What do we do at school?';
      case 'Lunch Time':
        return 'What do we do at lunch time?';
      case 'Play Time':
        return 'What do we do in the afternoon?';
      case 'Bed Time':
        return 'What do we do at night?';
      default:
        return currentConcept.description;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 