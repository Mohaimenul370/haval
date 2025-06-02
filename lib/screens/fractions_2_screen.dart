import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/shared_preference_service.dart';
import 'package:flutter/services.dart';

// --- LESSON DATA ---
class Fractions2Lesson {
  final String title;
  final String description;
  final Widget visual;
  Fractions2Lesson({required this.title, required this.description, required this.visual});
}

// --- GAME DATA ---
class Fractions2GameQuestion {
  final String question;
  final Widget visual;
  final List<String> options;
  final String answer;
  Fractions2GameQuestion({required this.question, required this.visual, required this.options, required this.answer});
}

class Fractions2Screen extends StatefulWidget {
  final bool isGameMode;
  const Fractions2Screen({super.key, required this.isGameMode});
  @override
  State<Fractions2Screen> createState() => _Fractions2ScreenState();
}

class _Fractions2ScreenState extends State<Fractions2Screen> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late bool isGameMode;
  int score = 0;
  int currentQuestion = 0;
  String? selectedAnswer;
  bool showResult = false;
  bool isCorrect = false;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;
  late List<Fractions2GameQuestion> shuffledQuestions;

  @override
  void initState() {
    super.initState();
    isGameMode = widget.isGameMode;
    _initializeTts();
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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
      score = 0;
      currentQuestion = 0;
      selectedAnswer = null;
      showResult = false;
      shuffledQuestions = List.from(fractions2GameQuestions)..shuffle();
      for (var q in shuffledQuestions) {
        q.options.shuffle();
      }
      _scaleAnimationController.reset();
    });
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showResult = true;
      isCorrect = answer == shuffledQuestions[currentQuestion].answer;
    });
    _scaleAnimationController.forward().then((_) {
      _scaleAnimationController.reverse();
    });
    if (isCorrect) {
      score++;
      _speakText('Correct!');
    } else {
      _speakText('Try again!');
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (currentQuestion < shuffledQuestions.length - 1) {
        setState(() {
          currentQuestion++;
          selectedAnswer = null;
          showResult = false;
          _scaleAnimationController.reset();
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final percentage = (score / shuffledQuestions.length) * 100;
    final isPassed = percentage >= 50.0;
    SharedPreferenceService.saveGameProgress('fractions_2', score, shuffledQuestions.length);
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
                      Color(0xFF7B2FF2).withOpacity(0.1),
                      Color(0xFFF3EFFF).withOpacity(0.1),
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
                        color: Color(0xFF7B2FF2).withOpacity(0.7),
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
                            color: Color(0xFF7B2FF2),
                          ),
                        ),
                        Text(
                          ' / ${shuffledQuestions.length}',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF7B2FF2).withOpacity(0.7),
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
                        color: Color(0xFFf357a8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPassed
                    ? 'Great job! You\'ve mastered halves!'
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
                    label: const Text('Go to Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7B2FF2),
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
                        backgroundColor: Color(0xFFf357a8),
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF7B2FF2),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF7B2FF2),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGameMode ? 'Fractions 2 Practice' : 'Fractions 2 Lessons',
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
          child: widget.isGameMode ? _buildGameMode() : _buildLessonMode(),
        ),
      ),
    );
  }

  Widget _buildLessonMode() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fractions2Lessons.length,
      itemBuilder: (context, index) {
        final lesson = fractions2Lessons[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF7B2FF2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  lesson.visual,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameMode() {
    final q = shuffledQuestions[currentQuestion];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Question ${currentQuestion + 1} of ${shuffledQuestions.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B2FF2),
            ),
          ),
          const SizedBox(height: 16),
          q.visual,
          const SizedBox(height: 16),
          Text(
            q.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...q.options.map((option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: showResult ? null : () => _checkAnswer(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: option == selectedAnswer
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Color(0xFF7B2FF2).withOpacity(0.1),
                foregroundColor: Color(0xFF7B2FF2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
          const SizedBox(height: 24),
          if (showResult)
            Text(
              isCorrect ? 'Correct!' : 'Try again!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  // --- LESSON CONTENT ---
  List<Fractions2Lesson> get fractions2Lessons => [
    Fractions2Lesson(
      title: 'What is a Half?',
      description: 'A half is one of two equal parts of a whole. We write it as ½.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Row(
                children: [
                  Container(width: 30, height: 60, color: Color(0xFF7B2FF2)),
                  Container(width: 30, height: 60, color: Colors.transparent),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text('½', style: TextStyle(fontSize: 28, color: Color(0xFF7B2FF2), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Halves of Objects',
      description: 'When you cut something into two equal parts, each part is a half. Both parts must be the same size.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(width: 30, height: 40, color: Color(0xFF7B2FF2)),
                  Container(width: 30, height: 40, color: Colors.transparent),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 60, height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(width: 20, height: 40, color: Color(0xFF7B2FF2)),
                  Container(width: 40, height: 40, color: Colors.transparent),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Halves of Sets',
      description: 'Half of a set means splitting the group into two equal parts. For example, half of 8 apples is 4 apples.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.apple, color: i < 4 ? Color(0xFF7B2FF2) : Colors.grey, size: 28),
          )),
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Sharing Equally',
      description: 'When you share a set equally between two, each person gets half. For example, 6 cookies shared equally means each gets 3.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: List.generate(3, (i) => Icon(Icons.cookie, color: Color(0xFF7B2FF2), size: 28))),
            const SizedBox(width: 16),
            Row(children: List.generate(3, (i) => Icon(Icons.cookie, color: Colors.orange, size: 28))),
          ],
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Putting Halves Together',
      description: 'Two halves of the same shape or set make a whole. ½ + ½ = 1 whole.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30, height: 40,
              color: Color(0xFF7B2FF2),
            ),
            Container(
              width: 30, height: 40,
              color: Colors.orange,
            ),
            const SizedBox(width: 16),
            Container(
              width: 60, height: 40,
              color: Color(0xFF7B2FF2).withOpacity(0.5),
              child: null,
            ),
          ],
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Recording Halves',
      description: 'We can record halves using ½, the word "half", or by saying "equal" or "the same as".',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('½ = half = equal = the same as', style: TextStyle(fontSize: 18, color: Color(0xFF7B2FF2))),
          ],
        ),
      ),
    ),
    Fractions2Lesson(
      title: 'Real-life Halves',
      description: 'We use halves in real life: half a sandwich, half a jug of water, half of a group of apples.',
      visual: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lunch_dining, color: Color(0xFF7B2FF2), size: 32),
            const SizedBox(width: 12),
            Icon(Icons.local_drink, color: Colors.blue, size: 32),
            const SizedBox(width: 12),
            Icon(Icons.apple, color: Colors.red, size: 32),
          ],
        ),
      ),
    ),
  ];

  // --- GAME CONTENT ---
  List<Fractions2GameQuestion> get fractions2GameQuestions => [
    Fractions2GameQuestion(
      question: 'Which shape is split into two equal halves?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Option A (correct)
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 20, height: 40, color: Color(0xFF7B2FF2)),
                    Container(width: 20, height: 40, color: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('A'),
            ],
          ),
          const SizedBox(width: 16),
          // Option B
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 25, height: 40, color: Color(0xFF7B2FF2)),
                    Container(width: 15, height: 40, color: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('B'),
            ],
          ),
        ],
      ),
      options: ['A', 'B'],
      answer: 'A',
    ),
    Fractions2GameQuestion(
      question: 'How many apples in half the set?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(8, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(Icons.apple, color: Colors.red, size: 28),
        )),
      ),
      options: ['2', '3', '4', '5'],
      answer: '4',
    ),
    Fractions2GameQuestion(
      question: 'Jamil needs ½ of these eggs for his cakes. How many eggs does he need?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(Icons.egg, color: Colors.brown, size: 28),
        )),
      ),
      options: ['2', '3', '4', '6'],
      answer: '3',
    ),
    Fractions2GameQuestion(
      question: 'A farmer has 10 sheep and 2 fields. He puts ½ in each field. How many sheep in each field?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(10, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(Icons.pets, color: Colors.grey, size: 24),
        )),
      ),
      options: ['2', '4', '5', '10'],
      answer: '5',
    ),
    Fractions2GameQuestion(
      question: 'Which of these is NOT a half?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Option A (correct)
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 20, height: 40, color: Color(0xFF7B2FF2)),
                    Container(width: 20, height: 40, color: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('A'),
            ],
          ),
          const SizedBox(width: 16),
          // Option B (not a half)
          Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(width: 30, height: 40, color: Color(0xFF7B2FF2)),
                    Container(width: 10, height: 40, color: Colors.transparent),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('B'),
            ],
          ),
        ],
      ),
      options: ['A', 'B'],
      answer: 'B',
    ),
    Fractions2GameQuestion(
      question: 'If you have 6 cookies and share them equally, how many does each person get?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(Icons.cookie, color: Colors.orange, size: 28),
        )),
      ),
      options: ['2', '3', '4', '6'],
      answer: '3',
    ),
    Fractions2GameQuestion(
      question: 'Do these two halves make a whole?',
      visual: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 30, height: 40, color: Color(0xFF7B2FF2)),
          Container(width: 30, height: 40, color: Colors.orange),
        ],
      ),
      options: ['Yes', 'No'],
      answer: 'Yes',
    ),
  ];
}