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

class _Geometry2ScreenState extends State<Geometry2Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  List<GeometryGameQuestion> _shuffledQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];

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

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeAnimations();
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

  List<String> _getShuffledOptions(GeometryGameQuestion question) {
    // Create a list of options including the correct answer
    final List<String> options = List.from(question.options);
    
    // Shuffle the options to randomize their order
    options.shuffle();
    
    return options;
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showResult = false;
      _shuffledQuestions = List.from(geometryGameQuestions)..shuffle();
      _currentOptions = _getShuffledOptions(_shuffledQuestions[0]);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect = answer == _shuffledQuestions[_currentQuestionIndex].correctAnswer;
      _answerAnimationController.forward().then((_) {
        _answerAnimationController.reverse();
      });
      if (_isCorrect) {
        _score++;
        _speakText('Correct! Well done!');
      } else {
        _speakText('Try again! The correct answer is ${_shuffledQuestions[_currentQuestionIndex].correctAnswer}');
      }
      if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _nextQuestion();
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _showCompletionDialog();
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _shuffledQuestions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showResult = false;
        _currentOptions = _getShuffledOptions(_shuffledQuestions[_currentQuestionIndex]);
        _animationController.reset();
        _animationController.forward();
        _speakText('Next question!');
      } else {
        _showCompletionDialog();
      }
    });
  }

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
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6A1B9A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF6A1B9A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_shuffledQuestions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
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
                            child: _shuffledQuestions[_currentQuestionIndex].visual ?? Container(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _shuffledQuestions[_currentQuestionIndex].question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6A1B9A),
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
                final isSelected = _selectedAnswer == option;
                final isCorrectOption = _showResult && option == _shuffledQuestions[_currentQuestionIndex].correctAnswer;
                final isIncorrect = _showResult && isSelected && !_isCorrect;
                Color backgroundColor;
                if (isCorrectOption) {
                  backgroundColor = Colors.green;
                } else if (isIncorrect) {
                  backgroundColor = Colors.red;
                } else if (isSelected) {
                  backgroundColor = const Color(0xFF6A1B9A);
                } else {
                  backgroundColor = const Color(0xFF6A1B9A).withOpacity(0.1);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedBuilder(
                    animation: _answerAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _answerScaleAnimation.value : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6A1B9A),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _showResult ? null : () => _checkAnswer(option),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected || isCorrectOption || isIncorrect
                                        ? Colors.white
                                        : const Color(0xFF6A1B9A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() async {
    final percentage = (_score / geometryGameQuestions.length) * 100;
    final isPassed = percentage >= 50.0;
    // Save game progress at the end, just like fractions_screen.dart
    developer.log('Saving game progress for geometry_2:');
    developer.log('Score: $_score out of ${geometryGameQuestions.length}');
    developer.log('Percentage: $percentage%');
    developer.log('Is passed: $isPassed');
    
    final saveResult = await SharedPreferenceService.saveGameProgress('geometry_2', _score, geometryGameQuestions.length);
    developer.log('Save result for geometry_2: $saveResult');
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
    _answerAnimationController.dispose();
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