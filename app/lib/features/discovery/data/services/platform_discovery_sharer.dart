import 'dart:io';
// ignore: deprecated_member_use
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/discovery.dart';
import '../../domain/services/discovery_share_formatter.dart';
import '../../domain/services/discovery_sharer.dart';

class PlatformDiscoverySharer implements DiscoverySharer {
  const PlatformDiscoverySharer();

  @override
  Future<void> share(Discovery discovery) async {
    final text = DiscoveryShareFormatter.format(discovery);
    final file = File(discovery.imagePath);

    if (await file.exists()) {
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(discovery.imagePath)],
        text: text,
        subject: 'My Discovery: ${discovery.title}',
      );
    } else {
      // ignore: deprecated_member_use
      await Share.share(
        text,
        subject: 'My Discovery: ${discovery.title}',
      );
    }
  }
}
