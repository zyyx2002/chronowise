import 'package:flutter/foundation.dart';
import '../models/health_data.dart';
import '../models/goal.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';

class HealthProvider with ChangeNotifier {
  List<HealthData> _healthDataList = [];
  List<Goal> _goals = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  List<HealthData> get healthDataList => _healthDataList;
  List<Goal> get goals => _goals;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  // 获取今日数据
  HealthData? get todayData {
    final today = DateTime.now();
    try {
      return _healthDataList.firstWhere(
        (data) => _isSameDay(data.date, today),
      );
    } catch (e) {
      return HealthData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: today,
      );
    }
  }

  // 初始化数据
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthDataList = await StorageService.loadHealthData();
      _goals = await StorageService.loadGoals();
      _achievements = await StorageService.loadAchievements();

      // 如果没有默认目标，创建一些
      if (_goals.isEmpty) {
        _createDefaultGoals();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }

  // 添加或更新健康数据
  Future<void> addOrUpdateHealthData(HealthData data) async {
    final existingIndex = _healthDataList.indexWhere(
      (item) => _isSameDay(item.date, data.date),
    );

    if (existingIndex != -1) {
      _healthDataList[existingIndex] = data;
    } else {
      _healthDataList.add(data);
    }

    _healthDataList.sort((a, b) => b.date.compareTo(a.date));
    await StorageService.saveHealthData(_healthDataList);

    // 检查成就
    _checkAchievements();

    notifyListeners();
  }

  // 添加目标
  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await StorageService.saveGoals(_goals);
    notifyListeners();
  }

  // 完成目标
  Future<void> completeGoal(String goalId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      _goals[goalIndex] = _goals[goalIndex].copyWith(isCompleted: true);
      await StorageService.saveGoals(_goals);

      // 添加成就
      _addAchievement(Achievement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '目标达成',
        description: '完成了目标: ${_goals[goalIndex].title}',
        iconData: 'goal_complete',
        unlockedDate: DateTime.now(),
        category: 'goal',
      ));

      notifyListeners();
    }
  }

  // 获取本周数据
  List<HealthData> getWeekData() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return _healthDataList.where((data) {
      return data.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          data.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // 获取本月数据
  List<HealthData> getMonthData() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return _healthDataList.where((data) {
      return data.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
          data.date.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // 创建默认目标
  void _createDefaultGoals() {
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));

    _goals = [
      Goal(
        id: 'weight_goal',
        title: '体重目标',
        type: 'weight',
        targetValue: 65.0,
        unit: 'kg',
        startDate: now,
        endDate: weekEnd,
      ),
      Goal(
        id: 'exercise_goal',
        title: '每日运动30分钟',
        type: 'exercise',
        targetValue: 30.0,
        unit: '分钟',
        startDate: now,
        endDate: weekEnd,
      ),
      Goal(
        id: 'sleep_goal',
        title: '每日睡眠8小时',
        type: 'sleep',
        targetValue: 8.0,
        unit: '小时',
        startDate: now,
        endDate: weekEnd,
      ),
      Goal(
        id: 'water_goal',
        title: '每日喝水8杯',
        type: 'water',
        targetValue: 8.0,
        unit: '杯',
        startDate: now,
        endDate: weekEnd,
      ),
    ];
    StorageService.saveGoals(_goals);
  }

  // 检查成就
  void _checkAchievements() {
    // 连续记录成就
    if (_healthDataList.length >= 7) {
      _addAchievement(Achievement(
        id: 'week_streak',
        title: '坚持一周',
        description: '连续记录健康数据7天',
        iconData: 'streak_7',
        unlockedDate: DateTime.now(),
        category: 'streak',
      ));
    }

    // 运动达人成就
    final weekData = getWeekData();
    final totalExercise = weekData
        .where((data) => data.exerciseMinutes != null)
        .fold(0, (sum, data) => sum + (data.exerciseMinutes ?? 0));

    if (totalExercise >= 150) {
      _addAchievement(Achievement(
        id: 'exercise_master',
        title: '运动达人',
        description: '本周运动超过150分钟',
        iconData: 'exercise_master',
        unlockedDate: DateTime.now(),
        category: 'exercise',
      ));
    }
  }

  // 添加成就
  void _addAchievement(Achievement achievement) {
    if (!_achievements.any((a) => a.id == achievement.id)) {
      _achievements.add(achievement);
      StorageService.saveAchievements(_achievements);
    }
  }

  // 判断是否是同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // 清除所有数据
  Future<void> clearAllData() async {
    _healthDataList.clear();
    _goals.clear();
    _achievements.clear();
    await StorageService.clearAllData();
    notifyListeners();
  }
}
