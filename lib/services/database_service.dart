import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/health_record.dart';
import '../models/point_transaction.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  Future<Database?> get database async {
    if (kIsWeb) {
      // Web 平台不支持 SQLite，返回 null
      return null;
    }
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<SharedPreferences> get webStorage async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'chronowise.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // 创建用户表 - 包含游戏化字段
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        goal TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        biological_age INTEGER DEFAULT 32,
        smart_coins INTEGER DEFAULT 120,
        daily_tasks INTEGER DEFAULT 8,
        completed_tasks INTEGER DEFAULT 0,
        streak_days INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        total_points INTEGER DEFAULT 0,
        avatar TEXT DEFAULT '',
        join_date TEXT DEFAULT '',
        total_days INTEGER DEFAULT 0
      )
    ''');

    // 创建健康记录表
    await db.execute('''
      CREATE TABLE health_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        steps INTEGER,
        water REAL,
        sleep_hours INTEGER,
        exercise_minutes INTEGER,
        meditation_minutes INTEGER,
        reading_minutes INTEGER,
        social_minutes INTEGER,
        skincare INTEGER,
        nutrition_score INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, date)
      )
    ''');

    // 创建积分交易表
    await db.execute('''
      CREATE TABLE point_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        points INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 创建任务表
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        target_date TEXT NOT NULL,
        points_reward INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // 数据库升级方法 - 添加游戏化字段
  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加游戏化字段到用户表
      await db.execute(
        'ALTER TABLE users ADD COLUMN biological_age INTEGER DEFAULT 32',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN smart_coins INTEGER DEFAULT 120',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN daily_tasks INTEGER DEFAULT 8',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN completed_tasks INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN streak_days INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE users ADD COLUMN level INTEGER DEFAULT 1');
      await db.execute(
        'ALTER TABLE users ADD COLUMN total_points INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE users ADD COLUMN avatar TEXT DEFAULT ""');
      await db.execute(
        'ALTER TABLE users ADD COLUMN join_date TEXT DEFAULT ""',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN total_days INTEGER DEFAULT 0',
      );
    }
  }

  // 🔧 Web 平台的数据操作方法
  Future<List<Map<String, dynamic>>> _getWebData(String key) async {
    final prefs = await webStorage;
    final jsonString = prefs.getString(key) ?? '[]';
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<void> _setWebData(String key, List<Map<String, dynamic>> data) async {
    final prefs = await webStorage;
    await prefs.setString(key, jsonEncode(data));
  }

  Future<int> _getNextWebId(String key) async {
    final data = await _getWebData(key);
    if (data.isEmpty) {
      return 1;
    }
    return (data
            .map((item) => item['id'] as int)
            .reduce((a, b) => a > b ? a : b)) +
        1;
  }

  // === 用户相关操作 - 新旧方法并存 ===

  Future<int> insertUser(User user) async {
    if (kIsWeb) {
      final users = await _getWebData('users');
      final id = await _getNextWebId('users');
      final userMap = user.toMap();
      userMap['id'] = id;
      users.add(userMap);
      await _setWebData('users', users);
      return id;
    } else {
      final db = await database;
      return await db!.insert('users', user.toMap());
    }
  }

  Future<void> updateUser(User user) async {
    if (kIsWeb) {
      final users = await _getWebData('users');
      final index = users.indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        users[index] = user.toMap();
        await _setWebData('users', users);
      }
    } else {
      final db = await database;
      await db!.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    }
  }

  // === 🆕 新的用户方法 - 使用统一User模型 ===

  // 新方法：获取完整User数据
  Future<User?> getUser([String? userId]) async {
    if (kIsWeb) {
      final users = await _getWebData('users');
      if (users.isNotEmpty) {
        // 使用新的User.fromMap，会自动处理所有字段
        return User.fromMap(users.first);
      }
      return null;
    } else {
      final db = await database;
      final maps = await db!.query('users', limit: 1);

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    }
  }

  // 新方法：保存完整User数据
  Future<int> saveUser(User user) async {
    if (kIsWeb) {
      final users = await _getWebData('users');
      final userMap = user.toMap();

      if (user.id != null) {
        // 更新现有用户
        final index = users.indexWhere((u) => u['id'] == user.id);
        if (index != -1) {
          users[index] = userMap;
        }
      } else {
        // 创建新用户
        final id = await _getNextWebId('users');
        userMap['id'] = id;
        users.add(userMap);
      }

      await _setWebData('users', users);
      return user.id ?? userMap['id'];
    } else {
      final db = await database;
      if (user.id != null) {
        await db!.update(
          'users',
          user.toMap(),
          where: 'id = ?',
          whereArgs: [user.id],
        );
        return user.id!;
      } else {
        return await db!.insert('users', user.toMap());
      }
    }
  }

  // 新方法：从SharedPreferences加载User数据
  Future<User?> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 检查是否有用户
    final hasUser = prefs.getBool('has_user') ?? false;
    if (!hasUser) return null;

    // 构建User对象（合并所有数据源）
    return User(
      name: prefs.getString('user_name') ?? '',
      age: int.tryParse(prefs.getString('user_age') ?? '') ?? 25,
      gender: prefs.getString('user_gender') ?? '未设置',
      height: prefs.getDouble('user_height') ?? 170.0,
      weight: prefs.getDouble('user_weight') ?? 65.0,
      goal: prefs.getString('user_goal') ?? '保持健康',
      createdAt: DateTime.now().subtract(
        Duration(days: prefs.getInt('total_days') ?? 0),
      ),
      updatedAt: DateTime.now(),
      // 游戏化数据
      biologicalAge: prefs.getInt('biological_age') ?? 32,
      smartCoins: prefs.getInt('smart_coins') ?? 120,
      dailyTasks: 8, // 固定值
      completedTasks: prefs.getInt('completed_tasks_today') ?? 0,
      streakDays: prefs.getInt('streak_days') ?? 0,
      level: prefs.getInt('user_level') ?? 1,
      totalPoints: prefs.getInt('total_points') ?? 0,
      avatar: prefs.getString('user_avatar') ?? '',
      joinDate:
          prefs.getString('join_date') ??
          DateTime.now().toString().split(' ')[0],
      totalDays: prefs.getInt('total_days') ?? 0,
    );
  }

  // 新方法：保存User数据到SharedPreferences
  Future<void> saveUserToPreferences(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('has_user', true);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_age', user.age.toString());
    await prefs.setString('user_gender', user.gender);
    await prefs.setDouble('user_height', user.height);
    await prefs.setDouble('user_weight', user.weight);
    await prefs.setString('user_goal', user.goal);

    // 游戏化数据
    await prefs.setInt('biological_age', user.biologicalAge);
    await prefs.setInt('smart_coins', user.smartCoins);
    await prefs.setInt('completed_tasks_today', user.completedTasks);
    await prefs.setInt('streak_days', user.streakDays);
    await prefs.setInt('user_level', user.level);
    await prefs.setInt('total_points', user.totalPoints);
    await prefs.setString('user_avatar', user.avatar);
    await prefs.setString('join_date', user.joinDate);
    await prefs.setInt('total_days', user.totalDays);
  }

  // === 健康记录相关操作 ===
  Future<int> insertHealthRecord(HealthRecord record) async {
    if (kIsWeb) {
      final records = await _getWebData('health_records');
      final id = await _getNextWebId('health_records');
      final recordMap = record.toMap();
      recordMap['id'] = id;

      // 检查是否已存在相同日期的记录，如果存在则替换
      final existingIndex = records.indexWhere(
        (r) =>
            r['user_id'] == record.userId &&
            r['date'] == record.date.toIso8601String().split('T')[0],
      );

      if (existingIndex != -1) {
        records[existingIndex] = recordMap;
      } else {
        records.add(recordMap);
      }

      await _setWebData('health_records', records);
      return id;
    } else {
      final db = await database;
      return await db!.insert(
        'health_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<HealthRecord?> getHealthRecord(int userId, DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    if (kIsWeb) {
      final records = await _getWebData('health_records');
      final found = records
          .where((r) => r['user_id'] == userId && r['date'] == dateString)
          .toList();

      if (found.isNotEmpty) {
        return HealthRecord.fromMap(found.first);
      }
      return null;
    } else {
      final db = await database;
      final maps = await db!.query(
        'health_records',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, dateString],
      );

      if (maps.isNotEmpty) {
        return HealthRecord.fromMap(maps.first);
      }
      return null;
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    if (kIsWeb) {
      final records = await _getWebData('health_records');
      final index = records.indexWhere((r) => r['id'] == record.id);
      if (index != -1) {
        records[index] = record.toMap();
        await _setWebData('health_records', records);
      }
    } else {
      final db = await database;
      await db!.update(
        'health_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
    }
  }

  Future<List<HealthRecord>> getHealthRecords(int userId, {int? days}) async {
    if (kIsWeb) {
      final records = await _getWebData('health_records');
      var filtered = records.where((r) => r['user_id'] == userId).toList();

      if (days != null) {
        final startDate = DateTime.now().subtract(Duration(days: days));
        final startDateString =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        filtered = filtered
            .where((r) => r['date'].compareTo(startDateString) >= 0)
            .toList();
      }

      filtered.sort((a, b) => b['date'].compareTo(a['date']));

      return filtered.map((map) => HealthRecord.fromMap(map)).toList();
    } else {
      final db = await database;
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (days != null) {
        final startDate = DateTime.now().subtract(Duration(days: days));
        final startDateString =
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
        whereClause += ' AND date >= ?';
        whereArgs.add(startDateString);
      }

      final maps = await db!.query(
        'health_records',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC',
      );

      return List.generate(maps.length, (i) {
        return HealthRecord.fromMap(maps[i]);
      });
    }
  }

  // === 积分交易相关操作 ===
  Future<int> insertPointTransaction(PointTransaction transaction) async {
    if (kIsWeb) {
      final transactions = await _getWebData('point_transactions');
      final id = await _getNextWebId('point_transactions');
      final transactionMap = transaction.toMap();
      transactionMap['id'] = id;
      transactions.add(transactionMap);
      await _setWebData('point_transactions', transactions);
      return id;
    } else {
      final db = await database;
      return await db!.insert('point_transactions', transaction.toMap());
    }
  }

  Future<List<PointTransaction>> getPointTransactions(
    int userId, {
    int? limit,
  }) async {
    if (kIsWeb) {
      final transactions = await _getWebData('point_transactions');
      var filtered = transactions.where((t) => t['user_id'] == userId).toList();
      filtered.sort((a, b) => b['created_at'].compareTo(a['created_at']));

      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }

      return filtered.map((map) => PointTransaction.fromMap(map)).toList();
    } else {
      final db = await database;
      final maps = await db!.query(
        'point_transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return PointTransaction.fromMap(maps[i]);
      });
    }
  }

  Future<int> getTotalPoints(int userId) async {
    if (kIsWeb) {
      final transactions = await _getWebData('point_transactions');
      final userTransactions = transactions.where(
        (t) => t['user_id'] == userId,
      );

      int total = 0;
      for (final transaction in userTransactions) {
        total += transaction['points'] as int? ?? 0;
      }
      return total;
    } else {
      final db = await database;
      final result = await db!.rawQuery(
        'SELECT SUM(points) as total FROM point_transactions WHERE user_id = ?',
        [userId],
      );

      return result.isNotEmpty && result.first['total'] != null
          ? result.first['total'] as int
          : 0;
    }
  }

  // === 任务相关操作 ===
  Future<int> insertTask(Task task) async {
    if (kIsWeb) {
      final tasks = await _getWebData('tasks');
      final id = await _getNextWebId('tasks');
      final taskMap = task.toMap();
      taskMap['id'] = id;
      tasks.add(taskMap);
      await _setWebData('tasks', tasks);
      return id;
    } else {
      final db = await database;
      return await db!.insert('tasks', task.toMap());
    }
  }

  Future<List<Task>> getTasks(int userId, DateTime date) async {
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    if (kIsWeb) {
      final tasks = await _getWebData('tasks');
      final filtered = tasks
          .where(
            (t) => t['user_id'] == userId && t['target_date'] == dateString,
          )
          .toList();
      filtered.sort((a, b) => a['created_at'].compareTo(b['created_at']));

      return filtered.map((map) => Task.fromMap(map)).toList();
    } else {
      final db = await database;
      final maps = await db!.query(
        'tasks',
        where: 'user_id = ? AND target_date = ?',
        whereArgs: [userId, dateString],
        orderBy: 'created_at ASC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    }
  }

  Future<void> updateTask(Task task) async {
    if (kIsWeb) {
      final tasks = await _getWebData('tasks');
      final index = tasks.indexWhere((t) => t['id'] == task.id);
      if (index != -1) {
        tasks[index] = task.toMap();
        await _setWebData('tasks', tasks);
      }
    } else {
      final db = await database;
      await db!.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
  }

  // 关闭数据库
  Future<void> close() async {
    if (!kIsWeb) {
      final db = await database;
      db?.close();
    }
  }
}
