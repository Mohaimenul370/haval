import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';

class Statistic {
  final String name;
  final Widget visual;
  final String description;
  final List<String> options;

  Statistic({
    required this.name,
    required this.visual,
    required this.description,
    required this.options,
  });
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isGameMode = false;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Statistic> shuffledStatistics = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = true;

  final List<Statistic> statistics = [
    Statistic(
      name: 'Count',
      visual: _buildStatisticVisual('🔢', 'Count'),
      description: 'Count is how many of something there are',
      options: ['Count', 'Sort', 'Compare', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Sort',
      visual: _buildStatisticVisual('📊', 'Sort'),
      description: 'Sort is putting things in order',
      options: ['Sort', 'Count', 'Compare', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Compare',
      visual: _buildStatisticVisual('⚖️', 'Compare'),
      description: 'Compare is looking at how things are different',
      options: ['Compare', 'Count', 'Sort', 'Group', 'Match'],
    ),
    Statistic(
      name: 'Group',
      visual: _buildStatisticVisual('👥', 'Group'),
      description: 'Group is putting similar things together',
      options: ['Group', 'Count', 'Sort', 'Compare', 'Match'],
    ),
    Statistic(
      name: 'Match',
      visual: _buildStatisticVisual('🔄', 'Match'),
      description: 'Match is finding things that go together',
      options: ['Match', 'Count', 'Sort', 'Compare', 'Group'],
    ),
  ];

  static Widget _buildStatisticVisual(String emoji, String statistic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 48),
        ),
      ],
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
    _initializeStorage();
    isGameMode = false;
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _initializeStorage() async {
    try {
      await PreferenceService.initialize();
      await _loadGameState();
    } catch (e) {
      developer.log('Error initializing storage: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameState() async {
    try {
      final savedScore = await PreferenceService.getInt('statistics_score') ?? 0;
      final savedQuestion = await PreferenceService.getInt('statistics_question') ?? 0;

      setState(() {
        score = savedScore;
        currentQuestion = savedQuestion;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading game state: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGameState() async {
    try {
      await PreferenceService.setInt('statistics_score', score);
      await PreferenceService.setInt('statistics_question', currentQuestion);
      await PreferenceService.setBool('statistics_game_mode', isGameMode);
    } catch (e) {
      developer.log('Error saving game state: $e');
    }
  }

  void _startGame() {
    setState(() {
      isGameMode = true;
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledStatistics = List.from(statistics)..shuffle();
      for (var statistic in shuffledStatistics) {
        final options = List<String>.from(statistic.options);
        options.shuffle();
        statistic.options.clear();
        statistic.options.addAll(options);
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledStatistics[currentQuestion].name;
      if (isCorrect) {
        score++;
        _animationController.reset();
        _animationController.forward();
        _speakText('Yay! You got it right! ${shuffledStatistics[currentQuestion].name} is correct!');
      } else {
        _speakText('Oops! Try again! Think about the statistic');
      }

      // Save score if this is the last question
      if (currentQuestion == shuffledStatistics.length - 1) {
        SharedPreferenceService.saveGameProgress('statistics', score, shuffledStatistics.length);
      }
    });
  }

  void _nextQuestion() async {
    setState(() {
      if (currentQuestion < shuffledStatistics.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
        _animationController.reset();
        _animationController.forward();
        _speakText('Great job! Let\'s try another one!');
      } else {
        isGameMode = false;
        _speakText('Wow! You finished the game! You got $score out of ${shuffledStatistics.length} correct! You\'re amazing!');
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
                'Your Score: $score/${shuffledStatistics.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                score >= shuffledStatistics.length / 2
                    ? 'Great job! You passed the game!'
                    : 'Keep practicing! You can do better!',
                style: TextStyle(
                  fontSize: 16,
                  color: score >= shuffledStatistics.length / 2
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
                          'Question ${currentQuestion + 1}/${shuffledStatistics.length}',
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
                          value: (currentQuestion + 1) / shuffledStatistics.length,
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
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Text(
                //     shuffledStatistics[currentQuestion].description,
                //     style: TextStyle(
                //       fontSize: isSmallScreen ? 16 : 20,
                //       fontWeight: FontWeight.bold,
                //       color: Theme.of(context).colorScheme.secondary,
                //     ),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Visual
                Container(
                  height: isSmallScreen ? 150 : 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: shuffledStatistics[currentQuestion].visual,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                // Answer options
                ...shuffledStatistics[currentQuestion].options.map((option) {
                  final isSelected = selectedAnswer == option;
                  final isCorrect = showResult && option == shuffledStatistics[currentQuestion].name;
                  final isIncorrect = showResult && isSelected && option != shuffledStatistics[currentQuestion].name;
                  
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
                        currentQuestion < shuffledStatistics.length - 1 ? 'Next Question' : 'Finish Game',
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
                  ...statistics.map((concept) {
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

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
} 