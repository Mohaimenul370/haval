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
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'KG Education',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF6A1B9A),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF6A1B9A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Hello,\nCharmie',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                      subtitle: 'Números',
                      onTap: () => Navigator.pushNamed(context, '/numbers'),
                    ),
                    MenuCard(
                      icon: Icons.menu_book,
                      color: Colors.orange,
                      title: 'Reading',
                      subtitle: 'Leer',
                      onTap: () => Navigator.pushNamed(context, '/reading'),
                    ),
                    MenuCard(
                      icon: Icons.category,
                      color: Colors.purple,
                      title: 'Shapes',
                      subtitle: 'Formas',
                      onTap: () => Navigator.pushNamed(context, '/shapes'),
                    ),
                    MenuCard(
                      icon: Icons.abc,
                      color: Colors.blue,
                      title: 'Vocab & Letters',
                      subtitle: 'Vocabulario & Letras',
                      onTap: () => Navigator.pushNamed(context, '/vocab'),
                    ),
                    MenuCard(
                      icon: Icons.analytics,
                      color: Colors.teal,
                      title: 'Learning Analysis',
                      subtitle: 'Gestión de aprendizaje',
                      onTap: () => Navigator.pushNamed(context, '/analysis'),
                    ),
                    MenuCard(
                      icon: Icons.settings,
                      color: Colors.red,
                      title: 'Settings',
                      subtitle: 'Ajustes de aplicación',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).padding.bottom + 20,
        color: const Color(0xFF6A1B9A),
      ),
    );
  }
} 