import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/restaurant_seeder_service.dart';

class AdminSeedScreen extends ConsumerStatefulWidget {
  const AdminSeedScreen({super.key});

  @override
  ConsumerState<AdminSeedScreen> createState() => _AdminSeedScreenState();
}

class _AdminSeedScreenState extends ConsumerState<AdminSeedScreen> {
  bool _isSeeding = false;
  final List<String> _logs = [];
  SeederResult? _result;

  Future<void> _startSeeding() async {
    setState(() {
      _isSeeding = true;
      _logs.clear();
      _result = null;
    });

    final seeder = ref.read(restaurantSeederServiceProvider);

    try {
      // Only seed, don't delete (user will delete manually from Firebase Console)
      final result = await seeder.seedFromPlacesAPI(
        onProgress: (status) {
          if (mounted) {
            setState(() {
              _logs.add(status);
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isSeeding = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logs.add('Error: $e');
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Restaurants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: AppColors.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This will add Nigerian/African restaurants from Google Places API. Delete existing restaurants from Firebase Console first if needed.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cities info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cities to search:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: RestaurantSeederService.ukCities
                          .map((city) => Chip(
                                label: Text(city, style: const TextStyle(fontSize: 12)),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Start button
            ElevatedButton.icon(
              onPressed: _isSeeding ? null : _startSeeding,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isSeeding ? 'Seeding in progress...' : 'Start Seeding'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Result card
            if (_result != null)
              Card(
                color: AppColors.success.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'Complete!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Added: ${_result!.added} restaurants'),
                      Text('Skipped: ${_result!.skipped} duplicates'),
                      Text('Failed: ${_result!.failed}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Logs
            const Text(
              'Progress Log:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  reverse: true,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[_logs.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: log.startsWith('Error')
                              ? Colors.red[300]
                              : log.startsWith('Added')
                                  ? Colors.green[300]
                                  : Colors.white70,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
