import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer' as developer;
import '../services/preference_service.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
  final bool isGameMode;

  const StatisticsScreen({super.key, this.isGameMode = false});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  List<Statistic> gameQuestions = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  bool _isAnswering = false;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    isGameMode = widget.isGameMode;
    _initializeTts();

    if (isGameMode) {
      _startGame(); // Always start fresh in game mode
    } else {
      _initializeStorage(); // Only restore state in learning mode
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
      _isAnswering = false;

      // Deep copy statistics for gameQuestions and shuffle both questions and options
      gameQuestions = List<Statistic>.from(statistics.map((stat) =>
        Statistic(
          name: stat.name,
          visual: stat.visual,
          description: stat.description,
          options: List<String>.from(stat.options)..shuffle(),
        )
      ))..shuffle();
      // If you want to limit to 5 questions, uncomment the next line:
      // gameQuestions = gameQuestions.take(5).toList();

      _animationController.reset();
      _animationController.forward();
    });
  }

  void _checkAnswer(String answer) {
    if (_isAnswering) return;
    _isAnswering = true;

    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == gameQuestions[currentQuestion].name;
      if (isCorrect) score++;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

      if (isCorrect) {
      _speakText('Correct! ${gameQuestions[currentQuestion].name} is right!');
      } else {
      _speakText('Try again!');
      }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (currentQuestion < gameQuestions.length - 1) {
    setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showResult = false;
          _isAnswering = false;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          showResult = false;
          _isAnswering = false;
        });
        _showGameCompletionDialog();
      }
    });
  }

  void _showGameCompletionDialog() {
    final percentage = (score / gameQuestions.length) * 100;
    final isPassed = percentage >= 50.0;
    
    // Save score to SharedPreferenceService
    SharedPreferenceService.saveGameProgress('statistics', score, gameQuestions.length);
    
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
                'Score: $score/${gameQuestions.length} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                isPassed
                  ? 'You\'ve completed the Statistics practice!'
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
                    label: const Text('Main Menu'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B2FF2),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isGameMode ? 'Statistics Game' : 'Learn Statistics',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF7B2FF2),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xFF7B2FF2),
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
          child: isGameMode ? _buildGameMode() : _buildLearningMode(),
        ),
      ),
    );
  }

  Widget _buildGameMode() {
    if (gameQuestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentQ = gameQuestions[currentQuestion];
    final isSmallScreen = MediaQuery.of(context).size.height < 600;
    return Padding(
      padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
          LinearProgressIndicator(
            value: (currentQuestion + 1) / gameQuestions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7B2FF2)),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${currentQuestion + 1} of ${gameQuestions.length}',
            style: const TextStyle(fontSize: 16, color: Color(0xFF7B2FF2)),
                      ),
          const SizedBox(height: 16),
                      Expanded(
                        flex: 2,
            child: Center(child: currentQ.visual),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: currentQ.options.length,
              itemBuilder: (context, index) {
                final option = currentQ.options[index];
                final isSelected = selectedAnswer == option;
                final isCorrectAnswer = showResult && option == currentQ.name;
                final isWrongAnswer = showResult && isSelected && option != currentQ.name;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                      color: isCorrectAnswer
                          ? Colors.green.withOpacity(0.2)
                          : isWrongAnswer
                              ? Colors.red.withOpacity(0.2)
                              : isSelected
                                  ? const Color(0xFF7B2FF2).withOpacity(0.1)
                                  : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                        color: isCorrectAnswer
                            ? Colors.green
                            : isWrongAnswer
                                ? Colors.red
                                : isSelected
                                    ? const Color(0xFF7B2FF2)
                                    : Colors.grey,
                              width: 2,
                            ),
                          ),
                    child: ListTile(
                      onTap: showResult ? null : () => _checkAnswer(option),
                      title: Text(option, style: const TextStyle(color: Color(0xFF7B2FF2))),
                      trailing: showResult
                          ? Icon(
                              isCorrectAnswer
                                  ? Icons.check_circle
                                  : isWrongAnswer
                                      ? Icons.cancel
                                      : null,
                              color: isCorrectAnswer ? Colors.green : Colors.red,
                            )
                          : null,
                      ),
                    ),
                  );
              },
                  ),
          ),
              ],
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
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF7B2FF2),
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
                children: statistics.map((statistic) {
                    return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statistic.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B2FF2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(child: statistic.visual),
                          const SizedBox(height: 12),
                          Text(
                            statistic.description,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF7B2FF2)),
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

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
} 