import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class FractionActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;
  final String name;
  final String funFact;

  FractionActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
    required this.name,
    required this.funFact,
  });
}

class FractionsScreen extends StatefulWidget {
  final bool isGameMode;
  
  const FractionsScreen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<FractionsScreen> createState() => _FractionsScreenState();
}

class _FractionsScreenState extends State<FractionsScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<FractionActivity> shuffledActivities = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;

  List<FractionActivity> get activities => [
    FractionActivity(
      title: 'Understanding Half',
      description: 'Learn about the concept of half and how to represent it',
      visual: _buildFractionVisual(1, 2, 'Half', gradient: [Colors.blue, Colors.cyan]),
      instruction: 'A half means one part out of two equal parts',
      options: ['Half', 'Third', 'Quarter', 'Fifth'],
      name: 'Half',
      funFact: 'If you cut an apple into 2 equal pieces and take one, you have half an apple!',
    ),
    FractionActivity(
      title: 'Understanding Thirds',
      description: 'Explore the concept of thirds and their representation',
      visual: _buildFractionVisual(1, 3, 'Third', gradient: [Colors.purple, Colors.deepPurpleAccent]),
      instruction: 'A third means one part out of three equal parts',
      options: ['Third', 'Half', 'Quarter', 'Fifth'],
      name: 'Third',
      funFact: 'If you share a chocolate bar with 2 friends, each gets a third!',
    ),
    FractionActivity(
      title: 'Understanding Quarters',
      description: 'Learn about quarters and how they divide a whole',
      visual: _buildFractionVisual(1, 4, 'Quarter', gradient: [Colors.orange, Colors.deepOrange]),
      instruction: 'A quarter means one part out of four equal parts',
      options: ['Quarter', 'Half', 'Third', 'Fifth'],
      name: 'Quarter',
      funFact: 'A quarter of an hour is 15 minutes!',
    ),
    FractionActivity(
      title: 'Understanding Fifths',
      description: 'Discover the concept of fifths and their visual representation',
      visual: _buildFractionVisual(1, 5, 'Fifth', gradient: [Colors.green, Colors.lightGreen]),
      instruction: 'A fifth means one part out of five equal parts',
      options: ['Fifth', 'Half', 'Third', 'Quarter'],
      name: 'Fifth',
      funFact: 'If you have 5 candies and eat one, you ate a fifth!',
    ),
    FractionActivity(
      title: 'Understanding Sixths',
      description: 'Learn about sixths and how they divide a whole',
      visual: _buildFractionVisual(1, 6, 'Sixth', gradient: [Colors.pink, Colors.redAccent]),
      instruction: 'A sixth means one part out of six equal parts',
      options: ['Sixth', 'Half', 'Third', 'Quarter', 'Fifth'],
      name: 'Sixth',
      funFact: 'If you cut a pizza into 6 slices and take one, you have a sixth!',
    ),
  ];

  static Widget _buildFractionVisual(int numerator, int denominator, String name, {List<Color>? gradient}) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        color: gradient == null ? Colors.white : null,
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
        painter: BarFractionPainter(
          numerator: numerator,
          denominator: denominator,
          name: name,
          gradient: gradient ?? [Colors.blue, Colors.cyan],
        ),
      ),
    );
  }

  void _initializeAnimation() {
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimation();
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

  void _handleActivityTap(FractionActivity activity, int index) {
    _speakText('${activity.title}. ${activity.instruction}');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary.withOpacity(0.15), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Basic Fractions',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              activity.visual,
              const SizedBox(height: 24),
              Text(
                activity.instruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity.funFact,
                        style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: activity.options.map((option) => ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _speakText('You selected $option. Let\'s learn more about fractions!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledActivities[currentQuestion].name;
    });

    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });

    if (isCorrect) {
      score++;
      _speakText('Correct!');
    } else {
      _speakText('Try again!');
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (currentQuestion < shuffledActivities.length - 1) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
          _scaleAnimationController.reset();
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledActivities = List.from(activities)..shuffle();
      for (var activity in shuffledActivities) {
        activity.options.shuffle();
      }
      _animationController.reset();
      _scaleAnimationController.reset();
      _animationController.forward();
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledActivities.length) * 100;
    final isPassed = percentage >= 50.0;

    // Save game progress
    SharedPreferenceService.saveGameProgress('fractions', score, shuffledActivities.length);

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          ' / ${shuffledActivities.length}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Message
              Text(
                isPassed
                    ? 'Great job! You\'ve mastered the fractions!'
                    : 'You\'re getting there! Practice makes perfect.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(isGameMode ? 'Fractions Game' : 'Learn Fractions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
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
        child: SafeArea(
          child: isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    return Container(
      height: MediaQuery.of(context).size.height,
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
                        'Question ${currentQuestion + 1}/${shuffledActivities.length}',
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
                        value: (currentQuestion + 1) / shuffledActivities.length,
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
              // Generic prompt instead of answer-revealing text
              Text(
                'Which fraction is shown below?',
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
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: shuffledActivities[currentQuestion].visual,
                ),
              ),
              const SizedBox(height: 24),
              // Answer options
              ...shuffledActivities[currentQuestion].options.map((option) {
                final isSelected = selectedAnswer == option;
                final isCorrect = showResult && option == shuffledActivities[currentQuestion].name;
                final isIncorrect = showResult && isSelected && option != shuffledActivities[currentQuestion].name;
                return _buildAnswerOption(option, isSelected, isCorrect, isIncorrect);
              }).toList(),
              const SizedBox(height: 20),
              // No Next Question button
            ],
          ),
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
            'Learn Basic Fractions',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _handleActivityTap(activity, index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Lesson ${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activity.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activity.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        activity.visual,
                        const SizedBox(height: 16),
                        Text(
                          activity.instruction,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOption(String option, bool isSelected, bool isCorrect, bool isIncorrect) {
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
      child: AnimatedBuilder(
        animation: _scaleAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? _scaleAnimation.value : 1.0,
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
        },
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }
}

class BarFractionPainter extends CustomPainter {
  final int numerator;
  final int denominator;
  final String name;
  final List<Color> gradient;

  BarFractionPainter({
    required this.numerator,
    required this.denominator,
    required this.name,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barHeight = size.height * 0.4;
    final double barWidth = size.width * 0.8;
    final double left = (size.width - barWidth) / 2;
    final double top = (size.height - barHeight) / 2;
    final double partWidth = barWidth / denominator;

    // Draw the bar background
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(left, top, barWidth, barHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(16)),
      bgPaint,
    );

    // Draw the filled parts
    for (int i = 0; i < numerator; i++) {
      final fillRect = Rect.fromLTWH(left + i * partWidth, top, partWidth, barHeight);
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(fillRect)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, const Radius.circular(16)),
        fillPaint,
      );
    }

    // Draw the part dividers
    final dividerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    for (int i = 1; i < denominator; i++) {
      final dx = left + i * partWidth;
      canvas.drawLine(
        Offset(dx, top),
        Offset(dx, top + barHeight),
        dividerPaint,
      );
    }

    // Draw the fraction text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$numerator/$denominator',
        style: const TextStyle(
          color: Colors.black,
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
        size.width / 2 - textPainter.width / 2,
        top + barHeight + 12,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 