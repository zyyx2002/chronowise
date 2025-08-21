class User {
  // === 数据库原有字段 ===
  final int? id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String goal;
  final DateTime createdAt;
  final DateTime updatedAt;

  // === 游戏化字段 ===
  final int biologicalAge;
  final int smartCoins;
  final int dailyTasks;
  final int completedTasks;
  final int streakDays;
  final int level;
  final int totalPoints;
  final String avatar;
  final String joinDate;
  final int totalDays;

  User({
    this.id,
    required this.name,
    required this.age,
    this.gender = '未设置',
    this.height = 170.0,
    this.weight = 65.0,
    this.goal = '保持健康',
    required this.createdAt,
    required this.updatedAt,
    // 游戏化字段默认值
    this.biologicalAge = 32,
    this.smartCoins = 120,
    this.dailyTasks = 8,
    this.completedTasks = 0,
    this.streakDays = 0,
    this.level = 1,
    this.totalPoints = 0,
    this.avatar = '',
    this.joinDate = '',
    this.totalDays = 0,
  });

  // === 数据库映射方法 ===
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      // 游戏化字段
      'biological_age': biologicalAge,
      'smart_coins': smartCoins,
      'daily_tasks': dailyTasks,
      'completed_tasks': completedTasks,
      'streak_days': streakDays,
      'level': level,
      'total_points': totalPoints,
      'avatar': avatar,
      'join_date': joinDate,
      'total_days': totalDays,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '未设置',
      height: map['height']?.toDouble() ?? 170.0,
      weight: map['weight']?.toDouble() ?? 65.0,
      goal: map['goal'] ?? '保持健康',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      // 游戏化字段
      biologicalAge: map['biological_age'] ?? 32,
      smartCoins: map['smart_coins'] ?? 120,
      dailyTasks: map['daily_tasks'] ?? 8,
      completedTasks: map['completed_tasks'] ?? 0,
      streakDays: map['streak_days'] ?? 0,
      level: map['level'] ?? 1,
      totalPoints: map['total_points'] ?? 0,
      avatar: map['avatar'] ?? '',
      joinDate: map['join_date'] ?? '',
      totalDays: map['total_days'] ?? 0,
    );
  }

  // === 业务方法 ===
  User copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? biologicalAge,
    int? smartCoins,
    int? dailyTasks,
    int? completedTasks,
    int? streakDays,
    int? level,
    int? totalPoints,
    String? avatar,
    String? joinDate,
    int? totalDays,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      biologicalAge: biologicalAge ?? this.biologicalAge,
      smartCoins: smartCoins ?? this.smartCoins,
      dailyTasks: dailyTasks ?? this.dailyTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
      avatar: avatar ?? this.avatar,
      joinDate: joinDate ?? this.joinDate,
      totalDays: totalDays ?? this.totalDays,
    );
  }

  // === 便利访问器 ===
  String get displayName => name.isNotEmpty ? name : 'ChronoWise用户';

  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  double get levelProgress => (totalPoints % 1000) / 1000.0;

  int get pointsToNextLevel => 1000 - (totalPoints % 1000);

  // === JSON序列化（用于SharedPreferences） ===
  Map<String, dynamic> toJson() => toMap();
  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);
}
