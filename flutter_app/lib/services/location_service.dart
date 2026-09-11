// lib/services/location_service.dart
// Thin wrapper around geolocator: handles permission requests and
// fetching the current GPS position.

import 'package:geolocator/geolocator.dart';

class LocationResult {
  final Position? position;
  final String? error;
  const LocationResult({this.position, this.error});
}

class LocationService {
  /// Returns a [LocationResult] with either a position or a human-readable
  /// error message. Never throws — callers just check result.error.
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
          error: 'Location services are turned off. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(error: 'Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Open app settings so the user can grant permission manually
      await Geolocator.openAppSettings();
      return const LocationResult(
          error:
              'Location permission permanently denied. Please allow it in Settings.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Location timed out'),
      );
      return LocationResult(position: position);
    } catch (e) {
      return LocationResult(error: 'Could not get location: ${e.toString()}');
    }
  }

  /// Streams live location updates — used by workers to keep their
  /// location fresh while they have an active job.
  Stream<Position> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25, // meters — only update after moving 25m
      ),
    );
  }
}
