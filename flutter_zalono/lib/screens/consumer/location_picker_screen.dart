import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';

class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    final locations = <Map<String, String>>[
      {'name': 'Saheed Nagar', 'sub': 'Janpath, Unit-9 Area', 'distance': '0.8 km', 'salons': '8'},
      {'name': 'Patia', 'sub': 'KIIT, Infocity Road', 'distance': '3.2 km', 'salons': '6'},
      {'name': 'Jaydev Vihar', 'sub': 'Near Hotel Hindustan', 'distance': '2.1 km', 'salons': '5'},
      {'name': 'Nayapalli', 'sub': 'CRPF Road, IRC Village', 'distance': '1.5 km', 'salons': '7'},
      {'name': 'Chandrasekharpur', 'sub': 'NH-16, Sailashree Vihar', 'distance': '4.0 km', 'salons': '4'},
      {'name': 'Khandagiri', 'sub': 'Near Baramunda Bus Stand', 'distance': '5.5 km', 'salons': '3'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Area',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final loc = locations[index];
            final isSelected = zalono.currentLocation == loc['name'];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    zalono.setLocation(loc['name']!);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? ZalonoTheme.primaryLight : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc['sub']!,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.storefront_rounded, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${loc['salons']} live salons',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: ZalonoTheme.primaryBurgundy, size: 24)
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                loc['distance']!,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                              ),
                              Text(
                                'away',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}