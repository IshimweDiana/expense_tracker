import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'expense_pie_chart.dart';
import 'category_list.dart';

class ExpenseAnalytics extends StatelessWidget {
  final int userId; // Added required userId parameter

  const ExpenseAnalytics({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: DatabaseHelper.instance.getExpensesByCategory(
        // Added missing future
        userId,
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double totalExpenses = snapshot.data!.values.fold(0, (a, b) => a + b);

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: ExpensePieChart(
                      categories: snapshot.data!,
                      radius: 70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: CategoryList(categories: snapshot.data!),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
