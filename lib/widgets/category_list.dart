import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final Map<String, double> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final entry = categories.entries.elementAt(index);
        return ListTile(
          title: Text(entry.key),
          trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
        );
      },
    );
  }
}
