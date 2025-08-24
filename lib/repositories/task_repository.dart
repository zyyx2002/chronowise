import '../models/task.dart';
import '../services/database_service.dart';

class TaskRepository {
  final DatabaseService _dbService = DatabaseService();

  // 获取今日任务
  Future<List<Task>> getTodayTasks(int userId) async {
    try {
      print('🔍 TaskRepository: 开始获取今日任务...');
      print('🔍 TaskRepository: 用户ID: $userId');

      final tasks = await _dbService.getTasks(userId, DateTime.now());
      print('🔍 TaskRepository: 数据库返回任务数量: ${tasks.length}');

      // 如果没有任务，创建默认任务
      if (tasks.isEmpty) {
        print('🔍 TaskRepository: 创建默认任务...');
        await _createDefaultTasks(userId);
        final newTasks = await _dbService.getTasks(userId, DateTime.now());
        print('🔍 TaskRepository: 创建后任务数量: ${newTasks.length}');
        return newTasks;
      }

      return tasks;
    } catch (e) {
      print('❌ TaskRepository: 获取任务失败: $e');
      return [];
    }
  }

  // 完成任务
  Future<bool> completeTask(int taskId, int userId) async {
    try {
      print('🔍 TaskRepository: 尝试完成任务 ID: $taskId, 用户ID: $userId');

      // 使用正确的用户ID获取任务
      final tasks = await _dbService.getTasks(userId, DateTime.now());
      final task = tasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => throw Exception('Task not found'),
      );

      if (task.completed) {
        print('🔍 TaskRepository: 任务已经完成了');
        return false;
      }

      final updatedTask = task.copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );

      await _dbService.updateTask(updatedTask);
      print('✅ TaskRepository: 任务完成成功');
      return true;
    } catch (e) {
      print('❌ TaskRepository: 完成任务失败: $e');
      return false;
    }
  }

  // 取消完成任务
  Future<bool> uncompleteTask(int taskId, int userId) async {
    try {
      print('🔍 TaskRepository: 尝试取消任务 ID: $taskId, 用户ID: $userId');

      // 使用正确的用户ID获取任务
      final tasks = await _dbService.getTasks(userId, DateTime.now());
      final task = tasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => throw Exception('Task not found'),
      );

      if (!task.completed) {
        print('🔍 TaskRepository: 任务还没有完成');
        return false;
      }

      final updatedTask = task.copyWith(completed: false, completedAt: null);

      await _dbService.updateTask(updatedTask);
      print('✅ TaskRepository: 任务取消成功');
      return true;
    } catch (e) {
      print('❌ TaskRepository: 取消任务失败: $e');
      return false;
    }
  }

  // 创建默认任务
  Future<void> _createDefaultTasks(int userId) async {
    print('🔍 TaskRepository: 开始创建默认任务...');

    final today = DateTime.now();
    final defaultTasks = [
      Task(
        userId: userId,
        type: 'water',
        title: '喝水打卡',
        description: '今日喝水2.5升',
        targetDate: today,
        pointsReward: 10,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'exercise',
        title: '运动打卡',
        description: '运动30分钟',
        targetDate: today,
        pointsReward: 20,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'meditation',
        title: '冥想打卡',
        description: '冥想10分钟',
        targetDate: today,
        pointsReward: 15,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'sleep',
        title: '睡眠打卡',
        description: '睡眠8小时',
        targetDate: today,
        pointsReward: 15,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'nutrition',
        title: '营养打卡',
        description: '健康饮食',
        targetDate: today,
        pointsReward: 10,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'skincare',
        title: '护肤打卡',
        description: '护肤保养',
        targetDate: today,
        pointsReward: 10,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'supplement',
        title: '补剂打卡',
        description: '服用营养补剂',
        targetDate: today,
        pointsReward: 15,
        createdAt: DateTime.now(),
      ),
      Task(
        userId: userId,
        type: 'social',
        title: '社交打卡',
        description: '社交互动',
        targetDate: today,
        pointsReward: 10,
        createdAt: DateTime.now(),
      ),
    ];

    // 保存到数据库
    for (final task in defaultTasks) {
      try {
        await _dbService.insertTask(task);
        print('✅ TaskRepository: 任务创建成功: ${task.title}');
      } catch (e) {
        print('❌ TaskRepository: 任务创建失败: ${task.title}, 错误: $e');
      }
    }
  }
}
