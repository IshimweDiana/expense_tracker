import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'transaction_card.dart';

class TransactionList extends StatelessWidget {
  final int userId;

  const TransactionList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getTransactionHistory(userId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final transaction = snapshot.data![index];
              return TransactionCard(
                category: transaction['category'],
                amount: transaction['amount'],
                date: DateTime.parse(transaction['date']),
                description: transaction['description'],
                icon: Icons.shopping_cart,
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
