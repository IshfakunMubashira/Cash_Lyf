class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String iconName;
  final int colorValue;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.iconName,
    required this.colorValue,
    required this.createdAt,
  });

  double get progress => targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  int get daysLeft => targetDate.difference(DateTime.now()).inDays;

  double get monthlyRequired {
    final months = (daysLeft / 30).ceil();
    if (months <= 0) return 0;
    return (targetAmount - currentAmount) / months;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate,
    'iconName': iconName,
    'colorValue': colorValue,
    'createdAt': createdAt,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount'].toDouble(),
    targetDate: (json['targetDate'] as dynamic).toDate(),
    iconName: json['iconName'],
    colorValue: json['colorValue'],
    createdAt: (json['createdAt'] as dynamic).toDate(),
  );
}