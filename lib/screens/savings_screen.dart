import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/savings_provider.dart';
import '../providers/user_provider.dart';
import '../models/savings_model.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _targetDate;
  String _selectedIcon = 'savings';
  int _selectedColor = 0xFF2196F3;

  final Map<String, TextEditingController> _addAmountControllers = {};

  final List<String> _availableIcons = [
    'savings', 'security', 'flight', 'phone_iphone',
    'directions_car', 'house', 'school', 'favorite',
  ];

  final List<int> _availableColors = [
    0xFF2196F3, 0xFF4CAF50, 0xFFFF9800, 0xFF9C27B0,
    0xFFF44336, 0xFF009688, 0xFFE91E63, 0xFF3F51B5,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    for (final c in _addAmountControllers.values) c.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings': return Icons.savings;
      case 'security': return Icons.security;
      case 'flight': return Icons.flight;
      case 'phone_iphone': return Icons.phone_iphone;
      case 'directions_car': return Icons.directions_car;
      case 'house': return Icons.house;
      case 'school': return Icons.school;
      case 'favorite': return Icons.favorite;
      default: return Icons.savings;
    }
  }

  void _showAddGoalDialog() {
    _nameController.clear();
    _targetController.clear();
    _currentController.clear();
    _targetDate = null;
    _selectedIcon = 'savings';
    _selectedColor = 0xFF2196F3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Add Savings Goal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Goal Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _currentController,
                    decoration: const InputDecoration(labelText: 'Current Amount (Optional)', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) setDialogState(() => _targetDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_targetDate == null ? 'Select Target Date' : DateFormat('dd/MM/yyyy').format(_targetDate!)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(alignment: Alignment.centerLeft, child: Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableIcons.length,
                      itemBuilder: (_, i) {
                        final selected = _selectedIcon == _availableIcons[i];
                        return GestureDetector(
                          onTap: () => setDialogState(() => _selectedIcon = _availableIcons[i]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF2196F3).withOpacity(0.2) : null,
                              border: Border.all(color: selected ? const Color(0xFF2196F3) : Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_getIconData(_availableIcons[i]), color: selected ? const Color(0xFF2196F3) : Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(alignment: Alignment.centerLeft, child: Text('Choose Color', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      itemBuilder: (_, i) {
                        final selected = _selectedColor == _availableColors[i];
                        return GestureDetector(
                          onTap: () => setDialogState(() => _selectedColor = _availableColors[i]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(_availableColors[i]),
                              shape: BoxShape.circle,
                              border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2),
                              boxShadow: selected ? [BoxShadow(color: Color(_availableColors[i]).withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  final target = double.tryParse(_targetController.text.trim());
                  if (name.isEmpty || target == null || target <= 0 || _targetDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields.')),
                    );
                    return;
                  }
                  final currentText = _currentController.text.trim();
                  final current = currentText.isEmpty ? 0.0 : (double.tryParse(currentText) ?? 0.0);

                  final savingsProvider = Provider.of<SavingsProvider>(context, listen: false);
                  savingsProvider.addGoal(
                    SavingsGoal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: '',
                      name: name,
                      targetAmount: target,
                      currentAmount: current,
                      targetDate: _targetDate!,
                      iconName: _selectedIcon,
                      colorValue: _selectedColor,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savingsProvider = Provider.of<SavingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddGoalDialog),
        ],
      ),
      body: savingsProvider.goals.isEmpty
          ? const Center(child: Text('No savings goals yet. Tap + to add one!'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savingsProvider.goals.length,
        itemBuilder: (context, index) {
          final goal = savingsProvider.goals[index];
          final addCtrl = _addAmountControllers.putIfAbsent(goal.id, () => TextEditingController());

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(goal.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getIconData(goal.iconName), color: Color(goal.colorValue), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Target: ${userProvider.currency}${goal.targetAmount.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Goal'),
                              content: Text('Delete "${goal.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    savingsProvider.deleteGoal(goal.id);
                                    Navigator.pop(ctx);
                                  },
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Color(goal.colorValue)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saved: ${userProvider.currency}${goal.currentAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('${(goal.progress * 100).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(goal.colorValue))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(goal.daysLeft > 0 ? '${goal.daysLeft} days left' : 'Past due',
                              style: TextStyle(fontSize: 12, color: goal.daysLeft > 0 ? Colors.grey[600] : Colors.red)),
                        ],
                      ),
                      if (goal.daysLeft > 0 && goal.currentAmount < goal.targetAmount)
                        Text('Need ${userProvider.currency}${goal.monthlyRequired.toStringAsFixed(0)}/month',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2196F3))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: addCtrl,
                          decoration: InputDecoration(
                            hintText: 'Add amount',
                            prefixText: userProvider.currency,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(goal.colorValue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            final input = addCtrl.text.trim();
                            final amount = double.tryParse(input);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Enter a valid amount')),
                              );
                              return;
                            }
                            final newAmount = goal.currentAmount + amount;
                            if (newAmount <= goal.targetAmount) {
                              savingsProvider.updateGoal(goal.id, newAmount);
                              addCtrl.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Amount exceeds goal target')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}