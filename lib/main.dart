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
import 'screens/statistics_2_screen.dart';
import 'screens/time_2_screen.dart';
import 'screens/position_patterns_2_screen.dart';
import 'screens/play_screen.dart';
import 'screens/geometry_screen.dart';
import 'package:flutter/services.dart';
import 'package:kg_education_app/services/hive_service.dart';
import 'widgets/menu_card.dart';
import 'screens/settings_screen.dart';

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
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
          background: Colors.white,
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
        '/shapes': (context) => const ShapesScreen(),
        '/vocab': (context) => const AlphabetScreen(), // Replace with your vocab screen if different
        '/analysis': (context) => const StatisticsScreen(), // Replace with your analysis screen if different
        '/settings': (context) => const SettingsScreen(), // Replace with your settings screen if you have one
        '/fractions': (context) => const FractionsScreen(),
        '/measures': (context) => const MeasuresScreen(),
        '/time': (context) => const TimeScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/position_patterns_2': (context) => const PositionPatterns2Screen(),
        '/geometry': (context) => const GeometryScreen(),
        '/geometry_2': (context) => const Geometry2Screen(),
        '/time_2': (context) => const Time2Screen(),
        '/statistics_2': (context) => const Statistics2Screen(),
        '/positions': (context) => const PositionsScreen(),
        '/measures_2': (context) => const Measures2Screen(),
        '/play': (context) => const PlayScreen(),
        '/fractions_2': (context) => const Fractions2Screen(),
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

      // Calculate overall completion percentage
      final percentage = ((passedGames / requiredGames.length) * 100).toStringAsFixed(1);
      developer.log('Overall progress: $percentage% ($passedGames/${requiredGames.length} games)');
      
      // Check if Math Play should be accessible
      final canAccess = passedGames >= requiredGames.length;
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
    // Calculate progress for the progress bar
    final requiredGames = GameProgressService.requiredGames;
    final passedGames = requiredGames.where((gameId) {
      final percent = _gameScores[gameId] ?? 0.0;
      return percent >= 50.0;
    }).length;
    final progress = requiredGames.isNotEmpty ? passedGames / requiredGames.length : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Hello,\nCharmie',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Overall progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Overall Progress: ${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 20),
                                tooltip: 'Reset Progress',
                                onPressed: _resetProgress,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : Colors.orange),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SliverGrid(
                delegate: SliverChildListDelegate(
                  [
                    MenuCard(
                      icon: Icons.looks_one,
                      color: Colors.green,
                      title: 'Numbers',
                      subtitle: 'Números',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/numbers');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.menu_book,
                      color: Colors.orange,
                      title: 'Number 20',
                      subtitle: 'Número 20',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/numbers_to_20');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.category,
                      color: Colors.purple,
                      title: 'Shapes',
                      subtitle: 'Formas',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/shapes');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.analytics,
                      color: Colors.teal,
                      title: 'Statistics 2',
                      subtitle: 'Estadísticas 2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/statistics_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.calculate,
                      color: Colors.indigo,
                      title: 'Fractions',
                      subtitle: 'Fracciones',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/fractions');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.calculate,
                      color: Colors.deepPurpleAccent,
                      title: 'Fraction 2',
                      subtitle: 'Fracción 2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/fractions_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.straighten,
                      color: Colors.brown,
                      title: 'Measures',
                      subtitle: 'Medidas',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/measures');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.access_time,
                      color: Colors.deepOrange,
                      title: 'Time',
                      subtitle: 'Tiempo',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/time');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.bar_chart,
                      color: Colors.cyan,
                      title: 'Statistics',
                      subtitle: 'Estadísticas',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/statistics');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.pattern,
                      color: Colors.pink,
                      title: 'Patterns',
                      subtitle: 'Patrones',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/position_patterns_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.shape_line,
                      color: Colors.amber,
                      title: 'Geometry',
                      subtitle: 'Geometría',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/geometry');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.shape_line,
                      color: Colors.amberAccent,
                      title: 'Geometry-2',
                      subtitle: 'Geometría-2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/geometry_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.access_time_filled,
                      color: Colors.deepOrangeAccent,
                      title: 'Time-2',
                      subtitle: 'Tiempo-2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/time_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.navigation,
                      color: Colors.pinkAccent,
                      title: 'Position-2',
                      subtitle: 'Posición-2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/positions');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: Icons.straighten,
                      color: Colors.brown.shade700,
                      title: 'Measures-2',
                      subtitle: 'Medidas-2',
                      onTap: () async {
                        await Navigator.pushNamed(context, '/measures_2');
                        if (mounted) _loadScores();
                      },
                    ),
                    MenuCard(
                      icon: _canAccessMathPlay ? Icons.flag : Icons.lock,
                      color: Colors.black,
                      title: 'Final',
                      subtitle: 'Final',
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
                  childAspectRatio: 0.92,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 16),
                sliver: SliverToBoxAdapter(child: SizedBox()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
