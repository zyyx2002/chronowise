import 'package:flutter/material.dart';
import '../models/health_record.dart';
import '../repositories/health_repository.dart';

class HealthProvider extends ChangeNotifier {
  final HealthRepository _healthRepository = HealthRepository();

  // === 状态管理 ===
  HealthRecord? _todayHealthRecord;
  int _todayHealthScore = 0;
  bool _isLoading = false;
  String? _error;

  // === Getters ===
  HealthRecord? get todayHealthRecord => _todayHealthRecord;
  HealthRecord? get todayRecord => _todayHealthRecord; // 兼容性getter
  int get todayHealthScore => _todayHealthScore;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 具体数据的便捷访问
  int get todaySteps => _todayHealthRecord?.steps ?? 0;
  double get todayWater => _todayHealthRecord?.water ?? 0.0;
  int get todaySleep => _todayHealthRecord?.sleepHours ?? 0;
  int get todayExercise => _todayHealthRecord?.exerciseMinutes ?? 0;

  // === 核心方法 ===

  /// 加载今日健康数据
  Future<void> loadTodayHealthData(int userId) async {
    if (_isLoading) return;

    debugPrint('🔍 HealthProvider: 加载今日健康数据, 用户ID: $userId');

    _setLoading(true);
    _error = null;

    try {
      final healthRecord = await _healthRepository.getTodayHealthRecord(userId);
      _todayHealthRecord = healthRecord;

      if (_todayHealthRecord != null) {
        _todayHealthScore = _healthRepository.calculateHealthScore(
          _todayHealthRecord!,
        );
      }

      debugPrint('✅ HealthProvider: 健康数据加载成功');
      _setLoading(false);
    } catch (e) {
      debugPrint('❌ HealthProvider: 加载健康数据失败: $e');
      _error = '加载健康数据失败：$e';
      _setLoading(false);
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
      debugPrint('🔍 HealthProvider: 更新健康数据...');

      final success = await _healthRepository.updateHealthData(
        userId: userId,
        steps: steps,
        water: water,
        sleepHours: sleepHours,
        exerciseMinutes: exerciseMinutes,
      );

      if (success) {
        // 重新加载数据以更新本地状态
        await loadTodayHealthData(userId);

        // 检查成就
        if (_todayHealthRecord != null) {
          final achievements = _healthRepository.checkHealthAchievements(
            _todayHealthRecord!,
          );
          if (achievements.isNotEmpty) {
            debugPrint('🏆 HealthProvider: 获得${achievements.length}个健康成就');
            // 这里可以发送成就通知事件
          }
        }
      }

      return success;
    } catch (e) {
      debugPrint('❌ HealthProvider: 更新健康数据失败: $e');
      _error = '更新健康数据失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 重置今日数据
  Future<bool> resetTodayData(int userId) async {
    try {
      debugPrint('🔄 HealthProvider: 重置今日数据...');

      final success = await _healthRepository.resetTodayData(userId);

      if (success) {
        await loadTodayHealthData(userId);
      }

      return success;
    } catch (e) {
      debugPrint('❌ HealthProvider: 重置数据失败: $e');
      _error = '重置数据失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 刷新健康数据
  Future<void> refreshHealthData(int userId) async {
    debugPrint('🔄 HealthProvider: 刷新健康数据');
    await loadTodayHealthData(userId);
  }

  // === 私有方法 ===
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // === 清理方法 ===
  void clearHealthData() {
    _todayHealthRecord = null;
    _todayHealthScore = 0;
    _error = null;
    notifyListeners();
  }

  // === 调试方法 ===
  void debugPrintHealthData() {
    debugPrint('📊 HealthProvider Debug - 今日健康数据:');
    debugPrint('  步数: $todaySteps');
    debugPrint('  饮水: ${todayWater}L');
    debugPrint('  睡眠: ${todaySleep}小时');
    debugPrint('  运动: ${todayExercise}分钟');
    debugPrint('  健康分数: $_todayHealthScore/100');
  }
}
