class Expense {
  final int id;
  final int userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final bool synced;

  Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }
}
