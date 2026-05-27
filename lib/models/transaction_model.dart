class Transaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String category;
  final String? note;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'amount': amount,
    'type': type,
    'date': date,
    'category': category,
    'note': note,
    'createdAt': createdAt,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    type: json['type'],
    date: (json['date'] as dynamic).toDate(),
    category: json['category'],
    note: json['note'],
    createdAt: (json['createdAt'] as dynamic).toDate(),
  );
}