import 'package:flutter/foundation.dart';
import '../../models/expense.dart';
import '../../services/database_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Expense> get expenses => _expenses;

  Future<void> loadExpenses(int userId) async {
    final expenseData = await _dbHelper.getExpensesByUser(userId);
    _expenses.clear();
    _expenses.addAll(
      expenseData.map(
        (data) => Expense(
          id: data['id'],
          userId: data['userId'],
          category: data['category'],
          amount: data['amount'],
          description: data['description'],
          date: DateTime.parse(data['date']),
          synced: data['synced'] == 1,
        ),
      ),
    );
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense.toMap());
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}
