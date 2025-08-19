import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class AppStateProvider extends ChangeNotifier {
  // 页面状态
  String _currentPage = 'onboarding';
  int _onboardingStep = 1;

  // 用户数据
  UserProfile _userProfile = UserProfile();

  // 打卡状态
  final Map<String, bool> _checkins = {
    'water': true,
    'exercise': false,
    'sleep': false,
    'meditation': true,
    'nutrition': false,
    'skincare': true,
    'supplement': false,
    'social': false,
  };

  // 计时器状态
  String? _activeTimer;
  int _timerSeconds = 0;

  // 成就数据
  final List<Achievement> _achievements = [
    Achievement(
        id: 1,
        name: '初来乍到',
        desc: '完成注册',
        icon: '🎉',
        unlocked: true,
        date: '2024-05-01'),
    Achievement(
        id: 2,
        name: '坚持一周',
        desc: '连续打卡7天',
        icon: '📅',
        unlocked: true,
        date: '2024-05-08'),
    Achievement(
        id: 3,
        name: '运动达人',
        desc: '累计运动30小时',
        icon: '🏃',
        unlocked: true,
        date: '2024-05-15'),
    Achievement(
        id: 4, name: '冥想大师', desc: '累计冥想100次', icon: '🧘', unlocked: false),
    Achievement(
        id: 5, name: '健康先锋', desc: '连续打卡30天', icon: '🏆', unlocked: false),
    Achievement(
        id: 6, name: '抗衰专家', desc: '生物年龄降低5岁', icon: '⭐', unlocked: false),
  ];

  // 排行榜数据
  List<LeaderboardUser> get leaderboard => [
        LeaderboardUser(rank: 1, name: '健康达人小王', smartAge: 28, coins: 2580),
        LeaderboardUser(rank: 2, name: '养生专家', smartAge: 30, coins: 2340),
        LeaderboardUser(rank: 3, name: '抗衰先锋', smartAge: 29, coins: 2180),
        LeaderboardUser(
            rank: 4, name: '你', smartAge: 32, coins: _userProfile.smartCoins),
        LeaderboardUser(rank: 5, name: '活力青春', smartAge: 33, coins: 1920),
      ];

  // Getters
  String get currentPage => _currentPage;
  int get onboardingStep => _onboardingStep;
  UserProfile get userProfile => _userProfile;
  Map<String, bool> get checkins => _checkins;
  String? get activeTimer => _activeTimer;
  int get timerSeconds => _timerSeconds;
  List<Achievement> get achievements => _achievements;

  // 任务配置
  Map<String, Map<String, dynamic>> get taskConfig => {
        'water': {
          'icon': '💧',
          'text': '喝水8杯',
          'desc': '保持身体水分平衡',
          'reward': 10,
          'color': 'blue'
        },
        'exercise': {
          'icon': '🏃',
          'text': '运动30分钟',
          'desc': '提升心肺功能',
          'reward': 25,
          'color': 'green'
        },
        'sleep': {
          'icon': '😴',
          'text': '睡前1小时不看手机',
          'desc': '改善睡眠质量',
          'reward': 20,
          'color': 'purple'
        },
        'meditation': {
          'icon': '🧘',
          'text': '冥想10分钟',
          'desc': '减压放松心情',
          'reward': 20,
          'color': 'indigo'
        },
        'nutrition': {
          'icon': '🥗',
          'text': '吃够5种蔬果',
          'desc': '补充维生素矿物质',
          'reward': 15,
          'color': 'orange'
        },
        'skincare': {
          'icon': '✨',
          'text': '护肤保养',
          'desc': '延缓皮肤衰老',
          'reward': 10,
          'color': 'pink'
        },
        'supplement': {
          'icon': '💊',
          'text': '服用营养补剂',
          'desc': '补充必需营养素',
          'reward': 15,
          'color': 'red'
        },
        'social': {
          'icon': '👥',
          'text': '社交互动',
          'desc': '保持心理健康',
          'reward': 10,
          'color': 'yellow'
        },
      };

  // 页面导航方法
  void setCurrentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userProfile.name = name;
    notifyListeners();
  }

  void updateUserAge(String age) {
    _userProfile.age = age;
    notifyListeners();
  }

  // 打卡相关方法
  void toggleCheckin(String taskKey) {
    _checkins[taskKey] = !_checkins[taskKey]!;

    if (_checkins[taskKey]!) {
      final reward = taskConfig[taskKey]!['reward'] as int;
      _userProfile.smartCoins += reward;
      _userProfile.completedTasks += 1;
      _userProfile.totalPoints += reward;
    } else {
      final reward = taskConfig[taskKey]!['reward'] as int;
      _userProfile.smartCoins -= reward;
      _userProfile.completedTasks -= 1;
      _userProfile.totalPoints -= reward;
    }

    notifyListeners();
  }

  // 计时器方法
  void toggleTimer(String taskKey) {
    if (_activeTimer == taskKey) {
      _activeTimer = null;
    } else {
      _activeTimer = taskKey;
      _timerSeconds = 0;
    }
    notifyListeners();
  }

  void incrementTimer() {
    _timerSeconds++;
    notifyListeners();
  }

  void resetTimer() {
    _timerSeconds = 0;
    notifyListeners();
  }

  // 格式化时间
  String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // 获取激励文字
  String getMotivationalText() {
    final completionRate =
        _userProfile.completedTasks / _userProfile.dailyTasks;

    if (completionRate >= 1.0) {
      return '🎉 太棒了！今天所有任务都完成了！';
    } else if (completionRate >= 0.75) {
      return '💪 做得很好！再坚持一下就完成了！';
    } else if (completionRate >= 0.5) {
      return '🚀 进展不错！继续加油！';
    } else if (completionRate > 0) {
      return '🌱 很好的开始！一步一步来！';
    } else {
      return '✨ 新的一天开始了，让我们一起变得更年轻！';
    }
  }
}
