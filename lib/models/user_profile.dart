class UserProfile {
  String name;
  String age;
  int biologicalAge;
  int smartCoins;
  int dailyTasks;
  int completedTasks;
  int streakDays;
  int level;
  int totalPoints;
  String avatar;
  String joinDate;
  int totalDays;

  UserProfile({
    this.name = '',
    this.age = '',
    this.biologicalAge = 32,
    this.smartCoins = 120,
    this.dailyTasks = 8,
    this.completedTasks = 3,
    this.streakDays = 7,
    this.level = 3,
    this.totalPoints = 2840,
    this.avatar = '',
    this.joinDate = '2024-05-01',
    this.totalDays = 47,
  });
}

class Achievement {
  final int id;
  final String name;
  final String desc;
  final String icon;
  final bool unlocked;
  final String? date;

  Achievement({
    required this.id,
    required this.name,
    required this.desc,
    required this.icon,
    required this.unlocked,
    this.date,
  });
}

class LeaderboardUser {
  final int rank;
  final String name;
  final int smartAge;
  final int coins;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.smartAge,
    required this.coins,
  });
}
