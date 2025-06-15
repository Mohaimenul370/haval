import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar and navigation bar color to purple
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF6A1B9A),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF6A1B9A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3E6FA),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  MenuCard(
                    icon: Icons.looks_one,
                    color: Colors.green,
                    title: 'Numbers',
                    subtitle: 'Learn to count',
                    onTap: () => Navigator.pushNamed(context, '/numbers'),
                  ),
                  MenuCard(
                    icon: Icons.category,
                    color: Colors.orange,
                    title: 'Shapes',
                    subtitle: 'Learn shapes',
                    onTap: () => Navigator.pushNamed(context, '/shapes'),
                  ),
                  MenuCard(
                    icon: Icons.pie_chart,
                    color: Colors.purple,
                    title: 'Fractions',
                    subtitle: 'Learn fractions',
                    onTap: () => Navigator.pushNamed(context, '/fractions'),
                  ),
                  MenuCard(
                    icon: Icons.analytics,
                    color: Colors.teal,
                    title: 'Learning Analysis',
                    subtitle: 'Track your progress',
                    onTap: () => Navigator.pushNamed(context, '/analysis'),
                  ),
                  MenuCard(
                    icon: Icons.settings,
                    color: Colors.red,
                    title: 'Settings',
                    subtitle: 'App settings',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).padding.bottom + 20,
        color: const Color(0xFF6A1B9A),
      ),
    );
  }
} 