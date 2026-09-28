import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
//import '../../models/models.dart';
//import '../../providers/zalono_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0: Today, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Period Selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodChip('Today', 0),
                  _buildPeriodChip('This Week', 1),
                  _buildPeriodChip('This Month', 2),
                ],
              ),
            ),

            // Key Metrics
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          '₹24,850',
                          'Total Revenue',
                          Icons.currency_rupee_rounded,
                          '+18% vs last period',
                          ZalonoTheme.primaryBurgundy,
                          isHighlight: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          '38',
                          'Appointments',
                          Icons.calendar_today_rounded,
                          '+5 vs last period',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          '6.2',
                          'Avg. Rating',
                          Icons.star_rounded,
                          '↑ 0.3 from last month',
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          '89%',
                          'Retention Rate',
                          Icons.repeat_rounded,
                          'Industry leading',
                          ZalonoTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Charts Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartCard(
                      'Revenue Trend',
                      Icons.trending_up_rounded,
                      _buildRevenueChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      'Appointments by Day',
                      Icons.bar_chart_rounded,
                      _buildAppointmentsChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      'Service Distribution',
                      Icons.pie_chart_rounded,
                      _buildServiceDistribution(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      'Stylist Performance',
                      Icons.leaderboard_rounded,
                      _buildStylistPerformance(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, String subtitle, Color color, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? ZalonoTheme.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? ZalonoTheme.primaryBurgundy.withValues() : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isHighlight ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, IconData icon, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: ZalonoTheme.primaryBurgundy),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final data = _selectedPeriod == 0
        ? [3200, 4100, 3800, 5200, 4800, 6100, 5500]
        : _selectedPeriod == 1
            ? [18000, 22000, 19000, 25000, 23000, 28000, 24850]
            : [72000, 85000, 78000, 92000, 88000, 105000, 98000];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(data.length, (i) {
          final height = (data[i] / maxVal) * 100;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: height,
                decoration: BoxDecoration(
                  color: ZalonoTheme.primaryBurgundy,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(labels[i], style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAppointmentsChart() {
    final data = _selectedPeriod == 0
        ? [4, 5, 3, 6, 7, 8, 5]
        : _selectedPeriod == 1
            ? [22, 28, 24, 32, 30, 38, 34]
            : [88, 105, 96, 118, 112, 135, 128];
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(data.length, (i) {
          final height = (data[i] / maxVal) * 100;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(labels[i], style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildServiceDistribution() {
    final services = [
      {'name': 'Haircut', 'count': 45, 'color': ZalonoTheme.primaryBurgundy},
      {'name': 'Haircut + Beard', 'count': 28, 'color': Colors.blue},
      {'name': 'Premium Haircut', 'count': 18, 'color': Colors.amber},
      {'name': 'Hair Color', 'count': 12, 'color': Colors.purple},
      {'name': 'Facial', 'count': 8, 'color': Colors.pink},
      {'name': 'Beard Trim', 'count': 5, 'color': Colors.teal},
    ];
    final total = services.fold(0, (sum, s) => sum + (s['count'] as int));

    final children = <Widget>[];
    for (final s in services) {
      final count = s['count'] as int;
      final percentage = (count / total * 100).toStringAsFixed(1);
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: s['color'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s['name'] as String, style: const TextStyle(fontSize: 13)),
              ),
              SizedBox(
                width: 120,
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(
                      height: 6,
                      width: 120 * (count / total),
                      decoration: BoxDecoration(
                        color: s['color'] as Color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count ($percentage%)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: children);
  }

  Widget _buildStylistPerformance() {
    final stylists = [
      {'name': 'Rahul', 'appointments': 14, 'revenue': 11200, 'rating': 4.9, 'utilization': 85},
      {'name': 'Priya', 'appointments': 11, 'revenue': 8900, 'rating': 4.8, 'utilization': 78},
      {'name': 'Amit', 'appointments': 9, 'revenue': 6300, 'rating': 4.7, 'utilization': 65},
      {'name': 'Neha', 'appointments': 4, 'revenue': 4200, 'rating': 4.6, 'utilization': 42},
    ];

    return Column(
      children: stylists.map((s) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: ZalonoTheme.primaryLight,
                child: Text(
                  (s['name'] as String)[0],
                  style: const TextStyle(color: ZalonoTheme.primaryBurgundy, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text(
                          '${s['appointments']} appts',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade600),
                            const SizedBox(width: 2),
                            Text('${s['rating']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${s['revenue']}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ZalonoTheme.primaryBurgundy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (s['utilization'] as int) > 70 ? ZalonoTheme.accentGreenLight : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${s['utilization']}% util.',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: (s['utilization'] as int) > 70 ? ZalonoTheme.accentGreen : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}