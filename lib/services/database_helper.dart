import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "expense_tracker.db";
  static const _databaseVersion = 1;

  // Make sure the database path is set to a permanent location
  Future<String> getDatabasePath() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, _databaseName);
    return path;
  }

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      fullName TEXT
    )
  ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        category TEXT,
        amount REAL,
        description TEXT,
        date TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Budget table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        amount REAL,
        month INTEGER,
        year INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Savings goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        targetAmount REAL,
        currentAmount REAL,
        deadline TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');
  }

  // User operations
  Future<int> createUser(String email, String password, String fullName) async {
    final db = await database;

    final existingUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email already exists');
    }

    try {
      final userId = await db.insert('users', {
        'email': email,
        'password': password,
        'fullName': fullName,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return userId;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Expense operations
  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getExpensesByUser(int userId) async {
    final db = await database;
    return await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // Budget operations
  Future<int> setBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  Future<Map<String, dynamic>?> getCurrentBudget(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final results = await db.query(
      'budgets',
      where: 'userId = ? AND month = ? AND year = ?',
      whereArgs: [userId, now.month, now.year],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Savings goals operations
  Future<int> insertSavingsGoal(Map<String, dynamic> goal) async {
    final db = await database;
    return await db.insert('savings_goals', goal);
  }

  Future<List<Map<String, dynamic>>> getSavingsGoals(int userId) async {
    final db = await database;
    return await db.query(
      'savings_goals',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getCurrentMonthExpenses(int userId) async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return await db.query(
      'expenses',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    final db = await database;
    return await db.query('expenses', where: 'synced = ?', whereArgs: [0]);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedSavingsGoals() async {
    final db = await database;
    return await db.query('savings_goals', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markAsSynced(String table, int id) async {
    final db = await database;
    await db.update(table, {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, double>> getExpensesByCategory(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final results = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE userId = ? AND date BETWEEN ? AND ?
      GROUP BY category
    ''',
      [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    Map<String, double> categoryTotals = {};
    for (var row in results) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }

  // Budget Analysis
  Future<double> getBudgetUtilization(int userId) async {
    final currentBudget = await getCurrentBudget(userId);
    final currentExpenses = await getCurrentMonthExpenses(userId);

    double totalExpenses = 0;
    for (var expense in currentExpenses) {
      totalExpenses += expense['amount'] as double;
    }

    return totalExpenses / (currentBudget?['amount'] ?? 1) * 100;
  }

  // Savings Progress
  Future<void> updateSavingsGoal(int goalId, double amount) async {
    final db = await database;
    await db.update(
      'savings_goals',
      {'currentAmount': amount, 'synced': 0},
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  // Transaction History
  Future<List<Map<String, dynamic>>> getTransactionHistory(
    int userId, {
    int limit = 10,
  }) async {
    final db = await database;
    return await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
  }

  Future<void> ensureDatabaseExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    // Check if database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Create database if it doesn't exist
      final database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDB,
      );
      _database = database;
    }
  }
}
