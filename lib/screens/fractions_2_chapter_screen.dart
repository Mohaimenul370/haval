import 'package:flutter/material.dart';
import 'fractions_2_screen.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class Fractions2ChapterScreen extends StatelessWidget {
  const Fractions2ChapterScreen({super.key});

  void _navigateToScreen(BuildContext context, String routeName) {
    try {
      developer.log('Navigating to $routeName');
      Navigator.pushNamed(context, routeName).then((_) {
        developer.log('Navigation completed for $routeName');
      }).catchError((error) {
        developer.log('Navigation error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error navigating to $routeName'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      developer.log('Navigation exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while navigating'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Color(0xFF7B2FF2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Learning Fractions 2',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
                'Fractions 2',
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
                'Learn Fractions 2',
                Icons.menu_book,
                'Interactive lessons and tutorials',
                () => _navigateToScreen(context, '/fractions_2_learn'),
              ),
              const SizedBox(height: 20),
              _buildModeCard(
                context,
                'Practice Game',
                Icons.videogame_asset,
                'Fun games to test your knowledge',
                () => _navigateToScreen(context, '/fractions_2_game'),
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