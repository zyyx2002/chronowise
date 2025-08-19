import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_data.dart';
import '../providers/health_data_provider.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _sleepController = TextEditingController();
  final _waterController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _exerciseController.dispose();
    _sleepController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录健康数据'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 日期选择
              ListTile(
                title: const Text('日期'),
                subtitle: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // 体重输入
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: '体重 (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 运动时间输入
              TextFormField(
                controller: _exerciseController,
                decoration: const InputDecoration(
                  labelText: '运动时间 (分钟)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 睡眠时间输入
              TextFormField(
                controller: _sleepController,
                decoration: const InputDecoration(
                  labelText: '睡眠时间 (小时)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.bedtime),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 饮水量输入
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(
                  labelText: '饮水量 (杯)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('保存数据'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
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
      );

      await context.read<HealthDataProvider>().addHealthData(healthData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据保存成功！')),
        );
        Navigator.pop(context);
      }
    }
  }
}
