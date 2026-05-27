import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/transaction_model.dart';
import '../models/savings_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

// Aliases to avoid naming conflicts
typedef AppTransaction = Transaction;
typedef AppSavingsGoal = SavingsGoal;
typedef AppUserNotification = AppNotification;

class DatabaseService {
  final FirebaseService _firebase = FirebaseService();

  String get _userId => _firebase.userId;

  // ========== TRANSACTIONS ==========
  Stream<List<AppTransaction>> getTransactions() {
    return _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppTransaction.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // ========== SAVINGS GOALS ==========
  Stream<List<AppSavingsGoal>> getSavingsGoals() {
    return _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('savings_goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppSavingsGoal.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addSavingsGoal(AppSavingsGoal goal) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('savings_goals')
        .doc(goal.id)
        .set(goal.toJson());
  }

  Future<void> updateSavingsGoal(String goalId, double newAmount) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('savings_goals')
        .doc(goalId)
        .update({'currentAmount': newAmount});
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('savings_goals')
        .doc(goalId)
        .delete();
  }

  // ========== NOTIFICATIONS ==========
  Stream<List<AppUserNotification>> getNotifications() {
    return _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppUserNotification.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  Future<void> addNotification(AppUserNotification notification) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead() async {
    final batch = _firebase.firestore.batch();
    final snapshot = await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // ========== USER PROFILE ==========
  Future<void> updateUserProfile({
    String? username,
    String? profession,
    String? currency,
    bool? darkMode,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> updates = {};
    if (username != null) updates['username'] = username;
    if (profession != null) updates['profession'] = profession;
    if (currency != null) updates['currency'] = currency;
    if (darkMode != null) updates['darkMode'] = darkMode;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firebase.firestore
        .collection('users')
        .doc(_userId)
        .update(updates);
  }

  Stream<AppUser?> getUserProfile() {
    return _firebase.firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromJson(snapshot.data()!);
      }
      return null;
    });
  }
}