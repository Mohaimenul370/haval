import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class Position {
  final String name;
  final String description;
  final Widget visual;
  final String example;

  Position({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
  });
}

class PositionsScreen extends StatefulWidget {
  const PositionsScreen({super.key});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;

  final List<Position> positions = [
    Position(
      name: 'Above',
      description: 'Something is higher than another thing',
      visual: _buildPositionVisual('above'),
      example: 'The sun is above the clouds',
    ),
    Position(
      name: 'Below',
      description: 'Something is lower than another thing',
      visual: _buildPositionVisual('below'),
      example: 'The fish swims below the water',
    ),
    Position(
      name: 'Left',
      description: 'The side that is opposite to right',
      visual: _buildPositionVisual('left'),
      example: 'The heart is on the left side of the body',
    ),
    Position(
      name: 'Right',
      description: 'The side that is opposite to left',
      visual: _buildPositionVisual('right'),
      example: 'Most people write with their right hand',
    ),
    Position(
      name: 'Between',
      description: 'In the middle of two things',
      visual: _buildPositionVisual('between'),
      example: 'The cat is between the two dogs',
    ),
    Position(
      name: 'Inside',
      description: 'Within something',
      visual: _buildPositionVisual('inside'),
      example: 'The bird is inside the cage',
    ),
    Position(
      name: 'Outside',
      description: 'Not inside something',
      visual: _buildPositionVisual('outside'),
      example: 'The dog is outside the house',
    ),
    Position(
      name: 'In Front',
      description: 'Before something',
      visual: _buildPositionVisual('front'),
      example: 'The teacher stands in front of the class',
    ),
    Position(
      name: 'Behind',
      description: 'At the back of something',
      visual: _buildPositionVisual('behind'),
      example: 'The moon is behind the clouds',
    ),
  ];

  static Widget _buildPositionVisual(String position) {
    switch (position) {
      case 'above':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'below':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'left':
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
            ),
            const SizedBox(width: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'right':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'between':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
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
            ),
          ],
        );
      case 'inside':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      case 'outside':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'front':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'behind':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
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
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == positions[currentQuestion].name;
      if (isCorrect) {
        score++;
        _speakText('Correct! ${positions[currentQuestion].description}');
      } else {
        _speakText('Try again! Think about the position.');
      }

      // Save score if this is the last question
      if (currentQuestion == positions.length - 1) {
        SharedPreferenceService.saveGameProgress('positions', score, positions.length);
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestion < positions.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _speakText('Next question!');
      } else {
        // Save final score and show completion dialog
        SharedPreferenceService.saveGameProgress('positions', score, positions.length);
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / positions.length) * 100;
    final isPassed = percentage >= 50.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isPassed ? 'Congratulations!' : 'Keep Practicing!',
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
              if (isPassed)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              const SizedBox(height: 20),
              Text(
                'Your score: $score out of ${positions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isPassed)
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isGameMode ? 'Positions Game' : 'Learn Positions'),
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
              Theme.of(context).colorScheme.primary.withValues(alpha: 77),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 77),
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
    // Create a list of options including the correct answer and 3 random wrong answers
    List<Position> allOptions = List.from(positions);
    allOptions.remove(positions[currentQuestion]); // Remove the correct answer
    allOptions.shuffle(); // Shuffle the remaining options
    List<Position> wrongOptions = allOptions.take(3).toList(); // Take 3 random wrong options
    List<Position> options = [...wrongOptions, positions[currentQuestion]]; // Add the correct answer
    options.shuffle(); // Shuffle all options together

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Question ${currentQuestion + 1} of ${positions.length}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Score: $score',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              positions[currentQuestion].visual,
              const SizedBox(height: 10),
              Text(
                'What position is shown?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: options.map((position) {
            final isSelected = selectedAnswer == position.name;
            final isCorrectAnswer = position.name == positions[currentQuestion].name;
            
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: showResult ? null : () => _checkAnswer(position.name),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: showResult
                        ? (isCorrectAnswer
                            ? Colors.green.shade100
                            : (isSelected && !isCorrectAnswer)
                                ? Colors.red.shade100
                                : Colors.white)
                        : (isSelected
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: showResult
                          ? (isCorrectAnswer
                              ? Colors.green
                              : (isSelected && !isCorrectAnswer)
                                  ? Colors.red
                                  : Colors.grey.shade300)
                          : (isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        position.name,
                        style: TextStyle(
                          color: showResult && isCorrectAnswer ? Colors.green : null,
                          fontWeight: isSelected || (showResult && isCorrectAnswer) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (showResult && isCorrectAnswer)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                        )
                      else if (showResult && isSelected && !isCorrectAnswer)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.cancel, color: Colors.red, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        if (showResult)
          ElevatedButton(
            onPressed: _nextQuestion,
            child: Text(
              currentQuestion < positions.length - 1 ? 'Next Question' : 'Finish Game',
            ),
          ),
      ],
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Positions',
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
                    'Understanding Positions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about different positions:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Position Concepts
                  ...positions.map((position) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              position.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: position.visual,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              position.description,
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
                          const Text('• Identify different positions'),
                          const Text('• Match positions with their names'),
                          const Text('• Understand position properties'),
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
    super.dispose();
  }
} 