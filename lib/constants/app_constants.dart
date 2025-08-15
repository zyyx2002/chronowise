class AppConstants {
  // 应用信息
  static const String appName = 'ChronoWise';
  static const String appVersion = '1.0.0';
  static const String appDescription = '科学抗衰老应用';

  // 任务类型
  static const Map<String, String> taskNames = {
    'water': '💧 饮水',
    'exercise': '🏃 运动',
    'sleep': '😴 睡眠',
    'meditation': '🧘 冥想',
    'nutrition': '🥗 营养',
    'skincare': '🧴 护肤',
    'supplement': '💊 补剂',
    'social': '👥 社交',
  };

  // 奖励点数
  static const int taskRewardPoints = 10;
  static const int dailyCompleteBonus = 50;
  static const int streakBonus = 20;

  // 等级系统
  static const List<int> levelRequirements = [
    0,
    100,
    300,
    600,
    1000,
    1500,
    2200,
    3000,
    4000,
    5200,
    6600
  ];

  // VIP功能
  static const List<String> vipFeatures = [
    '高级数据分析',
    '个性化建议',
    '专属挑战',
    '优先客服',
    '无限存储',
  ];

  // 徽章系统
  static const Map<String, String> badgeDescriptions = {
    '断食21天': '连续21天完成间歇性断食',
    '冥想大师': '累计冥想100小时',
    '运动狂魔': '连续30天完成运动任务',
    '睡眠优化师': '连续14天保持优质睡眠',
    '营养专家': '连续7天完成营养记录',
  };

  // 社交等级
  static const List<String> socialLevels = [
    '新手圈',
    '青铜圈',
    '白银圈',
    '黄金圈',
    '铂金圈',
    '钻石圈',
    '大师圈'
  ];

  // 默认设置
  static const Map<String, dynamic> defaultSettings = {
    'notifications': true,
    'darkMode': false,
    'language': 'zh',
    'reminderTime': '09:00',
    'weeklyReport': true,
  };
}
