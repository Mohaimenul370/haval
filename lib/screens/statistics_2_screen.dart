import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class StatisticsConcept {
  final String name;
  final String description;
  final Widget visual;
  final String example;
  final List<String> options;

  StatisticsConcept({
    required this.name,
    required this.description,
    required this.visual,
    required this.example,
    required this.options,
  });
}

class Statistics2Screen extends StatefulWidget {
  final bool isGameMode;
  const Statistics2Screen({super.key, this.isGameMode = false});

  @override
  State<Statistics2Screen> createState() => _Statistics2ScreenState();
}

class _Statistics2ScreenState extends State<Statistics2Screen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<StatisticsConcept> shuffledConcepts = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<StatisticsConcept> concepts = [
    StatisticsConcept(
      name: 'Data Collection',
      description: 'Gathering and organizing information',
      visual: _buildDataCollectionVisual(),
      example: 'Favorite Colors',
      options: [
        'Favorite Colors',
        'Types of Pets',
        'Weather Data',
        'Classroom Attendance',
        'Lunch Choices',
      ],
    ),
    StatisticsConcept(
      name: 'Bar Graphs',
      description: 'Using bars to show data',
      visual: _buildBarGraphVisual(),
      example: 'Bar Graph',
      options: [
        'Bar Graph',
        'Line Graph',
        'Pie Chart',
        'Pictograph',
        'Table',
      ],
    ),
    StatisticsConcept(
      name: 'Pictographs',
      description: 'Using pictures to show data',
      visual: _buildPictographVisual(),
      example: 'Pictograph',
      options: [
        'Pictograph',
        'Bar Graph',
        'Line Graph',
        'Pie Chart',
        'Table',
      ],
    ),
    StatisticsConcept(
      name: 'Data Analysis',
      description: 'Understanding what data tells us',
      visual: _buildDataAnalysisVisual(),
      example: 'Most Common',
      options: [
        'Most Common',
        'Least Common',
        'Total Count',
        'Difference',
        'Average',
      ],
    ),
    StatisticsConcept(
      name: 'Data Comparison',
      description: 'Comparing different sets of data',
      visual: _buildDataComparisonVisual(),
      example: 'Compare Data',
      options: [
        'Compare Data',
        'Count Data',
        'Sort Data',
        'Graph Data',
        'Collect Data',
      ],
    ),
  ];

  static Widget _buildDataCollectionVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDataItem('Red', Colors.red),
            _buildDataItem('Blue', Colors.blue),
            _buildDataItem('Green', Colors.green),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDataItem('Yellow', Colors.yellow),
            _buildDataItem('Purple', Colors.purple),
          ],
        ),
      ],
    );
  }

  static Widget _buildDataItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _buildBarGraphVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(40, 'A'),
            _buildBar(60, 'B'),
            _buildBar(30, 'C'),
            _buildBar(50, 'D'),
          ],
        ),
      ],
    );
  }

  static Widget _buildBar(double height, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Container(
            width: 20,
            height: height,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _buildPictographVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPictoItem('🍎', 3),
            _buildPictoItem('🍌', 2),
            _buildPictoItem('🍇', 4),
          ],
        ),
      ],
    );
  }

  static Widget _buildPictoItem(String emoji, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            'x$count',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _buildDataAnalysisVisual() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnalysisItem('Most', Colors.green),
            _buildAnalysisItem('Least', Colors.red),
          ],
        ),
      ],
    );
  }

  static Widget _buildAnalysisItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDataComparisonVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildComparisonItem('Group A', 5),
        const Text(' vs ', style: TextStyle(fontSize: 16)),
        _buildComparisonItem('Group B', 3),
      ],
    );
  }

  static Widget _buildComparisonItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Count: $count',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeTts();
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
    isGameMode = widget.isGameMode;
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
      shuffledConcepts = List.from(concepts)..shuffle();
      for (var concept in shuffledConcepts) {
        concept.options.shuffle();
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledConcepts[currentQuestion].example;
      if (isCorrect) {
        score++;
        _speakText('Yay! You got it right! ${shuffledConcepts[currentQuestion].example} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the statistic');
      }
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
      // Move to next question immediately (no delay)
      if (mounted) {
        if (currentQuestion < shuffledConcepts.length - 1) {
          setState(() {
            currentQuestion++;
            selectedAnswer = null;
            showResult = false;
          });
        } else {
          _showGameCompletionDialog();
        }
      }
    });
    // Save score if this is the last question
    if (currentQuestion == shuffledConcepts.length - 1) {
      SharedPreferenceService.saveGameProgress('statistics_2', score, shuffledConcepts.length);
    }
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

  void _showGameCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Game Completed!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $score/${shuffledConcepts.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                score >= shuffledConcepts.length / 2
                    ? 'Great job! You passed the game!'
                    : 'Keep practicing! You can do better!',
                style: TextStyle(
                  fontSize: 16,
                  color: score >= shuffledConcepts.length / 2
                      ? Colors.green
                      : Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finish Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isGameMode ? 'Statistics Game' : 'Learn Statistics'),
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
          child: isGameMode ? _buildGameMode() : _buildLearningMode(),
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
            'Learn Statistics',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: concepts.length,
            itemBuilder: (context, index) {
              final concept = concepts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _handleConceptTap(concept, index),
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
                                concept.name,
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
                          concept.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        concept.visual,
                        const SizedBox(height: 16),
                        Text(
                          'Example: ${concept.example}',
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

  void _handleConceptTap(StatisticsConcept concept, int index) {
    _speakText('${concept.name}. ${concept.description}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(concept.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              concept.visual,
              const SizedBox(height: 16),
              Text(concept.description),
              const SizedBox(height: 16),
              Text('Example: ${concept.example}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: concept.options.map((option) => ElevatedButton(
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

  Widget _buildGameMode() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final isNarrowScreen = constraints.maxWidth < 360;
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 8.0 : 16.0,
            vertical: isSmallScreen ? 8.0 : 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Question ${currentQuestion + 1}/${shuffledConcepts.length}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: (currentQuestion + 1) / shuffledConcepts.length,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        minHeight: isSmallScreen ? 6 : 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Score: $score',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Main content fills the rest of the screen
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Question
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        shuffledConcepts[currentQuestion].description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 20),
                    // Visual
                    Container(
                      height: isSmallScreen ? 150 : 200,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: shuffledConcepts[currentQuestion].visual,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    // Answer options
                    ...shuffledConcepts[currentQuestion].options.map((option) {
                      final isSelected = selectedAnswer == option;
                      final isCorrect = showResult && option == shuffledConcepts[currentQuestion].example;
                      final isIncorrect = showResult && isSelected && option != shuffledConcepts[currentQuestion].example;

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: isSmallScreen ? 6 : 8,
                          left: isNarrowScreen ? 4 : 0,
                          right: isNarrowScreen ? 4 : 0,
                        ),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallScreen ? 8 : 12,
                                      horizontal: isSmallScreen ? 12 : 16,
                                    ),
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
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 12 : 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        if (isCorrect)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: isSmallScreen ? 16 : 20,
                                          )
                                        else if (isIncorrect)
                                          Icon(
                                            Icons.cancel,
                                            color: Colors.white,
                                            size: isSmallScreen ? 16 : 20,
                                          ),
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
              SizedBox(height: isSmallScreen ? 8 : 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 