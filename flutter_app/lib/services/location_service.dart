// lib/services/location_service.dart
// Thin wrapper around geolocator: handles permission requests and
// fetching the current GPS position.

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the current position, or null if permission was denied
  /// or location services are off. Callers should show a friendly
  /// message when null is returned.
  Future<Position?> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
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
