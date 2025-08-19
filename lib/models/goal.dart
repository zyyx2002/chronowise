class Goal {
  final String id;
  final String title;
  final String type; // weight, exercise, sleep, water
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'targetValue': targetValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      targetValue: json['targetValue'].toDouble(),
      unit: json['unit'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Goal copyWith({
    String? id,
    String? title,
    String? type,
    double? targetValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
