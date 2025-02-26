import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class BudgetTracker extends StatelessWidget {
  final int userId;

  const BudgetTracker({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: DatabaseHelper.instance.getBudgetUtilization(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              CircularProgressIndicator(
                value: snapshot.data! / 100,
                backgroundColor: Colors.grey[200],
                color: _getColorForPercentage(snapshot.data!),
              ),
              Text(
                '${snapshot.data!.toStringAsFixed(1)}% of budget used',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }
}
