import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/task_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, TaskProvider>(
      builder: (context, appProvider, taskProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('仪表板'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(appProvider),
                const SizedBox(height: 16),
                _buildHealthScoreCard(appProvider),
                const SizedBox(height: 16),
                _buildTodayProgress(appProvider, taskProvider),
                const SizedBox(height: 16),
                _buildQuickActions(appProvider, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(AppStateProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好，${provider.currentUser?.name ?? '用户'}！',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '今天是美好的一天，继续保持健康习惯！',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(AppStateProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日健康评分',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: provider.todayHealthScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(provider.todayHealthScore),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${provider.todayHealthScore}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '分',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(provider.todayHealthScore),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress(
    AppStateProvider appProvider,
    TaskProvider taskProvider,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日进度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              '任务完成',
              taskProvider.completedTasksToday,
              taskProvider.totalTasksToday,
              Colors.blue,
              Icons.assignment_turned_in,
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              '步数',
              appProvider.todaySteps,
              10000,
              Colors.green,
              Icons.directions_walk,
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              '饮水量',
              (appProvider.todayWater * 1000).toInt(),
              2500,
              Colors.lightBlue,
              Icons.local_drink,
              unit: 'ml',
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              '运动时间',
              appProvider.todayExercise,
              60,
              Colors.orange,
              Icons.fitness_center,
              unit: '分钟',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    num current,
    num target,
    Color color,
    IconData icon, {
    String unit = '',
  }) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    unit.isEmpty
                        ? '$current/$target'
                        : '$current$unit/$target$unit',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(AppStateProvider provider, BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  '每日签到',
                  Icons.check_circle,
                  Colors.green,
                  () async {
                    final success = await provider.dailyCheckIn();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '签到成功！获得20积分' : '今日已签到'),
                          backgroundColor: success
                              ? Colors.green
                              : Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                _buildActionButton('健康数据', Icons.favorite, Colors.red, () {
                  // 跳转到健康页面的逻辑
                }),
                _buildActionButton('任务列表', Icons.assignment, Colors.blue, () {
                  // 跳转到任务页面的逻辑
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return '健康状态优秀！继续保持！';
    if (score >= 60) return '健康状态良好，还有提升空间';
    if (score >= 40) return '健康状态一般，需要更多关注';
    return '健康状态需要改善，建议增加健康活动';
  }
}
