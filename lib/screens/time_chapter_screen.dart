import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../main.dart';

class TimeChapterScreen extends StatelessWidget {
  const TimeChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Learning Time',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B2FF2), Color(0xFFf357a8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B2FF2),
                  ),
                ),
                const SizedBox(height: 8),
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
                  'Learn Time',
                  Icons.menu_book,
                  'Interactive lessons and tutorials',
                  () => Navigator.pushNamed(context, '/time_learn'),
                ),
                const SizedBox(height: 20),
                _buildModeCard(
                  context,
                  'Practice Game',
                  Icons.videogame_asset,
                  'Fun games to test your knowledge',
                  () => Navigator.pushNamed(context, '/time_game'),
                ),
                const Spacer(),
                Opacity(
                  opacity: 0.08,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(Icons.square, size: 100, color: Color(0xFF7B2FF2)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FF2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Color(0xFF7B2FF2), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF7B2FF2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7B2FF2),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF7B2FF2), size: 18),
            ],
          ),
        ),
      ),
    );
  }
} 