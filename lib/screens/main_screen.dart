import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';
import 'dashboard_screen.dart';
import 'health_screen.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HealthScreen(),
    const TasksScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '仪表盘'),
    const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '健康'),
    const BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: '任务'),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: _bottomNavItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton:
          _currentIndex ==
              2 // 在任务页面显示FAB
          ? FloatingActionButton(
              onPressed: () {
                _showAddTaskDialog(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // 这里可以添加自定义任务的功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('自定义任务功能即将推出')));
  }
}
