import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
//import '../../models/models.dart';
//import '../../providers/zalono_provider.dart';

class CustomerCRMScreen extends StatefulWidget {
  const CustomerCRMScreen({super.key});

  @override
  State<CustomerCRMScreen> createState() => _CustomerCRMScreenState();
}

class _CustomerCRMScreenState extends State<CustomerCRMScreen> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Customer CRM',
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
            // Search Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildTab('All Customers', 0),
                  const SizedBox(width: 24),
                  _buildTab('VIP', 1),
                  const SizedBox(width: 24),
                  _buildTab('New This Month', 2),
                ],
              ),
            ),

            // Customer List
            Expanded(
              child: _buildCustomerList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: isSelected ? 60 : 0,
            color: ZalonoTheme.primaryBurgundy,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    final customers = [
      {
        'name': 'Isha ',
        'phone': '+91 00000 00000',
        'visits': 12,
        'spent': 15600,
        'lastVisit': '2 days ago',
        'favoriteService': 'Haircut',
        'favoriteStylist': 'Rahul',
        'isVip': true,
        'notes': 'Prefers morning slots, likes hot towel treatment',
      },
      {
        'name': 'Amit Patel',
        'phone': '+91 87654 32109',
        'visits': 8,
        'spent': 9800,
        'lastVisit': '1 week ago',
        'favoriteService': 'Haircut + Beard',
        'favoriteStylist': 'Priya',
        'isVip': false,
        'notes': 'Always asks for fade on sides',
      },
      {
        'name': 'Rohit Singh',
        'phone': '+91 76543 21098',
        'visits': 3,
        'spent': 3200,
        'lastVisit': '3 weeks ago',
        'favoriteService': 'Premium Haircut',
        'favoriteStylist': 'Amit',
        'isVip': false,
        'notes': 'New customer, referred by Jay',
      },
      {
        'name': 'Vikram Reddy',
        'phone': '+91 00000 00000',
        'visits': 15,
        'spent': 22400,
        'lastVisit': '5 days ago',
        'favoriteService': 'Hair Color',
        'favoriteStylist': 'Neha',
        'isVip': true,
        'notes': 'Color specialist client, books 2hr slots',
      },
      {
        'name': 'Suresh Kumar',
        'phone': '+91 00000 00000',
        'visits': 1,
        'spent': 599,
        'lastVisit': 'Today',
        'favoriteService': 'Haircut + Beard',
        'favoriteStylist': 'Rahul',
        'isVip': false,
        'notes': 'First visit walk-in',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showCustomerDetail(context, c),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: c['isVip'] == true
                          ? Colors.amber.shade100
                          : ZalonoTheme.primaryLight,
                      child: Text(
                        (c['name'] as String)[0],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: c['isVip'] == true
                              ? Colors.amber.shade800
                              : ZalonoTheme.primaryBurgundy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['name'] as String,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              if (c['isVip'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c['phone'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildMiniStat('${c['visits']} visits', Icons.calendar_today_rounded),
                              const SizedBox(width: 16),
                              _buildMiniStat('₹${c['spent']}', Icons.currency_rupee_rounded),
                              const SizedBox(width: 16),
                              _buildMiniStat(c['lastVisit'] as String, Icons.access_time_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(height: 4),
                        Text(
                          c['favoriteService'] as String,
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildMiniStat(String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
      ],
    );
  }

  void _showCustomerDetail(BuildContext context, Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: customer['isVip'] == true
                          ? Colors.amber.shade100
                          : ZalonoTheme.primaryLight,
                      child: Text(
                        (customer['name'] as String)[0],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: customer['isVip'] == true
                              ? Colors.amber.shade800
                              : ZalonoTheme.primaryBurgundy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                customer['name'] as String,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              if (customer['isVip'] == true) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            customer['phone'] as String,
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),

                _buildDetailSection('Visit History', [
                  _buildDetailRow('Total Visits', '${customer['visits']}'),
                  _buildDetailRow('Total Spent', '₹${customer['spent']}'),
                  _buildDetailRow('Last Visit', customer['lastVisit'] as String),
                  _buildDetailRow('Favorite Service', customer['favoriteService'] as String),
                  _buildDetailRow('Preferred Stylist', customer['favoriteStylist'] as String),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('Notes', [
                  _buildDetailRow('', customer['notes'] as String, isNote: true),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('Quick Actions', [
                  _buildActionRow(Icons.message_outlined, 'Send Message', Colors.blue),
                  _buildActionRow(Icons.phone_outlined, 'Call', Colors.green),
                  _buildActionRow(Icons.calendar_today_outlined, 'Book Appointment', ZalonoTheme.primaryBurgundy),
                  _buildActionRow(Icons.star_outlined, 'Add Loyalty Points', Colors.amber),
                ]),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ZalonoTheme.textDark),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isNote = false}) {
    if (isNote) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues()),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, color: color.withValues()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}