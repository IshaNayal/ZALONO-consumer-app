import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

/// Saved payment instruments. The default one is what the booking flow
/// pre-selects at the payment step.
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final methods = zalono.paymentMethods;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMethodSheet(context),
        backgroundColor: ZalonoTheme.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add method'),
      ),
      body: SafeArea(
        child: methods.isEmpty
            ? const _EmptyMethods()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: methods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final method = methods[index];
                  return _MethodCard(
                    method: method,
                    onUseDefault: () => zalono.useDefaultPaymentMethod(method.id),
                    onDelete: () => zalono.removePaymentMethod(method.id),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddMethodSheet(BuildContext context) async {
    final zalono = context.read<ZalonoProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AddMethodSheet(onSave: zalono.addPaymentMethod),
    );
  }
}

/// Owns its own controllers and the UPI/card choice.
///
/// The caller must not dispose the controllers: the sheet is still animating
/// out when [showModalBottomSheet] completes, so disposing them there makes the
/// still-mounted TextFields throw.
class _AddMethodSheet extends StatefulWidget {
  const _AddMethodSheet({required this.onSave});

  final void Function({required String type, required String label}) onSave;

  @override
  State<_AddMethodSheet> createState() => _AddMethodSheetState();
}

class _AddMethodSheetState extends State<_AddMethodSheet> {
  final _labelController = TextEditingController();
  String _type = 'UPI';
  String? _errorText;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _errorText = 'Please enter the details.');
      return;
    }
    widget.onSave(type: _type, label: label);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a payment method',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final option in const ['UPI', 'Card']) ...[
                  ChoiceChip(
                    label: Text(option),
                    selected: _type == option,
                    selectedColor: ZalonoTheme.primaryLight,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _type == option
                          ? ZalonoTheme.primaryBurgundy
                          : ZalonoTheme.textMuted,
                    ),
                    side: BorderSide(
                      color: _type == option
                          ? ZalonoTheme.primaryBurgundy
                          : ZalonoTheme.borderLight,
                    ),
                    onSelected: (_) => setState(() => _type = option),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _labelController,
              keyboardType: _type == 'UPI'
                  ? TextInputType.emailAddress
                  : TextInputType.number,
              decoration: InputDecoration(
                labelText: _type == 'UPI'
                    ? 'UPI ID (e.g. name@bank)'
                    : 'Card number',
                border: const OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Card details are not stored on the device in this pilot build.',
              style: TextStyle(fontSize: 11.5, color: ZalonoTheme.textMuted),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZalonoTheme.primaryBurgundy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save method',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.onUseDefault,
    required this.onDelete,
  });

  final SavedPaymentMethod method;
  final VoidCallback onUseDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: method.isDefault
              ? ZalonoTheme.primaryBurgundy
              : ZalonoTheme.borderLight,
          width: method.isDefault ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZalonoTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              method.type == 'UPI'
                  ? Icons.account_balance_wallet_rounded
                  : Icons.credit_card_rounded,
              size: 20,
              color: ZalonoTheme.primaryBurgundy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        method.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZalonoTheme.textDark,
                        ),
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ZalonoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.primaryBurgundy,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  method.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZalonoTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!method.isDefault)
            TextButton(
              onPressed: onUseDefault,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Set default',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZalonoTheme.primaryBurgundy,
                ),
              ),
            ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                size: 20, color: Colors.red.shade600),
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _EmptyMethods extends StatelessWidget {
  const _EmptyMethods();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                size: 26,
                color: ZalonoTheme.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No payment methods',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add a UPI ID or card to pay in one tap.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ZalonoTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
