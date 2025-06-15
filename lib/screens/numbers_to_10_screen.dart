import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/menu_card.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class Question {
  final int num1;
  final int num2;
  final String operation;
  final List<int> options;
  final int correctAnswer;

  Question({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.options,
    required this.correctAnswer,
  });
}

class NumberActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;

  NumberActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
  });
}

class NumbersTo10Screen extends StatefulWidget {
  final bool isGameMode;
  
  const NumbersTo10Screen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<NumbersTo10Screen> createState() => _NumbersTo10ScreenState();
}

class _NumbersTo10ScreenState extends State<NumbersTo10Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  int currentNumber = 1;
  List<Question> questions = [];
  late List<NumberActivity> activities;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeActivities();
    });
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

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      // Create a list of 5 random questions
      questions = List.generate(5, (index) {
        final num1 = Random().nextInt(10) + 1;
        final num2 = Random().nextInt(10) + 1;
        final operation = Random().nextBool() ? '+' : '-';
        final answer = operation == '+' ? num1 + num2 : num1 - num2;
        
        // Generate options including the correct answer
        final options = <int>[];
        // Add the correct answer
        options.add(answer);
        
        // Generate unique wrong options
        while (options.length < 4) {
          // Generate a random number within a reasonable range
          int wrongOption;
          if (operation == '+') {
            // For addition, generate numbers close to the answer
            wrongOption = answer + (Random().nextInt(5) - 2); // Range: answer-2 to answer+2
          } else {
            // For subtraction, generate numbers close to the answer
            wrongOption = answer + (Random().nextInt(5) - 2); // Range: answer-2 to answer+2
          }
          
          // Make sure the wrong option is not the same as the answer
          // and not already in the options list
          if (wrongOption != answer && !options.contains(wrongOption)) {
            options.add(wrongOption);
          }
        }
        
        // Shuffle the options to randomize their positions
        options.shuffle();
        
        return Question(
          num1: num1,
          num2: num2,
          operation: operation,
          options: options,
          correctAnswer: answer,
        );
      });
    });
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

  void _checkAnswer(int answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == questions[currentQuestion].correctAnswer;
    });

    // Start animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (isCorrect) {
      score++;
      _speakText('Correct! ${questions[currentQuestion].num1} ${questions[currentQuestion].operation} ${questions[currentQuestion].num2} equals $answer');
    } else {
      _speakText('Try again! The correct answer is ${questions[currentQuestion].correctAnswer}');
    }

    // Move to next question after animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
          });
          _speakText('Next question!');
        } else {
          _showCompletionDialog();
        }
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / questions.length) * 100;
    final isPassed = percentage >= 50.0;
    // Add debug log
    developer.log('Saving game progress for numbers: score=$score, total=${questions.length}, percentage=$percentage');
    SharedPreferenceService.saveGameProgress('numbers', score, questions.length);
    
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
                          ' / ${questions.length}',
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
                    ? 'Great job! You\'ve mastered the numbers!'
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7B2FF2),
        systemNavigationBarColor: Color(0xFF7B2FF2),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF3EFFF),
      appBar: AppBar(
          title: Text(
            widget.isGameMode ? 'Numbers to 10 Practice' : 'Learn Numbers to 10',
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
            child: widget.isGameMode ? _buildGameContent() : _buildLearningContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress bar
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Question ${currentQuestion + 1}/${questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (currentQuestion + 1) / questions.length,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Score: $score',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Visual
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: _buildVisual(questions[currentQuestion]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Answer options with animation
              ...questions[currentQuestion].options.map((option) {
                final isSelected = selectedAnswer == option;
                final isCorrect = showResult && option == questions[currentQuestion].correctAnswer;
                final isIncorrect = showResult && isSelected && option != questions[currentQuestion].correctAnswer;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _scaleAnimation.value : 1.0,
                        child: Material(
                          borderRadius: BorderRadius.circular(12),
                          elevation: isSelected ? 4 : 1,
                          child: InkWell(
                            onTap: showResult ? null : () => _checkAnswer(option),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: _getOptionColor(isSelected, isCorrect, isIncorrect),
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getOptionColor(isSelected, isCorrect, isIncorrect),
                                    _getOptionColor(isSelected, isCorrect, isIncorrect).withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Icon(Icons.check_circle, color: Colors.white, size: 24)
                                  else if (isIncorrect)
                                    const Icon(Icons.cancel, color: Colors.white, size: 24),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningContent() {
    return Column(
      children: [
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

  void _handleActivityTap(NumberActivity activity, int index) {
    _speakText('${activity.title}. ${activity.instruction}');
    // Show interactive lesson dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            activity.visual,
            const SizedBox(height: 16),
            Text(activity.instruction),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activity.options.map((option) => ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _speakText('You selected $option. Let\'s practice more!');
                },
                child: Text(option),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    switch (index) {
      case 0:
        return Icons.format_list_numbered;
      case 1:
        return Icons.timeline;
      case 2:
        return Icons.text_fields;
      case 3:
        return Icons.compare_arrows;
      case 4:
        return Icons.compare;
      default:
        return Icons.numbers;
    }
  }

  Widget _buildVisual(Question question) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${question.num1} ${question.operation} ${question.num2}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '= ?',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _initializeActivities() {
    setState(() {
      activities = [
        NumberActivity(
          title: 'Introduction to Numbers 1-5',
          description: 'Learn the first five numbers with interactive counting',
          visual: _buildCountingVisual(5),
          instruction: 'Count along with the objects and learn their names',
          options: ['1', '2', '3', '4', '5'],
        ),
        NumberActivity(
          title: 'Numbers 6-10',
          description: 'Continue learning with numbers 6 through 10',
          visual: _buildCountingVisual(10),
          instruction: 'Practice counting from 6 to 10',
          options: ['6', '7', '8', '9', '10'],
        ),
        NumberActivity(
          title: 'Number Sequence',
          description: 'Learn the order of numbers from 1 to 10',
          visual: _buildNumberLine(),
          instruction: 'Follow the number line and learn the sequence',
          options: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        ),
        NumberActivity(
          title: 'Number Names',
          description: 'Learn how to write and say numbers in words',
          visual: _buildNumberWords(),
          instruction: 'Match the numbers with their written names',
          options: ['One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten'],
        ),
        NumberActivity(
          title: 'Number Relationships',
          description: 'Learn about numbers that come before and after',
          visual: _buildBeforeAfterVisual(5),
          instruction: 'Identify numbers that come before and after',
          options: ['4', '5', '6'],
        ),
        NumberActivity(
          title: 'Comparing Numbers',
          description: 'Learn to compare numbers using greater than and less than',
          visual: _buildComparisonVisual(3, 7),
          instruction: 'Which number is greater?',
          options: ['3', '7'],
        ),
        NumberActivity(
          title: 'Number Patterns',
          description: 'Discover patterns in numbers from 1 to 10',
          visual: _buildPatternVisual(),
          instruction: 'Find the pattern and continue the sequence',
          options: ['2', '4', '6', '8', '10'],
        ),
      ];
    });
  }

  Widget _buildCountingVisual(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberLine() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          11,
          (index) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2,
                height: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                '$index',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberWords() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(
        10,
        (index) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Text(
            _getNumberWord(index + 1),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeforeAfterVisual(int number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNumberBox(number - 1, 'Before'),
        const SizedBox(width: 16),
        _buildNumberBox(number, 'Current'),
        const SizedBox(width: 16),
        _buildNumberBox(number + 1, 'After'),
      ],
    );
  }

  Widget _buildNumberBox(int number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonVisual(int smaller, int larger) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildComparisonBox(smaller, 'Smaller'),
        const SizedBox(width: 24),
        Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(width: 24),
        _buildComparisonBox(larger, 'Larger'),
      ],
    );
  }

  Widget _buildComparisonBox(int number, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getNumberWord(int number) {
    final words = [
      'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten'
    ];
    return words[number - 1];
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

  Widget _buildPatternVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${(index + 1) * 2}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Even Numbers Pattern',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 