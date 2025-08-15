import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/health_data.dart';
import '../models/challenge.dart';
import '../models/achievement.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _healthDataKey = 'health_data';
  static const String _challengesKey = 'challenges';
  static const String _achievementsKey = 'achievements';
  static const String _settingsKey = 'app_settings';

  // 单例模式
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // 初始化
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 保存用户数据
  Future<bool> saveUser(User user) async {
    await initialize();
    try {
      final userJson = jsonEncode(user.toJson());
      return await _prefs!.setString(_userKey, userJson);
    } catch (e) {
      print('保存用户数据失败: $e');
      return false;
    }
  }

  // 获取用户数据
  Future<User?> getUser() async {
    await initialize();
    try {
      final userJson = _prefs!.getString(_userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('获取用户数据失败: $e');
      return null;
    }
  }

  // 保存健康数据
  Future<bool> saveHealthData(HealthData healthData) async {
    await initialize();
    try {
      final healthJson = jsonEncode(healthData.toJson());
      return await _prefs!.setString(_healthDataKey, healthJson);
    } catch (e) {
      print('保存健康数据失败: $e');
      return false;
    }
  }

  // 获取健康数据
  Future<HealthData?> getHealthData() async {
    await initialize();
    try {
      final healthJson = _prefs!.getString(_healthDataKey);
      if (healthJson != null) {
        final healthMap = jsonDecode(healthJson) as Map<String, dynamic>;
        return HealthData.fromJson(healthMap);
      }
      return null;
    } catch (e) {
      print('获取健康数据失败: $e');
      return null;
    }
  }

  // 保存挑战列表
  Future<bool> saveChallenges(List<Challenge> challenges) async {
    await initialize();
    try {
      final challengesJson =
          jsonEncode(challenges.map((c) => c.toJson()).toList());
      return await _prefs!.setString(_challengesKey, challengesJson);
    } catch (e) {
      print('保存挑战数据失败: $e');
      return false;
    }
  }

  // 获取挑战列表
  Future<List<Challenge>> getChallenges() async {
    await initialize();
    try {
      final challengesJson = _prefs!.getString(_challengesKey);
      if (challengesJson != null) {
        final challengesList = jsonDecode(challengesJson) as List;
        return challengesList
            .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取挑战数据失败: $e');
      return [];
    }
  }

  // 保存成就列表
  Future<bool> saveAchievements(List<Achievement> achievements) async {
    await initialize();
    try {
      final achievementsJson =
          jsonEncode(achievements.map((a) => a.toJson()).toList());
      return await _prefs!.setString(_achievementsKey, achievementsJson);
    } catch (e) {
      print('保存成就数据失败: $e');
      return false;
    }
  }

  // 获取成就列表
  Future<List<Achievement>> getAchievements() async {
    await initialize();
    try {
      final achievementsJson = _prefs!.getString(_achievementsKey);
      if (achievementsJson != null) {
        final achievementsList = jsonDecode(achievementsJson) as List;
        return achievementsList
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取成就数据失败: $e');
      return [];
    }
  }

  // 保存设置
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    await initialize();
    try {
      final settingsJson = jsonEncode(settings);
      return await _prefs!.setString(_settingsKey, settingsJson);
    } catch (e) {
      print('保存设置失败: $e');
      return false;
    }
  }

  // 获取设置
  Future<Map<String, dynamic>> getSettings() async {
    await initialize();
    try {
      final settingsJson = _prefs!.getString(_settingsKey);
      if (settingsJson != null) {
        return jsonDecode(settingsJson) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('获取设置失败: $e');
      return {};
    }
  }

  // 清除所有数据
  Future<bool> clearAll() async {
    await initialize();
    try {
      return await _prefs!.clear();
    } catch (e) {
      print('清除数据失败: $e');
      return false;
    }
  }

  // 清除特定数据
  Future<bool> clearUser() async {
    await initialize();
    return await _prefs!.remove(_userKey);
  }

  Future<bool> clearHealthData() async {
    await initialize();
    return await _prefs!.remove(_healthDataKey);
  }

  Future<bool> clearChallenges() async {
    await initialize();
    return await _prefs!.remove(_challengesKey);
  }

  Future<bool> clearAchievements() async {
    await initialize();
    return await _prefs!.remove(_achievementsKey);
  }

  // 检查数据是否存在
  Future<bool> hasUser() async {
    await initialize();
    return _prefs!.containsKey(_userKey);
  }

  Future<bool> hasHealthData() async {
    await initialize();
    return _prefs!.containsKey(_healthDataKey);
  }

  Future<bool> hasChallenges() async {
    await initialize();
    return _prefs!.containsKey(_challengesKey);
  }

  Future<bool> hasAchievements() async {
    await initialize();
    return _prefs!.containsKey(_achievementsKey);
  }
}
