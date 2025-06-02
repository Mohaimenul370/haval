import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/game_progress_service.dart';

class MathProblem {
  final String question;
  final Widget visual;
  final List<String> options;
  final String correctAnswer;
  final String category;

  MathProblem({
    required this.question,
    required this.visual,
    required this.options,
    required this.correctAnswer,
    required this.category,
  });
}

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  bool showFinalResults = false;
  List<MathProblem> shuffledProblems = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  late AnimationController _answerAnimationController;
  late Animation<double> _answerAnimation;
  Color _answerColor = Colors.transparent;

  final List<MathProblem> problems = [
    MathProblem(
      question: 'How many sides does a triangle have?',
      visual: _buildShapeVisual('🔺'),
      options: ['2', '3', '4', '5', '6'],
      correctAnswer: '3',
      category: 'Shapes',
    ),
    MathProblem(
      question: 'What time is shown on the clock?',
      visual: _buildClockVisual(3, 0),
      options: ['2:00', '3:00', '4:00', '5:00', '6:00'],
      correctAnswer: '3:00',
      category: 'Time',
    ),
    MathProblem(
      question: 'Which object is longer?',
      visual: _buildLengthComparisonVisual(),
      options: ['Blue', 'Red', 'Green', 'Yellow', 'Purple'],
      correctAnswer: 'Blue',
      category: 'Measures',
    ),
    MathProblem(
      question: 'What comes next in the pattern?',
      visual: _buildPatternVisual(['🔴', '🟡', '🔴', '?']),
      options: ['🔴', '🟡', '🟢', '🔵', '🟣'],
      correctAnswer: '🟡',
      category: 'Patterns',
    ),
    MathProblem(
      question: 'How many apples are there?',
      visual: _buildNumberVisual(5),
      options: ['3', '4', '5', '6', '7'],
      correctAnswer: '5',
      category: 'Numbers',
    ),
    MathProblem(
      question: 'Which shape has 4 equal sides?',
      visual: _buildShapeVisual('⬜'),
      options: ['Triangle', 'Square', 'Circle', 'Rectangle', 'Star'],
      correctAnswer: 'Square',
      category: 'Shapes',
    ),
    MathProblem(
      question: 'What is 2 + 3?',
      visual: _buildAdditionVisual(2, 3),
      options: ['4', '5', '6', '7', '8'],
      correctAnswer: '5',
      category: 'Numbers',
    ),
    MathProblem(
      question: 'Which container has more water?',
      visual: _buildVolumeComparisonVisual(),
      options: ['Tall', 'Short', 'Wide', 'Narrow', 'Both'],
      correctAnswer: 'Tall',
      category: 'Measures',
    ),
    MathProblem(
      question: 'What time of day is it?',
      visual: _buildTimeOfDayVisual('🌅'),
      options: ['Morning', 'Afternoon', 'Evening', 'Night', 'Midnight'],
      correctAnswer: 'Morning',
      category: 'Time',
    ),
    MathProblem(
      question: 'What comes next in the pattern?',
      visual: _buildPatternVisual(['⭐', '🔺', '⭐', '?']),
      options: ['⭐', '🔺', '🔵', '🟢', '🔶'],
      correctAnswer: '🔺',
      category: 'Patterns',
    ),
  ];

  static Widget _buildShapeVisual(String shape) {
    return Text(
      shape,
      style: const TextStyle(fontSize: 48),
    );
  }

  static Widget _buildClockVisual(int hour, int minutes) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Transform.rotate(
            angle: (hour % 12 + minutes / 60) * (2 * 3.14159 / 12),
            child: Container(
              width: 2,
              height: 40,
              color: Colors.black,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Transform.rotate(
            angle: minutes * (2 * 3.14159 / 60),
            child: Container(
              width: 2,
              height: 50,
              color: Colors.black,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLengthComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 20,
          color: Colors.red,
        ),
      ],
    );
  }

  static Widget _buildPatternVisual(List<String> pattern) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pattern.map((emoji) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildNumberVisual(int number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(number, (index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '🍎',
            style: TextStyle(fontSize: 32),
          ),
        );
      }),
    );
  }

  static Widget _buildAdditionVisual(int a, int b) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$a + $b = ?',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }

  static Widget _buildVolumeComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: Border.all(color: Colors.blue),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            border: Border.all(color: Colors.red),
          ),
        ),
      ],
    );
  }

  static Widget _buildTimeOfDayVisual(String emoji) {
    return Text(
      emoji,
      style: const TextStyle(fontSize: 48),
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
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultAnimationController,
        curve: Curves.easeOutBack,
      ),
    );
    _answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _answerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _answerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _startGame();
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
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledProblems = List.from(problems)..shuffle();
      for (var problem in shuffledProblems) {
        problem.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledProblems[currentQuestion].correctAnswer;
      _answerColor = isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3);
      _answerAnimationController.reset();
      _answerAnimationController.forward();
      
      if (isCorrect) {
        score++;
        _speakText('Correct!');
      } else {
        _speakText('Try again!');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledProblems.length - 1) {
        GameProgressService.saveGameProgress('play', score, shuffledProblems.length);
      }

      // Automatically move to next question after a short delay
      if (currentQuestion < shuffledProblems.length - 1) {
        Future.delayed(const Duration(seconds: 1), () {
          _nextQuestion();
        });
      } else {
        // Show final results after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          _showFinalResults();
        });
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (currentQuestion < shuffledProblems.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _animationController.reset();
        _animationController.forward();
        _speakText('Next question!');
      } else {
        showFinalResults = true;
        _speakText('You completed the game!');
        _showFinalResults();
      }
    });
  }

  void _restartGame() {
    setState(() {
      showFinalResults = false;
      _startGame();
    });
  }

  void _showFinalResults() {
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
                    Icons.emoji_events,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: $score/${shuffledProblems.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getResultMessage(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _restartGame();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Main Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
        );
      },
    );
  }

  String _getResultMessage() {
    final percentage = (score / shuffledProblems.length) * 100;
    if (percentage >= 90) {
      return 'Excellent! You\'re a math superstar! 🌟';
    } else if (percentage >= 70) {
      return 'Great job! You\'re doing amazing! 👍';
    } else if (percentage >= 50) {
      return 'Good work! Keep practicing! 💪';
    } else {
      return 'Keep trying! You\'ll get better! 🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Play Time'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
          child: showFinalResults ? _buildFinalResults() : _buildGameScreen(),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${currentQuestion + 1} of ${shuffledProblems.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: shuffledProblems[currentQuestion].visual,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        shuffledProblems[currentQuestion].question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
              children: shuffledProblems[currentQuestion].options.map((option) {
                final isSelected = option == selectedAnswer;
                final isCorrectAnswer = option == shuffledProblems[currentQuestion].correctAnswer;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedBuilder(
                    animation: _answerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: showResult && isSelected
                            ? BoxDecoration(
                                color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCorrect ? Colors.green : Colors.red,
                                  width: 2,
                                ),
                              )
                            : null,
                        child: ScaleTransition(
                          scale: _animation,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: showResult ? null : () => _checkAnswer(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showResult
                                    ? (isSelected
                                        ? (isCorrect ? Colors.green : Colors.red)
                                        : (isCorrectAnswer && showResult
                                            ? Colors.green
                                            : null))
                                    : null,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    option,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (showResult && isSelected) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      isCorrect ? Icons.check_circle : Icons.cancel,
                                      color: isCorrect ? Colors.green : Colors.red,
                                    ),
                                  ],
                                ],
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

  Widget _buildFinalResults() {
    return Center(
      child: ScaleTransition(
        scale: _resultAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your Score: $score/${shuffledProblems.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _getResultMessage(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 16),
                ),
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
    _resultAnimationController.dispose();
    _answerAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 