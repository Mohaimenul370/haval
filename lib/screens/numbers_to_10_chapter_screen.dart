import 'package:flutter/material.dart';
import '../widgets/global_app_bar.dart';
import 'numbers_to_10_screen.dart';
import '../services/shared_preference_service.dart';

class NumbersTo10ChapterScreen extends StatefulWidget {
  const NumbersTo10ChapterScreen({super.key});

  @override
  State<NumbersTo10ChapterScreen> createState() => _NumbersTo10ChapterScreenState();
}

class _NumbersTo10ChapterScreenState extends State<NumbersTo10ChapterScreen> {
  double _score = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    await SharedPreferenceService.initialize();
    if (mounted) {
      setState(() {
        _score = SharedPreferenceService.getGamePercentage('numbers_to_10');
        _isLoading = false;
      });
    }
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap, {
    bool showScore = false,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: const Color(0xFF7B2FF2),
                  ),
                  if (showScore && !_isLoading) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _score >= 50 ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _score >= 50 ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B2FF2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
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
      appBar: const GlobalAppBar(
        title: 'Numbers to 10',
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3EFFF), Color(0xFFE3F0FF)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Text(
              'Choose your learning path',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7B2FF2),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            _buildModeCard(
              context,
              'Learn Numbers',
              Icons.menu_book,
              'Interactive lessons and tutorials',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NumbersTo10Screen(isGameMode: false),
                  fullscreenDialog: true,
                ),
              ),
              showScore: false,
            ),
            const SizedBox(height: 20),
            _buildModeCard(
              context,
              'Practice Game',
              Icons.videogame_asset,
              'Fun games to test your knowledge',
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NumbersTo10Screen(isGameMode: true),
                    fullscreenDialog: true,
                  ),
                );
                // Reload score after returning from game
                _loadScore();
              },
              showScore: true,
            ),
          ],
        ),
      ),
    );
  }
} 