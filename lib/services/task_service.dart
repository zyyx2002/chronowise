import '../models/task.dart';
import 'database_service.dart';

class TaskService {
  static const String tableName = 'tasks';

  // ===== 获取数据库实例 =====
  static Future<dynamic> _getDatabase() async {
    return await DatabaseService().database;
  }

  // ===== 核心CRUD操作 =====
  static Future<int> createTask(Task task) async {
    final db = await _getDatabase();
    if (db == null) return -1; // Web平台返回-1表示失败
    return await db.insert(tableName, task.toMap());
  }

  static Future<Task?> getTaskById(int id) async {
    final db = await _getDatabase();
    if (db == null) return null;

    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Task>> getTasksByUser(int userId) async {
    final db = await _getDatabase();
    if (db == null) return [];

    final maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'target_date ASC, created_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ===== 今日任务专用方法 =====
  static Future<List<Task>> getTodayTasks(int userId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final db = await _getDatabase();
    if (db == null) return [];

    final maps = await db.query(
      tableName,
      where: 'user_id = ? AND target_date = ?',
      whereArgs: [userId, today],
      orderBy: 'completed ASC, created_at ASC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  static Future<int> getTodayCompletedCount(int userId) async {
    final todayTasks = await getTodayTasks(userId);
    return todayTasks.where((task) => task.completed).length;
  }

  static Future<int> getTodayTotalCount(int userId) async {
    final todayTasks = await getTodayTasks(userId);
    return todayTasks.length;
  }

  // ===== 任务状态管理 =====
  static Future<bool> completeTask(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null || task.completed) return false;

    final updatedTask = task.copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );

    final db = await _getDatabase();
    if (db == null) return false;

    final result = await db.update(
      tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [taskId],
    );

    return result > 0;
  }

  static Future<bool> uncompleteTask(int taskId) async {
    final task = await getTaskById(taskId);
    if (task == null || !task.completed) return false;

    final updatedTask = task.copyWith(completed: false, completedAt: null);

    final db = await _getDatabase();
    if (db == null) return false;

    final result = await db.update(
      tableName,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [taskId],
    );

    return result > 0;
  }

  // ===== 过期任务管理 =====
  static Future<List<Task>> getOverdueTasks(int userId) async {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final db = await _getDatabase();
    if (db == null) return [];

    final maps = await db.query(
      tableName,
      where: 'user_id = ? AND target_date < ? AND completed = 0',
      whereArgs: [userId, today],
      orderBy: 'target_date DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // ===== 数据清理 =====
  static Future<int> deleteTask(int taskId) async {
    final db = await _getDatabase();
    if (db == null) return 0;

    return await db.delete(tableName, where: 'id = ?', whereArgs: [taskId]);
  }

  static Future<int> deleteCompletedTasks(int userId) async {
    final db = await _getDatabase();
    if (db == null) return 0;

    return await db.delete(
      tableName,
      where: 'user_id = ? AND completed = 1',
      whereArgs: [userId],
    );
  }
}
