import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class StorageService {
  static const String _achievementsKey = 'achievements';

  static Future<void> initialize() async {
    // 初始化存储服务
    await SharedPreferences.getInstance();
  }

  static Future<void> saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = achievements
        .map((achievement) => achievement.toJson())
        .toList();
    await prefs.setString(_achievementsKey, jsonEncode(jsonList));
  }

  static Future<List<Achievement>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_achievementsKey);
    if (jsonString == null) {
      return [];
    }

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Achievement.fromJson(json)).toList();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
  }
}
