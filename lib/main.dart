import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// ============ NOTIFICATION SERVICE ============

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'savings_channel',
      'Savings Notifications',
      channelDescription: 'Notifications for savings goals',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}

// ============ MODELS ============

class AppUser {
  final String uid;
  final String email;
  final String username;
  final String profession;
  final String currency;
  final String? profileImageUrl;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.profession,
    required this.currency,
    this.profileImageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'profession': profession,
    'currency': currency,
    'profileImageUrl': profileImageUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    profession: json['profession'] ?? '',
    currency: json['currency'] ?? '\$',
    profileImageUrl: json['profileImageUrl'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}

class Transaction {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type;
  final DateTime date;
  final String category;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
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
    'createdAt': createdAt,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    type: json['type'],
    date: (json['date'] as Timestamp).toDate(),
    category: json['category'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}

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
  List<SavingsContribution> contributions;

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
    this.contributions = const [],
  });

  double get progress => targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get daysLeft => targetDate.difference(DateTime.now()).inDays;
  double get remainingAmount => targetAmount - currentAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': Timestamp.fromDate(targetDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'iconName': iconName,
    'colorValue': colorValue,
    'contributions': contributions.map((c) => c.toJson()).toList(),
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    userId: json['userId'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount'].toDouble(),
    targetDate: (json['targetDate'] as Timestamp).toDate(),
    iconName: json['iconName'],
    colorValue: json['colorValue'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    contributions: (json['contributions'] as List?)
        ?.map((c) => SavingsContribution.fromJson(c))
        .toList() ?? [],
  );
}

class SavingsContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  SavingsContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'note': note,
  };

  factory SavingsContribution.fromJson(Map<String, dynamic> json) => SavingsContribution(
    id: json['id'],
    amount: json['amount'].toDouble(),
    date: (json['date'] as Timestamp).toDate(),
    note: json['note'],
  );
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'createdAt': createdAt,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    message: json['message'],
    type: json['type'],
    isRead: json['isRead'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}

// ============ PROVIDERS ============

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Function(String uid)? onUserAuthenticated;
  VoidCallback? onUserSignedOut;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
        onUserAuthenticated?.call(user.uid);
      } else {
        _user = null;
        onUserSignedOut?.call();
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = AppUser.fromJson(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _error = null;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        username: username,
        profession: '',
        currency: '\$',
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(appUser.toJson());
      _user = appUser;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? username,
    String? profession,
    String? currency,
    String? profileImageUrl,
  }) async {
    if (_user == null) return;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (profession != null) updates['profession'] = profession;
    if (currency != null) updates['currency'] = currency;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

    await _firestore.collection('users').doc(_user!.uid).update(updates);

    _user = AppUser(
      uid: _user!.uid,
      email: _user!.email,
      username: username ?? _user!.username,
      profession: profession ?? _user!.profession,
      currency: currency ?? _user!.currency,
      profileImageUrl: profileImageUrl ?? _user!.profileImageUrl,
      createdAt: _user!.createdAt,
    );
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  String _userId = '';

  List<Transaction> get transactions => _transactions;

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setUserId(String userId) {
    _userId = userId;
    _listenToTransactions();
  }

  void _listenToTransactions() {
    if (_userId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transaction.id)
        .set(transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  Map<String, double> getCategoryBreakdown() {
    final Map<String, double> breakdown = {};
    for (var t in currentMonthTransactions.where((t) => t.type == 'expense')) {
      breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
    }
    return breakdown;
  }
}

class SavingsProvider extends ChangeNotifier {
  List<SavingsGoal> _goals = [];
  String _userId = '';
  bool _isLoading = false;
  String? _error;

  List<SavingsGoal> get goals => _goals;
  double get totalSaved => _goals.fold(0, (sum, g) => sum + g.currentAmount);
  double get totalTarget => _goals.fold(0, (sum, g) => sum + g.targetAmount);
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setUserId(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _goals = [];
    if (_userId.isNotEmpty) {
      _listenToGoals();
    } else {
      notifyListeners();
    }
  }

  void _listenToGoals() {
    if (_userId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(_userId)
        .collection('savings_goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _goals = snapshot.docs
          .map((doc) => SavingsGoal.fromJson(doc.data()))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  Future<void> addGoal(SavingsGoal goal) async {
    if (_userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('savings_goals')
          .doc(goal.id)
          .set(goal.toJson());
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContribution(String goalId, double amount, {String? note}) async {
    if (_userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final goalIndex = _goals.indexWhere((g) => g.id == goalId);
      if (goalIndex == -1) {
        throw Exception('Goal not found');
      }

      final goal = _goals[goalIndex];
      final contribution = SavingsContribution(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        date: DateTime.now(),
        note: note,
      );

      final updatedContributions = [...goal.contributions, contribution];
      final newAmount = goal.currentAmount + amount;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('savings_goals')
          .doc(goalId)
          .update({
        'currentAmount': newAmount,
        'contributions': updatedContributions.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    if (_userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('savings_goals')
          .doc(id)
          .delete();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  String _userId = '';

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setUserId(String userId) {
    _userId = userId;
    _listenToNotifications();
  }

  void _listenToNotifications() {
    if (_userId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => AppNotification.fromJson(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addNotification(AppNotification notification) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  }

  Future<void> markAsRead(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    for (var notification in _notifications.where((n) => !n.isRead)) {
      batch.update(_firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .doc(notification.id), {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(id)
        .delete();
  }
}

// ============ SCREENS ============

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.account_balance_wallet, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('CashLyf', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
              const SizedBox(height: 46),
              if (!_isLogin)
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 22),
              if (authProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    bool success;
                    if (_isLogin) {
                      success = await authProvider.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    } else {
                      success = await authProvider.signUp(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _usernameController.text.trim(),
                      );
                    }
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authProvider.error ?? 'Error'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(_isLogin ? 'Login' : 'Sign Up'),
                ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Create an account' : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String _selectedType = 'expense';
  String _selectedCategory = 'Food';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _checkForLargeTransaction(double amount, String type, double newBalance) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (type == 'income' && amount >= 500) {
      final hasActiveSavings = savingsProvider.goals.isNotEmpty;

      if (hasActiveSavings && newBalance > 500) {
        await notificationProvider.addNotification(AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: authProvider.user!.uid,
          title: '💰 Extra Cash Available!',
          message: 'New income is added. Want to save?',
          type: 'reminder',
          isRead: false,
          createdAt: DateTime.now(),
        ));

        await NotificationService().showNotification(
          id: DateTime.now().millisecond,
          title: 'Extra Cash Available!',
          body: 'Consider adding to your savings goals',
        );
      }
    }
  }

  void _addTransaction() {
    _titleController.clear();
    _amountController.clear();
    _selectedType = 'expense';
    _selectedCategory = 'Food';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              if (_selectedType == 'expense')
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Education', 'Other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => _selectedCategory = value);
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final amount = double.tryParse(_amountController.text.trim());
                if (title.isNotEmpty && amount != null && amount > 0) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

                  await transactionProvider.addTransaction(Transaction(
                    id: _firestore.collection('_').doc().id,
                    userId: authProvider.user!.uid,
                    title: title,
                    amount: amount,
                    type: _selectedType,
                    date: DateTime.now(),
                    category: _selectedType == 'expense' ? _selectedCategory : 'Income',
                    createdAt: DateTime.now(),
                  ));

                  final newBalance = _selectedType == 'income'
                      ? transactionProvider.totalBalance + amount
                      : transactionProvider.totalBalance - amount;
                  await _checkForLargeTransaction(amount, _selectedType, newBalance);

                  if (mounted) Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid title and amount')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Text(user != null && user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Hello, ${user?.username ?? 'User'}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    '${user?.currency ?? '\$'} ${transactionProvider.totalBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Income', style: TextStyle(color: Colors.white70)),
                            Text('${user?.currency ?? '\$'} ${transactionProvider.totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expenses', style: TextStyle(color: Colors.white70)),
                            Text('${user?.currency ?? '\$'} ${transactionProvider.totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ],
            ),
            const SizedBox(height: 10),
            if (transactionProvider.transactions.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No transactions yet')))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactionProvider.transactions.length > 5 ? 5 : transactionProvider.transactions.length,
                itemBuilder: (context, index) {
                  final t = transactionProvider.transactions[index];
                  return Dismissible(
                    key: Key(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: Text('Delete "${t.title}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (_) => transactionProvider.deleteTransaction(t.id),
                    child: Card(
                      child: ListTile(
                        leading: Icon(t.type == 'income' ? Icons.trending_up : Icons.trending_down,
                            color: t.type == 'income' ? Colors.green : Colors.red),
                        title: Text(t.title),
                        subtitle: Text('${DateFormat('dd MMM').format(t.date)} • ${t.category}'),
                        trailing: Text('${user?.currency ?? '\$'} ${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(color: t.type == 'income' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final categories = transactionProvider.getCategoryBreakdown();
    final total = categories.values.fold(0.0, (s, v) => s + v);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Income',
                    '${user?.currency ?? '\$'} ${transactionProvider.currentMonthIncome.toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Expense',
                    '${user?.currency ?? '\$'} ${transactionProvider.currentMonthExpense.toStringAsFixed(0)}',
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (categories.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: categories.entries.map((e) {
                            final pct = (e.value / total) * 100;
                            return PieChartSectionData(
                              value: e.value,
                              title: '${pct.toStringAsFixed(0)}%',
                              color: _getCategoryColor(e.key),
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }).toList(),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...categories.entries.map((e) {
                      final pct = (e.value / total) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: _getCategoryColor(e.key), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(flex: 2, child: Text(e.key)),
                            Text('${user?.currency ?? '\$'} ${e.value.toStringAsFixed(0)}', textAlign: TextAlign.right),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 50,
                              child: Text('${pct.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[600])),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
    ],
  );

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.purple;
      case 'Shopping': return Colors.pink;
      case 'Bills': return Colors.red;
      case 'Entertainment': return Colors.teal;
      case 'Health': return Colors.green;
      case 'Education': return Colors.indigo;
      default: return Colors.grey;
    }
  }
}

// ============ SAVINGS PAGE ============

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final List<Map<String, dynamic>> _icons = [
    {'name': '🏦', 'icon': Icons.savings},
    {'name': '🏠', 'icon': Icons.house},
    {'name': '🚗', 'icon': Icons.directions_car},
    {'name': '✈️', 'icon': Icons.flight},
    {'name': '🎓', 'icon': Icons.school},
    {'name': '❤️', 'icon': Icons.favorite},
    {'name': '📱', 'icon': Icons.phone_iphone},
    {'name': '💰', 'icon': Icons.attach_money},
  ];

  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _contributionAmountController = TextEditingController();
  final TextEditingController _contributionNoteController = TextEditingController();

  String _selectedIcon = '🏦';
  int _selectedColor = 0xFF2196F3;
  DateTime _selectedTargetDate = DateTime.now().add(const Duration(days: 30));
  SavingsGoal? _selectedGoal;

  bool _showAddGoalForm = false;
  bool _showAddMoneyForm = false;
  bool _isSubmitting = false;

  final List<Color> _colors = [
    const Color(0xFF2196F3),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFFF44336),
    const Color(0xFF009688),
    const Color(0xFF795548),
    const Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
      if (authProvider.user != null) {
        savingsProvider.setUserId(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _contributionAmountController.dispose();
    _contributionNoteController.dispose();
    super.dispose();
  }

  void _resetAddGoalForm() {
    _goalNameController.clear();
    _targetAmountController.clear();
    _selectedIcon = '🏦';
    _selectedColor = 0xFF2196F3;
    _selectedTargetDate = DateTime.now().add(const Duration(days: 30));
    _isSubmitting = false;
  }

  void _resetAddMoneyForm() {
    _contributionAmountController.clear();
    _contributionNoteController.clear();
    _selectedGoal = null;
    _isSubmitting = false;
  }

  Future<void> _createGoal() async {
    if (_goalNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal name'), backgroundColor: Colors.red),
      );
      return;
    }

    final amount = double.tryParse(_targetAmountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);

      final goal = SavingsGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authProvider.user!.uid,
        name: _goalNameController.text.trim(),
        targetAmount: amount,
        currentAmount: 0,
        targetDate: _selectedTargetDate,
        iconName: _selectedIcon,
        colorValue: _selectedColor,
        createdAt: DateTime.now(),
        contributions: [],
      );

      await savingsProvider.addGoal(goal);

      setState(() {
        _showAddGoalForm = false;
        _resetAddGoalForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal created successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _addMoneyToGoal() async {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No goal selected'), backgroundColor: Colors.red),
      );
      return;
    }

    final amount = double.tryParse(_contributionAmountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      await savingsProvider.addContribution(
        _selectedGoal!.id,
        amount,
        note: _contributionNoteController.text.trim().isNotEmpty
            ? _contributionNoteController.text.trim()
            : null,
      );

      setState(() {
        _showAddMoneyForm = false;
        _resetAddMoneyForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${user?.currency ?? '\$'}${amount.toStringAsFixed(2)} to ${_selectedGoal!.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
        await savingsProvider.deleteGoal(goal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${goal.name} deleted'), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getEmoji(String iconName) {
    switch (iconName) {
      case '🏦': return '🏦';
      case '🏠': return '🏠';
      case '🚗': return '🚗';
      case '✈️': return '✈️';
      case '🎓': return '🎓';
      case '❤️': return '❤️';
      case '📱': return '📱';
      case '💰': return '💰';
      default: return '💰';
    }
  }

  @override
  Widget build(BuildContext context) {
    final savingsProvider = Provider.of<SavingsProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final currency = user?.currency ?? '\$';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showAddGoalForm = true),
            tooltip: 'Create Goal',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.user != null) {
                savingsProvider.setUserId(authProvider.user!.uid);
              }
            },
            child: savingsProvider.isLoading && savingsProvider.goals.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : savingsProvider.goals.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No savings goals yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Tap the + button to create one', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAddGoalForm = true),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Your First Goal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savingsProvider.goals.length,
              itemBuilder: (context, index) {
                final goal = savingsProvider.goals[index];
                final color = Color(goal.colorValue);
                final progress = goal.progress;
                final isCompleted = progress >= 1.0;
                final remaining = goal.targetAmount - goal.currentAmount;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getEmoji(goal.iconName),
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.name,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Target: $currency${goal.targetAmount.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Complete! 🎉', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Progress', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    Text('${(progress * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Saved', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        const SizedBox(height: 4),
                                        Text('$currency${goal.currentAmount.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Remaining', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        const SizedBox(height: 4),
                                        Text('$currency${remaining.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('Days Left', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        const SizedBox(height: 4),
                                        Text('${goal.daysLeft}',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedGoal = goal;
                                        _showAddMoneyForm = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('Add Money'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () => _deleteGoal(goal),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                  ),
                                  tooltip: 'Delete Goal',
                                ),
                              ],
                            ),
                            if (goal.contributions.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.history, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text('Recent Contributions',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...goal.contributions.reversed.take(3).map((contribution) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.arrow_upward, size: 14, color: Colors.green),
                                                const SizedBox(width: 4),
                                                Text(DateFormat('dd MMM').format(contribution.date),
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                              ],
                                            ),
                                            Text('+$currency${contribution.amount.toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showAddGoalForm)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Create New Goal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _showAddGoalForm = false;
                                  _resetAddGoalForm();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _goalNameController,
                          decoration: const InputDecoration(
                            labelText: 'Goal Name',
                            hintText: 'e.g., Dream Vacation, New Car',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _targetAmountController,
                          decoration: InputDecoration(
                            labelText: 'Target Amount',
                            hintText: '0.00',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                            prefixText: '$currency ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Target Date'),
                          subtitle: Text(DateFormat('MMMM dd, yyyy').format(_selectedTargetDate)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedTargetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null && mounted) {
                              setState(() => _selectedTargetDate = date);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: _icons.map((icon) {
                            final isSelected = _selectedIcon == icon['name'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIcon = icon['name']),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                                ),
                                child: Text(icon['name'], style: const TextStyle(fontSize: 24)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        const Text('Choose Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _colors.map((color) {
                            final isSelected = _selectedColor == color.value;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = color.value),
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () {
                                  setState(() {
                                    _showAddGoalForm = false;
                                    _resetAddGoalForm();
                                  });
                                },
                                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _createGoal,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Text('Create Goal', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_showAddMoneyForm && _selectedGoal != null)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add to ${_selectedGoal!.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _showAddMoneyForm = false;
                                _resetAddMoneyForm();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(_selectedGoal!.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Savings:', style: TextStyle(fontSize: 14)),
                            Text(
                              '$currency${_selectedGoal!.currentAmount.toStringAsFixed(2)} / $currency${_selectedGoal!.targetAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _contributionAmountController,
                        decoration: InputDecoration(
                          labelText: 'Amount to Add',
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.attach_money),
                          prefixText: '$currency ',
                        ),
                        keyboardType: TextInputType.number,
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contributionNoteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          hintText: 'e.g., Monthly savings, Bonus, etc.',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                setState(() {
                                  _showAddMoneyForm = false;
                                  _resetAddMoneyForm();
                                });
                              },
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _addMoneyToGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(_selectedGoal!.colorValue),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Add Money', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _professionController = TextEditingController();
  bool _isEditing = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _usernameController.text = authProvider.user!.username;
      _professionController.text = authProvider.user!.profession;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _professionController.dispose();
    super.dispose();
  }



  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.updateUserProfile(
      username: _usernameController.text.trim(),
      profession: _professionController.text.trim(),
    );

    setState(() => _isEditing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _usernameController.text = user?.username ?? '';
                  _professionController.text = user?.profession ?? '';
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2196F3), width: 3),
                      image: user?.profileImageUrl != null
                          ? DecorationImage(
                        image: NetworkImage(user!.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: user?.profileImageUrl == null
                        ? CircleAvatar(
                      radius: 58,
                      backgroundColor: const Color(0xFF2196F3),
                      child: Text(
                        user != null && user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _isUploading
                        ? Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,

                        ),

                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(child: Text(user?.email ?? '', style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Username', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  _isEditing
                      ? TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(child: Text(user?.username ?? '', style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Profession', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  _isEditing
                      ? TextField(
                    controller: _professionController,
                    decoration: InputDecoration(
                      hintText: 'Enter profession',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work, size: 20, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            user?.profession?.isNotEmpty == true ? user!.profession : 'Not specified',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.attach_money, color: Color(0xFF2196F3)),
                          SizedBox(width: 10),
                          Text('Currency'),
                        ],
                      ),
                      DropdownButton<String>(
                        value: user?.currency ?? '\$',
                        items: ['\$', '€', '£', '¥', '₹', '৳', '₿']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 16))))
                            .toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            await authProvider.updateUserProfile(currency: value);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Currency updated')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await authProvider.signOut();
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return '🎉';
      case 'reminder':
        return '💰';
      default:
        return 'ℹ️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notifications yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('You\'ll see milestones and savings tips here', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final n = notificationProvider.notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: n.isRead ? null : const Color(0xFF2196F3).withOpacity(0.05),
            child: ListTile(
              leading: Text(
                _getNotificationIcon(n.type),
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.message),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(n.createdAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: !n.isRead
                  ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
              )
                  : null,
              onTap: () {
                if (!n.isRead) notificationProvider.markAsRead(n.id);
              },
            ),
          );
        },
      ),
    );
  }
}

// ============ MAIN APP ============

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'CashLyf',
            theme: ThemeData(
              primaryColor: const Color(0xFF2196F3),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: authProvider.isAuthenticated ? const MainWrapper() : const LoginPage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    AnalyticsPage(),
    SavingsPage(),
    ProfilePage(),
    NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    authProvider.onUserAuthenticated = (uid) {
      transactionProvider.setUserId(uid);
      savingsProvider.setUserId(uid);
      notificationProvider.setUserId(uid);
    };
    authProvider.onUserSignedOut = () {
      transactionProvider.setUserId('');
      savingsProvider.setUserId('');
      notificationProvider.setUserId('');
    };

    if (authProvider.user != null) {
      transactionProvider.setUserId(authProvider.user!.uid);
      savingsProvider.setUserId(authProvider.user!.uid);
      notificationProvider.setUserId(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}