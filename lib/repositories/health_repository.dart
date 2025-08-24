import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_record.dart';
import '../services/database_service.dart';

class HealthRepository {
  final DatabaseService _dbService = DatabaseService();

  /// 加载今日健康数据
  Future<HealthRecord?> getTodayHealthRecord(int userId) async {
    try {
      debugPrint('🔍 HealthRepository: 开始加载今日健康数据...');

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final savedDate = prefs.getString('last_data_date');

      if (savedDate == today) {
        // 从SharedPreferences加载健康数据
        final steps = prefs.getInt('today_steps') ?? 0;
        final water = prefs.getDouble('today_water') ?? 0.0;
        final sleep = prefs.getInt('today_sleep') ?? 0;
        final exercise = prefs.getInt('today_exercise') ?? 0;

        final healthRecord = HealthRecord(
          userId: userId,
          date: DateTime.now(),
          steps: steps,
          water: water,
          sleepHours: sleep,
          exerciseMinutes: exercise,
          createdAt: DateTime.now(),
        );

        debugPrint('✅ HealthRepository: 从缓存加载健康数据成功');
        return healthRecord;
      } else {
        // 如果不是今天的数据，重置为默认值
        debugPrint('🔄 HealthRepository: 日期变更，重置健康数据');
        return await _createEmptyTodayRecord(userId);
      }
    } catch (e) {
      debugPrint('❌ HealthRepository: 加载健康数据失败: $e');
      return await _createEmptyTodayRecord(userId);
    }
  }

  /// 更新健康数据
  Future<bool> updateHealthData({
    required int userId,
    int? steps,
    double? water,
    int? sleepHours,
    int? exerciseMinutes,
  }) async {
    try {
      debugPrint('🔍 HealthRepository: 更新健康数据...');

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      // 获取当前数据
      final currentRecord = await getTodayHealthRecord(userId);
      if (currentRecord == null) {
        debugPrint('❌ HealthRepository: 无法获取当前健康记录');
        return false;
      }

      // 保存到SharedPreferences
      if (steps != null) {
        await prefs.setInt('today_steps', steps);
      }
      if (water != null) {
        await prefs.setDouble('today_water', water);
      }
      if (sleepHours != null) {
        await prefs.setInt('today_sleep', sleepHours);
      }
      if (exerciseMinutes != null) {
        await prefs.setInt('today_exercise', exerciseMinutes);
      }

      await prefs.setString('last_data_date', today);

      debugPrint('✅ HealthRepository: 健康数据更新成功');
      return true;
    } catch (e) {
      debugPrint('❌ HealthRepository: 更新健康数据失败: $e');
      return false;
    }
  }

  /// 计算健康分数
  int calculateHealthScore(HealthRecord healthRecord) {
    int score = 0;
    final steps = healthRecord.steps ?? 0;
    final water = healthRecord.water ?? 0.0;
    final sleep = healthRecord.sleepHours ?? 0;
    final exercise = healthRecord.exerciseMinutes ?? 0;

    // 步数评分 (0-20分)
    if (steps >= 10000) {
      score += 20;
    } else if (steps >= 8000) {
      score += 15;
    } else if (steps >= 5000) {
      score += 10;
    } else if (steps >= 3000) {
      score += 5;
    }

    // 饮水评分 (0-15分)
    if (water >= 2.5) {
      score += 15;
    } else if (water >= 2.0) {
      score += 10;
    } else if (water >= 1.5) {
      score += 5;
    }

    // 睡眠评分 (0-20分)
    if (sleep >= 7 && sleep <= 9) {
      score += 20;
    } else if (sleep >= 6 && sleep <= 10) {
      score += 15;
    } else if (sleep >= 5) {
      score += 10;
    }

    // 运动评分 (0-20分)
    if (exercise >= 60) {
      score += 20;
    } else if (exercise >= 30) {
      score += 15;
    } else if (exercise >= 15) {
      score += 10;
    } else if (exercise > 0) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// 检查健康成就
  List<HealthAchievement> checkHealthAchievements(HealthRecord healthRecord) {
    final achievements = <HealthAchievement>[];
    final steps = healthRecord.steps ?? 0;
    final water = healthRecord.water ?? 0.0;
    final score = calculateHealthScore(healthRecord);

    if (steps >= 10000) {
      achievements.add(
        HealthAchievement(
          type: 'steps',
          title: '步数达标',
          description: '今日步数达到10000步',
          points: 50,
        ),
      );
    }

    if (water >= 3.0) {
      achievements.add(
        HealthAchievement(
          type: 'water',
          title: '饮水达标',
          description: '今日饮水达到3升',
          points: 30,
        ),
      );
    }

    if (score >= 80) {
      achievements.add(
        HealthAchievement(
          type: 'health_score',
          title: '健康达人',
          description: '今日健康分数达到80分以上',
          points: 100,
        ),
      );
    }

    return achievements;
  }

  /// 重置今日数据
  Future<bool> resetTodayData(int userId) async {
    try {
      debugPrint('🔄 HealthRepository: 重置今日数据...');

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];

      await prefs.setInt('today_steps', 0);
      await prefs.setDouble('today_water', 0.0);
      await prefs.setInt('today_sleep', 0);
      await prefs.setInt('today_exercise', 0);
      await prefs.setString('last_data_date', today);

      debugPrint('✅ HealthRepository: 今日数据重置成功');
      return true;
    } catch (e) {
      debugPrint('❌ HealthRepository: 重置数据失败: $e');
      return false;
    }
  }

  /// 创建空的今日记录
  Future<HealthRecord> _createEmptyTodayRecord(int userId) async {
    final record = HealthRecord(
      userId: userId,
      date: DateTime.now(),
      steps: 0,
      water: 0.0,
      sleepHours: 0,
      exerciseMinutes: 0,
      createdAt: DateTime.now(),
    );

    // 同时重置SharedPreferences
    await resetTodayData(userId);

    return record;
  }
}

/// 健康成就数据类
class HealthAchievement {
  final String type;
  final String title;
  final String description;
  final int points;

  HealthAchievement({
    required this.type,
    required this.title,
    required this.description,
    required this.points,
  });
}
