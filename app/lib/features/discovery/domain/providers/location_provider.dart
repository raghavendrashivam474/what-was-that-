import '../entities/discovery_location.dart';

abstract class LocationProvider {
  /// Attempts to capture the current geographic coordinates.
  /// Returns null if permissions are denied, services are disabled, or acquisition fails/times out.
  Future<DiscoveryLocation?> getCurrentLocation();
}
