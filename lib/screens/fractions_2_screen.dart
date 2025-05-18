import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/shared_preference_service.dart';

class Fractions2Screen extends StatefulWidget {
  final bool isGameMode;

  const Fractions2Screen({
    super.key,
    required this.isGameMode,
  });

  @override
  State<Fractions2Screen> createState() => _Fractions2ScreenState();
}

class _Fractions2ScreenState extends State<Fractions2Screen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentQuestion = 0;
  bool showResult = false;
  bool isCorrect = false;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimation();
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

  void _startGame() {
    setState(() {
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / 5) * 100; // Assuming 5 questions
    final isPassed = percentage >= 50.0;

    // Save game progress
    SharedPreferenceService.saveGameProgress('fractions_2', score, 5);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isPassed ? 'Congratulations!' : 'Keep Practicing!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPassed ? Icons.celebration : Icons.school,
              size: 64,
              color: isPassed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isPassed
                  ? 'You\'ve completed the Fractions 2 practice!'
                  : 'You\'re making progress! Keep practicing to improve.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score/5 (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to chapter screen
            },
            child: const Text('Return to Menu'),
          ),
          if (!isPassed)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _startGame(); // Restart game
              },
              child: const Text('Try Again'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(
          widget.isGameMode ? 'Fractions 2 Practice' : 'Fractions 2 Lessons',
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
    // TODO: Implement actual game content
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Mode Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re working on exciting games to help you practice Fractions 2 concepts.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return to chapter screen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Return to Menu',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningContent() {
    // TODO: Implement actual learning content
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Learning Content Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'re preparing interactive lessons to help you learn Fractions 2 concepts.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return to chapter screen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Return to Menu',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 