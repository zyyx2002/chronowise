import '../models/user.dart';
import '../models/health_data.dart';
import '../models/challenge.dart';
import '../models/achievement.dart';

class AppService {
  // 单例模式
  static final AppService _instance = AppService._internal();
  factory AppService() => _instance;
  AppService._internal();

  // 获取用户数据
  static Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return User(
      id: 'user_001',
      name: '健康达人',
      email: 'user@example.com',
      age: 28,
      height: 175.0,
      weight: 70.0,
      gender: 'male',
      smartCoins: 1920.0,
      level: 15,
      experience: 2840.0,
      streakDays: 12,
      biologicalAge: 25.5,
      longestStreak: 45,
      dateOfBirth: DateTime(1995, 5, 15),
      totalPoints: 3680.0,
      joinDate: now.subtract(const Duration(days: 180)),
      completedTasks: ['drink_water', 'exercise', 'sleep_well'],
      dailyTasks: ['drink_8_water', 'walk_10k', 'sleep_7h', 'meditate'],
      avatar: '🧑‍💼',
    );
  }

  // 获取健康数据
  static Future<HealthData> getHealthData() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    return HealthData(
      steps: 8500,
      heartRate: 72,
      sleepHours: 7.5,
      waterIntake: 6,
      calories: 2200,
      weight: 70.0,
      bloodPressure: '120/80',
      stressLevel: 2,
      mood: 4,
      exerciseMinutes: 45,
      timestamp: now,
      completedTasks: 3,
      completionRate: 0.75,
      date: now,
      streakDays: 12,
      tasks: ['喝水', '运动', '冥想', '睡眠'],
      wisdomCoins: 85.0,
    );
  }

  // 获取历史健康数据
  static Future<List<HealthData>> getHistoricalHealthData(int days) async {
    await Future.delayed(const Duration(milliseconds: 600));

    List<HealthData> data = [];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      data.add(HealthData(
        steps: 7000 + (i * 200) + (date.day % 1000),
        heartRate: 68 + (i % 10),
        sleepHours: 7.0 + (i % 2) * 0.5,
        waterIntake: 5 + (i % 4),
        calories: 2000 + (i * 50),
        weight: 70.0 + (i % 3) * 0.5,
        bloodPressure: '${115 + (i % 5)}/80',
        stressLevel: (i % 5) + 1,
        mood: (i % 5) + 1,
        exerciseMinutes: 30 + (i % 4) * 15,
        timestamp: date,
        completedTasks: (i % 4) + 1,
        completionRate: ((i % 4) + 1) / 4,
        date: date,
        streakDays: i < 12 ? 12 - i : 0,
        tasks: ['任务${i % 4 + 1}'],
        wisdomCoins: 50.0 + (i % 10) * 5,
      ));
    }
    return data;
  }

  // 获取挑战列表
  static Future<List<Challenge>> getChallenges() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    return [
      Challenge(
        id: 'daily_water',
        title: '每日饮水',
        description: '每天喝8杯水',
        icon: '💧',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        durationDays: 1,
        reward: 10.0,
        experienceReward: 20.0,
        requirements: ['drink_8_glasses'],
        startDate: now,
        endDate: now.add(const Duration(days: 1)),
        isActive: true,
        progress: 0.6,
      ),
      Challenge(
        id: 'weekly_exercise',
        title: '每周运动',
        description: '每周运动5次',
        icon: '🏃‍♂️',
        type: ChallengeType.weekly,
        difficulty: ChallengeDifficulty.medium,
        durationDays: 7,
        reward: 50.0,
        experienceReward: 100.0,
        requirements: ['exercise_5_times'],
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        isActive: true,
        progress: 0.4,
      ),
      Challenge(
        id: 'monthly_meditation',
        title: '冥想挑战',
        description: '每月冥想20天',
        icon: '🧘‍♀️',
        type: ChallengeType.monthly,
        difficulty: ChallengeDifficulty.hard,
        durationDays: 30,
        reward: 200.0,
        experienceReward: 500.0,
        requirements: ['meditate_20_days'],
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        isActive: true,
        progress: 0.3,
      ),
    ];
  }

  // 获取成就列表
  static Future<List<Achievement>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 350));

    return [
      Achievement(
        id: 'first_week',
        name: 'first_week_complete',
        title: '第一周完成',
        description: '完成第一周的健康记录',
        icon: '🎯',
        category: 'streak',
        type: 'milestone',
        requirement: 7,
        requiredValue: 7,
        currentProgress: 7,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        reward: 50,
        experienceReward: 100,
      ),
      Achievement(
        id: 'water_master',
        name: 'water_master',
        title: '饮水大师',
        description: '连续30天达到饮水目标',
        icon: '💧',
        category: 'water',
        type: 'streak',
        requirement: 30,
        requiredValue: 30,
        currentProgress: 15,
        isUnlocked: false,
        reward: 200,
        experienceReward: 300,
      ),
      Achievement(
        id: 'step_champion',
        name: 'step_champion',
        title: '步数冠军',
        description: '单日步数超过15000步',
        icon: '👟',
        category: 'steps',
        type: 'single',
        requirement: 15000,
        requiredValue: 15000,
        currentProgress: 8500,
        isUnlocked: false,
        reward: 100,
        experienceReward: 200,
      ),
    ];
  }

  // 获取排行榜
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'rank': 1, 'name': '健康达人小王', 'biologicalAge': 24.5, 'smartCoins': 2580},
      {'rank': 2, 'name': '养生专家', 'biologicalAge': 26.2, 'smartCoins': 2340},
      {'rank': 3, 'name': '抗衰先锋', 'biologicalAge': 25.8, 'smartCoins': 2180},
      {'rank': 4, 'name': '你', 'biologicalAge': 25.5, 'smartCoins': 1920},
      {'rank': 5, 'name': '健康小白', 'biologicalAge': 28.1, 'smartCoins': 1650},
      {'rank': 6, 'name': '运动达人', 'biologicalAge': 27.3, 'smartCoins': 1480},
      {'rank': 7, 'name': '养生新手', 'biologicalAge': 29.6, 'smartCoins': 1200},
    ];
  }

  // 计算生物年龄
  static double calculateBiologicalAge({
    required int chronologicalAge,
    required double averageSteps,
    required double averageSleep,
    required double averageHeartRate,
    required double averageStress,
    required double averageExercise,
  }) {
    double biologicalAge = chronologicalAge.toDouble();

    // 步数影响
    if (averageSteps >= 10000) {
      biologicalAge -= 2;
    } else if (averageSteps >= 8000) {
      biologicalAge -= 1;
    } else if (averageSteps < 5000) {
      biologicalAge += 3;
    } else if (averageSteps < 7000) {
      biologicalAge += 1;
    }

    // 睡眠影响
    if (averageSleep >= 7 && averageSleep <= 8) {
      biologicalAge -= 1.5;
    } else if (averageSleep < 6 || averageSleep > 9) {
      biologicalAge += 2;
    } else if (averageSleep < 7 || averageSleep > 8) {
      biologicalAge += 0.5;
    }

    // 心率影响
    if (averageHeartRate >= 60 && averageHeartRate <= 75) {
      biologicalAge -= 1;
    } else if (averageHeartRate > 85) {
      biologicalAge += 1.5;
    } else if (averageHeartRate > 75) {
      biologicalAge += 0.5;
    }

    // 压力影响
    if (averageStress <= 2) {
      biologicalAge -= 0.5;
    } else if (averageStress >= 4) {
      biologicalAge += 2;
    } else if (averageStress == 3) {
      biologicalAge += 0.5;
    }

    // 运动影响
    if (averageExercise >= 60) {
      biologicalAge -= 1.5;
    } else if (averageExercise >= 30) {
      biologicalAge -= 0.5;
    } else if (averageExercise < 15) {
      biologicalAge += 1;
    }

    return biologicalAge.clamp(18.0, 100.0);
  }

  // 获取健康建议
  static List<String> getHealthRecommendations(HealthData healthData) {
    List<String> recommendations = [];

    if (healthData.steps < 8000) {
      recommendations.add('增加日常步数，建议每天至少8000步');
    }

    if (healthData.sleepHours < 7) {
      recommendations.add('保证充足睡眠，建议每晚7-8小时');
    }

    if (healthData.waterIntake < 8) {
      recommendations.add('增加饮水量，建议每天8杯水');
    }

    if (healthData.stressLevel > 3) {
      recommendations.add('尝试放松技巧，如冥想或深呼吸');
    }

    if (healthData.exerciseMinutes < 30) {
      recommendations.add('增加运动时间，建议每天至少30分钟');
    }

    if (recommendations.isEmpty) {
      recommendations.add('保持当前的健康习惯！');
    }

    return recommendations;
  }

  // 获取健康评分
  static int getHealthScore(HealthData healthData) {
    int score = 0;

    // 步数评分 (0-25分)
    if (healthData.steps >= 10000)
      score += 25;
    else if (healthData.steps >= 8000)
      score += 20;
    else if (healthData.steps >= 6000)
      score += 15;
    else if (healthData.steps >= 4000)
      score += 10;
    else
      score += 5;

    // 睡眠评分 (0-25分)
    if (healthData.sleepHours >= 7 && healthData.sleepHours <= 8)
      score += 25;
    else if (healthData.sleepHours >= 6 && healthData.sleepHours <= 9)
      score += 20;
    else if (healthData.sleepHours >= 5 && healthData.sleepHours <= 10)
      score += 15;
    else
      score += 10;

    // 饮水评分 (0-20分)
    if (healthData.waterIntake >= 8)
      score += 20;
    else if (healthData.waterIntake >= 6)
      score += 15;
    else if (healthData.waterIntake >= 4)
      score += 10;
    else
      score += 5;

    // 压力评分 (0-15分)
    if (healthData.stressLevel <= 2)
      score += 15;
    else if (healthData.stressLevel == 3)
      score += 10;
    else if (healthData.stressLevel == 4)
      score += 5;
    else
      score += 0;

    // 运动评分 (0-15分)
    if (healthData.exerciseMinutes >= 60)
      score += 15;
    else if (healthData.exerciseMinutes >= 30)
      score += 12;
    else if (healthData.exerciseMinutes >= 15)
      score += 8;
    else
      score += 4;

    return score;
  }

  // 更新挑战进度
  static Future<void> updateChallengeProgress(
      String challengeId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 这里可以添加实际的数据存储逻辑
  }

  // 完成任务
  static Future<void> completeTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 这里可以添加实际的数据存储逻辑
  }

  // 更新用户数据
  static Future<void> updateUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // 这里可以添加实际的数据存储逻辑
  }
}
