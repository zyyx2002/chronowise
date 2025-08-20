import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';

class HealthDataProvider with ChangeNotifier {
  List<HealthData> _healthDataList = [];
  bool _isLoading = false;

  // 新增智龄功能的状态
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

  // 原有的 getter 方法 (保持兼容)
  List<HealthData> get healthDataList => _healthDataList;
  bool get isLoading => _isLoading;

  // 新增的智龄功能 getter
  Map<String, bool> get todayCheckins => _todayCheckins;
  int get completedTasks =>
      _todayCheckins.values.where((completed) => completed).length;
  int get totalTasks => _todayCheckins.length;
  double get completionRate => completedTasks / totalTasks;

  HealthDataProvider() {
    loadHealthData();
    _loadTodayCheckins();
  }

  // 原有方法 - 加载健康数据
  Future<void> loadHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final dataString = prefs.getString('health_data_list');

      if (dataString != null) {
        // 这里解析数据，暂时用模拟数据
        _healthDataList = _generateMockData();
      } else {
        _healthDataList = _generateMockData();
      }
    } catch (e) {
      _healthDataList = _generateMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 原有方法 - 添加健康数据
  Future<void> addHealthData(HealthData data) async {
    _healthDataList.add(data);
    await _saveHealthData();
    notifyListeners();
  }

  // 原有方法 - 获取最新数据
  HealthData? getLatestData() {
    if (_healthDataList.isEmpty) {return null;}
    return _healthDataList.last;
  }

  // 新增方法 - 智龄打卡
  Future<bool> completeTask(String taskId) async {
    if (_todayCheckins[taskId] == true) {return false;}

    _todayCheckins[taskId] = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkin_$taskId', true);
    await prefs.setString(
        'last_checkin_date', DateTime.now().toIso8601String());

    notifyListeners();
    return true;
  }

  // 获取任务奖励
  int getTaskReward(String taskId) {
    const rewards = {
      'water': 10,
      'exercise': 25,
      'sleep': 20,
      'meditation': 20,
      'nutrition': 15,
      'skincare': 10,
      'supplement': 15,
      'social': 10,
    };
    return rewards[taskId] ?? 0;
  }

  // 获取任务信息
  Map<String, dynamic> getTaskInfo(String taskId) {
    const taskInfo = {
      'water': {'name': '喝水8杯', 'icon': '💧', 'desc': '保持身体水分平衡'},
      'exercise': {'name': '运动30分钟', 'icon': '🏃', 'desc': '提升心肺功能'},
      'sleep': {'name': '优质睡眠', 'icon': '😴', 'desc': '改善睡眠质量'},
      'meditation': {'name': '冥想10分钟', 'icon': '🧘', 'desc': '减压放松心情'},
      'nutrition': {'name': '营养均衡', 'icon': '🥗', 'desc': '补充维生素矿物质'},
      'skincare': {'name': '护肤保养', 'icon': '✨', 'desc': '延缓皮肤衰老'},
      'supplement': {'name': '营养补剂', 'icon': '💊', 'desc': '补充必需营养素'},
      'social': {'name': '社交互动', 'icon': '👥', 'desc': '保持心理健康'},
    };
    return taskInfo[taskId] ?? {'name': '未知任务', 'icon': '❓', 'desc': ''};
  }

  // 私有方法
  void _loadTodayCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final lastDateString = prefs.getString('last_checkin_date');

    if (lastDateString != null) {
      final lastDate = DateTime.parse(lastDateString);
      if (!_isSameDay(today, lastDate)) {
        _resetDailyCheckins();
        return;
      }
    }

    for (String key in _todayCheckins.keys) {
      _todayCheckins[key] = prefs.getBool('checkin_$key') ?? false;
    }
    notifyListeners();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _resetDailyCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    for (String key in _todayCheckins.keys) {
      _todayCheckins[key] = false;
      await prefs.setBool('checkin_$key', false);
    }
    await prefs.setString(
        'last_checkin_date', DateTime.now().toIso8601String());
  }

  Future<void> _saveHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    // 保存数据逻辑
    await prefs.setString('health_data_list', 'data');
  }

  List<HealthData> _generateMockData() {
    return [
      HealthData(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 7)),
        weight: 65.5,
        exerciseMinutes: 45,
        sleepHours: 7.5,
        waterGlasses: 8,
        mood: 'good',
        notes: '感觉很棒，继续保持',
      ),
      HealthData(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 6)),
        weight: 65.3,
        exerciseMinutes: 30,
        sleepHours: 8.0,
        waterGlasses: 7,
        mood: 'excellent',
        notes: '运动后精神状态很好',
      ),
      HealthData(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 5)),
        weight: 65.1,
        exerciseMinutes: 60,
        sleepHours: 7.0,
        waterGlasses: 9,
        mood: 'good',
        notes: '今天跑步了5公里',
      ),
      HealthData(
        id: '4',
        date: DateTime.now().subtract(const Duration(days: 4)),
        weight: 65.0,
        exerciseMinutes: 25,
        sleepHours: 6.5,
        waterGlasses: 6,
        mood: 'tired',
        notes: '工作比较忙，休息不够',
      ),
      HealthData(
        id: '5',
        date: DateTime.now().subtract(const Duration(days: 3)),
        weight: 64.8,
        exerciseMinutes: 40,
        sleepHours: 8.5,
        waterGlasses: 8,
        mood: 'excellent',
        notes: '早睡早起，状态很好',
      ),
      HealthData(
        id: '6',
        date: DateTime.now().subtract(const Duration(days: 2)),
        weight: 64.7,
        exerciseMinutes: 50,
        sleepHours: 7.5,
        waterGlasses: 10,
        mood: 'good',
        notes: '瑜伽课很放松',
      ),
      HealthData(
        id: '7',
        date: DateTime.now().subtract(const Duration(days: 1)),
        weight: 64.5,
        exerciseMinutes: 35,
        sleepHours: 8.0,
        waterGlasses: 8,
        mood: 'good',
        notes: '今天的目标都完成了',
      ),
    ];
  }
}
