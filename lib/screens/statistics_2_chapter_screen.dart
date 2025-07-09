import 'package:flutter/material.dart';
import '../services/shared_preference_service.dart';

class Statistics2ChapterScreen extends StatefulWidget {
  const Statistics2ChapterScreen({super.key});

  @override
  State<Statistics2ChapterScreen> createState() => _Statistics2ChapterScreenState();
}

class _Statistics2ChapterScreenState extends State<Statistics2ChapterScreen> {
  double? score;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    await SharedPreferenceService.initialize();
    setState(() {
      score = SharedPreferenceService.getGamePercentage('statistics_2');
      isLoading = false;
    });
  }

  Widget _buildModeCard(String title, String description, IconData icon, VoidCallback onTap, {bool showScore = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showScore && !isLoading) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FF2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(score ?? 0).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Color(0xFF7B2FF2),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(icon, size: 32, color: const Color(0xFF7B2FF2)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics 2'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
            ),
          ),
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildModeCard(
              'Learn Mode',
              'Study about Venn diagrams, Carroll diagrams, pictograms, lists, tables, and block graphs',
              Icons.book,
              () => Navigator.pushNamed(
                context,
                '/statistics_2/learn',
              ),
            ),
            _buildModeCard(
              'Game Mode',
              'Test your knowledge with fun questions about different ways to show data',
              Icons.games,
              () async {
                await Navigator.pushNamed(
                  context,
                  '/statistics_2/game',
                );
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