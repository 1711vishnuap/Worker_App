// lib/screens/customer/worker_map_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';

class WorkerMapScreen extends StatefulWidget {
  const WorkerMapScreen({super.key});

  @override
  State<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends State<WorkerMapScreen> {
  late int _workId;
  Timer? _pollTimer;
  GoogleMapController? _mapController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkProvider>().loadAssignedWorker(_workId);
    _pollTimer ??= Timer.periodic(const Duration(seconds: 6), (_) {
      context.read<WorkProvider>().loadAssignedWorker(_workId);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkProvider>().currentWork;
    final worker = context.watch<WorkProvider>().assignedWorker;

    if (worker == null || worker.currentLat == null || worker.currentLng == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Worker Location')),
        body: const LoadingIndicator(),
      );
    }

    final workerPos = LatLng(worker.currentLat!, worker.currentLng!);
    final customerPos = work != null ? LatLng(work.customerLat, work.customerLng) : workerPos;

    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: workerPos, zoom: 14),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('worker'),
                  position: workerPos,
                  infoWindow: InfoWindow(title: worker.name),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
                Marker(
                  markerId: const MarkerId('customer'),
                  position: customerPos,
                  infoWindow: const InfoWindow(title: 'Your location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.phone_outlined),
                const SizedBox(width: 10),
                Text(worker.mobileNumber, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
