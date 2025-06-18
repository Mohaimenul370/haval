import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/shared_preference_service.dart';

class PositionConcept {
  final String name;
  final String description;
  final IconData icon;

  PositionConcept({required this.name, required this.description, required this.icon});
}

class PositionGameQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final Widget visual;

  PositionGameQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.visual,
  });
}

final List<PositionConcept> concepts = [
  PositionConcept(
    name: 'Above and Below',
    description: 'Learn about positions above and below objects',
    icon: Icons.arrow_upward,
  ),
  PositionConcept(
    name: 'Left and Right',
    description: 'Learn about positions to the left and right of objects',
    icon: Icons.arrow_forward,
  ),
  PositionConcept(
    name: 'In Front and Behind',
    description: 'Learn about positions in front of and behind objects',
    icon: Icons.compare_arrows,
  ),
  PositionConcept(
    name: 'Inside and Outside',
    description: 'Learn about positions inside and outside of objects',
    icon: Icons.crop_square,
  ),
];

final List<PositionGameQuestion> positionGameQuestions = [
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Above',
    options: ['Above', 'Below', 'Left', 'Right'],
    visual: _buildPositionVisual('above'),
  ),
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Below',
    options: ['Above', 'Below', 'Left', 'Right'],
    visual: _buildPositionVisual('below'),
  ),
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Left',
    options: ['Left', 'Right', 'Above', 'Below'],
    visual: _buildPositionVisual('left'),
  ),
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Right',
    options: ['Left', 'Right', 'Above', 'Below'],
    visual: _buildPositionVisual('right'),
  ),
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Inside',
    options: ['Inside', 'Outside', 'Above', 'Below'],
    visual: _buildPositionVisual('inside'),
  ),
  PositionGameQuestion(
    question: 'Where is the red circle positioned?',
    correctAnswer: 'Outside',
    options: ['Inside', 'Outside', 'Above', 'Below'],
    visual: _buildPositionVisual('outside'),
  ),
];

Widget _buildPositionVisual(String position) {
  return Container(
    width: 150,
    height: 150,
    child: CustomPaint(
      painter: PositionPainter(position),
      size: const Size(150, 150),
    ),
  );
}

class PositionsScreen extends StatefulWidget {
  final bool isGameMode;
  const PositionsScreen({super.key, this.isGameMode = false});

  @override
  State<PositionsScreen> createState() => _PositionsScreenState();
}

class _PositionsScreenState extends State<PositionsScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  List<PositionGameQuestion> _shuffledQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerScaleAnimation;
  late Animation<Color?> _answerColorAnimation;
  List<String> _currentOptions = [];

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

  List<String> _getShuffledOptions(PositionGameQuestion question) {
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
      _shuffledQuestions = List.from(positionGameQuestions)..shuffle();
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

  void _showCompletionDialog() async {
    final percentage = (_score / _shuffledQuestions.length) * 100;
    final isPassed = percentage >= 50.0;
    // Save game progress
    developer.log('Saving game progress for positions:');
    developer.log('Score: $_score out of ${_shuffledQuestions.length}');
    developer.log('Percentage: $percentage%');
    developer.log('Is passed: $isPassed');
    
    final saveResult = await SharedPreferenceService.saveGameProgress('positions', _score, _shuffledQuestions.length);
    developer.log('Save result for positions: $saveResult');
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
                'Score: $_score/${_shuffledQuestions.length} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                isPassed
                  ? 'You\'ve completed the Positions practice!'
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
                      _startGame();
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
    _animationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6A1B9A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF6A1B9A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isGameMode ? 'Positions Game' : 'Learn Positions',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
                            child: _shuffledQuestions[_currentQuestionIndex].visual,
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

  Widget _buildLearningMode() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            'Learn Positions',
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
                          Center(
                            child: Icon(
                              concept.icon,
                              color: const Color(0xFF6A1B9A),
                              size: 48,
                            ),
                          ),
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
}

class PositionPainter extends CustomPainter {
  final String position;

  PositionPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.1;

    // Draw blue square as reference
    paint.color = Colors.blue;
    final squareSize = size.width * 0.3;
    final squareRect = Rect.fromCenter(
      center: center,
      width: squareSize,
      height: squareSize,
    );
    canvas.drawRect(squareRect, paint);

    // Draw red circle in different positions
    paint.color = Colors.red;
    Offset circleCenter;

    switch (position) {
      case 'above':
        circleCenter = Offset(center.dx, center.dy - squareSize * 0.8);
        break;
      case 'below':
        circleCenter = Offset(center.dx, center.dy + squareSize * 0.8);
        break;
      case 'left':
        circleCenter = Offset(center.dx - squareSize * 0.8, center.dy);
        break;
      case 'right':
        circleCenter = Offset(center.dx + squareSize * 0.8, center.dy);
        break;
      case 'inside':
        circleCenter = center;
        break;
      case 'outside':
        circleCenter = Offset(center.dx + squareSize * 1.2, center.dy + squareSize * 1.2);
        break;
      default:
        circleCenter = center;
    }

    canvas.drawCircle(circleCenter, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 