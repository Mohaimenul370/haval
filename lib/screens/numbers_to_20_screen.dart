import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/menu_card.dart';
import 'dart:math';

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

class NumbersTo20Screen extends StatefulWidget {
  final bool isGameMode;
  
  const NumbersTo20Screen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<NumbersTo20Screen> createState() => _NumbersTo20ScreenState();
}

class _NumbersTo20ScreenState extends State<NumbersTo20Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  int? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  int currentNumber = 1;
  List<Question> questions = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<NumberActivity> get activities => [
    NumberActivity(
      title: 'Introduction to Numbers 1-10',
      description: 'Learn the first ten numbers with interactive counting',
      visual: _buildCountingVisual(10),
      instruction: 'Count along with the objects and learn their names',
      options: List.generate(10, (index) => (index + 1).toString()),
    ),
    NumberActivity(
      title: 'Numbers 11-20',
      description: 'Continue learning with numbers 11 through 20',
      visual: _buildCountingVisual(20),
      instruction: 'Practice counting from 11 to 20',
      options: List.generate(10, (index) => (index + 11).toString()),
    ),
    NumberActivity(
      title: 'Number Sequence',
      description: 'Learn the order of numbers from 1 to 20',
      visual: _buildNumberLine(),
      instruction: 'Follow the number line and learn the sequence',
      options: List.generate(20, (index) => (index + 1).toString()),
    ),
    NumberActivity(
      title: 'Number Names',
      description: 'Learn how to write and say numbers in words',
      visual: _buildNumberWords(),
      instruction: 'Match the numbers with their written names',
      options: List.generate(20, (index) => _getNumberWord(index + 1)),
    ),
    NumberActivity(
      title: 'Number Relationships',
      description: 'Learn about numbers that come before and after',
      visual: _buildBeforeAfterVisual(15),
      instruction: 'Identify numbers that come before and after',
      options: ['14', '15', '16'],
    ),
    NumberActivity(
      title: 'Comparing Numbers',
      description: 'Learn to compare numbers using greater than and less than',
      visual: _buildComparisonVisual(13, 17),
      instruction: 'Which number is greater?',
      options: ['13', '17', '15'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _initializeAnimation();
    if (isGameMode) {
      _startGame();
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
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      // Create a list of 5 random questions
      questions = List.generate(5, (index) {
        final random = Random();
        int num1, num2, answer;
        String operation;
        
        // Keep generating numbers until we get a valid combination
        do {
          num1 = random.nextInt(20) + 1; // 1 to 20
          num2 = random.nextInt(20) + 1; // 1 to 20
          operation = random.nextBool() ? '+' : '-';
          
          if (operation == '+') {
            answer = num1 + num2;
          } else {
            answer = num1 - num2;
          }
        } while (
          // For addition, ensure sum is <= 20
          (operation == '+' && answer > 20) ||
          // For subtraction, ensure result is >= 0
          (operation == '-' && answer < 0)
        );

        // Generate options including the correct answer
        final options = <int>{answer};
        while (options.length < 4) {
          int option;
          if (operation == '+') {
            // For addition, generate options close to the answer but within 1-20
            option = answer + (random.nextInt(5) - 2); // Range: answer-2 to answer+2
            if (option < 1) option = 1;
            if (option > 20) option = 20;
          } else {
            // For subtraction, generate options close to the answer but >= 0
            option = answer + (random.nextInt(5) - 2); // Range: answer-2 to answer+2
            if (option < 0) option = 0;
            if (option > 20) option = 20;
          }
          
          if (option != answer) {
            options.add(option);
          }
        }

        // Convert to list and shuffle
        final shuffledOptions = options.toList()..shuffle();

        return Question(
          num1: num1,
          num2: num2,
          operation: operation,
          options: shuffledOptions,
          correctAnswer: answer,
        );
      });
    });
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

  String _getNumberWord(int number) {
    final words = [
      'One', 'Two', 'Three', 'Four', 'Five',
      'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty'
    ];
    return words[number - 1];
  }

  void _showCompletionDialog() {
    final percentage = (score / questions.length) * 100;
    final isPassed = percentage >= 50.0;
    
    // Save game progress
    SharedPreferenceService.saveGameProgress('numbers_to_20', score, questions.length);
    
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(isGameMode ? 'Practice Game' : 'Learn Numbers'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: isGameMode ? _buildGameMode() : _buildLearningMode(),
    );
  }

  Widget _buildGameMode() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildLearningMode() {
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
        content: SingleChildScrollView(
          child: Column(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(option),
                )).toList(),
              ),
            ],
          ),
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
        return Icons.compare;
      case 4:
        return Icons.pattern;
      default:
        return Icons.numbers;
    }
  }

  Color _getActivityColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildVisual(Question question) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${question.num1} ${question.operation} ${question.num2}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '= ?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildCountingVisual(int count) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      ),
    );
  }

  Widget _buildNumberLine() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(
            21,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
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
        20,
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

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 