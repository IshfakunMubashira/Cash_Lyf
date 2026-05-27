import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(transactionProvider, userProvider),
            const SizedBox(height: 20),
            _buildMonthlyChart(transactionProvider, userProvider),
            const SizedBox(height: 20),
            _buildCategoryBreakdown(transactionProvider, userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(TransactionProvider tp, UserProvider up) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Income',
            '${up.currency}${tp.totalIncome.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Expense',
            '${up.currency}${tp.totalExpense.toStringAsFixed(0)}',
            Icons.trending_down,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
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

  Widget _buildMonthlyChart(TransactionProvider tp, UserProvider up) {
    final monthlyData = tp.getMonthlyChartData();

    if (monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: const Center(child: Text('No data available')),
      );
    }

    final List<String> months = monthlyData.keys.toList();
    double maxY = 0;
    for (var v in monthlyData.values) {
      if (v['income']! > maxY) maxY = v['income']!;
      if (v['expense']! > maxY) maxY = v['expense']!;
    }
    maxY = maxY == 0 ? 1000 : maxY * 1.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: months.asMap().entries.map((entry) {
                  final data = monthlyData[entry.value]!;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(toY: data['income']!, color: Colors.green, width: 16),
                      BarChartRodData(toY: data['expense']!, color: Colors.red, width: 16),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < months.length) {
                          return Text(months[value.toInt()], style: const TextStyle(fontSize: 12));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${up.currency}${value.toInt()}'),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(TransactionProvider tp, UserProvider up) {
    final categories = tp.getCategoryBreakdown();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = categories.values.fold(0.0, (s, v) => s + v);

    return Container(
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
                  Expanded(
                    flex: 1,
                    child: Text('${up.currency}${e.value.toStringAsFixed(0)}', textAlign: TextAlign.right),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('${pct.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[600])),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
    ],
  );

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Housing': return Colors.blue;
      case 'Transport': return Colors.purple;
      case 'Bills': return Colors.red;
      case 'Shopping': return Colors.pink;
      case 'Entertainment': return Colors.teal;
      case 'Health': return Colors.green;
      case 'Education': return Colors.indigo;
      default: return Colors.grey;
    }
  }
}