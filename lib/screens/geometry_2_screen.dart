import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/screens/measures_2_screen.dart';
import 'package:kg_education_app/screens/statistics_screen.dart';
import 'package:kg_education_app/screens/positions_screen.dart';

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

class GeometryGameQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final Widget? visual;

  GeometryGameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.visual,
  });
}

class Geometry2Screen extends StatefulWidget {
  final bool isGameMode;
  const Geometry2Screen({super.key, required this.isGameMode});

  @override
  State<Geometry2Screen> createState() => _Geometry2ScreenState();
}

class _Geometry2ScreenState extends State<Geometry2Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;  // Set to false since we don't need to load game state initially
  bool _isGameMode = false;  // Initialize as false to show lesson mode first
  int _score = 0;
  int _currentQuestion = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool isCorrect = false;
  bool _isAnswering = false;  // Add this to prevent multiple taps
  
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

  final List<GeometryGameQuestion> geometryGameQuestions = [
    GeometryGameQuestion(
      question: 'What is shown in this shape?',
      correctAnswer: 'Symmetry',
      options: ['Circle', 'Symmetry', 'Square', 'Angle'],
      visual: _buildSymmetryVisual(),
    ),
    GeometryGameQuestion(
      question: 'What is shown in this shape?',
      correctAnswer: 'Angle',
      options: ['Line', 'Circle', 'Angle', 'Square'],
      visual: _buildAnglesVisual(),
    ),
    GeometryGameQuestion(
      question: 'What is shown around this shape?',
      correctAnswer: 'Perimeter',
      options: ['Area', 'Line', 'Perimeter', 'Angle'],
      visual: _buildPerimeterVisual(),
    ),
    GeometryGameQuestion(
      question: 'What is shown inside this shape?',
      correctAnswer: 'Area',
      options: ['Line', 'Area', 'Perimeter', 'Angle'],
      visual: _buildAreaVisual(),
    ),
    GeometryGameQuestion(
      question: 'What type of shape is shown?',
      correctAnswer: '3D Shape',
      options: ['2D Shape', 'Line', 'Angle', '3D Shape'],
      visual: _build3DShapesVisual(),
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
    _initializeAnimation();
    if (widget.isGameMode) {
      _isGameMode = true;
      _score = 0;
      _currentQuestion = 0;
      _showResult = false;
      _selectedAnswer = null;
      _options = _getRandomOptions(concepts[_currentQuestion]);
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    if (_isAnswering) return;  // Prevent multiple taps
    _isAnswering = true;

    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      isCorrect = answer == concepts[_currentQuestion].name;
    });

    // Start animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (isCorrect) {
      _score++;
      _speakText('Correct! ${concepts[_currentQuestion].description}');
    } else {
      _speakText('Try again! Think about the concept.');
    }

    // Move to next question after animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      
      if (_currentQuestion < concepts.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _showResult = false;
          _isAnswering = false;
          _options = _getRandomOptions(concepts[_currentQuestion]);
        });
        _speakText('Next question!');
      } else {
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

  Color _getOptionColor(bool isSelected, bool isCorrect, bool isIncorrect) {
    if (isCorrect) {
      return Colors.green.withOpacity(0.9);
    } else if (isIncorrect) {
      return Colors.red.withOpacity(0.9);
    } else if (isSelected) {
      return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    } else {
      return Theme.of(context).colorScheme.primary.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6A1B9A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF6A1B9A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

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
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Geometry 2',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF6A1B9A),
          systemNavigationBarIconBrightness: Brightness.light,
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
          child: widget.isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildLearningMode() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Geometry',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF6A1B9A),
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
                children: concepts.map((concept) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: concept.visual),
                          const SizedBox(height: 12),
                          Text(
                            concept.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            concept.description,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF6A1B9A)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameMode() {
    if (_isGameCompleted) {
      // Show popup dialog instead of full screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF6A1B9A),
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quiz Finished!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your score: $_score / ${geometryGameQuestions.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            setState(() {
                              _currentQuestion = 0;
                              _score = 0;
                              _selectedAnswer = null;
                              _showResult = false;
                              _isGameCompleted = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A1B9A),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Play Again'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Return to main menu
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Main Menu',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
      // Return empty container while dialog is showing
      return const SizedBox.shrink();
    }

    final q = geometryGameQuestions[_currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${_currentQuestion + 1} of ${geometryGameQuestions.length}',
            style: const TextStyle(fontSize: 18, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Question ${_currentQuestion + 1}/${geometryGameQuestions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A1B9A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: LinearProgressIndicator(
                    value: (_currentQuestion + 1) / geometryGameQuestions.length,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Score: $_score',
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
          const SizedBox(height: 16),
          if (q.visual != null)
            Container(
              height: 200,
              width: 200,
              child: q.visual,
            ),
          const SizedBox(height: 16),
          Text(
            q.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...q.options.map((option) {
            final isSelected = _selectedAnswer == option;
            final isCorrect = _showResult && option == q.correctAnswer;
            final isIncorrect = _showResult && isSelected && option != q.correctAnswer;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..scale(_showResult && (isCorrect || isIncorrect) ? 1.05 : 1.0),
                child: Card(
                  elevation: _showResult && (isCorrect || isIncorrect) ? 8 : 2,
                  color: isCorrect
                      ? Colors.green.shade100
                      : isIncorrect
                          ? Colors.red.shade100
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCorrect
                          ? Colors.green
                          : isIncorrect
                              ? Colors.red
                              : Colors.grey.shade300,
                      width: _showResult && (isCorrect || isIncorrect) ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isCorrect
                            ? Colors.green.shade900
                            : isIncorrect
                                ? Colors.red.shade900
                                : Colors.black87,
                        fontWeight: _showResult && (isCorrect || isIncorrect)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: _showResult && (isCorrect || isIncorrect)
                        ? Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                          )
                        : null,
                    onTap: _showResult || _selectedAnswer != null
                        ? null
                        : () {
                            setState(() {
                              _selectedAnswer = option;
                              _showResult = true;
                              if (option == q.correctAnswer) _score++;
                            });
                            // Move to next question after animation
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (_currentQuestion < geometryGameQuestions.length - 1) {
                                setState(() {
                                  _currentQuestion++;
                                  _selectedAnswer = null;
                                  _showResult = false;
                                });
                              } else {
                                setState(() {
                                  _isGameCompleted = true;
                                });
                              }
                            });
                          },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    final percentage = (_score / geometryGameQuestions.length) * 100;
    final isPassed = percentage >= 50.0;
    // Save game progress at the end, just like fractions_screen.dart
    developer.log('Saving game progress for geometry_2:');
    developer.log('Score: $_score out of ${geometryGameQuestions.length}');
    developer.log('Percentage: $percentage%');
    developer.log('Is passed: $isPassed');
    SharedPreferenceService.saveGameProgress('geometry_2', _score, geometryGameQuestions.length);
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
                'Score: $_score/${geometryGameQuestions.length} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                isPassed
                  ? 'You\'ve completed the Geometry-2 practice!'
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
    _animationController.dispose();
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