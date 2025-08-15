import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/health_data.dart';
import '../models/challenge.dart';
import '../models/achievement.dart';
import '../services/app_service.dart';

class AppProvider extends ChangeNotifier {
  // 私有变量
  User? _currentUser;
  HealthData? _currentHealthData;
  List<HealthData> _historicalData = [];
  List<Challenge> _challenges = [];
  List<Achievement> _achievements = [];
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  HealthData? get currentHealthData => _currentHealthData;
  List<HealthData> get historicalData => _historicalData;
  List<Challenge> get challenges => _challenges;
  List<Achievement> get achievements => _achievements;
  List<Map<String, dynamic>> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 计算属性
  List<Challenge> get activeChallenges =>
      _challenges.where((c) => c.isActive && !c.isCompleted).toList();

  List<Challenge> get completedChallenges =>
      _challenges.where((c) => c.isCompleted).toList();

  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  int get totalActiveRewards =>
      activeChallenges.fold(0, (sum, c) => sum + c.reward.toInt());
  int get totalActiveExperience =>
      activeChallenges.fold(0, (sum, c) => sum + c.experienceReward.toInt());

  double get todayProgress {
    if (_currentHealthData == null) return 0.0;
    final goals = {
      'steps': _currentHealthData!.steps >= 8000,
      'sleep': _currentHealthData!.sleepHours >= 7,
      'water': _currentHealthData!.waterIntake >= 8,
      'exercise': _currentHealthData!.exerciseMinutes >= 30,
    };
    return goals.values.where((achieved) => achieved).length / goals.length;
  }

  // 初始化
  Future<void> initialize() async {
    await loadAllData();
  }

  // 加载所有数据
  Future<void> loadAllData() async {
    setLoading(true);
    try {
      await Future.wait([
        loadUser(),
        loadHealthData(),
        loadChallenges(),
        loadAchievements(),
        loadLeaderboard(),
      ]);
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  // 加载用户数据
  Future<void> loadUser() async {
    try {
      _currentUser = await AppService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      setError('加载用户数据失败: $e');
    }
  }

  // 加载健康数据
  Future<void> loadHealthData() async {
    try {
      _currentHealthData = await AppService.getHealthData();
      notifyListeners();
    } catch (e) {
      setError('加载健康数据失败: $e');
    }
  }

  // 加载历史数据
  Future<void> loadHistoricalData(int days) async {
    try {
      setLoading(true);
      _historicalData = await AppService.getHistoricalHealthData(days);
      clearError();
    } catch (e) {
      setError('加载历史数据失败: $e');
    } finally {
      setLoading(false);
    }
  }

  // 加载挑战
  Future<void> loadChallenges() async {
    try {
      _challenges = await AppService.getChallenges();
      notifyListeners();
    } catch (e) {
      setError('加载挑战失败: $e');
    }
  }

  // 加载成就
  Future<void> loadAchievements() async {
    try {
      _achievements = await AppService.getAchievements();
      notifyListeners();
    } catch (e) {
      setError('加载成就失败: $e');
    }
  }

  // 加载排行榜
  Future<void> loadLeaderboard() async {
    try {
      _leaderboard = await AppService.getLeaderboard();
      notifyListeners();
    } catch (e) {
      setError('加载排行榜失败: $e');
    }
  }

  // 更新挑战进度
  Future<void> updateChallengeProgress(
      String challengeId, double progress) async {
    try {
      await AppService.updateChallengeProgress(challengeId, progress);

      final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
      if (challengeIndex != -1) {
        _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
          progress: progress,
          isCompleted: progress >= 1.0,
        );

        // 如果挑战完成，给用户奖励
        if (progress >= 1.0 && _currentUser != null) {
          final challenge = _challenges[challengeIndex];
          _currentUser = _currentUser!.copyWith(
            smartCoins: _currentUser!.smartCoins + challenge.reward,
            experience: _currentUser!.experience + challenge.experienceReward,
            totalPoints: _currentUser!.totalPoints +
                challenge.reward +
                challenge.experienceReward,
          );
          _updateUserLevel();
        }

        notifyListeners();
      }
    } catch (e) {
      setError('更新挑战进度失败: $e');
    }
  }

  // 完成任务
  Future<void> completeTask(String taskId) async {
    try {
      await AppService.completeTask(taskId);

      if (_currentUser != null) {
        final updatedTasks = List<String>.from(_currentUser!.completedTasks);
        if (!updatedTasks.contains(taskId)) {
          updatedTasks.add(taskId);

          _currentUser = _currentUser!.copyWith(
            completedTasks: updatedTasks,
            smartCoins: _currentUser!.smartCoins + 10,
            experience: _currentUser!.experience + 20,
            totalPoints: _currentUser!.totalPoints + 30,
          );

          _updateUserLevel();
          _checkAchievements();
          notifyListeners();
        }
      }
    } catch (e) {
      setError('完成任务失败: $e');
    }
  }

  // 更新用户级别
  void _updateUserLevel() {
    if (_currentUser == null) return;

    final newLevel = (_currentUser!.experience / 1000).floor() + 1;
    if (newLevel != _currentUser!.level) {
      _currentUser = _currentUser!.copyWith(level: newLevel);
    }
  }

  // 检查成就
  void _checkAchievements() {
    if (_currentUser == null) return;

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;

        switch (achievement.category) {
          case 'streak':
            shouldUnlock = _currentUser!.streakDays >= achievement.requirement;
            break;
          case 'water':
            shouldUnlock = _currentHealthData?.waterIntake != null &&
                _currentHealthData!.waterIntake >= achievement.requirement;
            break;
          case 'steps':
            shouldUnlock = _currentHealthData?.steps != null &&
                _currentHealthData!.steps >= achievement.requirement;
            break;
        }

        if (shouldUnlock) {
          _achievements[i] = Achievement(
            id: achievement.id,
            name: achievement.name,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            category: achievement.category,
            type: achievement.type,
            requirement: achievement.requirement,
            requiredValue: achievement.requiredValue,
            currentProgress: achievement.requirement,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            reward: achievement.reward,
            experienceReward: achievement.experienceReward,
          );

          // 给用户奖励
          _currentUser = _currentUser!.copyWith(
            smartCoins: _currentUser!.smartCoins + achievement.reward,
            experience: _currentUser!.experience + achievement.experienceReward,
            totalPoints: _currentUser!.totalPoints +
                achievement.reward +
                achievement.experienceReward,
          );
        }
      }
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await loadAllData();
  }

  // 更新健康数据
  Future<void> updateHealthData(HealthData newData) async {
    try {
      _currentHealthData = newData;

      // 计算生物年龄
      if (_currentUser != null && _historicalData.isNotEmpty) {
        final avgSteps =
            _historicalData.map((d) => d.steps).reduce((a, b) => a + b) /
                _historicalData.length;
        final avgSleep =
            _historicalData.map((d) => d.sleepHours).reduce((a, b) => a + b) /
                _historicalData.length;
        final avgHeartRate =
            _historicalData.map((d) => d.heartRate).reduce((a, b) => a + b) /
                _historicalData.length;
        final avgStress =
            _historicalData.map((d) => d.stressLevel).reduce((a, b) => a + b) /
                _historicalData.length;
        final avgExercise = _historicalData
                .map((d) => d.exerciseMinutes)
                .reduce((a, b) => a + b) /
            _historicalData.length;

        final biologicalAge = AppService.calculateBiologicalAge(
          chronologicalAge: _currentUser!.age,
          averageSteps: avgSteps,
          averageSleep: avgSleep,
          averageHeartRate: avgHeartRate.toDouble(),
          averageStress: avgStress.toDouble(),
          averageExercise: avgExercise.toDouble(),
        );

        _currentUser = _currentUser!.copyWith(biologicalAge: biologicalAge);
      }

      _checkAchievements();
      notifyListeners();
    } catch (e) {
      setError('更新健康数据失败: $e');
    }
  }

  // 更新用户信息
  Future<void> updateUser(User updatedUser) async {
    try {
      await AppService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      setError('更新用户信息失败: $e');
    }
  }

  // 获取健康建议
  List<String> getHealthRecommendations() {
    if (_currentHealthData == null) return [];
    return AppService.getHealthRecommendations(_currentHealthData!);
  }

  // 获取健康评分
  int getHealthScore() {
    if (_currentHealthData == null) return 0;
    return AppService.getHealthScore(_currentHealthData!);
  }

  // 工具方法
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 调试方法
  void debugPrint() {
    if (kDebugMode) {
      print('=== AppProvider Debug ===');
      print('User: ${_currentUser?.name ?? 'null'}');
      print('Health Data: ${_currentHealthData != null ? 'loaded' : 'null'}');
      print('Challenges: ${_challenges.length}');
      print('Achievements: ${_achievements.length}');
      print('Loading: $_isLoading');
      print('Error: $_error');
      print('========================');
    }
  }
}
