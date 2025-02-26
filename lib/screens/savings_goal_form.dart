import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingsGoalForm extends StatefulWidget {
  const SavingsGoalForm({super.key});

  @override
  _SavingsGoalFormState createState() => _SavingsGoalFormState();
}

class _SavingsGoalFormState extends State<SavingsGoalForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> goals = [];

  @override
  void initState() {
    super.initState();
    _loadSavingsGoals();
  }

  Future<void> _loadSavingsGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final loadedGoals = await _dbHelper.getSavingsGoals(userId);
    setState(() {
      goals = loadedGoals;
    });
  }

  Future<void> _setGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final goal = {
      'userId': userId,
      'title': _titleController.text,
      'targetAmount': double.parse(_amountController.text),
      'currentAmount': 0.0,
      'deadline': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'synced': 0,
    };

    try {
      await _dbHelper.insertSavingsGoal(goal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal added successfully')),
      );
      _titleController.clear();
      _amountController.clear();
      _loadSavingsGoals();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error adding savings goal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Goal Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Target Amount',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _setGoal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Set Goal'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  child: ListTile(
                    title: Text(goal['title']),
                    subtitle: Text('\$${goal['targetAmount']}'),
                    trailing: Text(
                      '${((goal['currentAmount'] / goal['targetAmount']) * 100).toStringAsFixed(1)}%',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
