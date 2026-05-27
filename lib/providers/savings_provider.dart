import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/savings_model.dart';

class SavingsProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<SavingsGoal> _goals = [];
  bool _isLoading = true;
  String? _error;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved => _goals.fold(0, (sum, g) => sum + g.currentAmount);
  double get totalTarget => _goals.fold(0, (sum, g) => sum + g.targetAmount);

  void startListening() {
    _dbService.getSavingsGoals().listen((goals) {
      _goals = goals;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addGoal(SavingsGoal goal) async {
    try {
      await _dbService.addSavingsGoal(goal);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoal(String id, double amount) async {
    try {
      await _dbService.updateSavingsGoal(id, amount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _dbService.deleteSavingsGoal(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}