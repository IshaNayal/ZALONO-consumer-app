import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

/// Saved addresses. Setting one as the active location also moves Home and the
/// salon list to it, so the choice is visible everywhere at once.
class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final locations = zalono.savedLocations;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Saved Locations',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLocationSheet(context),
        backgroundColor: ZalonoTheme.primaryBurgundy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: SafeArea(
        child: locations.isEmpty
            ? const _EmptyLocations()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return _LocationCard(
                    location: location,
                    onUse: () => zalono.useSavedLocation(location.id),
                    onDelete: locations.length <= 1
                        ? null
                        : () => zalono.removeSavedLocation(location.id),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showAddLocationSheet(BuildContext context) async {
    final zalono = context.read<ZalonoProvider>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (_) => _AddLocationSheet(
        onSave: zalono.addSavedLocation,
      ),
    );
  }
}

/// Owns its own text controllers.
///
/// They must not be disposed by the caller: the sheet is still animating out
/// when [showModalBottomSheet] completes, and disposing them at that point
/// makes the still-mounted TextFields throw.
class _AddLocationSheet extends StatefulWidget {
  const _AddLocationSheet({required this.onSave});

  final void Function({required String label, required String address}) onSave;

  @override
  State<_AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<_AddLocationSheet> {
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      setState(() => _errorText = 'Please enter an address.');
      return;
    }
    widget.onSave(
      label: _labelController.text,
      address: address,
    );
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
              'Add an address',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Full address',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
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
                  'Save address',
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.onUse,
    this.onDelete,
  });

  final SavedLocation location;
  final VoidCallback onUse;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: location.isDefault
              ? ZalonoTheme.primaryBurgundy
              : ZalonoTheme.borderLight,
          width: location.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                location.label.toLowerCase() == 'work'
                    ? Icons.work_rounded
                    : Icons.home_rounded,
                size: 18,
                color: ZalonoTheme.primaryBurgundy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ZalonoTheme.textDark,
                  ),
                ),
              ),
              if (location.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ZalonoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.primaryBurgundy,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            location.address,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: ZalonoTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!location.isDefault)
                TextButton(
                  onPressed: onUse,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Use this location',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ZalonoTheme.primaryBurgundy,
                    ),
                  ),
                ),
              if (onDelete != null)
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyLocations extends StatelessWidget {
  const _EmptyLocations();

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
                Icons.location_on_outlined,
                size: 26,
                color: ZalonoTheme.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add an address to book salons around it faster.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ZalonoTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
