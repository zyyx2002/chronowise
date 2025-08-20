import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../models/user.dart';
import '../models/health_record.dart';
import '../models/point_transaction.dart';
import '../models/task.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  HealthRecord? _todayRecord;
  List<PointTransaction> _pointHistory = [];
  List<Task> _todayTasks = [];
  int _totalPoints = 0;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  HealthRecord? get todayRecord => _todayRecord;
  List<PointTransaction> get pointHistory => _pointHistory;
  List<Task> get todayTasks => _todayTasks;
  int get totalPoints => _totalPoints;
  bool get isLoading => _isLoading;

  // 检查是否有用户
  bool get hasUser => _currentUser != null;

  // 获取今日完成任务数
  int get completedTasksToday =>
      _todayTasks.where((task) => task.completed).length;

  // 获取今日任务总数
  int get totalTasksToday => _todayTasks.length;

  // 获取今日健康得分
  int get todayHealthScore => _todayRecord?.healthScore ?? 0;

  // 初始化数据
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadCurrentUser();
      if (_currentUser != null) {
        await _loadTodayData();
        await _loadPointHistory();
        await _loadTotalPoints();
      }
    } catch (e) {
      debugPrint('初始化数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 创建新用户
  Future<bool> createUser({
    required String name,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String goal,
  }) async {
    try {
      _setLoading(true);
      final now = DateTime.now();
      final user = User(
        name: name,
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        goal: goal,
        createdAt: now,
        updatedAt: now,
      );

      final userId = await _dbService.insertUser(user);
      _currentUser = user.copyWith(id: userId);

      // 创建今日健康记录
      await _createTodayRecord();

      // 创建今日任务
      await _createTodayTasks();

      // 给予新用户奖励
      await _addWelcomePoints();

      await _loadTodayData();
      await _loadPointHistory();
      await _loadTotalPoints();

      return true;
    } catch (e) {
      debugPrint('创建用户失败: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 更新用户信息
  Future<bool> updateUser(User user) async {
    try {
      await _dbService.updateUser(user.copyWith(updatedAt: DateTime.now()));
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新用户失败: $e');
      return false;
    }
  }

  // 更新健康数据
  Future<bool> updateHealthData({
    int? steps,
    double? water,
    int? sleepHours,
    int? exerciseMinutes,
    int? meditationMinutes,
    int? readingMinutes,
    int? socialMinutes,
    bool? skincare,
    int? nutritionScore,
  }) async {
    if (_currentUser == null || _todayRecord == null) {return false;}

    try {
      final updatedRecord = _todayRecord!.copyWith(
        steps: steps,
        water: water,
        sleepHours: sleepHours,
        exerciseMinutes: exerciseMinutes,
        meditationMinutes: meditationMinutes,
        readingMinutes: readingMinutes,
        socialMinutes: socialMinutes,
        skincare: skincare,
        nutritionScore: nutritionScore,
      );

      await _dbService.updateHealthRecord(updatedRecord);
      _todayRecord = updatedRecord;

      // 检查是否达成健康目标，给予奖励
      await _checkHealthAchievements(updatedRecord);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新健康数据失败: $e');
      return false;
    }
  }

  // 完成任务
  Future<bool> completeTask(int taskId) async {
    if (_currentUser == null) {return false;}

    try {
      final taskIndex = _todayTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {return false;}

      final task = _todayTasks[taskIndex];
      if (task.completed) {return false;}

      final completedTask = task.copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );

      await _dbService.updateTask(completedTask);
      _todayTasks[taskIndex] = completedTask;

      // 添加积分奖励
      await _addTaskPoints(task);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('完成任务失败: $e');
      return false;
    }
  }

  // 取消完成任务
  Future<bool> uncompleteTask(int taskId) async {
    if (_currentUser == null) {return false;}

    try {
      final taskIndex = _todayTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {return false;}

      final task = _todayTasks[taskIndex];
      if (!task.completed) {return false;}

      final uncompletedTask = task.copyWith(
        completed: false,
        completedAt: null,
      );

      await _dbService.updateTask(uncompletedTask);
      _todayTasks[taskIndex] = uncompletedTask;

      // 扣除积分
      await _removeTaskPoints(task);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('取消完成任务失败: $e');
      return false;
    }
  }

  // 每日签到
  Future<bool> dailyCheckIn() async {
    if (_currentUser == null) {return false;}

    try {
      // 检查今日是否已签到
      final today = DateTime.now();
      final checkInTransactions = _pointHistory.where(
        (transaction) =>
            transaction.type == 'daily_login' &&
            _isSameDay(transaction.createdAt, today),
      );

      if (checkInTransactions.isNotEmpty) {
        return false; // 已经签到过了
      }

      // 添加签到积分
      await _addPointTransaction(
        points: 20,
        type: 'daily_login',
        description: '每日签到奖励',
      );

      return true;
    } catch (e) {
      debugPrint('每日签到失败: $e');
      return false;
    }
  }

  // 获取历史健康记录
  Future<List<HealthRecord>> getHealthHistory({int days = 30}) async {
    if (_currentUser == null) {return [];}

    try {
      return await _dbService.getHealthRecords(_currentUser!.id!, days: days);
    } catch (e) {
      debugPrint('获取健康历史失败: $e');
      return [];
    }
  }

  // 重置当天数据（用于测试）
  Future<void> resetTodayData() async {
    if (_currentUser == null) {return;}

    try {
      _setLoading(true);

      // 重新创建今日任务
      await _createTodayTasks();

      // 重新加载数据
      await _loadTodayData();
      await _loadPointHistory();
      await _loadTotalPoints();
    } catch (e) {
      debugPrint('重置今日数据失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _dbService.getCurrentUser();
  }

  Future<void> _loadTodayData() async {
    if (_currentUser == null) {return;}

    final today = DateTime.now();
    _todayRecord = await _dbService.getHealthRecord(_currentUser!.id!, today);
    _todayTasks = await _dbService.getTasks(_currentUser!.id!, today);

    // 如果今日没有记录，创建新的
    if (_todayRecord == null) {
      await _createTodayRecord();
    }

    if (_todayTasks.isEmpty) {
      await _createTodayTasks();
    }
  }

  Future<void> _createTodayRecord() async {
    if (_currentUser == null) {return;}

    final today = DateTime.now();
    final record = HealthRecord(
      userId: _currentUser!.id!,
      date: today,
      createdAt: today,
    );

    await _dbService.insertHealthRecord(record);
    _todayRecord = record;
  }

  Future<void> _createTodayTasks() async {
    if (_currentUser == null) {return;}

    final today = DateTime.now();
    final defaultTasks = [
      {
        'type': 'water',
        'title': '喝水打卡',
        'description': '今日喝水2.5升',
        'points': 10,
      },
      {
        'type': 'exercise',
        'title': '运动打卡',
        'description': '运动30分钟',
        'points': 20,
      },
      {
        'type': 'meditation',
        'title': '冥想打卡',
        'description': '冥想10分钟',
        'points': 15,
      },
      {'type': 'sleep', 'title': '睡眠打卡', 'description': '睡眠8小时', 'points': 15},
      {
        'type': 'nutrition',
        'title': '营养打卡',
        'description': '健康饮食',
        'points': 10,
      },
      {
        'type': 'skincare',
        'title': '护肤打卡',
        'description': '护肤保养',
        'points': 10,
      },
      {
        'type': 'reading',
        'title': '阅读打卡',
        'description': '阅读30分钟',
        'points': 15,
      },
      {'type': 'social', 'title': '社交打卡', 'description': '社交互动', 'points': 10},
    ];

    // 清除旧任务（如果存在）
    final existingTasks = await _dbService.getTasks(_currentUser!.id!, today);
    if (existingTasks.isNotEmpty) {
      // 如果已经有任务，直接返回，避免重复创建
      return;
    }

    for (final taskData in defaultTasks) {
      final task = Task(
        userId: _currentUser!.id!,
        type: taskData['type'] as String,
        title: taskData['title'] as String,
        description: taskData['description'] as String,
        targetDate: today,
        pointsReward: taskData['points'] as int,
        createdAt: today,
      );

      await _dbService.insertTask(task);
    }

    _todayTasks = await _dbService.getTasks(_currentUser!.id!, today);
  }

  Future<void> _loadPointHistory() async {
    if (_currentUser == null) {return;}
    _pointHistory = await _dbService.getPointTransactions(
      _currentUser!.id!,
      limit: 50,
    );
  }

  Future<void> _loadTotalPoints() async {
    if (_currentUser == null) {return;}
    _totalPoints = await _dbService.getTotalPoints(_currentUser!.id!);
  }

  Future<void> _addWelcomePoints() async {
    await _addPointTransaction(
      points: 100,
      type: 'bonus',
      description: '新用户欢迎奖励',
    );
  }

  Future<void> _addTaskPoints(Task task) async {
    await _addPointTransaction(
      points: task.pointsReward,
      type: 'task',
      description: '完成任务：${task.title}',
    );
  }

  Future<void> _removeTaskPoints(Task task) async {
    await _addPointTransaction(
      points: -task.pointsReward,
      type: 'task',
      description: '取消任务：${task.title}',
    );
  }

  Future<void> _checkHealthAchievements(HealthRecord record) async {
    // 检查步数成就
    if (record.steps != null && record.steps! >= 10000) {
      await _addPointTransaction(
        points: 50,
        type: 'achievement',
        description: '步数达标奖励（10000步）',
      );
    }

    // 检查饮水成就
    if (record.water != null && record.water! >= 3.0) {
      await _addPointTransaction(
        points: 30,
        type: 'achievement',
        description: '饮水达标奖励（3升）',
      );
    }

    // 检查全面健康成就
    if (record.healthScore >= 80) {
      await _addPointTransaction(
        points: 100,
        type: 'achievement',
        description: '健康达人奖励（80分以上）',
      );
    }
  }

  Future<void> _addPointTransaction({
    required int points,
    required String type,
    required String description,
  }) async {
    if (_currentUser == null) {return;}

    final transaction = PointTransaction(
      userId: _currentUser!.id!,
      points: points,
      type: type,
      description: description,
      createdAt: DateTime.now(),
    );

    await _dbService.insertPointTransaction(transaction);
    await _loadPointHistory();
    await _loadTotalPoints();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
