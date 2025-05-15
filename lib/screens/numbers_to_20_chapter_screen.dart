import 'package:flutter/material.dart';
import 'numbers_to_20_screen.dart';
import 'dart:developer' as developer;

class NumbersTo20ChapterScreen extends StatelessWidget {
  const NumbersTo20ChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Numbers to 20',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Header Section with Animation
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Choose Your\nLearning Path',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a mode to begin your journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 60),
                // Mode Selection Cards
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeCard(
                        context,
                        'Learn Numbers',
                        Icons.school,
                        'Start your learning journey with interactive lessons',
                        Colors.blue,
                        () {
                          developer.log('Navigating to Learn Numbers mode');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NumbersTo20Screen(isGameMode: false),
                              fullscreenDialog: true,
                            ),
                          ).then((_) {
                            developer.log('Returned from Learn Numbers mode');
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildModeCard(
                        context,
                        'Practice Game',
                        Icons.games,
                        'Test your knowledge with fun challenges',
                        Colors.orange,
                        () {
                          developer.log('Navigating to Practice Game mode');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NumbersTo20Screen(isGameMode: true),
                              fullscreenDialog: true,
                            ),
                          ).then((_) {
                            developer.log('Returned from Practice Game mode');
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Footer with Decorative Element
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Choose a mode to begin your adventure!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
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
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          developer.log('Navigating to $title mode');
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container with Background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 24),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Add arrow indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 