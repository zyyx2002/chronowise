class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconData;
  final DateTime unlockedDate;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    required this.unlockedDate,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconData': iconData,
      'unlockedDate': unlockedDate.toIso8601String(),
      'category': category,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconData: json['iconData'],
      unlockedDate: DateTime.parse(json['unlockedDate']),
      category: json['category'],
    );
  }
}
