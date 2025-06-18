import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> chapters = [
    {
      'title': 'Fractions',
      'icon': Icons.pie_chart,
      'route': '/fractions',
    },
    {
      'title': 'Numbers to 20',
      'icon': Icons.format_list_numbered,
      'route': '/numbers_to_20',
    },
    {
      'title': 'Numbers',
      'icon': Icons.numbers,
      'route': '/numbers',
    },
    {
      'title': 'Shapes',
      'icon': Icons.shape_line,
      'route': '/shapes',
    },
    {
      'title': 'Fractions 2',
      'icon': Icons.pie_chart_outline,
      'route': '/fractions_2',
    },
    {
      'title': 'Measures',
      'icon': Icons.straighten,
      'route': '/measures',
    },
    {
      'title': 'Geometry',
      'icon': Icons.architecture,
      'route': '/geometry',
    },
    {
      'title': 'Time',
      'icon': Icons.access_time,
      'route': '/time',
    },
    {
      'title': 'Statistics',
      'icon': Icons.bar_chart,
      'route': '/statistics',
    },
    {
      'title': 'Measures 2',
      'icon': Icons.straighten_outlined,
      'route': '/measures_2',
    },
    {
      'title': 'Positions 2',
      'icon': Icons.grid_view,
      'route': '/positions_2',
    },
    {
      'title': 'Statistics 2',
      'icon': Icons.bar_chart_outlined,
      'route': '/statistics_2',
    },
    {
      'title': 'Positions',
      'icon': Icons.grid_4x4,
      'route': '/positions',
    },
    {
      'title': 'Time 2',
      'icon': Icons.timer,
      'route': '/time_2',
    },
    {
      'title': 'Geometry 2',
      'icon': Icons.architecture_outlined,
      'route': '/geometry_2',
    },
  ];

  List<List<Map<String, dynamic>>> get chapterGroups {
    final int itemsPerPage = 15;
    final List<List<Map<String, dynamic>>> groups = [];
    
    for (var i = 0; i < chapters.length; i += itemsPerPage) {
      groups.add(
        chapters.sublist(
          i,
          i + itemsPerPage > chapters.length ? chapters.length : i + itemsPerPage,
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: chapterGroups.length,
              itemBuilder: (context, pageIndex) {
                final chapters = chapterGroups[pageIndex];
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return ChapterCard(
                      chapter: chapter,
                      onTap: () => Navigator.pushNamed(context, chapter['route']),
                    );
                  },
                );
              },
            ),
          ),
          if (chapterGroups.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  chapterGroups.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final VoidCallback onTap;

  const ChapterCard({
    Key? key,
    required this.chapter,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              chapter['icon'] as IconData,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              chapter['title'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 