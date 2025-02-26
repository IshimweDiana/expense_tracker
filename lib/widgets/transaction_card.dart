import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final IconData? icon;

  const TransactionCard({
    super.key,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon ?? Icons.receipt_long),
        title: Text(category),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: amount < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
