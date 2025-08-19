import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_data_provider.dart';

class SmartAgeScreen extends StatelessWidget {
  const SmartAgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '智龄打卡',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // 顶部进度卡片
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '今日完成度',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: provider.completionRate,
                              strokeWidth: 8,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '${(provider.completionRate * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${provider.completedTasks}/${provider.totalTasks}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getMotivationalText(provider.completionRate),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // 打卡任务列表
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final taskId =
                          provider.todayCheckins.keys.elementAt(index);
                      final isCompleted =
                          provider.todayCheckins[taskId] ?? false;
                      final taskInfo = provider.getTaskInfo(taskId);
                      final reward = provider.getTaskReward(taskId);

                      return _buildTaskCard(
                        context,
                        taskId,
                        taskInfo,
                        reward,
                        isCompleted,
                        provider,
                      );
                    },
                    childCount: provider.todayCheckins.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskInfo,
    int reward,
    bool isCompleted,
    HealthDataProvider provider,
  ) {
    return GestureDetector(
      onTap: isCompleted
          ? null
          : () => _showTaskDialog(context, taskId, taskInfo, reward, provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                taskInfo['icon'] ?? '❓',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                taskInfo['name'] ?? '未知任务',
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '+$reward 智龄积分',
                style: TextStyle(
                  color: isCompleted ? Colors.white70 : const Color(0xFF667EEA),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(
    BuildContext context,
    String taskId,
    Map<String, dynamic> taskInfo,
    int reward,
    HealthDataProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(taskInfo['icon'] ?? '❓', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                taskInfo['name'] ?? '未知任务',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskInfo['desc'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFF667EEA)),
                  const SizedBox(width: 8),
                  Text(
                    '完成可获得 $reward 智龄积分',
                    style: const TextStyle(
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.completeTask(taskId);
              if (success && context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('🎉 恭喜完成「${taskInfo['name']}」！获得 $reward 智龄积分'),
                    backgroundColor: const Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('完成打卡'),
          ),
        ],
      ),
    );
  }

  String _getMotivationalText(double completionRate) {
    if (completionRate >= 1.0) {
      return '🎉 太棒了！今天所有任务都完成了！';
    } else if (completionRate >= 0.75) {
      return '💪 做得很好！再坚持一下就完成了！';
    } else if (completionRate >= 0.5) {
      return '🚀 进展不错！继续加油！';
    } else if (completionRate > 0) {
      return '🌱 很好的开始！一步一步来！';
    } else {
      return '✨ 新的一天开始了，让我们一起变得更年轻！';
    }
  }
}
