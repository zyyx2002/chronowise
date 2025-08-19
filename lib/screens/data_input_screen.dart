import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/health_provider.dart';
import '../models/health_data.dart';

class DataInputScreen extends StatefulWidget {
  const DataInputScreen({super.key});

  @override
  State<DataInputScreen> createState() => _DataInputScreenState();
}

class _DataInputScreenState extends State<DataInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _sleepController = TextEditingController();
  final _waterController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedMood = 'neutral';
  DateTime _selectedDate = DateTime.now();

  final List<String> _moodOptions = [
    'excellent',
    'good',
    'neutral',
    'bad',
    'terrible'
  ];

  final Map<String, String> _moodLabels = {
    'excellent': '😄 非常好',
    'good': '😊 好',
    'neutral': '😐 一般',
    'bad': '😞 不好',
    'terrible': '😩 很糟'
  };

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  void _loadTodayData() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final todayData = healthProvider.todayData;

    if (todayData != null) {
      _weightController.text = todayData.weight?.toString() ?? '';
      _exerciseController.text = todayData.exerciseMinutes?.toString() ?? '';
      _sleepController.text = todayData.sleepHours?.toString() ?? '';
      _waterController.text = todayData.waterGlasses?.toString() ?? '';
      _notesController.text = todayData.notes;
      _selectedMood = todayData.mood;
      _selectedDate = todayData.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录健康数据'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveData,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              const SizedBox(height: 20),
              _buildWeightInput(),
              const SizedBox(height: 20),
              _buildExerciseInput(),
              const SizedBox(height: 20),
              _buildSleepInput(),
              const SizedBox(height: 20),
              _buildWaterInput(),
              const SizedBox(height: 20),
              _buildMoodSelector(),
              const SizedBox(height: 20),
              _buildNotesInput(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('日期'),
        subtitle: Text(DateFormat('yyyy年MM月dd日').format(_selectedDate)),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
            });
          }
        },
      ),
    );
  }

  Widget _buildWeightInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.blue),
                SizedBox(width: 8),
                Text('体重',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入体重',
                suffixText: 'kg',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0 || weight > 300) {
                    return '请输入有效的体重 (0-300kg)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.orange),
                SizedBox(width: 8),
                Text('运动时间',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exerciseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入运动时间',
                suffixText: '分钟',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final minutes = int.tryParse(value);
                  if (minutes == null || minutes < 0 || minutes > 720) {
                    return '请输入有效的运动时间 (0-720分钟)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bedtime, color: Colors.purple),
                SizedBox(width: 8),
                Text('睡眠时间',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sleepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入睡眠时间',
                suffixText: '小时',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final hours = double.tryParse(value);
                  if (hours == null || hours < 0 || hours > 24) {
                    return '请输入有效的睡眠时间 (0-24小时)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop, color: Colors.cyan),
                SizedBox(width: 8),
                Text('饮水量',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _waterController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入饮水杯数',
                suffixText: '杯',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final glasses = int.tryParse(value);
                  if (glasses == null || glasses < 0 || glasses > 20) {
                    return '请输入有效的饮水杯数 (0-20杯)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mood, color: Colors.amber),
                SizedBox(width: 8),
                Text('心情',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _moodOptions.map((mood) {
                return FilterChip(
                  label: Text(_moodLabels[mood] ?? mood),
                  selected: _selectedMood == mood,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: Colors.green),
                SizedBox(width: 8),
                Text('备注',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '记录今天的感受或特殊情况...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveData,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '保存数据',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final healthProvider =
          Provider.of<HealthProvider>(context, listen: false);

      final healthData = HealthData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        exerciseMinutes: _exerciseController.text.isNotEmpty
            ? int.tryParse(_exerciseController.text)
            : null,
        sleepHours: _sleepController.text.isNotEmpty
            ? double.tryParse(_sleepController.text)
            : null,
        waterGlasses: _waterController.text.isNotEmpty
            ? int.tryParse(_waterController.text)
            : null,
        mood: _selectedMood,
        notes: _notesController.text,
      );

      await healthProvider.addOrUpdateHealthData(healthData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据保存成功！')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _exerciseController.dispose();
    _sleepController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
