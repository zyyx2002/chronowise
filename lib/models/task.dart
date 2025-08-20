class Task {
  final int? id;
  final int userId;
  final String type; // 'water', 'exercise', 'meditation', etc.
  final String title;
  final String description;
  final DateTime targetDate;
  final int pointsReward;
  final bool completed;
  final DateTime? completedAt;
  final DateTime createdAt;

  Task({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.pointsReward,
    this.completed = false,
    this.completedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'target_date': _dateToString(targetDate),
      'points_reward': pointsReward,
      'completed': completed ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      title: map['title'],
      description: map['description'],
      targetDate: _stringToDate(map['target_date']),
      pointsReward: map['points_reward'],
      completed: map['completed'] == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Task copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? description,
    DateTime? targetDate,
    int? pointsReward,
    bool? completed,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      pointsReward: pointsReward ?? this.pointsReward,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
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

  // 检查任务是否过期
  bool get isOverdue {
    if (completed) {return false;}
    final now = DateTime.now();
    return targetDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  // 检查是否为今日任务
  bool get isToday {
    final now = DateTime.now();
    return targetDate.year == now.year &&
        targetDate.month == now.month &&
        targetDate.day == now.day;
  }

  // 获取任务类型的图标
  String get iconData {
    switch (type) {
      case 'water':
        return '💧';
      case 'exercise':
        return '🏃‍♂️';
      case 'meditation':
        return '🧘‍♀️';
      case 'sleep':
        return '😴';
      case 'nutrition':
        return '🥗';
      case 'skincare':
        return '🧴';
      case 'reading':
        return '📚';
      case 'social':
        return '👥';
      default:
        return '✅';
    }
  }

  // 获取任务状态的显示文本
  String get statusDisplay {
    if (completed) {
      return '已完成';
    } else if (isOverdue) {
      return '已过期';
    } else if (isToday) {
      return '今日任务';
    } else {
      return '待完成';
    }
  }
}
