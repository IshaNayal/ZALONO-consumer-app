import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  int _selectedTab = 0; // 0: Shifts, 1: Status

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salon = zalono.salons.first;

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
          'Staff Management',
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
            // Tab Selector
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildTab('Shift Schedule', 0),
                  const SizedBox(width: 16),
                  _buildTab('Live Status', 1),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildShiftsTab(context, salon)
                  : _buildStatusTab(context, salon),
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
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsTab(BuildContext context, Salon salon) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: salon.stylists.length,
      itemBuilder: (context, index) {
        final stylist = salon.stylists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  CircleAvatar(
                    backgroundColor: ZalonoTheme.primaryLight,
                    child: Text(
                      stylist.name[0],
                      style: const TextStyle(color: ZalonoTheme.primaryBurgundy, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stylist.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(stylist.role, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(stylist.status).withValues(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusLabel(stylist.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(stylist.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Text('Shift Hours', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInput('Shift Start', '10:00 AM', Icons.access_time),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeInput('Shift End', '7:00 PM', Icons.access_time),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Breaks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInput('Break Start', '1:00 PM', Icons.coffee),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeInput('Break End', '2:00 PM', Icons.coffee),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Copy from Yesterday'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ZalonoTheme.primaryBurgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Schedule'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTab(BuildContext context, Salon salon) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: salon.stylists.length,
      itemBuilder: (context, index) {
        final stylist = salon.stylists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: ZalonoTheme.primaryLight,
                child: Text(
                  stylist.name[0],
                  style: const TextStyle(color: ZalonoTheme.primaryBurgundy, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stylist.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(stylist.role, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              DropdownButton<StylistStatus>(
                value: stylist.status,
                underline: const SizedBox(),
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    Provider.of<ZalonoProvider>(context, listen: false).updateStylistStatus(salon.id, stylist.id, newStatus);
                  }
                },
                items: StylistStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusLabel(status)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeInput(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StylistStatus status) {
    switch (status) {
      case StylistStatus.available:
        return ZalonoTheme.accentGreen;
      case StylistStatus.withCustomer:
        return ZalonoTheme.accentAmber;
      case StylistStatus.onBreak:
        return Colors.grey.shade600;
      case StylistStatus.off:
        return Colors.red.shade600;
    }
  }

  String _getStatusLabel(StylistStatus status) {
    switch (status) {
      case StylistStatus.available:
        return 'Available';
      case StylistStatus.withCustomer:
        return 'With Customer';
      case StylistStatus.onBreak:
        return 'On Break';
      case StylistStatus.off:
        return 'Off Duty';
    }
  }
}