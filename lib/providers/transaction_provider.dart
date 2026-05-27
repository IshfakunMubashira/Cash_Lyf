import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  List<Transaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) =>
    t.date.year == now.year && t.date.month == now.month).toList();
  }

  double get currentMonthIncome => currentMonthTransactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get currentMonthExpense => currentMonthTransactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  double get currentMonthSavings => currentMonthIncome - currentMonthExpense;

  void startListening() {
    _dbService.getTransactions().listen((transactions) {
      _transactions = transactions;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _dbService.addTransaction(transaction);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dbService.deleteTransaction(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Map<String, double> getCategoryBreakdown() {
    final Map<String, double> breakdown = {};
    for (var t in currentMonthTransactions.where((t) => t.type == 'expense')) {
      breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
    }
    return breakdown;
  }

  Map<String, Map<String, double>> getMonthlyChartData() {
    final Map<String, Map<String, double>> monthlyData = {};
    for (var t in _transactions) {
      final String monthKey = '${t.date.month}/${t.date.year}';
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
      }
      if (t.type == 'income') {
        monthlyData[monthKey]!['income'] =
            (monthlyData[monthKey]!['income'] ?? 0) + t.amount;
      } else {
        monthlyData[monthKey]!['expense'] =
            (monthlyData[monthKey]!['expense'] ?? 0) + t.amount;
      }
    }
    return monthlyData;
  }
}