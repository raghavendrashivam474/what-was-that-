import '../entities/discovery.dart';

abstract class DiscoverySharer {
  /// Shares a individual Discovery's details (and image, if available).
  Future<void> share(Discovery discovery);
}
