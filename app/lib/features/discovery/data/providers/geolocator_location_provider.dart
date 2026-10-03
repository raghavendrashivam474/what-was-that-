import 'package:geolocator/geolocator.dart';
import '../../domain/entities/discovery_location.dart';
import '../../domain/providers/location_provider.dart';

class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  @override
  Future<DiscoveryLocation?> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // 2. Handle permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // 3. Obtain location with a strict timeout to avoid hang-ups
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 5));

      return DiscoveryLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Return null on any error (permission denied, service issues, timeout)
      // to ensure a graceful fallback.
      return null;
    }
  }
}
