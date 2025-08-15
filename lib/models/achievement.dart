class Achievement {
  final String id;
  final String name;
  final String title;
  final String description;
  final String icon;
  final String category;
  final String type;
  final int requirement;
  final int requiredValue;
  int currentProgress;
  bool isUnlocked;
  DateTime? unlockedAt;
  final int reward;
  final int experienceReward;

  Achievement({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.type,
    required this.requirement,
    required this.requiredValue,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.reward = 0,
    this.experienceReward = 0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      requirement: json['requirement'] ?? 0,
      requiredValue: json['requiredValue'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      reward: json['reward'] ?? 0,
      experienceReward: json['experienceReward'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'type': type,
      'requirement': requirement,
      'requiredValue': requiredValue,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'reward': reward,
      'experienceReward': experienceReward,
    };
  }

  double get progress =>
      requirement > 0 ? (currentProgress / requirement).clamp(0.0, 1.0) : 0.0;
}
