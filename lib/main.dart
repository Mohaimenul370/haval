import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'services/game_progress_service.dart';
import 'services/shared_preference_service.dart';
import 'screens/alphabet_screen.dart';
import 'screens/numbers_screen.dart';
import 'screens/games_screen.dart';
import 'screens/shapes_screen.dart';
import 'screens/fractions_screen.dart';
import 'screens/fractions_2_screen.dart';
import 'screens/measures_screen.dart';
import 'screens/numbers_to_10_screen.dart';
import 'screens/numbers_to_10_chapter_screen.dart';
import 'screens/numbers_to_20_screen.dart';
import 'screens/numbers_to_20_chapter_screen.dart';
import 'screens/positions_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/time_screen.dart';
import 'screens/geometry_2_screen.dart';
import 'screens/measures_2_screen.dart';
import 'screens/statistics_2_chapter_screen.dart';
import 'screens/time_2_screen.dart';
import 'screens/position_patterns_2_screen.dart';
import 'screens/play_screen.dart';
import 'screens/geometry_screen.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/services/hive_service.dart';
import 'widgets/menu_card.dart';
import 'screens/settings_screen.dart';
import 'screens/shapes_chapter_screen.dart';
import 'screens/fractions_chapter_screen.dart';
import 'screens/fractions_2_chapter_screen.dart';
import 'screens/measures_chapter_screen.dart';
import 'screens/time_chapter_screen.dart';
import 'screens/statistics_chapter_screen.dart';
import 'screens/positions_chapter_screen.dart';
import 'screens/geometry_chapter_screen.dart';
import 'screens/geometry_2_chapter_screen.dart';
import 'screens/time_2_chapter_screen.dart';
import 'screens/measures_2_chapter_screen.dart';
import 'screens/position_patterns_2_chapter_screen.dart';

void main() async {
  try {
    // Initialize Flutter binding first
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive
    await HiveService.initialize();
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style globally
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6A1B9A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF6A1B9A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    // Log start of initialization
    print('Starting application initialization...');
    
    // Initialize SharedPreferenceService
    print('Initializing SharedPreferenceService...');
    await SharedPreferenceService.initialize();
    print('SharedPreferenceService initialized successfully');
    
    // For backward compatibility, also initialize GameProgressService
    print('Initializing GameProgressService for backward compatibility...');
    await GameProgressService.initialize();
    print('GameProgressService initialized successfully');
    
    // Debug: Print all stored values to verify initialization
    SharedPreferenceService.debugPrintAllValues();
    
    // Start the app
    print('Starting application...');
    runApp(const MyApp());
  } catch (e) {
    // Critical error handling
    print('CRITICAL ERROR during app initialization: $e');
    // Still try to run the app even if initialization failed
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KG Education App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          primary: const Color(0xFF6A1B9A),
          secondary: Colors.orange,
          background: const Color(0xFFF3E6FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        fontFamily: 'Comic Sans MS',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/numbers': (context) => const NumbersTo10ChapterScreen(),
        '/numbers_to_10_learn': (context) => const NumbersTo10Screen(isGameMode: false),
        '/numbers_to_10_game': (context) => const NumbersTo10Screen(isGameMode: true),
        '/numbers_to_20': (context) => const NumbersTo20ChapterScreen(),
        '/numbers_to_20_learn': (context) => const NumbersTo20Screen(isGameMode: false),
        '/numbers_to_20_game': (context) => const NumbersTo20Screen(isGameMode: true),
        '/shapes': (context) => const ShapesChapterScreen(),
        '/vocab': (context) => const AlphabetScreen(),
        '/analysis': (context) => const StatisticsChapterScreen(),
        '/statistics_learn': (context) => const StatisticsScreen(isGameMode: false),
        '/statistics_game': (context) => const StatisticsScreen(isGameMode: true),
        '/settings': (context) => const SettingsScreen(),
        '/fractions': (context) => const FractionsChapterScreen(),
        '/fractions_2': (context) => const Fractions2ChapterScreen(),
        '/fractions_2_learn': (context) => const Fractions2Screen(isGameMode: false),
        '/fractions_2_game': (context) => const Fractions2Screen(isGameMode: true),
        '/measures': (context) => const MeasuresChapterScreen(),
        '/measures_learn': (context) => const MeasuresScreen(isGameMode: false),
        '/measures_game': (context) => const MeasuresScreen(isGameMode: true),
        '/time': (context) => const TimeChapterScreen(),
        '/time_learn': (context) => const TimeScreen(isGameMode: false),
        '/time_game': (context) => const TimeScreen(isGameMode: true),
        '/position_patterns_2': (context) => const PositionPatterns2ChapterScreen(),
        '/position_patterns_2/learn': (context) => const PositionPatterns2Screen(isGameMode: false),
        '/position_patterns_2/game': (context) => const PositionPatterns2Screen(isGameMode: true),
        '/geometry': (context) => const GeometryChapterScreen(),
        '/geometry/learn': (context) => const GeometryScreen(isGameMode: false),
        '/geometry/game': (context) => const GeometryScreen(isGameMode: true),
        '/time_2': (context) => const Time2ChapterScreen(),
        '/time_2/learn': (context) => const Time2Screen(isGameMode: false),
        '/time_2/game': (context) => const Time2Screen(isGameMode: true),
        '/statistics_2': (context) => const Statistics2ChapterScreen(),
        '/positions': (context) => const PositionsChapterScreen(),
        '/positions/learn': (context) => const PositionsScreen(isGameMode: false),
        '/positions/game': (context) => const PositionsScreen(isGameMode: true),
        '/measures_2': (context) => const Measures2ChapterScreen(),
        '/measures_2/learn': (context) => const Measures2Screen(isGameMode: false),
        '/measures_2/game': (context) => const Measures2Screen(isGameMode: true),
        '/play': (context) => const PlayScreen(),
        '/geometry_2': (context) => const Geometry2ChapterScreen(),
        '/geometry_2/learn': (context) => const Geometry2Screen(isGameMode: false),
        '/geometry_2/game': (context) => const Geometry2Screen(isGameMode: true),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/statistics') {
          final args = settings.arguments as Map<String, dynamic>?;
          final isGameMode = args != null && args['isGameMode'] == true;
          return MaterialPageRoute(
            builder: (context) => StatisticsScreen(isGameMode: isGameMode),
          );
        }
        // fallback to default
        return null;
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _canAccessMathPlay = false;
  Map<String, double> _gameScores = {};
  Map<String, bool> _gameCompleted = {};
  String _mathPlayPercentage = "0.0";

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScores();
  }

  Future<void> _loadScores() async {
    developer.log('Loading scores in HomeScreen...');
    try {
      // Initialize SharedPreferenceService explicitly if not done already
      await SharedPreferenceService.initialize();
      
      // Get list of all games with saved progress
      final List<String> gameIds = SharedPreferenceService.getAllGameIds();
      developer.log('Found ${gameIds.length} games with saved progress');
      
      // Create maps to store scores and completion status
      Map<String, double> scores = {};
      Map<String, bool> completed = {};
      
      // For each required game, check if there's saved progress
      List<String> requiredGames = GameProgressService.requiredGames;
      // Remove 'geometry_2' from required games if it exists
      requiredGames.remove('geometry_2');
      int passedGames = 0;
      
      for (String gameId in requiredGames) {
        // Get game progress data
        final score = SharedPreferenceService.getGameScore(gameId);
        final totalQuestions = SharedPreferenceService.getTotalQuestions(gameId);
        final percentage = SharedPreferenceService.getGamePercentage(gameId);
        final isCompleted = SharedPreferenceService.isGameCompleted(gameId);
        
        // Store in maps
        scores[gameId] = percentage;
        completed[gameId] = isCompleted;
        
        // Count passed games
        if (isCompleted) {
          passedGames++;
          developer.log('$gameId: PASSED (completed)');
        } else if (percentage >= 50.0) {
          // Consider games with score ≥ 50% as passed even if not marked as completed
          passedGames++;
          developer.log('$gameId: PASSED (score $percentage%)');
        } else {
          developer.log('$gameId: NOT PASSED (score $percentage%)');
        }
      }

      // Calculate overall completion percentage (now out of 14 chapters)
      final percentage = ((passedGames / 14) * 100).toStringAsFixed(1);
      developer.log('Overall progress: $percentage% ($passedGames/14 games)');
      
      // Check if Math Play should be accessible
      final canAccess = passedGames >= 14;
      developer.log('Math Play access: ${canAccess ? 'GRANTED' : 'DENIED'}');

      // Update UI if component is still mounted
      if (mounted) {
        setState(() {
          _gameScores = scores;
          _gameCompleted = completed;
          _mathPlayPercentage = percentage;
          _canAccessMathPlay = canAccess;
        });
        developer.log('Scores and completion status updated in UI successfully');
      }
    } catch (e) {
      developer.log('Error loading scores: $e');
      // Set default values in case of error
      if (mounted) {
        setState(() {
          _canAccessMathPlay = false;
          _gameScores = {};
          _gameCompleted = {};
          _mathPlayPercentage = "0.0";
        });
      }
    }
  }

  void _showLockMessage(BuildContext context) {
    developer.log('Showing Math Play lock message...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Math Play Locked'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To unlock Math Play, you need to score at least 50% in all game sections. Current progress: $_mathPlayPercentage%',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your current progress:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._gameScores.entries.map((entry) {
                  // Skip the non-existent "Numbers to 20 2" module
                  if (entry.key == 'numbers_to_20_2') return const SizedBox.shrink();
                  
                  final gameName = entry.key.replaceAll('_', ' ').toUpperCase();
                  final score = entry.value.toStringAsFixed(1);
                  final isComplete = _gameCompleted[entry.key] ?? false;
                  developer.log('Displaying progress for $gameName: $score%, completed: $isComplete');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isComplete ? Icons.check_circle : Icons.warning,
                          color: isComplete ? Colors.green : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gameName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '$score%',
                          style: TextStyle(
                            color: isComplete ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetProgress() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text('If you click reset, all your progress will be lost. Are you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Reset'),
          ),
        ],
      ),
    );
    if (shouldReset == true) {
      for (final gameId in GameProgressService.requiredGames) {
        await SharedPreferenceService.saveGameProgress(gameId, 0, 1);
      }
      await SharedPreferenceService.saveGameProgress('play', 0, 1);
      if (mounted) _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiredGames = GameProgressService.requiredGames;
    final passedGames = requiredGames.where((gameId) {
      final percent = _gameScores[gameId] ?? 0.0;
      return percent >= 50.0;
    }).length;
    final progress = requiredGames.isNotEmpty ? passedGames / requiredGames.length : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'KG Education',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Row for progress bar, info button, and settings icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1B9A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Info button
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Color(0xFF6A1B9A), size: 18),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Info'),
                            content: const Text('Pass all the chapter to unlock the Math Play'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  // Settings icon at top right, aligned with row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.grey),
                      onPressed: _resetProgress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Home screen title below progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello learners',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's Start",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Main content below
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox()),
                    SliverGrid(
                      delegate: SliverChildListDelegate(
                        [
                          _buildChapterCard(
                            context,
                            icon: Icons.pie_chart,
                            label: 'Fractions',
                            color: const Color(0xFFE91E63),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/fractions');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.remove,
                            label: 'Number 20',
                            color: const Color(0xFF2196F3),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/numbers_to_20');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.clear,
                            label: 'Numbers',
                            color: const Color(0xFF4CAF50),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/numbers');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.horizontal_split,
                            label: 'Shapes',
                            color: const Color(0xFFFF9800),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/shapes');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.pie_chart,
                            label: 'Fractions 2',
                            color: const Color(0xFFE91E63),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/fractions_2');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.linear_scale,
                            label: 'Measures',
                            color: const Color(0xFF9C27B0),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/measures');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.category,
                            label: 'Geometry',
                            color: const Color(0xFF2196F3),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/geometry');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.access_time,
                            label: 'Time',
                            color: const Color(0xFF00BCD4),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/time');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.bar_chart,
                            label: 'Statistics',
                            color: const Color(0xFF8BC34A),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/analysis');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.straighten,
                            label: 'Measures 2',
                            color: const Color(0xFFFF9800),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/measures_2');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.pattern,
                            label: 'Positions 2',
                            color: const Color(0xFFE91E63),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/position_patterns_2');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.bar_chart,
                            label: 'Statistics 2',
                            color: const Color(0xFF00BCD4),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/statistics_2');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.dataset,
                            label: 'Positions',
                            color: const Color(0xFF4CAF50),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/positions');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: Icons.text_snippet,
                            label: 'Time 2',
                            color: const Color(0xFF9C27B0),
                            onTap: () async {
                              await Navigator.pushNamed(context, '/time_2');
                              if (mounted) _loadScores();
                            },
                          ),
                          _buildChapterCard(
                            context,
                            icon: _canAccessMathPlay ? Icons.emoji_events : Icons.lock,
                            label: 'Math Play',
                            color: const Color(0xFF673AB7),
                            onTap: () {
                              if (_canAccessMathPlay) {
                                Navigator.pushNamed(context, '/play');
                              } else {
                                _showLockMessage(context);
                              }
                            },
                          ),
                        ],
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 16),
                      sliver: SliverToBoxAdapter(child: SizedBox()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChapterCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
