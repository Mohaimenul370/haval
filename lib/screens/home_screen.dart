import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_card.dart';
import 'main_menu_screen.dart';

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
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return MenuCard(
                    icon: chapter['icon'] as IconData,
                    color: _getColorForIndex(index),
                    title: chapter['title'] as String,
                    subtitle: 'Learn ${chapter['title']}',
                    onTap: () => Navigator.pushNamed(context, chapter['route'] as String),
                  );
                },
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

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.blue,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lime,
      Colors.deepOrange,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }
} 