import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/health_data_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<HealthDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.healthDataList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('暂无数据，请先记录一些健康数据'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '数据概览',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 统计卡片
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            '总记录',
                            '${provider.healthDataList.length}',
                            Icons.event_note)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatCard('最近记录',
                            _getLastRecordDays(provider), Icons.schedule)),
                  ],
                ),
                const SizedBox(height: 20),

                // 体重趋势图
                if (_hasWeightData(provider)) ...[
                  const Text(
                    '体重趋势',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildWeightChart(provider),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 运动时间图表
                if (_hasExerciseData(provider)) ...[
                  const Text(
                    '运动时间',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildExerciseChart(provider),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _getLastRecordDays(HealthDataProvider provider) {
    if (provider.healthDataList.isEmpty) return '无';
    final latestData = provider.getLatestData();
    if (latestData == null) return '无';

    final daysDiff = DateTime.now().difference(latestData.date).inDays;
    if (daysDiff == 0) return '今天';
    if (daysDiff == 1) return '昨天';
    return '$daysDiff天前';
  }

  bool _hasWeightData(HealthDataProvider provider) {
    return provider.healthDataList.any((data) => data.weight != null);
  }

  bool _hasExerciseData(HealthDataProvider provider) {
    return provider.healthDataList.any((data) => data.exerciseMinutes != null);
  }

  Widget _buildWeightChart(HealthDataProvider provider) {
    final weightData = provider.healthDataList
        .where((data) => data.weight != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weightData.isEmpty) return const Center(child: Text('暂无体重数据'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weightData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.weight!);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseChart(HealthDataProvider provider) {
    final exerciseData = provider.healthDataList
        .where((data) => data.exerciseMinutes != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (exerciseData.isEmpty) return const Center(child: Text('暂无运动数据'));

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: exerciseData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.exerciseMinutes!.toDouble(),
                color: Colors.green,
                width: 15,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
