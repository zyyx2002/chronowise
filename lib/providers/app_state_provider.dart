import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/achievement.dart';
import '../models/health_record.dart';
import '../services/database_service.dart';

class AppStateProvider extends ChangeNotifier {
  // === 核心状态 ===
  bool _isLoading = true;
  bool _hasUser = false;
  User? _currentUser;

  // === 健康数据（统一管理）===
  HealthRecord? _todayHealthRecord;
  int _todayHealthScore = 0; // 额外存储健康分数

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
      id: '1',
      title: '初来乍到',
      description: '完成注册',
      iconData: '🎉',
      unlocked: true,
      unlockedDate: DateTime.parse('2024-05-01'),
      category: 'registration',
    ),
    Achievement(
      id: '2',
      title: '坚持一周',
      description: '连续打卡7天',
      iconData: '📅',
      unlocked: true,
      unlockedDate: DateTime.parse('2024-05-08'),
      category: 'consistency',
    ),
    Achievement(
      id: '3',
      title: '运动达人',
      description: '累计运动30小时',
      iconData: '🏃',
      unlocked: true,
      unlockedDate: DateTime.parse('2024-05-15'),
      category: 'exercise',
    ),
    Achievement.locked(
      id: '4',
      title: '冥想大师',
      description: '累计冥想100次',
      iconData: '🧘',
      category: 'meditation',
    ),
    Achievement.locked(
      id: '5',
      title: '健康先锋',
      description: '连续打卡30天',
      iconData: '🏆',
      category: 'consistency',
    ),
    Achievement.locked(
      id: '6',
      title: '抗衰专家',
      description: '生物年龄降低5岁',
      iconData: '⭐',
      category: 'health',
    ),
  ];

  // === Getters ===
  bool get isLoading => _isLoading;
  bool get hasUser => _hasUser;
  User? get currentUser => _currentUser;
  String get currentPage => _currentPage;
  int get onboardingStep => _onboardingStep;

  // 健康数据（通过统一的 HealthRecord 访问）
  int get todaySteps => _todayHealthRecord?.steps ?? 0;
  double get todayWater => _todayHealthRecord?.water ?? 0.0;
  int get todaySleep => _todayHealthRecord?.sleepHours ?? 0;
  int get todayExercise => _todayHealthRecord?.exerciseMinutes ?? 0;
  int get todayHealthScore => _todayHealthScore;

  // 统一的健康记录访问
  HealthRecord? get todayHealthRecord => _todayHealthRecord;

  // 兼容性 getter（为了支持 health_screen.dart）
  HealthRecord? get todayRecord => _todayHealthRecord;

  // 积分数据
  int get totalPoints => _currentUser?.totalPoints ?? 0;
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
      smartAge: _currentUser?.biologicalAge ?? 32,
      coins: _currentUser?.smartCoins ?? 120,
    ),
    LeaderboardUser(rank: 5, name: '活力青春', smartAge: 33, coins: 1920),
  ];

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

      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('初始化失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('🔍 开始加载用户数据...');

      // 首先从数据库加载
      debugPrint('🔍 正在从数据库查询用户...');
      _currentUser = await _dbService.getUser();
      debugPrint('🔍 数据库返回用户: ${_currentUser?.name}');

      if (_currentUser == null) {
        debugPrint('🔍 数据库无用户，尝试从SharedPreferences加载...');
        _currentUser = await _dbService.loadUserFromPreferences();
        debugPrint('🔍 SharedPreferences返回用户: ${_currentUser?.name}');

        if (_currentUser != null) {
          debugPrint('🔍 找到SharedPreferences用户，保存到数据库...');
          await _dbService.saveUser(_currentUser!);
          _hasUser = true;
          debugPrint('✅ 用户已保存到数据库');
        } else {
          debugPrint('❌ SharedPreferences中也没有用户数据');
        }
      } else {
        _hasUser = true;
        debugPrint('✅ 从数据库成功加载用户');
      }

      debugPrint(
        '🔍 最终用户状态: hasUser=$_hasUser, currentUser=${_currentUser?.name}',
      );
    } catch (e) {
      debugPrint('❌ 加载用户数据失败: $e');
      _hasUser = false;
      _currentUser = null;
    }
  }

  Future<void> _loadTodayData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('last_data_date');

    if (savedDate == today) {
      // 从SharedPreferences加载健康数据
      final steps = prefs.getInt('today_steps') ?? 0;
      final water = prefs.getDouble('today_water') ?? 0.0;
      final sleep = prefs.getInt('today_sleep') ?? 0;
      final exercise = prefs.getInt('today_exercise') ?? 0;

      // 创建统一的健康记录
      _todayHealthRecord = HealthRecord(
        userId: _currentUser?.id ?? 0,
        date: DateTime.now(),
        steps: steps,
        water: water,
        sleepHours: sleep,
        exerciseMinutes: exercise,
        createdAt: DateTime.now(),
      );
    } else {
      await _resetDailyData();
    }

    // 重新计算健康分数
    _updateHealthScore();
  }

  Future<void> _loadPointsData() async {
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

  Future<bool> createUser({
    required String name,
    required String age,
    String gender = '未设置',
    String goal = '保持健康',
  }) async {
    try {
      _currentUser = User(
        name: name,
        age: int.tryParse(age) ?? 25,
        gender: gender,
        goal: goal,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        biologicalAge: 32,
        smartCoins: 220,
        level: 1,
        totalPoints: 100,
        joinDate: DateTime.now().toString().split(' ')[0],
        totalDays: 0,
      );

      await _dbService.saveUser(_currentUser!);
      await _dbService.saveUserToPreferences(_currentUser!);

      _hasUser = true;

      await _addPoints(100, 'bonus', '新用户欢迎奖励');

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('创建用户失败: $e');
      return false;
    }
  }

  Future<bool> updateHealthData({
    int? steps,
    double? water,
    int? sleepHours,
    int? exerciseMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 确保有健康记录对象
      _todayHealthRecord ??= HealthRecord(
        userId: _currentUser?.id ?? 0,
        date: DateTime.now(),
        steps: 0,
        water: 0.0,
        sleepHours: 0,
        exerciseMinutes: 0,
        createdAt: DateTime.now(),
      );

      // 更新数据
      if (steps != null) {
        _todayHealthRecord = _todayHealthRecord!.copyWith(steps: steps);
        await prefs.setInt('today_steps', steps);
      }

      if (water != null) {
        _todayHealthRecord = _todayHealthRecord!.copyWith(water: water);
        await prefs.setDouble('today_water', water);
      }

      if (sleepHours != null) {
        _todayHealthRecord = _todayHealthRecord!.copyWith(
          sleepHours: sleepHours,
        );
        await prefs.setInt('today_sleep', sleepHours);
      }

      if (exerciseMinutes != null) {
        _todayHealthRecord = _todayHealthRecord!.copyWith(
          exerciseMinutes: exerciseMinutes,
        );
        await prefs.setInt('today_exercise', exerciseMinutes);
      }

      await prefs.setString('last_data_date', today);

      _updateHealthScore();
      await _checkHealthAchievements();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新健康数据失败: $e');
      return false;
    }
  }

  void _updateHealthScore() {
    if (_todayHealthRecord == null) return;

    int score = 0;
    final steps = _todayHealthRecord!.steps ?? 0;
    final water = _todayHealthRecord!.water ?? 0.0;
    final sleep = _todayHealthRecord!.sleepHours ?? 0;
    final exercise = _todayHealthRecord!.exerciseMinutes ?? 0;

    // 步数评分
    if (steps >= 10000) {
      score += 20;
    } else if (steps >= 8000) {
      score += 15;
    } else if (steps >= 5000) {
      score += 10;
    } else if (steps >= 3000) {
      score += 5;
    }

    // 饮水评分
    if (water >= 2.5) {
      score += 15;
    } else if (water >= 2.0) {
      score += 10;
    } else if (water >= 1.5) {
      score += 5;
    }

    // 睡眠评分
    if (sleep >= 7 && sleep <= 9) {
      score += 20;
    } else if (sleep >= 6 && sleep <= 10) {
      score += 15;
    } else if (sleep >= 5) {
      score += 10;
    }

    // 运动评分
    if (exercise >= 60) {
      score += 20;
    } else if (exercise >= 30) {
      score += 15;
    } else if (exercise >= 15) {
      score += 10;
    } else if (exercise > 0) {
      score += 5;
    }

    // 🆕 移除了任务相关的评分：score += (completedTasksToday * 3).clamp(0, 25);

    _todayHealthScore = score.clamp(0, 100);
  }

  Future<void> _addPoints(int points, String type, String description) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      totalPoints: _currentUser!.totalPoints + points,
      smartCoins: _currentUser!.smartCoins + points,
      updatedAt: DateTime.now(),
    );

    _pointHistory.insert(
      0,
      PointTransaction(
        points: points,
        type: type,
        description: description,
        createdAt: DateTime.now(),
      ),
    );

    await _dbService.saveUser(_currentUser!);
    await _dbService.saveUserToPreferences(_currentUser!);

    _checkLevelUp();
  }

  void _checkLevelUp() {
    if (_currentUser == null) return;

    final newLevel = (_currentUser!.totalPoints / 1000).floor() + 1;
    if (newLevel > _currentUser!.level) {
      _currentUser = _currentUser!.copyWith(level: newLevel);
    }
  }

  Future<bool> dailyCheckIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastCheckIn = prefs.getString('last_checkin_date');

      if (lastCheckIn == today) {
        return false;
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

  Future<void> _checkHealthAchievements() async {
    if (_todayHealthRecord == null) return;

    final steps = _todayHealthRecord!.steps ?? 0;
    final water = _todayHealthRecord!.water ?? 0.0;

    if (steps >= 10000) {
      await _addPoints(50, 'achievement', '步数达标奖励（10000步）');
    }

    if (water >= 3.0) {
      await _addPoints(30, 'achievement', '饮水达标奖励（3升）');
    }

    if (_todayHealthScore >= 80) {
      await _addPoints(100, 'achievement', '健康达人奖励（80分以上）');
    }
  }

  void setCurrentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    notifyListeners();
  }

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

  Future<void> _resetDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];

    // 重置健康记录
    _todayHealthRecord = HealthRecord(
      userId: _currentUser?.id ?? 0,
      date: DateTime.now(),
      steps: 0,
      water: 0.0,
      sleepHours: 0,
      exerciseMinutes: 0,
      createdAt: DateTime.now(),
    );

    await prefs.setInt('today_steps', 0);
    await prefs.setDouble('today_water', 0.0);
    await prefs.setInt('today_sleep', 0);
    await prefs.setInt('today_exercise', 0);
    await prefs.setString('last_data_date', today);

    _updateHealthScore();
  }

  Future<void> resetTodayData() async {
    await _resetDailyData();
    notifyListeners();
  }
}

// === 辅助类 ===
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
