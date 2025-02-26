import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/database_helper.dart';
import '../../services/api_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> syncData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    // Sync expenses
    final expenses = await _dbHelper.getUnsyncedExpenses();
    for (var expense in expenses) {
      try {
        final response = await ApiService.postRequest('expenses/sync', expense);
        if (response['success']) {
          await _dbHelper.markAsSynced('expenses', expense['id']);
        }
      } catch (e) {
        print('Error syncing expense: $e');
      }
    }

    // Sync savings goals
    final goals = await _dbHelper.getUnsyncedSavingsGoals();
    for (var goal in goals) {
      try {
        final response = await ApiService.postRequest('goals/sync', goal);
        if (response['success']) {
          await _dbHelper.markAsSynced('savings_goals', goal['id']);
        }
      } catch (e) {
        print('Error syncing goal: $e');
      }
    }
  }
}
