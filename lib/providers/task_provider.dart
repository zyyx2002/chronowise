import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();

  // === 状态管理 ===
  List<Task> _todayTasks = [];
  bool _isLoading = false;
  String? _error;

  // === Getters ===
  List<Task> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 计算属性
  int get completedTasksToday =>
      _todayTasks.where((task) => task.completed).length;

  int get totalTasksToday => _todayTasks.length;

  double get completionRate =>
      totalTasksToday > 0 ? completedTasksToday / totalTasksToday : 0.0;

  // === 核心方法 ===

  /// 加载今日任务
  Future<void> loadTodayTasks(int userId) async {
    if (_isLoading) return; // 防止重复加载

    print('🔍 TaskProvider: 开始加载今日任务, 用户ID: $userId');

    _setLoading(true);
    _error = null;

    try {
      final tasks = await _taskRepository.getTodayTasks(userId);
      _todayTasks = tasks;
      print('✅ TaskProvider: 任务加载成功，数量: ${tasks.length}');
      _setLoading(false);
    } catch (e) {
      print('❌ TaskProvider: 加载任务失败: $e');
      _error = '加载任务失败：$e';
      _setLoading(false);
    }
  }

  /// 完成任务
  Future<bool> completeTask(int taskId) async {
    try {
      print('🔍 TaskProvider: 完成任务 $taskId');

      final success = await _taskRepository.completeTask(taskId);

      if (success) {
        // 更新本地状态
        final taskIndex = _todayTasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _todayTasks[taskIndex] = _todayTasks[taskIndex].copyWith(
            completed: true,
            completedAt: DateTime.now(),
          );
          notifyListeners();
          print('✅ TaskProvider: 任务状态更新成功');
        }
      }

      return success;
    } catch (e) {
      print('❌ TaskProvider: 完成任务失败: $e');
      _error = '完成任务失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 取消完成任务
  Future<bool> uncompleteTask(int taskId) async {
    try {
      print('🔍 TaskProvider: 取消完成任务 $taskId');

      final success = await _taskRepository.uncompleteTask(taskId);

      if (success) {
        // 更新本地状态
        final taskIndex = _todayTasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _todayTasks[taskIndex] = _todayTasks[taskIndex].copyWith(
            completed: false,
            completedAt: null,
          );
          notifyListeners();
          print('✅ TaskProvider: 任务状态更新成功');
        }
      }

      return success;
    } catch (e) {
      print('❌ TaskProvider: 取消任务失败: $e');
      _error = '取消任务失败：$e';
      notifyListeners();
      return false;
    }
  }

  /// 刷新任务列表
  Future<void> refreshTasks(int userId) async {
    print('🔄 TaskProvider: 刷新任务列表');
    await loadTodayTasks(userId);
  }

  /// 获取指定任务
  Task? getTaskById(int taskId) {
    try {
      return _todayTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // === 私有方法 ===
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // === 清理方法 ===
  void clearTasks() {
    _todayTasks.clear();
    _error = null;
    notifyListeners();
  }

  // === 调试方法 ===
  void debugPrintTasks() {
    print('📋 TaskProvider Debug - 当前任务:');
    for (int i = 0; i < _todayTasks.length; i++) {
      final task = _todayTasks[i];
      print('  [$i] ${task.title} - ${task.completed ? "已完成" : "未完成"}');
    }
    print(
      '📊 完成情况: $completedTasksToday/$totalTasksToday (${(completionRate * 100).toStringAsFixed(1)}%)',
    );
  }
}
