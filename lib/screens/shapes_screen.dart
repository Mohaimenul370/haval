import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import '../widgets/menu_card.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class ShapeQuestion {
  final String shape;
  final List<String> options;
  final String correctAnswer;

  ShapeQuestion({
    required this.shape,
    required this.options,
    required this.correctAnswer,
  });
}

class ShapeActivity {
  final String title;
  final String description;
  final Widget visual;
  final String instruction;
  final List<String> options;

  ShapeActivity({
    required this.title,
    required this.description,
    required this.visual,
    required this.instruction,
    required this.options,
  });
}

class ShapesScreen extends StatefulWidget {
  final bool isGameMode;
  
  const ShapesScreen({
    super.key,
    this.isGameMode = false,
  });

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<ShapeQuestion> questions = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<ShapeActivity> get activities => [
    ShapeActivity(
      title: 'Basic Shapes',
      description: 'Learn about basic shapes like circle, square, and triangle',
      visual: _buildBasicShapesVisual(),
      instruction: 'Identify and learn the names of basic shapes',
      options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
    ),
    ShapeActivity(
      title: 'Advanced Shapes',
      description: 'Explore more complex shapes like pentagon and hexagon',
      visual: _buildAdvancedShapesVisual(),
      instruction: 'Learn about shapes with more sides',
      options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
    ),
    ShapeActivity(
      title: 'Shape Properties',
      description: 'Learn about sides, corners, and other properties of shapes',
      visual: _buildShapePropertiesVisual(),
      instruction: 'Count the sides and corners of each shape',
      options: ['3 sides', '4 sides', '5 sides', '6 sides'],
    ),
    ShapeActivity(
      title: 'Shape Patterns',
      description: 'Learn to identify and create patterns with shapes',
      visual: _buildShapePatternsVisual(),
      instruction: 'Continue the pattern with the correct shape',
      options: ['Circle', 'Square', 'Triangle', 'Star'],
    ),
    ShapeActivity(
      title: 'Real World Shapes',
      description: 'Find shapes in everyday objects around you',
      visual: _buildRealWorldShapesVisual(),
      instruction: 'Match the shape to real world objects',
      options: ['Clock', 'Window', 'Road Sign', 'Ball'],
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
      
      // Create a list of shape questions
      questions = [
        ShapeQuestion(
          shape: 'Circle',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Circle',
        ),
        ShapeQuestion(
          shape: 'Square',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Square',
        ),
        ShapeQuestion(
          shape: 'Triangle',
          options: ['Circle', 'Square', 'Triangle', 'Rectangle'],
          correctAnswer: 'Triangle',
        ),
        ShapeQuestion(
          shape: 'Pentagon',
          options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
          correctAnswer: 'Pentagon',
        ),
        ShapeQuestion(
          shape: 'Hexagon',
          options: ['Pentagon', 'Hexagon', 'Octagon', 'Star'],
          correctAnswer: 'Hexagon',
        ),
      ];
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == questions[currentQuestion].correctAnswer;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (isCorrect) {
      score++;
      _speakText('Correct! This is a ${questions[currentQuestion].correctAnswer}');
    } else {
      _speakText('Try again! The correct answer is ${questions[currentQuestion].correctAnswer}');
    }

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
    
    SharedPreferenceService.saveGameProgress('shapes', score, questions.length);
    
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
              Text(
                isPassed ? 'Congratulations!' : 'Keep Practicing!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
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
              Text(
                isPassed
                    ? 'Great job! You\'ve mastered the shapes!'
                    : 'You\'re getting there! Practice makes perfect.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
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
                        Navigator.of(context).pop();
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
            widget.isGameMode ? 'Shapes Practice' : 'Learn Shapes',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFF7B2FF2), width: 2),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: _buildShapeVisual(questions[currentQuestion]),
              ),
            ),
            const SizedBox(height: 24),
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
                                    option,
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

  void _handleActivityTap(ShapeActivity activity, int index) {
    _speakText('${activity.title}. ${activity.instruction}');
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

  Widget _buildShapeVisual(ShapeQuestion question) {
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
      child: Center(
        child: _buildShapeIcon(question.shape),
      ),
    );
  }

  Widget _buildShapeIcon(String shape) {
    switch (shape.toLowerCase()) {
      case 'circle':
        return const Icon(Icons.circle, size: 100, color: Colors.blue);
      case 'square':
        return const Icon(Icons.square, size: 100, color: Colors.red);
      case 'triangle':
        return const Icon(Icons.change_history, size: 100, color: Colors.green);
      case 'rectangle':
        return const Icon(Icons.rectangle, size: 100, color: Colors.orange);
      case 'pentagon':
        return const Icon(Icons.pentagon, size: 100, color: Colors.purple);
      case 'hexagon':
        return const Icon(Icons.hexagon, size: 100, color: Colors.teal);
      default:
        return const Icon(Icons.shape_line, size: 100, color: Colors.grey);
    }
  }

  Widget _buildBasicShapesVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeIcon('Circle'),
          const SizedBox(width: 16),
          _buildShapeIcon('Square'),
          const SizedBox(width: 16),
          _buildShapeIcon('Triangle'),
          const SizedBox(width: 16),
          _buildShapeIcon('Rectangle'),
        ],
      ),
    );
  }

  Widget _buildAdvancedShapesVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeIcon('Pentagon'),
          const SizedBox(width: 16),
          _buildShapeIcon('Hexagon'),
          const SizedBox(width: 16),
          const Icon(Icons.star, size: 100, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildShapePropertiesVisual() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildShapeWithProperties('Triangle', '3 sides'),
        _buildShapeWithProperties('Square', '4 sides'),
        _buildShapeWithProperties('Pentagon', '5 sides'),
        _buildShapeWithProperties('Hexagon', '6 sides'),
      ],
    );
  }

  Widget _buildShapeWithProperties(String shape, String properties) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildShapeIcon(shape),
        const SizedBox(height: 8),
        Text(
          properties,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShapePatternsVisual() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShapeIcon('Circle'),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeIcon('Square'),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeIcon('Triangle'),
          const Icon(Icons.arrow_forward, size: 40, color: Colors.grey),
          _buildShapeIcon('Circle'),
        ],
      ),
    );
  }

  Widget _buildRealWorldShapesVisual() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildRealWorldObject('Clock', Icons.access_time),
        _buildRealWorldObject('Window', Icons.window),
        _buildRealWorldObject('Road Sign', Icons.traffic),
        _buildRealWorldObject('Ball', Icons.sports_soccer),
      ],
    );
  }

  Widget _buildRealWorldObject(String name, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 60, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 