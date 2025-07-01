import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_card.dart';
import '../services/shared_preference_service.dart';
import '../services/game_progress_service.dart';
import '../widgets/lock_message_dialog.dart';
import '../widgets/global_app_bar.dart';
import 'dart:developer' as developer;
import 'play_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _canAccessMathPlay = false;
  Map<String, double> _gameScores = {};
  Map<String, bool> _gameCompleted = {};
  double _progressValue = 0.0;

  final List<Map<String, dynamic>> chapters = const [
    {
      'title': 'Math Play',
      'icon': Icons.videogame_asset,
      'route': '/math_play',
      'color': Color(0xFF9C27B0), // Purple
    },
    {
      'title': 'Numbers to 10',
      'icon': Icons.filter_1,
      'route': '/numbers_to_10',
      'color': Color(0xFF2196F3), // Blue
    },
    {
      'title': 'Number 20',
      'icon': Icons.remove,
      'route': '/numbers_to_20',
      'color': Color(0xFF2196F3), // Blue
    },
    {
      'title': 'Shapes',
      'icon': Icons.menu,
      'route': '/shapes',
      'color': Color(0xFFFF9800), // Orange
    },
    {
      'title': 'Fractions',
      'icon': Icons.pie_chart,
      'route': '/fractions',
      'color': Color(0xFFE91E63), // Pink
    },
    {
      'title': 'Fractions 2',
      'icon': Icons.pie_chart_outline,
      'route': '/fractions_2',
      'color': Color(0xFFE91E63), // Pink
    },
    {
      'title': 'Geometry',
      'icon': Icons.change_history,
      'route': '/geometry',
      'color': Color(0xFF2196F3), // Blue
    },
    {
      'title': 'Geometry 2',
      'icon': Icons.view_in_ar,
      'route': '/geometry_2',
      'color': Color(0xFF2196F3), // Blue
    },
    {
      'title': 'Measures',
      'icon': Icons.linear_scale,
      'route': '/measures',
      'color': Color(0xFF9C27B0), // Purple
    },
    {
      'title': 'Measures 2',
      'icon': Icons.straighten,
      'route': '/measures_2',
      'color': Color(0xFF9C27B0), // Purple
    },
    {
      'title': 'Positions',
      'icon': Icons.grid_on,
      'route': '/positions',
      'color': Color(0xFFFF9800), // Orange
    },
    {
      'title': 'Statistics',
      'icon': Icons.bar_chart,
      'route': '/statistics',
      'color': Color(0xFF4CAF50), // Green
    },
    {
      'title': 'Time',
      'icon': Icons.access_time,
      'route': '/time',
      'color': Color(0xFF00BCD4), // Cyan
    },
    {
      'title': 'Statistics 2',
      'icon': Icons.insert_chart_outlined,
      'route': '/statistics_2',
      'color': Color(0xFF4CAF50), // Green
    },
    {
      'title': 'Time 2',
      'icon': Icons.timer,
      'route': '/time_2',
      'color': Color(0xFF00BCD4), // Cyan
    },
    {
      'title': 'Position Patterns 2',
      'icon': Icons.grid_goldenratio,
      'route': '/position_patterns_2',
      'color': Color(0xFFFF9800), // Orange
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadGameScores();
  }

  Future<void> _loadGameScores() async {
    await SharedPreferenceService.initialize();
    setState(() {
      _gameScores.clear();
      _gameCompleted.clear();

      // Load scores for each chapter
      for (var chapter in chapters) {
        final route = chapter['route'].toString().substring(1);
        final score = SharedPreferenceService.getGamePercentage(route);
        final completed = SharedPreferenceService.isGameCompleted(route);
        _gameScores[route] = score;
        _gameCompleted[route] = completed;
      }

      // Get overall progress
      _progressValue = SharedPreferenceService.getOverallProgress();
      _canAccessMathPlay = _progressValue >= 100;
    });
  }

  void _showLockMessage(BuildContext context) {
    showLockMessageDialog(
      context,
      _progressValue,
      _gameScores,
      _gameCompleted,
      isFromMathPlay: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: GlobalAppBar(
        title: 'KG Education',
        showBackButton: false,
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar and Icons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  // Progress Bar
                  SizedBox(
                    width: screenWidth * 0.45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            height: 24,
                            width: double.infinity,
                            color: Colors.grey[200],
                          ),
                          // Progress
                          Container(
                            height: 24,
                            width: (screenWidth * 0.45) * (_progressValue / 100),
                            decoration: const BoxDecoration(
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          // Centered Text
                          Container(
                            height: 24,
                            width: screenWidth * 0.45,
                            alignment: Alignment.center,
                            child: Text(
                              '${_progressValue.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: _progressValue > 0 ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                shadows: _progressValue > 0 ? [
                                  const Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 2.0,
                                    color: Color(0x80000000),
                                  ),
                                ] : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Info Icon
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.info_outline, size: 16),
                      onPressed: () => _showLockMessage(context),
                    ),
                  ),
                  const Spacer(), // This will push the settings icon to the right
                  // Settings Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.settings, size: 20),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ],
              ),
            ),
            
            // Welcome Text
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Text(
                'Hello learners',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Let\'s Start',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                ),
              ),
            ),
            
            // Grid of Chapters
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return MenuCard(
                    title: chapter['title'],
                    icon: chapter['icon'],
                    color: chapter['color'],
                    onTap: () async {
                      await Navigator.pushNamed(context, chapter['route']);
                      // Reload scores when returning from chapter
                      _loadGameScores();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 