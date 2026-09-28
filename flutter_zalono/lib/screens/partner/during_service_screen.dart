import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class DuringServiceScreen extends StatefulWidget {
  final Booking? booking;

  const DuringServiceScreen({super.key, this.booking});

  @override
  State<DuringServiceScreen> createState() => _DuringServiceScreenState();
}

class _DuringServiceScreenState extends State<DuringServiceScreen> {
  int _currentStep = 2; // 0: Checked In, 1: You're Next, 2: In Service, 3: Completed

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final booking = widget.booking ?? zalono.activeBooking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Service')),
        body: const Center(child: Text('No active booking')),
      );
    }

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
          'Live Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: ZalonoTheme.primaryLight,
                      child: Text(
                        (booking.customerName.split(' ').first)[0],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ZalonoTheme.primaryBurgundy),
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
                                booking.customerName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStepColor(_currentStep).withValues(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStepLabel(_currentStep),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _getStepColor(_currentStep),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${booking.serviceName} · ₹${booking.servicePrice.toInt()} · ${booking.serviceDuration} min',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          Text(
                            'Stylist: ${booking.stylistName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.phone_outlined, size: 20, color: ZalonoTheme.primaryBurgundy),
                        SizedBox(height: 4),
                        Icon(Icons.message_outlined, size: 20, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress Stepper
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Progress',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildProgressStep(
                      step: 0,
                      title: 'Checked In',
                      time: '11:28 AM',
                      subtitle: 'Customer arrived',
                    ),
                    _buildProgressStep(
                      step: 1,
                      title: "You're Next",
                      time: '11:40 AM',
                      subtitle: 'Preparing station',
                    ),
                    _buildProgressStep(
                      step: 2,
                      title: 'In Service',
                      time: '11:43 AM',
                      subtitle: 'Service in progress',
                      isCurrent: true,
                    ),
                    _buildProgressStep(
                      step: 3,
                      title: 'Completed',
                      time: '—',
                      subtitle: 'Payment & feedback',
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Service Timer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZalonoTheme.primaryBurgundy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Service Timer',
                      style: TextStyle(fontSize: 14, color: Colors.white.withValues()),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '32:15',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ${booking.serviceDuration} minutes',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimerButton(Icons.pause_rounded, 'Pause', () {}),
                        _buildTimerButton(Icons.add_rounded, '+5 min', () {}),
                        _buildTimerButton(Icons.remove_rounded, '-5 min', () {}),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Service Notes
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Notes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add notes about this service...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: ZalonoTheme.primaryBurgundy, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Upsell Services
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Add-ons',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAddonChip('Hair Wash', '₹199'),
                        _buildAddonChip('Head Massage', '₹299'),
                        _buildAddonChip('Beard Trim', '₹149'),
                        _buildAddonChip('Hair Serum', '₹99'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              if (_currentStep < 3) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep < 3) {
                        setState(() => _currentStep++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 2 ? ZalonoTheme.accentGreen : ZalonoTheme.primaryBurgundy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Complete Service' : 'Next Step',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      zalono.advanceQueueStatus(booking.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZalonoTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Finish & Request Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep({
    required int step,
    required String title,
    required String time,
    required String subtitle,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    final isDone = step < _currentStep;
    final nodeColor = isDone
        ? ZalonoTheme.accentGreen
        : (isCurrent ? ZalonoTheme.primaryBurgundy : Colors.grey.shade300);
    final iconColor = isDone || isCurrent ? Colors.white : Colors.grey.shade500;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check : _getStepIcon(step),
                size: 14,
                color: iconColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone ? ZalonoTheme.accentGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: isCurrent ? ZalonoTheme.primaryBurgundy : (isDone ? ZalonoTheme.accentGreen : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonChip(String name, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ZalonoTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZalonoTheme.primaryBurgundy.withValues()),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ZalonoTheme.primaryBurgundy)),
        ],
      ),
    );
  }

  Color _getStepColor(int step) {
    switch (step) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.purple;
      case 2:
        return ZalonoTheme.primaryBurgundy;
      case 3:
        return ZalonoTheme.accentGreen;
      default:
        return Colors.grey;
    }
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 0:
        return 'Checked In';
      case 1:
        return "You're Next";
      case 2:
        return 'In Service';
      case 3:
        return 'Completed';
      default:
        return '';
    }
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.login_rounded;
      case 1:
        return Icons.content_cut;
      case 2:
        return Icons.brush_outlined;
      case 3:
        return Icons.done_all_rounded;
      default:
        return Icons.circle;
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text('Message Customer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Call Customer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Service'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Colors.red),
              title: const Text('Cancel Service', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}