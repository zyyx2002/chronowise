class UserModel {
  String name;
  int age;
  String gender;
  double biologicalAge;
  int smartCoins;
  int level;
  int totalPoints;
  int streakDays;
  int healthScore;
  DateTime joinDate;

  UserModel({
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.biologicalAge = 32.0,
    this.smartCoins = 120,
    this.level = 1,
    this.totalPoints = 0,
    this.streakDays = 0,
    this.healthScore = 85,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'biologicalAge': biologicalAge,
      'smartCoins': smartCoins,
      'level': level,
      'totalPoints': totalPoints,
      'streakDays': streakDays,
      'healthScore': healthScore,
      'joinDate': joinDate.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      biologicalAge: json['biologicalAge']?.toDouble() ?? 32.0,
      smartCoins: json['smartCoins'] ?? 120,
      level: json['level'] ?? 1,
      totalPoints: json['totalPoints'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      healthScore: json['healthScore'] ?? 85,
      joinDate:
          DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
