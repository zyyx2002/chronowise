enum ChallengeType { daily, weekly, monthly, special, social }

enum ChallengeDifficulty { easy, medium, hard, expert }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int durationDays;
  final double reward;
  final double experienceReward;
  final List<String> requirements;
  final DateTime startDate;
  final DateTime endDate;
  bool isActive;
  bool isCompleted;
  double progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.difficulty,
    required this.durationDays,
    required this.reward,
    required this.experienceReward,
    required this.requirements,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🎯',
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == 'ChallengeType.${json['type']}',
        orElse: () => ChallengeType.daily,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.toString() == 'ChallengeDifficulty.${json['difficulty']}',
        orElse: () => ChallengeDifficulty.easy,
      ),
      durationDays: json['durationDays'] ?? 1,
      reward: (json['reward'] ?? 0).toDouble(),
      experienceReward: (json['experienceReward'] ?? 0).toDouble(),
      requirements: List<String>.from(json['requirements'] ?? []),
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ??
          DateTime.now().add(const Duration(days: 1)).toIso8601String()),
      isActive: json['isActive'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'durationDays': durationDays,
      'reward': reward,
      'experienceReward': experienceReward,
      'requirements': requirements,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    int? durationDays,
    double? reward,
    double? experienceReward,
    List<String>? requirements,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isCompleted,
    double? progress,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      durationDays: durationDays ?? this.durationDays,
      reward: reward ?? this.reward,
      experienceReward: experienceReward ?? this.experienceReward,
      requirements: requirements ?? this.requirements,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
}
