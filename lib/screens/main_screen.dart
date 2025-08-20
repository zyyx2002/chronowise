import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'dashboard_screen.dart';
import 'health_screen.dart';
import 'tasks_screen.dart';
import 'leaderboard_screen.dart';
import 'community_screen.dart';
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
    const LeaderboardScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '仪表板'),
    const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '健康'),
    const BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '任务'),
    const BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: '排行榜'),
    const BottomNavigationBarItem(icon: Icon(Icons.groups), label: '社区'),
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
    return Consumer<AppStateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
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
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: _bottomNavItems,
          ),
        );
      },
    );
  }
}
