import 'package:flutter/material.dart';
import '../screens/play_screen.dart';  // Import to access the chapters list
import '../services/shared_preference_service.dart';

String _formatChapterName(String key) {
  // Convert snake_case to Title Case and handle special cases
  final specialCases = {
    'numbers_to_10': 'Numbers to 10',
    'numbers_to_20': 'Numbers to 20',
    'position_patterns_2': 'Position Patterns 2',
    'fractions_2': 'Fractions 2',
    'geometry_2': 'Geometry 2',
    'measures_2': 'Measures 2',
    'statistics_2': 'Statistics 2',
    'time_2': 'Time 2',
  };

  return specialCases[key] ?? 
         key.split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
}

Future<void> showLockMessageDialog(
  BuildContext context,
  double progressValue,
  Map<String, double> gameScores,
  Map<String, bool> gameCompleted, {
  bool isFromMathPlay = false,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Create a list of all chapters with their scores
      final List<MapEntry<String, double>> sortedEntries = [];
      
      // First, add Numbers to 10 if it exists in scores
      if (gameScores.containsKey('numbers_to_10')) {
        sortedEntries.add(MapEntry('numbers_to_10', gameScores['numbers_to_10']!));
      } else {
        // If it doesn't exist in scores, add it with 0%
        sortedEntries.add(const MapEntry('numbers_to_10', 0.0));
      }

      // Then add all other chapters in order
      for (var chapter in SharedPreferenceService.allChapters) {
        if (chapter != 'numbers_to_10' && gameScores.containsKey(chapter)) {
          sortedEntries.add(MapEntry(chapter, gameScores[chapter]!));
        }
      }

      return WillPopScope(
        onWillPop: () async => false, // Prevent back button from closing dialog
        child: AlertDialog(
          title: const Text(
            'Chapter Progress',
            style: TextStyle(
              color: Color(0xFF9C27B0),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Progress
                Text(
                  'Overall Progress: ${progressValue.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Chapter Progress List
                ...sortedEntries.map((entry) {
                  final isCompleted = gameCompleted[entry.key] ?? false;
                  final score = entry.value;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _formatChapterName(entry.key),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: isCompleted || score >= 50.0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                // Reset Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldReset = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Progress'),
                          content: const Text(
                            'Are you sure you want to reset all progress? This cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'RESET',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldReset == true) {
                        await SharedPreferenceService.resetAllProgress();
                        if (context.mounted) {
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progress has been reset'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Reset All Progress'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Just close the dialog
              },
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    },
  );
} 