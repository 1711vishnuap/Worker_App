// lib/screens/worker/navigation_map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_routes.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class NavigationMapScreen extends StatefulWidget {
  const NavigationMapScreen({super.key});

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkerProvider>().loadWorkById(workId);
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkerProvider>().acceptedWork;

    if (work == null) {
      return Scaffold(appBar: AppBar(title: const Text('Navigate')), body: const LoadingIndicator());
    }

    final customerPos = LatLng(work.customerLat, work.customerLng);

    return Scaffold(
      appBar: AppBar(title: const Text('Navigate to Customer')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: customerPos, zoom: 15),
              markers: {
                Marker(markerId: const MarkerId('customer'), position: customerPos, infoWindow: const InfoWindow(title: 'Customer location')),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Open in Google Maps',
                  icon: Icons.navigation_outlined,
                  onPressed: () => _openInGoogleMaps(work.customerLat, work.customerLng),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.password_outlined),
                  label: const Text('I\'ve Arrived — Enter OTP'),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.workerEnterOtp, arguments: work.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
