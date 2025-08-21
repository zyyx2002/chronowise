import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AppStateProvider extends ChangeNotifier {
  // === 核心状态 ===
  bool _isLoading = true;
  bool _hasUser = false;
  User? _currentUser; // 🆕 使用新的User模型

  // === 健康数据 ===
  int _todaySteps = 0;
  double _todayWater = 0.0;
  int _todaySleep = 0;
  int _todayExercise = 0;
  int _todayHealthScore = 0;

  // === 任务数据 ===
  final Map<String, bool> _todayCheckins = {
    'water': false,
    'exercise': false,
    'sleep': false,
    'meditation': false,
    'nutrition': false,
    'skincare': false,
    'supplement': false,
    'social': false,
  };

  // === 积分系统 ===
  List<PointTransaction> _pointHistory = [];

  // === 页面状态 ===
  String _currentPage = 'welcome';
  int _onboardingStep = 1;

  // === 数据库服务 ===
  final DatabaseService _dbService = DatabaseService();

  // === 成就系统 ===
  final List<Achievement> _achievements = [
    Achievement(
      id: 1,
      name: '初来乍到',
      desc: '完成注册',
      icon: '🎉',
      unlocked: true,
      date: '2024-05-01',
    ),
    Achievement(
      id: 2,
      name: '坚持一周',
      desc: '连续打卡7天',
      icon: '📅',
      unlocked: true,
      date: '2024-05-08',
    ),
    Achievement(
      id: 3,
      name: '运动达人',
      desc: '累计运动30小时',
      icon: '🏃',
      unlocked: true,
      date: '2024-05-15',
    ),
    Achievement(
      id: 4,
      name: '冥想大师',
      desc: '累计冥想100次',
      icon: '🧘',
      unlocked: false,
    ),
    Achievement(
      id: 5,
      name: '健康先锋',
      desc: '连续打卡30天',
      icon: '🏆',
      unlocked: false,
    ),
    Achievement(
      id: 6,
      name: '抗衰专家',
      desc: '生物年龄降低5岁',
      icon: '⭐',
      unlocked: false,
    ),
  ];

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasUser => _hasUser;
  User? get currentUser => _currentUser; // 🆕 新的getter
  String get currentPage => _currentPage;
  int get onboardingStep => _onboardingStep;

  // 健康数据
  int get todaySteps => _todaySteps;
  double get todayWater => _todayWater;
  int get todaySleep => _todaySleep;
  int get todayExercise => _todayExercise;
  int get todayHealthScore => _todayHealthScore;

  // 任务数据
  Map<String, bool> get todayCheckins => _todayCheckins;
  int get completedTasksToday => _todayCheckins.values.where((v) => v).length;
  int get totalTasksToday => _todayCheckins.length;
  double get completionRate => completedTasksToday / totalTasksToday;

  // 积分数据
  int get totalPoints => _currentUser?.totalPoints ?? 0; // 🆕 从User模型获取
  List<PointTransaction> get pointHistory => _pointHistory;

  // 成就数据
  List<Achievement> get achievements => _achievements;

  // 排行榜数据
  List<LeaderboardUser> get leaderboard => [
    LeaderboardUser(rank: 1, name: '健康达人小王', smartAge: 28, coins: 2580),
    LeaderboardUser(rank: 2, name: '养生专家', smartAge: 30, coins: 2340),
    LeaderboardUser(rank: 3, name: '抗衰先锋', smartAge: 29, coins: 2180),
    LeaderboardUser(
      rank: 4,
      name: '你',
      smartAge: _currentUser?.biologicalAge ?? 32, // 🆕 从User模型获取
      coins: _currentUser?.smartCoins ?? 120, // 🆕 从User模型获取
    ),
    LeaderboardUser(rank: 5, name: '活力青春', smartAge: 33, coins: 1920),
  ];

  // === 模拟任务数据 ===
  List<TaskItem> get todayTasks => [
    TaskItem(
      id: 1,
      title: '喝水打卡',
      description: '今日喝水2.5升',
      type: 'water',
      pointsReward: 10,
      completed: _todayCheckins['water'] ?? false,
    ),
    TaskItem(
      id: 2,
      title: '运动打卡',
      description: '运动30分钟',
      type: 'exercise',
      pointsReward: 20,
      completed: _todayCheckins['exercise'] ?? false,
    ),
    TaskItem(
      id: 3,
      title: '冥想打卡',
      description: '冥想10分钟',
      type: 'meditation',
      pointsReward: 15,
      completed: _todayCheckins['meditation'] ?? false,
    ),
    TaskItem(
      id: 4,
      title: '睡眠打卡',
      description: '睡眠8小时',
      type: 'sleep',
      pointsReward: 15,
      completed: _todayCheckins['sleep'] ?? false,
    ),
    TaskItem(
      id: 5,
      title: '营养打卡',
      description: '健康饮食',
      type: 'nutrition',
      pointsReward: 10,
      completed: _todayCheckins['nutrition'] ?? false,
    ),
    TaskItem(
      id: 6,
      title: '护肤打卡',
      description: '护肤保养',
      type: 'skincare',
      pointsReward: 10,
      completed: _todayCheckins['skincare'] ?? false,
    ),
    TaskItem(
      id: 7,
      title: '补剂打卡',
      description: '服用营养补剂',
      type: 'supplement',
      pointsReward: 15,
      completed: _todayCheckins['supplement'] ?? false,
    ),
    TaskItem(
      id: 8,
      title: '社交打卡',
      description: '社交互动',
      type: 'social',
      pointsReward: 10,
      completed: _todayCheckins['social'] ?? false,
    ),
  ];

  // === 模拟健康记录 ===
  HealthRecordItem? get todayRecord => HealthRecordItem(
    steps: _todaySteps,
    water: _todayWater,
    sleepHours: _todaySleep,
    exerciseMinutes: _todayExercise,
  );

  // === 构造函数 ===
  AppStateProvider() {
    _initializeApp();
  }

  // === 初始化方法 ===
  Future<void> _initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserData();
      await _loadTodayData();
      await _loadPointsData();

      // 模拟加载延迟
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === 🆕 使用新的数据加载方法 ===
  Future<void> _loadUserData() async {
    try {
      // 优先从数据库加载
      _currentUser = await _dbService.getUser();

      // 如果数据库没有，尝试从SharedPreferences加载并迁移
      if (_currentUser == null) {
        _currentUser = await _dbService.loadUserFromPreferences();

        if (_currentUser != null) {
          // 迁移到数据库
          await _dbService.saveUser(_currentUser!);
          _hasUser = true;
        }
      } else {
        _hasUser = true;
      }
    } catch (e) {
      debugPrint('加载用户数据失败: $e');
      _hasUser = false;
      _currentUser = null;
    }
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('last_data_date');

    if (savedDate == today) {
      // 加载今日数据
      _todaySteps = prefs.getInt('today_steps') ?? 0;
      _todayWater = prefs.getDouble('today_water') ?? 0.0;
      _todaySleep = prefs.getInt('today_sleep') ?? 0;
      _todayExercise = prefs.getInt('today_exercise') ?? 0;

      // 加载打卡状态
      for (String key in _todayCheckins.keys) {
        _todayCheckins[key] = prefs.getBool('checkin_$key') ?? false;
      }
    } else {
      // 新的一天，重置数据
      await _resetDailyData();
    }

    _calculateHealthScore();
  }

  Future<void> _loadPointsData() async {
    // 模拟积分历史（实际项目中应该从数据库加载）
    _pointHistory = [
      PointTransaction(
        points: 20,
        type: 'daily_login',
        description: '每日签到奖励',
        createdAt: DateTime.now(),
      ),
      PointTransaction(
        points: 15,
        type: 'task',
        description: '完成任务：冥想打卡',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PointTransaction(
        points: 10,
        type: 'task',
        description: '完成任务：喝水打卡',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  // === 🆕 用户管理方法 - 使用新的User模型 ===
  Future<bool> createUser({
    required String name,
    required String age,
    String gender = '未设置',
    String goal = '保持健康',
  }) async {
    try {
      // 创建新的User对象
      _currentUser = User(
        name: name,
        age: int.tryParse(age) ?? 25,
        gender: gender,
        goal: goal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // 游戏化数据使用默认值
        biologicalAge: 32,
        smartCoins: 220, // 120 + 100 新用户奖励
        level: 1,
        totalPoints: 100,
        joinDate: DateTime.now().toString().split(' ')[0],
        totalDays: 0,
      );

      // 保存到数据库和SharedPreferences
      await _dbService.saveUser(_currentUser!);
      await _dbService.saveUserToPreferences(_currentUser!);

      _hasUser = true;

      // 给新用户奖励
      await _addPoints(100, 'bonus', '新用户欢迎奖励');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('创建用户失败: $e');
      return false;
    }
  }

  // === 健康数据管理 ===
  Future<bool> updateHealthData({
    int? steps,
    double? water,
    int? sleepHours,
    int? exerciseMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (steps != null) {
        _todaySteps = steps;
        await prefs.setInt('today_steps', steps);
      }

      if (water != null) {
        _todayWater = water;
        await prefs.setDouble('today_water', water);
      }

      if (sleepHours != null) {
        _todaySleep = sleepHours;
        await prefs.setInt('today_sleep', sleepHours);
      }

      if (exerciseMinutes != null) {
        _todayExercise = exerciseMinutes;
        await prefs.setInt('today_exercise', exerciseMinutes);
      }

      await prefs.setString('last_data_date', today);

      _calculateHealthScore();
      await _checkHealthAchievements();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新健康数据失败: $e');
      return false;
    }
  }

  void _calculateHealthScore() {
    int score = 0;

    // 步数评分 (最高20分)
    if (_todaySteps >= 10000) {
      score += 20;
    } else if (_todaySteps >= 8000) {
      score += 15;
    } else if (_todaySteps >= 5000) {
      score += 10;
    } else if (_todaySteps >= 3000) {
      score += 5;
    }

    // 饮水评分 (最高15分)
    if (_todayWater >= 2.5) {
      score += 15;
    } else if (_todayWater >= 2.0) {
      score += 10;
    } else if (_todayWater >= 1.5) {
      score += 5;
    }

    // 睡眠评分 (最高20分)
    if (_todaySleep >= 7 && _todaySleep <= 9) {
      score += 20;
    } else if (_todaySleep >= 6 && _todaySleep <= 10) {
      score += 15;
    } else if (_todaySleep >= 5) {
      score += 10;
    }

    // 运动评分 (最高20分)
    if (_todayExercise >= 60) {
      score += 20;
    } else if (_todayExercise >= 30) {
      score += 15;
    } else if (_todayExercise >= 15) {
      score += 10;
    } else if (_todayExercise > 0) {
      score += 5;
    }

    // 打卡评分 (最高25分)
    score += (completedTasksToday * 3).clamp(0, 25);

    _todayHealthScore = score.clamp(0, 100);
  }

  // === 任务管理 ===
  Future<bool> completeTask(int taskId) async {
    try {
      final task = todayTasks.firstWhere((t) => t.id == taskId);

      if (task.completed) return false;

      final prefs = await SharedPreferences.getInstance();

      // 更新打卡状态
      _todayCheckins[task.type] = true;
      await prefs.setBool('checkin_${task.type}', true);

      // 添加积分
      await _addPoints(task.pointsReward, 'task', '完成任务：${task.title}');

      _calculateHealthScore();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('完成任务失败: $e');
      return false;
    }
  }

  Future<bool> uncompleteTask(int taskId) async {
    try {
      final task = todayTasks.firstWhere((t) => t.id == taskId);

      if (!task.completed) return false;

      final prefs = await SharedPreferences.getInstance();

      // 更新打卡状态
      _todayCheckins[task.type] = false;
      await prefs.setBool('checkin_${task.type}', false);

      // 扣除积分
      await _addPoints(-task.pointsReward, 'task', '取消任务：${task.title}');

      _calculateHealthScore();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('取消任务失败: $e');
      return false;
    }
  }

  // === 🆕 积分管理 - 更新User模型 ===
  Future<void> _addPoints(int points, String type, String description) async {
    if (_currentUser == null) return;

    // 更新用户数据
    _currentUser = _currentUser!.copyWith(
      totalPoints: _currentUser!.totalPoints + points,
      smartCoins: _currentUser!.smartCoins + points,
      updatedAt: DateTime.now(),
    );

    // 添加积分记录
    _pointHistory.insert(
      0,
      PointTransaction(
        points: points,
        type: type,
        description: description,
        createdAt: DateTime.now(),
      ),
    );

    // 保存到数据库
    await _dbService.saveUser(_currentUser!);
    await _dbService.saveUserToPreferences(_currentUser!);

    // 检查等级提升
    _checkLevelUp();
  }

  void _checkLevelUp() {
    if (_currentUser == null) return;

    final newLevel = (_currentUser!.totalPoints / 1000).floor() + 1;
    if (newLevel > _currentUser!.level) {
      _currentUser = _currentUser!.copyWith(level: newLevel);
      // 可以在这里添加等级提升的奖励
    }
  }

  // === 每日签到 ===
  Future<bool> dailyCheckIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastCheckIn = prefs.getString('last_checkin_date');

      if (lastCheckIn == today) {
        return false; // 今天已经签到过了
      }

      await prefs.setString('last_checkin_date', today);
      await _addPoints(20, 'daily_login', '每日签到奖励');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('每日签到失败: $e');
      return false;
    }
  }

  // === 成就检查 ===
  Future<void> _checkHealthAchievements() async {
    // 步数成就
    if (_todaySteps >= 10000) {
      await _addPoints(50, 'achievement', '步数达标奖励（10000步）');
    }

    // 饮水成就
    if (_todayWater >= 3.0) {
      await _addPoints(30, 'achievement', '饮水达标奖励（3升）');
    }

    // 健康达人成就
    if (_todayHealthScore >= 80) {
      await _addPoints(100, 'achievement', '健康达人奖励（80分以上）');
    }
  }

  // === 页面导航 ===
  void setCurrentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

  // === 🆕 用户信息更新方法 ===
  void updateUserName(String name) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );
    _dbService.saveUser(_currentUser!);
    _dbService.saveUserToPreferences(_currentUser!);
    notifyListeners();
  }

  void updateUserAge(String age) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      age: int.tryParse(age) ?? _currentUser!.age,
      updatedAt: DateTime.now(),
    );
    _dbService.saveUser(_currentUser!);
    _dbService.saveUserToPreferences(_currentUser!);
    notifyListeners();
  }

  // === 重置数据 ===
  Future<void> _resetDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 重置健康数据
    _todaySteps = 0;
    _todayWater = 0.0;
    _todaySleep = 0;
    _todayExercise = 0;

    // 重置打卡状态
    for (String key in _todayCheckins.keys) {
      _todayCheckins[key] = false;
      await prefs.setBool('checkin_$key', false);
    }

    // 保存重置后的数据
    await prefs.setInt('today_steps', 0);
    await prefs.setDouble('today_water', 0.0);
    await prefs.setInt('today_sleep', 0);
    await prefs.setInt('today_exercise', 0);
    await prefs.setString('last_data_date', today);

    _calculateHealthScore();
  }

  Future<void> resetTodayData() async {
    await _resetDailyData();
    notifyListeners();
  }
}

// === 辅助类保持不变 ===
class TaskItem {
  final int id;
  final String title;
  final String description;
  final String type;
  final int pointsReward;
  final bool completed;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.pointsReward,
    required this.completed,
  });

  String get iconData {
    switch (type) {
      case 'water':
        return '💧';
      case 'exercise':
        return '🏃‍♂️';
      case 'meditation':
        return '🧘‍♀️';
      case 'sleep':
        return '😴';
      case 'nutrition':
        return '🥗';
      case 'skincare':
        return '🧴';
      case 'supplement':
        return '💊';
      case 'social':
        return '👥';
      default:
        return '✅';
    }
  }

  String get statusDisplay {
    return completed ? '已完成' : '待完成';
  }
}

class HealthRecordItem {
  final int? steps;
  final double? water;
  final int? sleepHours;
  final int? exerciseMinutes;

  HealthRecordItem({
    this.steps,
    this.water,
    this.sleepHours,
    this.exerciseMinutes,
  });
}

class UserItem {
  final String name;
  final int age;
  final String gender;
  final String goal;
  final DateTime createdAt;

  UserItem({
    required this.name,
    required this.age,
    required this.gender,
    required this.goal,
    required this.createdAt,
  });
}

class PointTransaction {
  final int points;
  final String type;
  final String description;
  final DateTime createdAt;

  PointTransaction({
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  String get pointsDisplay => points > 0 ? '+$points' : '$points';
  bool get isPositive => points > 0;

  String get typeDisplay {
    switch (type) {
      case 'task':
        return '任务完成';
      case 'bonus':
        return '奖励';
      case 'daily_login':
        return '每日签到';
      case 'penalty':
        return '扣分';
      case 'achievement':
        return '成就奖励';
      default:
        return '其他';
    }
  }
}

class Achievement {
  final int id;
  final String name;
  final String desc;
  final String icon;
  final bool unlocked;
  final String? date;

  Achievement({
    required this.id,
    required this.name,
    required this.desc,
    required this.icon,
    required this.unlocked,
    this.date,
  });
}

class LeaderboardUser {
  final int rank;
  final String name;
  final int smartAge;
  final int coins;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.smartAge,
    required this.coins,
  });
}
