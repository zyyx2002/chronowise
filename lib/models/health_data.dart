class HealthData {
  final String id;
  final DateTime date;
  final double? weight;
  final int? exerciseMinutes;
  final double? sleepHours;
  final int? waterGlasses;
  final String mood;
  final String notes;

  HealthData({
    required this.id,
    required this.date,
    this.weight,
    this.exerciseMinutes,
    this.sleepHours,
    this.waterGlasses,
    this.mood = 'neutral',
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weight': weight,
      'exerciseMinutes': exerciseMinutes,
      'sleepHours': sleepHours,
      'waterGlasses': waterGlasses,
      'mood': mood,
      'notes': notes,
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      weight: json['weight']?.toDouble(),
      exerciseMinutes: json['exerciseMinutes'],
      sleepHours: json['sleepHours']?.toDouble(),
      waterGlasses: json['waterGlasses'],
      mood: json['mood'] ?? 'neutral',
      notes: json['notes'] ?? '',
    );
  }

  HealthData copyWith({
    String? id,
    DateTime? date,
    double? weight,
    int? exerciseMinutes,
    double? sleepHours,
    int? waterGlasses,
    String? mood,
    String? notes,
  }) {
    return HealthData(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      sleepHours: sleepHours ?? this.sleepHours,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
    );
  }
}
