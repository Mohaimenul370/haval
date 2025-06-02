import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';

class GeometryConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;

  GeometryConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
  });
}

class GeometryScreen extends StatefulWidget {
  final bool isGameMode;
  
  const GeometryScreen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<GeometryScreen> createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;  // Initialize as false to show lesson mode first
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<GeometryConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _optionAnimationController;
  late Animation<double> _optionScaleAnimation;
  bool _isLoading = false;  // Set to false since we don't need to load game state initially

  final List<GeometryConcept> concepts = [
    GeometryConcept(
      name: 'Circle',
      visual: _buildGeometryVisual('⭕', 'Circle'),
      description: 'A round shape with no corners',
      options: ['Circle', 'Square', 'Triangle', 'Rectangle', 'Star'],
    ),
    GeometryConcept(
      name: 'Square',
      visual: _buildGeometryVisual('⬛', 'Square'),
      description: 'A shape with four equal sides',
      options: ['Square', 'Circle', 'Triangle', 'Rectangle', 'Star'],
    ),
    GeometryConcept(
      name: 'Triangle',
      visual: _buildGeometryVisual('🔺', 'Triangle'),
      description: 'A shape with three sides',
      options: ['Triangle', 'Circle', 'Square', 'Rectangle', 'Star'],
    ),
    GeometryConcept(
      name: 'Rectangle',
      visual: _buildGeometryVisual('📏', 'Rectangle'),
      description: 'A shape with four sides, two longer and two shorter',
      options: ['Rectangle', 'Circle', 'Square', 'Triangle', 'Star'],
    ),
    GeometryConcept(
      name: 'Star',
      visual: _buildGeometryVisual('⭐', 'Star'),
      description: 'A shape with five points',
      options: ['Star', 'Circle', 'Square', 'Triangle', 'Rectangle'],
    ),
  ];

  static Widget _buildGeometryVisual(String emoji, String shape) {
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
    _optionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _optionScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _optionAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isGameMode) {
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
        _speakText('Correct! ${shuffledConcepts[currentQuestion].description}');
      } else {
        _speakText('Try again! Think about the shape.');
      }
    });
    _optionAnimationController.forward().then((_) {
      _optionAnimationController.reverse();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (currentQuestion < shuffledConcepts.length - 1) {
        setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledConcepts.length) * 100;
    final isPassed = percentage >= 50.0;
    
    // Save game progress
    SharedPreferenceService.saveGameProgress('geometry', score, shuffledConcepts.length);
    
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
                  ? 'You\'ve completed the Geometry practice!'
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
                  if (isPassed)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        setState(() {
                          score = 0;
                          currentQuestion = 0;
                          selectedAnswer = null;
                          showResult = false;
                          shuffledConcepts = List.from(concepts)..shuffle();
                          for (var concept in shuffledConcepts) {
                            concept.options.shuffle();
                          }
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6A1B9A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF6A1B9A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGameMode ? 'Geometry Game' : 'Learn Geometry',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF7B2FF2),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final isNarrowScreen = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          height: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isNarrowScreen ? 8.0 : 16.0,
              vertical: isSmallScreen ? 8.0 : 16.0,
            ),
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
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
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
                          minHeight: isSmallScreen ? 6 : 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Question
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'What shape is this?',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Visual
                Container(
                  height: isSmallScreen ? 150 : 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: shuffledConcepts[currentQuestion].visual,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
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

                return AnimatedBuilder(
                  animation: _optionAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _optionScaleAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: isSmallScreen ? 6 : 8,
                      left: isNarrowScreen ? 4 : 0,
                      right: isNarrowScreen ? 4 : 0,
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: isSelected ? 4 : 1,
                      child: InkWell(
                        onTap: showResult ? null : () => _checkAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 12,
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
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
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              if (isCorrect)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: isSmallScreen ? 16 : 20,
                                )
                              else if (isIncorrect)
                                Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  );
                }).toList(),
                SizedBox(height: isSmallScreen ? 8 : 16),
              ],
          ),
        );
      },
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Geometry',
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
                    'Let\'s learn about different geometric shapes:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Geometry Concepts
                  ...concepts.map((concept) {
                    return Card(
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
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: concept.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              concept.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),
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
    _optionAnimationController.dispose();
    super.dispose();
  }
} 