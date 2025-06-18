import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kg_education_app/services/game_progress_service.dart';
import 'package:kg_education_app/services/shared_preference_service.dart';

class MathPlayScreen extends StatefulWidget {
  @override
  _MathPlayScreenState createState() => _MathPlayScreenState();
}

class _MathPlayScreenState extends State<MathPlayScreen> {
  double _completionPercentage = 0.0;
  Map<String, double> _chapterPercentages = {};
  Map<String, bool> _chapterCompleted = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    await SharedPreferenceService.initialize();
    int passed = 0;
    Map<String, double> chapterPercentages = {};
    Map<String, bool> chapterCompleted = {};
    for (final gameId in GameProgressService.requiredGames) {
      final percent = SharedPreferenceService.getGamePercentage(gameId);
      final completed = SharedPreferenceService.isGameCompleted(gameId);
      chapterPercentages[gameId] = percent;
      chapterCompleted[gameId] = completed;
      if (completed || percent >= 50.0) passed++;
    }
    setState(() {
      _completionPercentage = (passed / GameProgressService.requiredGames.length) * 100;
      _chapterPercentages = chapterPercentages;
      _chapterCompleted = chapterCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chapterNames = [
      'Fractions',
      'Number 20',
      'Numbers',
      'Shapes',
      'Fractions 2',
      'Measures',
      'Geometry',
      'Time',
      'Statistics',
      'Measures 2',
      'Positions 2',
      'Statistics 2',
      'Positions',
      'Time 2',
      'Geometry 2',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Play'),
        backgroundColor: const Color(0xFF9C27B0),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF9C27B0),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Complete all 15 chapters to unlock Math Play!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LinearProgressIndicator(
                  value: _completionPercentage / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${_completionPercentage.toStringAsFixed(1)}% Complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: GameProgressService.requiredGames.length,
                  itemBuilder: (context, index) {
                    final gameId = GameProgressService.requiredGames[index];
                    final chapterName = chapterNames[index];
                    final percent = _chapterPercentages[gameId] ?? 0.0;
                    final completed = _chapterCompleted[gameId] ?? false;
                    return ListTile(
                      leading: Icon(
                        completed || percent >= 50.0 ? Icons.check_circle : Icons.lock,
                        color: completed || percent >= 50.0 ? Colors.greenAccent : Colors.redAccent,
                      ),
                      title: Text(
                        chapterName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 