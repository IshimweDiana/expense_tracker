import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';
import '../../services/notification_service.dart';
import '../../screens/expense_form.dart';
import '../../screens/budget_form.dart';
import '../../screens/savings_goal_form.dart';
import '../../screens/reports_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _dbHelper = DatabaseHelper.instance;
  final _syncService = SyncService();
  final _notificationService = NotificationService();
  String _userEmail = '';

  final List<Widget> _pages = [
    const ExpenseForm(),
    const BudgetForm(),
    const SavingsGoalForm(),
    const ReportsPage(), // This now includes both analytics and transaction list
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _notificationService.initialize();
    _syncService.syncData();
    _checkBudget();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final userData = await _dbHelper.getUserById(userId);
    if (userData != null) {
      setState(() {
        _userEmail = userData['email'];
      });
    }
  }

  Future<void> _checkBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final budget = await _dbHelper.getCurrentBudget(userId);
    final expenses = await _dbHelper.getCurrentMonthExpenses(userId);

    if (budget != null) {
      double totalExpenses = expenses.fold(
        0,
        (sum, expense) => sum + (expense['amount'] as double),
      );
      if (totalExpenses > budget['amount'] * 0.8) {
        _notificationService.showBudgetAlert(
          'Budget Alert',
          'You have used ${((totalExpenses / budget['amount']) * 100).toStringAsFixed(1)}% of your budget',
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _syncService.syncData(),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_userEmail),
              accountEmail: Text(_userEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Expense Logging'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Budget Setting'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Savings Goals'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Expense'),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Budget',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
