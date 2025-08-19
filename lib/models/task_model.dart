class TaskModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int reward;
  final String category;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.reward,
    required this.category,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? reward,
    String? category,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      reward: reward ?? this.reward,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'reward': reward,
      'category': category,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      reward: json['reward'],
      category: json['category'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
