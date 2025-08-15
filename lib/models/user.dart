class User {
  final String id;
  final String name;
  final String email;
  final int age;
  final double height;
  final double weight;
  final String gender;
  double smartCoins;
  int level;
  double experience;
  int streakDays;
  double biologicalAge;
  int longestStreak;
  final DateTime dateOfBirth;
  double totalPoints;
  final DateTime joinDate;
  List<String> completedTasks;
  List<String> dailyTasks;
  String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    this.smartCoins = 0.0,
    this.level = 1,
    this.experience = 0.0,
    this.streakDays = 0,
    this.biologicalAge = 0.0,
    this.longestStreak = 0,
    required this.dateOfBirth,
    this.totalPoints = 0.0,
    required this.joinDate,
    this.completedTasks = const [],
    this.dailyTasks = const [],
    this.avatar = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 25,
      height: (json['height'] ?? 170).toDouble(),
      weight: (json['weight'] ?? 70).toDouble(),
      gender: json['gender'] ?? 'male',
      smartCoins: (json['smartCoins'] ?? 0).toDouble(),
      level: json['level'] ?? 1,
      experience: (json['experience'] ?? 0).toDouble(),
      streakDays: json['streakDays'] ?? 0,
      biologicalAge: (json['biologicalAge'] ?? 25).toDouble(),
      longestStreak: json['longestStreak'] ?? 0,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? '1999-01-01'),
      totalPoints: (json['totalPoints'] ?? 0).toDouble(),
      joinDate:
          DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      completedTasks: List<String>.from(json['completedTasks'] ?? []),
      dailyTasks: List<String>.from(json['dailyTasks'] ?? []),
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'smartCoins': smartCoins,
      'level': level,
      'experience': experience,
      'streakDays': streakDays,
      'biologicalAge': biologicalAge,
      'longestStreak': longestStreak,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'totalPoints': totalPoints,
      'joinDate': joinDate.toIso8601String(),
      'completedTasks': completedTasks,
      'dailyTasks': dailyTasks,
      'avatar': avatar,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? gender,
    double? smartCoins,
    int? level,
    double? experience,
    int? streakDays,
    double? biologicalAge,
    int? longestStreak,
    DateTime? dateOfBirth,
    double? totalPoints,
    DateTime? joinDate,
    List<String>? completedTasks,
    List<String>? dailyTasks,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      smartCoins: smartCoins ?? this.smartCoins,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      streakDays: streakDays ?? this.streakDays,
      biologicalAge: biologicalAge ?? this.biologicalAge,
      longestStreak: longestStreak ?? this.longestStreak,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      totalPoints: totalPoints ?? this.totalPoints,
      joinDate: joinDate ?? this.joinDate,
      completedTasks: completedTasks ?? List.from(this.completedTasks),
      dailyTasks: dailyTasks ?? List.from(this.dailyTasks),
      avatar: avatar ?? this.avatar,
    );
  }
}
