class DiscoveryLocation {
  final double latitude;
  final double longitude;

  const DiscoveryLocation({
    required this.latitude,
    required this.longitude,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveryLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'DiscoveryLocation(lat: $latitude, lon: $longitude)';
}
