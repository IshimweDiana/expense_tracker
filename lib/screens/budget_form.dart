import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';

class BudgetForm extends StatefulWidget {
  const BudgetForm({super.key});

  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _budgetController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;
  double? currentBudget;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  Future<void> _loadCurrentBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final budget = await _dbHelper.getCurrentBudget(userId);

    setState(() {
      currentBudget = budget?['amount'];
      if (currentBudget != null) {
        _budgetController.text = currentBudget.toString();
      }
    });
  }

  Future<void> _setBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;
    final now = DateTime.now();

    final budget = {
      'userId': userId,
      'amount': double.parse(_budgetController.text),
      'month': now.month,
      'year': now.year,
    };

    try {
      await _dbHelper.setBudget(budget);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget set successfully')));
      _loadCurrentBudget();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error setting budget')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentBudget != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Current Budget: \$${currentBudget?.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Monthly Budget',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _setBudget,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }
}
