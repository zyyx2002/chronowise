import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/task_provider.dart'; // 🆕 添加
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  // 🆕 改为StatefulWidget
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // 🆕 在组件初始化时加载任务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksIfNeeded();
    });
  }

  void _loadTasksIfNeeded() {
    final appProvider = Provider.of<AppStateProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // 如果有用户且任务列表为空，则加载任务
    if (appProvider.currentUser?.id != null &&
        taskProvider.todayTasks.isEmpty) {
      taskProvider.loadTodayTasks(appProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, TaskProvider>(
      // 🆕 使用Consumer2监听两个Provider
      builder: (context, appProvider, taskProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 顶部标题栏
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '今日任务',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${taskProvider.completedTasksToday}/${taskProvider.totalTasksToday}', // 🆕 使用TaskProvider的数据
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 进度条
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            taskProvider.completionRate, // 🆕 使用TaskProvider的数据
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 任务列表
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child:
                          taskProvider
                              .isLoading // 🆕 显示加载状态
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('正在加载任务...'),
                                ],
                              ),
                            )
                          : taskProvider
                                .todayTasks
                                .isEmpty // 🆕 使用TaskProvider的数据
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '暂无任务',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: taskProvider
                                  .todayTasks
                                  .length, // 🆕 使用TaskProvider的数据
                              itemBuilder: (context, index) {
                                final task = taskProvider
                                    .todayTasks[index]; // 🆕 使用TaskProvider的数据
                                return _buildTaskCard(
                                  context,
                                  task,
                                  taskProvider,
                                ); // 🆕 传递TaskProvider
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🆕 修改方法签名，使用TaskProvider而不是AppStateProvider
  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    TaskProvider taskProvider, // 🆕 改为TaskProvider
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: task.completed ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.completed ? Colors.green.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: task.completed ? Colors.green : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              _getTaskIcon(task.type),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(
                color: task.completed ? Colors.grey : Colors.grey.shade600,
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  '${task.pointsReward} 积分',
                  style: TextStyle(
                    color: Colors.amber.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: task.completed ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.completed ? '已完成' : '待完成',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () async {
            if (task.completed) {
              await taskProvider.uncompleteTask(
                task.id!,
              ); // 🆕 使用TaskProvider的方法
            } else {
              await taskProvider.completeTask(task.id!); // 🆕 使用TaskProvider的方法
            }
          },
          icon: Icon(
            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.completed ? Colors.green : Colors.grey.shade400,
            size: 32,
          ),
        ),
      ),
    );
  }

  // 获取任务图标的辅助方法
  String _getTaskIcon(String type) {
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
      case 'supplement':
        return '💊';
      case 'social':
        return '👥';
      default:
        return '✅';
    }
  }
}
