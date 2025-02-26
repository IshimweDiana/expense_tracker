import 'package:flutter/material.dart';
import '../widgets/expense_analytics.dart';
import '../widgets/transaction_list.dart';

class AnalyticsScreen extends StatelessWidget {
  final int userId;

  const AnalyticsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpenseAnalytics(userId: userId),
        Expanded(child: TransactionList(userId: userId)),
      ],
    );
  }
}
