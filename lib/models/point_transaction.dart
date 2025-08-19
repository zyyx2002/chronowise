class PointTransaction {
  final int? id;
  final int userId;
  final int points; // 可以是正数或负数
  final String type; // 'task', 'bonus', 'daily_login', 'penalty', etc.
  final String description;
  final DateTime createdAt;

  PointTransaction({
    this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'type': type,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PointTransaction.fromMap(Map<String, dynamic> map) {
    return PointTransaction(
      id: map['id'],
      userId: map['user_id'],
      points: map['points'],
      type: map['type'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  PointTransaction copyWith({
    int? id,
    int? userId,
    int? points,
    String? type,
    String? description,
    DateTime? createdAt,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 获取积分变化的显示文本
  String get pointsDisplay {
    return points > 0 ? '+$points' : '$points';
  }

  // 获取类型的显示文本
  String get typeDisplay {
    switch (type) {
      case 'task':
        return '任务完成';
      case 'bonus':
        return '奖励';
      case 'daily_login':
        return '每日签到';
      case 'penalty':
        return '扣分';
      case 'achievement':
        return '成就奖励';
      case 'health_bonus':
        return '健康奖励';
      default:
        return '其他';
    }
  }

  // 获取积分变化的颜色（用于UI显示）
  bool get isPositive => points > 0;
}
