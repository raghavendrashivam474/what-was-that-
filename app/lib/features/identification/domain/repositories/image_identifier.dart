import '../entities/identification_result.dart';

abstract class ImageIdentifier {
  Future<IdentificationResult> identify(String imagePath);
}
