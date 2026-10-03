import '../entities/discovery.dart';

class DiscoveryShareFormatter {
  /// Formats a Discovery object into a clean, human-readable text string.
  static String format(Discovery discovery) {
    final buffer = StringBuffer();
    buffer.writeln('What Was That?\n');
    buffer.writeln(discovery.title);
    
    if (discovery.identifiable) {
      buffer.writeln('${discovery.confidence.displayName} confidence');
    }
    buffer.writeln();
    buffer.writeln(discovery.explanation);
    buffer.writeln();
    
    buffer.writeln('Discovered: ${_formatDateTime(discovery.createdAt)}');
    
    if (discovery.location != null) {
      buffer.writeln();
      buffer.writeln('Location:');
      buffer.writeln('${discovery.location!.latitude.toStringAsFixed(6)}, ${discovery.location!.longitude.toStringAsFixed(6)}');
    }
    
    return buffer.toString().trim();
  }

  static String _formatDateTime(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year at $hour:$minute $period';
  }
}
