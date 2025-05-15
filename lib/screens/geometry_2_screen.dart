import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/shared_preference_service.dart';

class GeometryConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;

  GeometryConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
  });
}

class Geometry2Screen extends StatefulWidget {
  const Geometry2Screen({super.key});

  @override
  State<Geometry2Screen> createState() => _Geometry2ScreenState();
}

class _Geometry2ScreenState extends State<Geometry2Screen> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isLoading = false;  // Set to false since we don't need to load game state initially
  bool _isGameMode = false;  // Initialize as false to show lesson mode first
  int _score = 0;
  int _currentQuestion = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool isCorrect = false;
  
  // Game progress data
  bool _hasExistingProgress = false;
  int _highScore = 0;
  double _completionPercentage = 0.0;
  bool _isGameCompleted = false;

  final List<GeometryConcept> concepts = [
    GeometryConcept(
      name: 'Symmetry',
      description: 'A shape has symmetry when one half is a mirror image of the other half',
      visual: _buildSymmetryVisual(),
      example: 'A butterfly has line symmetry',
    ),
    GeometryConcept(
      name: 'Angles',
      description: 'Angles are formed when two lines meet at a point',
      visual: _buildAnglesVisual(),
      example: 'A right angle is 90 degrees',
    ),
    GeometryConcept(
      name: 'Perimeter',
      description: 'The total distance around the outside of a shape',
      visual: _buildPerimeterVisual(),
      example: 'The perimeter of a square is the sum of all its sides',
    ),
    GeometryConcept(
      name: 'Area',
      description: 'The amount of space inside a shape',
      visual: _buildAreaVisual(),
      example: 'The area of a rectangle is length times width',
    ),
    GeometryConcept(
      name: '3D Shapes',
      description: 'Shapes that have length, width, and height',
      visual: _build3DShapesVisual(),
      example: 'A cube has 6 square faces',
    ),
  ];

  List<String> _options = [];

  static Widget _buildSymmetryVisual() {
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
        painter: SymmetryPainter(),
      ),
    );
  }

  static Widget _buildAnglesVisual() {
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
        painter: AnglesPainter(),
      ),
    );
  }

  static Widget _buildPerimeterVisual() {
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
        painter: PerimeterPainter(),
      ),
    );
  }

  static Widget _buildAreaVisual() {
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
        painter: AreaPainter(),
      ),
    );
  }

  static Widget _build3DShapesVisual() {
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
        painter: ThreeDShapesPainter(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
    // Remove _loadGameProgress() call to ensure lesson mode is shown first
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
      _isGameMode = true;
      _score = 0;
      _currentQuestion = 0;
      _showResult = false;
      _selectedAnswer = null;
      _options = _getRandomOptions(concepts[_currentQuestion]); // Initialize options for the first question
    });
  }

  // Save game state (during gameplay)
  Future<void> _saveGameState() async {
    try {
      await SharedPreferenceService.setInt('geometry_2_current_question', _currentQuestion);
      await SharedPreferenceService.setInt('geometry_2_score', _score);
      await SharedPreferenceService.setBool('geometry_2_game_mode', _isGameMode);
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  // Save final game progress
  Future<void> _saveGameProgress(int finalScore, int totalQuestions) async {
    try {
      developer.log('Saving final game progress:');
      developer.log('Score: $finalScore/$totalQuestions');
      
      final success = await SharedPreferenceService.saveGameProgress('geometry_2', finalScore, totalQuestions);
      
      if (success) {
        // Retrieve and update with the saved values
        final savedScore = SharedPreferenceService.getGameScore('geometry_2');
        final percentage = SharedPreferenceService.getGamePercentage('geometry_2');
        final isCompleted = SharedPreferenceService.isGameCompleted('geometry_2');
        
        setState(() {
          _highScore = savedScore;
          _completionPercentage = percentage;
          _isGameCompleted = isCompleted;
          _hasExistingProgress = true;
        });
        
        developer.log('Game progress saved successfully:');
        developer.log('Percentage: $_completionPercentage%');
        developer.log('Completed: $_isGameCompleted');
      } else {
        developer.log('Failed to save game progress');
      }
    } catch (e) {
      developer.log('Error saving game progress: $e');
    }
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      isCorrect = answer == concepts[_currentQuestion].name;
      if (isCorrect) {
        _score++;
        _speakText('Correct! ${concepts[_currentQuestion].description}');
      } else {
        _speakText('Try again! Think about the concept.');
      }

      // Save score if this is the last question
      if (_currentQuestion == concepts.length - 1) {
        SharedPreferenceService.saveGameProgress('geometry_2', _score, concepts.length);
      }

      // Automatically move to next question after a short delay
      if (_currentQuestion < concepts.length - 1) {
        Future.delayed(const Duration(seconds: 1), () {
          _nextQuestion();
        });
      } else {
        // Show completion dialog after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _showCompletionDialog();
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestion < concepts.length - 1) {
        _currentQuestion++;
        _selectedAnswer = null;
        _showResult = false;
        _options = _getRandomOptions(concepts[_currentQuestion]); // Update options for the new question
        _speakText('Next question!');
      } else {
        // Save final score and show completion dialog
        SharedPreferenceService.saveGameProgress('geometry_2', _score, concepts.length);
        _showCompletionDialog();
      }
    });
  }

  List<String> _getRandomOptions(GeometryConcept concept) {
    // Create a list of all possible answers (all concept names)
    final List<String> allOptions = concepts.map((c) => c.name).toList();
    
    // Remove the correct answer from the list
    allOptions.remove(concept.name);
    
    // Shuffle the remaining options
    allOptions.shuffle();
    
    // Take 3 wrong options
    final List<String> wrongOptions = allOptions.take(3).toList();
    
    // Add the correct answer
    final List<String> options = [...wrongOptions, concept.name];
    
    // Shuffle options once and store them
    options.shuffle();
    
    // Return options
    return options;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Geometry'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isGameMode ? 'Geometry Game' : 'Advanced Geometry'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isGameMode)
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
          child: _isGameMode ? _buildGameMode() : _buildLearningMode(),
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
            'Learn Advanced Geometry',
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
                    'Understanding Advanced Geometry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about advanced geometric concepts:',
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
                          const Text('• Identify different geometric concepts'),
                          const Text('• Match concepts with their descriptions'),
                          const Text('• Understand advanced geometry properties'),
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
    // Game completed view
    if (_currentQuestion >= concepts.length) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 80,
            color: Colors.amber,
          ),
          const SizedBox(height: 20),
          Text(
            'Game Completed!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your final score: $_score out of ${concepts.length}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Completion: ${(_score / concepts.length * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _score == concepts.length ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: LinearProgressIndicator(
              value: _score / concepts.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _score == concepts.length ? Colors.green : Colors.orange,
              ),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isGameMode = false;
                  });
                },
                icon: const Icon(Icons.book),
                label: const Text('Learning Mode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _score = 0;
                    _currentQuestion = 0;
                    _showResult = false;
                    _selectedAnswer = null;
                  });
                  _saveGameState();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Current game question view
    final concept = concepts[_currentQuestion];
    // Use stored options
    final options = _options;

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
                  Text(
                    'Question ${_currentQuestion + 1}/${concepts.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentQuestion + 1) / concepts.length,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Question
            Text(
              'What is this geometric concept?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Visual
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              child: concept.visual,
            ),
            const SizedBox(height: 32),
            // Answer options
            ...options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isCorrect = _showResult && option == concept.name;
              final isIncorrect = _showResult && isSelected && option != concept.name;
              
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
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: isSelected ? 4 : 1,
                  child: InkWell(
                    onTap: _showResult ? null : () => _checkAnswer(option),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                fontSize: 16,
                                fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            const Icon(Icons.check_circle, color: Colors.green)
                          else if (isIncorrect)
                            const Icon(Icons.cancel, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    final percentage = (_score / concepts.length) * 100;
    final isPassed = percentage >= 50.0;
    
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
              'Your score: $_score out of ${concepts.length}',
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
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}

class SymmetryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw butterfly shape
    final path = Path()
      ..moveTo(center.dx, center.dy - 50)
      ..quadraticBezierTo(center.dx + 30, center.dy - 30, center.dx + 20, center.dy)
      ..quadraticBezierTo(center.dx + 40, center.dy + 20, center.dx, center.dy + 40)
      ..quadraticBezierTo(center.dx - 40, center.dy + 20, center.dx - 20, center.dy)
      ..quadraticBezierTo(center.dx - 30, center.dy - 30, center.dx, center.dy - 50);

    canvas.drawPath(path, paint);
    
    // Draw symmetry line
    canvas.drawLine(
      Offset(center.dx, center.dy - 60),
      Offset(center.dx, center.dy + 60),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnglesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw right angle
    canvas.drawLine(
      Offset(center.dx - 30, center.dy),
      center,
      paint,
    );
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - 30),
      paint,
    );
    
    // Draw arc for angle
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 40, height: 40),
      -90 * 3.14159 / 180,
      90 * 3.14159 / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PerimeterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw rectangle
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 80, height: 60),
      paint,
    );
    
    // Draw arrows around perimeter
    final arrowPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(center.dx - 40, center.dy - 30),
      Offset(center.dx + 40, center.dy - 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 40, center.dy - 30),
      Offset(center.dx + 40, center.dy + 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 40, center.dy + 30),
      Offset(center.dx - 40, center.dy + 30),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 40, center.dy + 30),
      Offset(center.dx - 40, center.dy - 30),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AreaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw rectangle
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 80, height: 60),
      paint,
    );
    
    // Draw grid inside rectangle
    final gridPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(center.dx - 40 + i * 10, center.dy - 30),
        Offset(center.dx - 40 + i * 10, center.dy + 30),
        gridPaint,
      );
    }
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(center.dx - 40, center.dy - 30 + i * 10),
        Offset(center.dx + 40, center.dy - 30 + i * 10),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ThreeDShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw cube
    final path = Path()
      ..moveTo(center.dx - 30, center.dy - 30)
      ..lineTo(center.dx + 30, center.dy - 30)
      ..lineTo(center.dx + 30, center.dy + 30)
      ..lineTo(center.dx - 30, center.dy + 30)
      ..close()
      ..moveTo(center.dx - 20, center.dy - 20)
      ..lineTo(center.dx + 40, center.dy - 20)
      ..lineTo(center.dx + 40, center.dy + 40)
      ..lineTo(center.dx - 20, center.dy + 40)
      ..close()
      ..moveTo(center.dx + 30, center.dy - 30)
      ..lineTo(center.dx + 40, center.dy - 20)
      ..moveTo(center.dx + 30, center.dy + 30)
      ..lineTo(center.dx + 40, center.dy + 40)
      ..moveTo(center.dx - 30, center.dy + 30)
      ..lineTo(center.dx - 20, center.dy + 40);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 