import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
//import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class AddWalkInScreen extends StatefulWidget {
  const AddWalkInScreen({super.key});

  @override
  State<AddWalkInScreen> createState() => _AddWalkInScreenState();
}

class _AddWalkInScreenState extends State<AddWalkInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedService = 'Haircut';
  String _selectedStylist = 'Rahul';
  int _duration = 45;

  final List<String> _services = ['Haircut', 'Haircut + Beard', 'Premium Haircut', 'Hair Color', 'Facial', 'Beard Trim'];
  final List<String> _stylists = ['Rahul', 'Priya', 'Amit', 'Neha'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

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
          'Add Walk-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Details
                      _buildSectionTitle('Customer Details'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Customer Name',
                        hint: 'Enter full name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+91 XXXXX XXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 24),

                      // Service Selection
                      _buildSectionTitle('Service'),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Select Service',
                        value: _selectedService,
                        items: _services,
                        onChanged: (val) => setState(() => _selectedService = val!),
                      ),

                      const SizedBox(height: 24),

                      // Stylist Selection
                      _buildSectionTitle('Assign Stylist'),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: 'Available Stylist',
                        value: _selectedStylist,
                        items: _stylists,
                        onChanged: (val) => setState(() => _selectedStylist = val!),
                      ),

                      const SizedBox(height: 24),

                      // Duration
                      _buildSectionTitle('Estimated Duration'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDurationButton(30, '30 min'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDurationButton(45, '45 min'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDurationButton(60, '60 min'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Queue Preview
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ZalonoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ZalonoTheme.primaryBurgundy.withValues()),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ZalonoTheme.primaryBurgundy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.people_outline, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Queue Position',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    '#${zalono.salons.first.queueCount + 1}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: ZalonoTheme.primaryBurgundy,
                                    ),
                                  ),
                                  Text(
                                    'Estimated wait: ~${(zalono.salons.first.queueCount + 1) * 15} minutes',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitWalkIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZalonoTheme.primaryBurgundy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add to Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ZalonoTheme.textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ZalonoTheme.textDark)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ZalonoTheme.primaryBurgundy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ZalonoTheme.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationButton(int minutes, String label) {
    final isSelected = _duration == minutes;
    return GestureDetector(
      onTap: () => setState(() => _duration = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _submitWalkIn() {
    final zalono = Provider.of<ZalonoProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      zalono.addWalkIn(
        customerName: _nameController.text,
        serviceName: _selectedService,
        stylistName: _selectedStylist,
        durationMin: _duration,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} added to queue at position ${zalono.salons.first.queueCount}'),
          backgroundColor: ZalonoTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }
}