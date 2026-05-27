import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/savings_provider.dart';
import '../models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildBalanceCard(),
              const SizedBox(height: 20),
              _buildMonthlyTracker(),
              const SizedBox(height: 20),
              _buildSavingsCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final userProvider = Provider.of<UserProvider>(context);
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              userProvider.username.isNotEmpty ? userProvider.username[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(
                userProvider.username,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.notifications, color: Color(0xFF2196F3)),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '${userProvider.currency} ${transactionProvider.totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Income', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      '${userProvider.currency} ${transactionProvider.totalIncome.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Expenses', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                      '${userProvider.currency} ${transactionProvider.totalExpense.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTracker() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('This Month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Income: ${userProvider.currency}${transactionProvider.currentMonthIncome.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTab('Income', 0),
                  _buildTab('Expense', 1),
                ],
              ),
              const SizedBox(height: 15),
              _buildTransactionList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF2196F3) : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? const Color(0xFF2196F3) : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final type = _selectedTabIndex == 0 ? 'income' : 'expense';
    final transactions = transactionProvider.currentMonthTransactions
        .where((t) => t.type == type)
        .toList();

    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No transactions found')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 15, color: Colors.grey),
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: t.type == 'income' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                t.type == 'income' ? Icons.trending_up : Icons.trending_down,
                color: t.type == 'income' ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text(t.category, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      const SizedBox(width: 8),
                      Text(DateFormat('dd MMM').format(t.date), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${userProvider.currency} ${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: t.type == 'income' ? Colors.green : Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsCard() {
    final savingsProvider = Provider.of<SavingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
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
          const Text('Savings Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Saved', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '${userProvider.currency}${savingsProvider.totalSaved.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      savingsProvider.totalTarget > 0
                          ? '${(savingsProvider.totalSaved / savingsProvider.totalTarget * 100).toStringAsFixed(1)}%'
                          : '0%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (savingsProvider.goals.isNotEmpty) ...[
            const SizedBox(height: 15),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savingsProvider.goals.length > 3 ? 3 : savingsProvider.goals.length,
                itemBuilder: (_, index) {
                  final goal = savingsProvider.goals[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(goal.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(goal.colorValue).withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings, color: Color(goal.colorValue), size: 20),
                        const SizedBox(height: 4),
                        Text(
                          goal.name.length > 8 ? '${goal.name.substring(0, 8)}…' : goal.name,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(goal.colorValue)),
                        ),
                        Text('${(goal.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'Food';
    DateTime selectedDate = DateTime.now();

    const categories = ['Food', 'Housing', 'Transport', 'Bills', 'Shopping', 'Entertainment', 'Health', 'Education', 'Other'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Add Transaction'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                    ],
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  const SizedBox(height: 10),
                  if (selectedType == 'expense')
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (value) => setState(() => selectedCategory = value!),
                    ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
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
                          Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text.trim());
                  if (title.isNotEmpty && amount != null && amount > 0) {
                    transactionProvider.addTransaction(
                      Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: '', // Will be set by Firestore rules
                        title: title,
                        amount: amount,
                        type: selectedType,
                        date: selectedDate,
                        category: selectedType == 'expense' ? selectedCategory : 'Income',
                        createdAt: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid title and amount.')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}