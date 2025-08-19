import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userName = '智龄用户';
  int _smartCoins = 120;
  int _level = 3;
  int _totalPoints = 2840;
  int _streakDays = 7;
  double _biologicalAge = 32.0;
  int _healthScore = 85;

  // Getters
  String get userName => _userName;
  int get smartCoins => _smartCoins;
  int get level => _level;
  int get totalPoints => _totalPoints;
  int get streakDays => _streakDays;
  double get biologicalAge => _biologicalAge;
  int get healthScore => _healthScore;

  UserProvider() {
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name') ?? '智龄用户';
    _smartCoins = prefs.getInt('smart_coins') ?? 120;
    _level = prefs.getInt('user_level') ?? 3;
    _totalPoints = prefs.getInt('total_points') ?? 2840;
    _streakDays = prefs.getInt('streak_days') ?? 7;
    _biologicalAge = prefs.getDouble('biological_age') ?? 32.0;
    _healthScore = prefs.getInt('health_score') ?? 85;
    notifyListeners();
  }

  void addSmartCoins(int coins) async {
    _smartCoins += coins;
    _totalPoints += coins;
    _level = (_totalPoints / 1000).floor() + 1;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('smart_coins', _smartCoins);
    await prefs.setInt('total_points', _totalPoints);
    await prefs.setInt('user_level', _level);

    notifyListeners();
  }

  void updateBiologicalAge(double newAge) async {
    _biologicalAge = newAge;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('biological_age', _biologicalAge);
    notifyListeners();
  }

  void updateStreakDays(int days) async {
    _streakDays = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_days', _streakDays);
    notifyListeners();
  }
}
