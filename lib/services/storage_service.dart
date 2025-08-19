import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';
import '../models/goal.dart';
import '../models/achievement.dart';

class StorageService {
  static const String _healthDataKey = 'health_data';
  static const String _goalsKey = 'goals';
  static const String _achievementsKey = 'achievements';

  // 保存健康数据
  static Future<void> saveHealthData(List<HealthData> dataList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = dataList.map((data) => data.toJson()).toList();
    await prefs.setString(_healthDataKey, jsonEncode(jsonList));
  }

  // 加载健康数据
  static Future<List<HealthData>> loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_healthDataKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HealthData.fromJson(json)).toList();
  }

  // 保存目标
  static Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = goals.map((goal) => goal.toJson()).toList();
    await prefs.setString(_goalsKey, jsonEncode(jsonList));
  }

  // 加载目标
  static Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_goalsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Goal.fromJson(json)).toList();
  }

  // 保存成就
  static Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
        achievements.map((achievement) => achievement.toJson()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(jsonList));
  }

  // 加载成就
  static Future<List<Achievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_achievementsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Achievement.fromJson(json)).toList();
  }

  // 清除所有数据
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_healthDataKey);
    await prefs.remove(_goalsKey);
    await prefs.remove(_achievementsKey);
  }
}
