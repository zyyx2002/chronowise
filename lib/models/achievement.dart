class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconData;
  final DateTime? unlockedDate; // 🆕 改为可选，未解锁时为 null
  final String category;
  final bool unlocked; // 🆕 添加解锁状态字段

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconData,
    this.unlockedDate, // 🆕 可选参数
    required this.category,
    required this.unlocked, // 🆕 必填参数
  });

  // 🆕 便捷的 getter，兼容旧代码
  String get name => title;
  String get desc => description;
  String get icon => iconData;
  String? get date => unlockedDate?.toIso8601String();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconData': iconData,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'category': category,
      'unlocked': unlocked,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconData: json['iconData'],
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
      category: json['category'],
      unlocked: json['unlocked'] ?? false,
    );
  }

  // 🆕 创建未解锁成就的工厂方法
  factory Achievement.locked({
    required String id,
    required String title,
    required String description,
    required String iconData,
    required String category,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconData: iconData,
      category: category,
      unlocked: false,
    );
  }

  // 🆕 解锁成就的方法
  Achievement unlock() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconData: iconData,
      unlockedDate: DateTime.now(),
      category: category,
      unlocked: true,
    );
  }
}
