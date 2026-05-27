import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  AppUser? _user;
  bool _isLoading = true;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get username => _user?.username ?? '';
  String get profession => _user?.profession ?? '';
  String get currency => _user?.currency ?? '\$';
  bool get darkMode => _user?.darkMode ?? false;

  void startListening() {
    _dbService.getUserProfile().listen((userData) {
      _user = userData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateUsername(String username) async {
    try {
      await _dbService.updateUserProfile(username: username);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfession(String profession) async {
    try {
      await _dbService.updateUserProfile(profession: profession);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      await _dbService.updateUserProfile(currency: currency);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    try {
      await _dbService.updateUserProfile(darkMode: !darkMode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}