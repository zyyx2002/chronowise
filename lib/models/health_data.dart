class HealthData {
  final int steps;
  final int heartRate;
  final double sleepHours;
  final int waterIntake;
  final int calories;
  final double weight;
  final String bloodPressure;
  final int stressLevel;
  final int mood;
  final int exerciseMinutes;
  final DateTime timestamp;
  final int completedTasks;
  final double completionRate;
  final DateTime date;
  final int streakDays;
  final List<String> tasks;
  final double wisdomCoins;

  HealthData({
    this.steps = 0,
    this.heartRate = 70,
    this.sleepHours = 7.0,
    this.waterIntake = 0,
    this.calories = 0,
    this.weight = 70.0,
    this.bloodPressure = '120/80',
    this.stressLevel = 1,
    this.mood = 3,
    this.exerciseMinutes = 0,
    required this.timestamp,
    this.completedTasks = 0,
    this.completionRate = 0.0,
    required this.date,
    this.streakDays = 0,
    this.tasks = const [],
    this.wisdomCoins = 0.0,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      steps: json['steps'] ?? 0,
      heartRate: json['heartRate'] ?? 70,
      sleepHours: (json['sleepHours'] ?? 7.0).toDouble(),
      waterIntake: json['waterIntake'] ?? 0,
      calories: json['calories'] ?? 0,
      weight: (json['weight'] ?? 70.0).toDouble(),
      bloodPressure: json['bloodPressure'] ?? '120/80',
      stressLevel: json['stressLevel'] ?? 1,
      mood: json['mood'] ?? 3,
      exerciseMinutes: json['exerciseMinutes'] ?? 0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      completedTasks: json['completedTasks'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      streakDays: json['streakDays'] ?? 0,
      tasks: List<String>.from(json['tasks'] ?? []),
      wisdomCoins: (json['wisdomCoins'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'heartRate': heartRate,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'calories': calories,
      'weight': weight,
      'bloodPressure': bloodPressure,
      'stressLevel': stressLevel,
      'mood': mood,
      'exerciseMinutes': exerciseMinutes,
      'timestamp': timestamp.toIso8601String(),
      'completedTasks': completedTasks,
      'completionRate': completionRate,
      'date': date.toIso8601String(),
      'streakDays': streakDays,
      'tasks': tasks,
      'wisdomCoins': wisdomCoins,
    };
  }

  HealthData copyWith({
    int? steps,
    int? heartRate,
    double? sleepHours,
    int? waterIntake,
    int? calories,
    double? weight,
    String? bloodPressure,
    int? stressLevel,
    int? mood,
    int? exerciseMinutes,
    DateTime? timestamp,
    int? completedTasks,
    double? completionRate,
    DateTime? date,
    int? streakDays,
    List<String>? tasks,
    double? wisdomCoins,
  }) {
    return HealthData(
      steps: steps ?? this.steps,
      heartRate: heartRate ?? this.heartRate,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      calories: calories ?? this.calories,
      weight: weight ?? this.weight,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      stressLevel: stressLevel ?? this.stressLevel,
      mood: mood ?? this.mood,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      timestamp: timestamp ?? this.timestamp,
      completedTasks: completedTasks ?? this.completedTasks,
      completionRate: completionRate ?? this.completionRate,
      date: date ?? this.date,
      streakDays: streakDays ?? this.streakDays,
      tasks: tasks ?? this.tasks,
      wisdomCoins: wisdomCoins ?? this.wisdomCoins,
    );
  }
}
