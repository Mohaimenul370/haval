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
  const Statistics2Screen({super.key});

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
  late Animation<double> _animation;

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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${shuffledConcepts[currentQuestion].example} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the statistic');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledConcepts.length - 1) {
        SharedPreferenceService.saveGameProgress('statistics_2', score, shuffledConcepts.length);
      }
    });
  }

  void _nextQuestion() async {
    setState(() {
      if (currentQuestion < shuffledConcepts.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        shuffledConcepts = List.from(concepts)..shuffle();
        for (var concept in shuffledConcepts) {
          concept.options.shuffle();
        }
        _animationController.reset();
        _animationController.forward();
        _speakText('Great job! Let\'s try another one!');
      } else {
        isGameMode = false;
        _speakText('Wow! You finished the game! You got $score out of ${shuffledConcepts.length} correct! You\'re amazing!');
        _showGameCompletionDialog();
      }
    });
    await _saveGameState();
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction
                  Text(
                    'Understanding Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let\'s learn about different statistical concepts:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Concepts
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
                          const Text('• Identify different statistical concepts'),
                          const Text('• Match concepts with their names'),
                          const Text('• Understand statistical properties'),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 600;
        final isNarrowScreen = constraints.maxWidth < 360;
        
        return SingleChildScrollView(
          child: Padding(
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
                SizedBox(height: isSmallScreen ? 12 : 20),
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
                    margin: EdgeInsets.only(
                      bottom: isSmallScreen ? 6 : 8,
                      left: isNarrowScreen ? 4 : 0,
                      right: isNarrowScreen ? 4 : 0,
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      elevation: isSelected ? 4 : 1,
                      child: InkWell(
                        onTap: showResult ? null : () => _checkAnswer(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 12,
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
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
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              if (isCorrect)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: isSmallScreen ? 16 : 20,
                                )
                              else if (isIncorrect)
                                Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Next button
                if (showResult)
                  Center(
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 24 : 32,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentQuestion < shuffledConcepts.length - 1 ? 'Next Question' : 'Finish Game',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: isSmallScreen ? 8 : 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveGameState() async {
    // Implementation of _saveGameState method
  }

  @override
  void dispose() {
    _animationController.dispose();
    flutterTts.stop();
    super.dispose();
  }
} 