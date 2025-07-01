import 'package:flutter/material.dart';

class Statistics2ChapterScreen extends StatelessWidget {
  const Statistics2ChapterScreen({super.key});

  Widget _buildModeCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(icon, size: 32, color: Colors.purple),
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
              () => Navigator.pushNamed(
                context,
                '/statistics_2/game',
              ),
            ),
          ],
        ),
      ),
    );
  }
} 