import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void startListening() {
    _dbService.getNotifications().listen((notifications) {
      _notifications = notifications;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      await _dbService.addNotification(notification);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dbService.markNotificationAsRead(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dbService.markAllNotificationsAsRead();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _dbService.deleteNotification(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}