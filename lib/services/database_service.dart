import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/health_record.dart';
import '../models/point_transaction.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'chronowise.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // 创建用户表
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
        updated_at INTEGER NOT NULL
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

  // 用户相关操作
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // 健康记录相关操作
  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await database;
    return await db.insert(
      'health_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HealthRecord?> getHealthRecord(int userId, DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'health_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateString],
    );

    if (maps.isNotEmpty) {
      return HealthRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    final db = await database;
    await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<List<HealthRecord>> getHealthRecords(int userId, {int? days}) async {
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

    final maps = await db.query(
      'health_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HealthRecord.fromMap(maps[i]);
    });
  }

  // 积分交易相关操作
  Future<int> insertPointTransaction(PointTransaction transaction) async {
    final db = await database;
    return await db.insert('point_transactions', transaction.toMap());
  }

  Future<List<PointTransaction>> getPointTransactions(
    int userId, {
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
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

  Future<int> getTotalPoints(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(points) as total FROM point_transactions WHERE user_id = ?',
      [userId],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? result.first['total'] as int
        : 0;
  }

  // 任务相关操作
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks(int userId, DateTime date) async {
    final db = await database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      'tasks',
      where: 'user_id = ? AND target_date = ?',
      whereArgs: [userId, dateString],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
