import 'package:flutter/material.dart';
import '../widgets/global_app_bar.dart';
import 'numbers_to_10_screen.dart';

class NumbersTo10ChapterScreen extends StatelessWidget {
  const NumbersTo10ChapterScreen({super.key});

  Widget _buildModeCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
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
              Icon(
                icon,
                size: 48,
                color: const Color(0xFF7B2FF2),
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
            ),
            const SizedBox(height: 20),
            _buildModeCard(
              context,
              'Practice Game',
              Icons.videogame_asset,
              'Fun games to test your knowledge',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NumbersTo10Screen(isGameMode: true),
                  fullscreenDialog: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 