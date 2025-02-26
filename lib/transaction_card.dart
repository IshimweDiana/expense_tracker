import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String category;
  final double amount;
  final String date;
  final IconData icon;

  const TransactionCard({
    super.key,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon, required description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amount < 0 ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
