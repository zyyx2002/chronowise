class HealthRecord {
  final int? id;
  final int userId;
  final DateTime date;
  final int? steps;
  final double? water; // 升
  final int? sleepHours;
  final int? exerciseMinutes;
  final int? meditationMinutes;
  final int? readingMinutes;
  final int? socialMinutes;
  final bool? skincare;
  final int? nutritionScore; // 1-10 分
  final DateTime createdAt;

  HealthRecord({
    this.id,
    required this.userId,
    required this.date,
    this.steps,
    this.water,
    this.sleepHours,
    this.exerciseMinutes,
    this.meditationMinutes,
    this.readingMinutes,
    this.socialMinutes,
    this.skincare,
    this.nutritionScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': _dateToString(date),
      'steps': steps,
      'water': water,
      'sleep_hours': sleepHours,
      'exercise_minutes': exerciseMinutes,
      'meditation_minutes': meditationMinutes,
      'reading_minutes': readingMinutes,
      'social_minutes': socialMinutes,
      'skincare': skincare == true ? 1 : 0,
      'nutrition_score': nutritionScore,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      userId: map['user_id'],
      date: _stringToDate(map['date']),
      steps: map['steps'],
      water: map['water'],
      sleepHours: map['sleep_hours'],
      exerciseMinutes: map['exercise_minutes'],
      meditationMinutes: map['meditation_minutes'],
      readingMinutes: map['reading_minutes'],
      socialMinutes: map['social_minutes'],
      skincare: map['skincare'] == 1,
      nutritionScore: map['nutrition_score'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  HealthRecord copyWith({
    int? id,
    int? userId,
    DateTime? date,
    int? steps,
    double? water,
    int? sleepHours,
    int? exerciseMinutes,
    int? meditationMinutes,
    int? readingMinutes,
    int? socialMinutes,
    bool? skincare,
    int? nutritionScore,
    DateTime? createdAt,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      water: water ?? this.water,
      sleepHours: sleepHours ?? this.sleepHours,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      readingMinutes: readingMinutes ?? this.readingMinutes,
      socialMinutes: socialMinutes ?? this.socialMinutes,
      skincare: skincare ?? this.skincare,
      nutritionScore: nutritionScore ?? this.nutritionScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 辅助方法：将 DateTime 转换为 YYYY-MM-DD 字符串
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 辅助方法：将 YYYY-MM-DD 字符串转换为 DateTime
  static DateTime _stringToDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // 计算健康得分 (0-100)
  int get healthScore {
    int score = 0;
    int totalItems = 0;

    // 步数 (目标 8000)
    if (steps != null) {
      totalItems++;
      if (steps! >= 8000)
        score += 15;
      else if (steps! >= 5000)
        score += 10;
      else if (steps! >= 3000)
        score += 5;
    }

    // 饮水 (目标 2.5L)
    if (water != null) {
      totalItems++;
      if (water! >= 2.5)
        score += 10;
      else if (water! >= 2.0)
        score += 7;
      else if (water! >= 1.5)
        score += 5;
    }

    // 睡眠 (目标 8小时)
    if (sleepHours != null) {
      totalItems++;
      if (sleepHours! >= 7 && sleepHours! <= 9)
        score += 15;
      else if (sleepHours! >= 6 && sleepHours! <= 10)
        score += 10;
      else if (sleepHours! >= 5)
        score += 5;
    }

    // 运动 (目标 30分钟)
    if (exerciseMinutes != null) {
      totalItems++;
      if (exerciseMinutes! >= 30)
        score += 15;
      else if (exerciseMinutes! >= 20)
        score += 10;
      else if (exerciseMinutes! >= 10)
        score += 5;
    }

    // 冥想 (目标 10分钟)
    if (meditationMinutes != null) {
      totalItems++;
      if (meditationMinutes! >= 10)
        score += 10;
      else if (meditationMinutes! >= 5)
        score += 7;
      else if (meditationMinutes! > 0)
        score += 3;
    }

    // 阅读 (目标 30分钟)
    if (readingMinutes != null) {
      totalItems++;
      if (readingMinutes! >= 30)
        score += 10;
      else if (readingMinutes! >= 15)
        score += 7;
      else if (readingMinutes! > 0)
        score += 3;
    }

    // 社交 (目标有社交活动)
    if (socialMinutes != null) {
      totalItems++;
      if (socialMinutes! >= 60)
        score += 10;
      else if (socialMinutes! >= 30)
        score += 7;
      else if (socialMinutes! > 0)
        score += 5;
    }

    // 护肤
    if (skincare != null) {
      totalItems++;
      if (skincare!) score += 5;
    }

    // 营养评分
    if (nutritionScore != null) {
      totalItems++;
      score += (nutritionScore! * 1.5).round(); // 最高15分
    }

    // 如果没有数据，返回0
    if (totalItems == 0) return 0;

    // 返回按比例计算的分数 (0-100)
    return (score * 100 / 100).clamp(0, 100).round();
  }
}
