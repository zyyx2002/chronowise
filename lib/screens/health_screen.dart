import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康管理'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, child) {
          final record = provider.todayRecord;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthScore(provider.todayHealthScore),
                const SizedBox(height: 24),
                _buildHealthMetrics(context, provider, record),
                const SizedBox(height: 24),
                _buildHealthTips(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthScore(int score) {
    Color scoreColor = Colors.red;
    String scoreText = '需要改善';

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreText = '优秀';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreText = '良好';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            '今日健康得分',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          Text(
            scoreText,
            style: TextStyle(
              fontSize: 16,
              color: scoreColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(
    BuildContext context,
    AppStateProvider provider,
    record,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健康指标',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          icon: Icons.directions_walk,
          title: '步数',
          value: provider.todaySteps.toString(),
          unit: '步',
          target: '8000',
          onTap: () => _showStepsDialog(context, provider),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.water_drop,
          title: '饮水',
          value: provider.todayWater.toStringAsFixed(1),
          unit: 'L',
          target: '2.5',
          onTap: () => _showWaterDialog(context, provider),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.bedtime,
          title: '睡眠',
          value: provider.todaySleep.toString(),
          unit: '小时',
          target: '8',
          onTap: () => _showSleepDialog(context, provider),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.fitness_center,
          title: '运动',
          value: provider.todayExercise.toString(),
          unit: '分钟',
          target: '30',
          onTap: () => _showExerciseDialog(context, provider),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String target,
    required VoidCallback onTap,
  }) {
    final currentValue = double.tryParse(value) ?? 0;
    final targetValue = double.tryParse(target) ?? 1;
    final progress = (currentValue / targetValue).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value $unit / $target $unit',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.green : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健康小贴士',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('今日建议', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12),
              Text('• 每天至少喝8杯水，保持身体水分充足'),
              SizedBox(height: 4),
              Text('• 坚持每天30分钟有氧运动'),
              SizedBox(height: 4),
              Text('• 保证7-9小时优质睡眠'),
              SizedBox(height: 4),
              Text('• 多吃蔬菜水果，均衡营养'),
            ],
          ),
        ),
      ],
    );
  }

  void _showStepsDialog(BuildContext context, AppStateProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录步数'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '今日步数',
            hintText: '例如: 8000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final steps = int.tryParse(controller.text);
              if (steps != null && steps >= 0) {
                await provider.updateHealthData(steps: steps);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('步数记录已更新')));
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showWaterDialog(BuildContext context, AppStateProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录饮水'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '饮水量 (升)',
            hintText: '例如: 2.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final water = double.tryParse(controller.text);
              if (water != null && water >= 0) {
                await provider.updateHealthData(water: water);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('饮水记录已更新')));
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSleepDialog(BuildContext context, AppStateProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录睡眠'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '睡眠时间 (小时)',
            hintText: '例如: 8',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final sleep = int.tryParse(controller.text);
              if (sleep != null && sleep >= 0) {
                await provider.updateHealthData(sleepHours: sleep);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('睡眠记录已更新')));
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDialog(BuildContext context, AppStateProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('记录运动'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '运动时间 (分钟)',
            hintText: '例如: 30',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final exercise = int.tryParse(controller.text);
              if (exercise != null && exercise >= 0) {
                await provider.updateHealthData(exerciseMinutes: exercise);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('运动记录已更新')));
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
