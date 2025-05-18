import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class MeasureConcept {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;

  MeasureConcept({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
  });
}

class MeasuresScreen extends StatefulWidget {
  final bool isGameMode;

  const MeasuresScreen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<MeasuresScreen> createState() => _MeasuresScreenState();
}

class _MeasuresScreenState extends State<MeasuresScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentQuestion = 0;
  bool showResult = false;
  bool isCorrect = false;
  String? selectedAnswer;
  List<MeasureConcept> shuffledConcepts = [];
  bool _isLoading = true;

  final List<MeasureConcept> concepts = [
    MeasureConcept(
      name: 'Length',
      visual: _buildMeasureVisual('📏', 'Length'),
      description: 'How long or short something is',
      options: ['Length', 'Weight', 'Time', 'Temperature', 'Volume'],
    ),
    MeasureConcept(
      name: 'Weight',
      visual: _buildMeasureVisual('⚖️', 'Weight'),
      description: 'How heavy or light something is',
      options: ['Weight', 'Length', 'Time', 'Temperature', 'Volume'],
    ),
    MeasureConcept(
      name: 'Time',
      visual: _buildMeasureVisual('⏰', 'Time'),
      description: 'How long something takes',
      options: ['Time', 'Length', 'Weight', 'Temperature', 'Volume'],
    ),
    MeasureConcept(
      name: 'Temperature',
      visual: _buildMeasureVisual('🌡️', 'Temperature'),
      description: 'How hot or cold something is',
      options: ['Temperature', 'Length', 'Weight', 'Time', 'Volume'],
    ),
    MeasureConcept(
      name: 'Volume',
      visual: _buildMeasureVisual('🧪', 'Volume'),
      description: 'How much space something takes up',
      options: ['Volume', 'Length', 'Weight', 'Time', 'Temperature'],
    ),
  ];

  static Widget _buildMeasureVisual(String emoji, String measure) {
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
    _initializeAnimation();
    _initializeAnswerAnimation();
    if (widget.isGameMode) {
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

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  void _initializeAnswerAnimation() {
    _answerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _answerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startGame() {
    setState(() {
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
      // Play answer animation
      _answerAnimationController.forward().then((_) {
        _answerAnimationController.reverse();
      });
      if (isCorrect) {
        score++;
        _speakText('Yay! You got it right! \\${shuffledConcepts[currentQuestion].name} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the measurement');
      }
    });
    // Automatically go to next question or show completion dialog
    Future.delayed(const Duration(milliseconds: 900), () {
      if (currentQuestion < shuffledConcepts.length - 1) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
          _animationController.reset();
          _animationController.forward();
        });
        _speakText('Next question!');
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledConcepts.length) * 100;
    final isPassed = percentage >= 50.0;
    SharedPreferenceService.saveGameProgress('measures', score, shuffledConcepts.length);
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
                  ? 'You\'ve completed the Measures practice!'
                  : 'You\'re making progress! Keep practicing to improve.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
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
                        _startGame(); // Start new game
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
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    _answerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          widget.isGameMode ? 'Measures Practice' : 'Learn Measures',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: widget.isGameMode ? _buildGameContent() : _buildLearningContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
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
                final isCorrectOption = showResult && option == shuffledConcepts[currentQuestion].name;
                final isIncorrect = showResult && isSelected && option != shuffledConcepts[currentQuestion].name;
                
                Color backgroundColor;
                if (isCorrectOption) {
                  backgroundColor = Colors.green.withOpacity(0.9);
                } else if (isIncorrect) {
                  backgroundColor = Colors.red.withOpacity(0.9);
                } else if (isSelected) {
                  backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.9);
                } else {
                  backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);
                }

                return ScaleTransition(
                  scale: (isSelected && showResult) ? _answerScaleAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: isSelected ? 4 : 1,
                      color: backgroundColor,
                      child: InkWell(
                        onTap: showResult ? null : () => _checkAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              if (isCorrectOption)
                                const Icon(Icons.check_circle, color: Colors.white, size: 24)
                              else if (isIncorrect)
                                const Icon(Icons.cancel, color: Colors.white, size: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Measures',
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
                    'Understanding Measures',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about different measures:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Measure Concepts
                  ...concepts.map((measure) {
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} 