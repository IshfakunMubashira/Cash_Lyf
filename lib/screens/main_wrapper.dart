import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'savings_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    AnalyticsScreen(),
    SavingsScreen(),
    ProfileScreen(),
    NotificationsScreen(),
  ];

  void _showAddTransactionDialog(BuildContext context) {
    // This will be implemented in dashboard_screen.dart
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Savings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }
}