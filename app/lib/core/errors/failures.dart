abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Unable to access the camera.']);
}

class CameraPermissionDeniedFailure extends Failure {
  const CameraPermissionDeniedFailure([
    super.message = 'Camera access is required to identify something.',
  ]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = "Couldn't reach the identification service. Check your connection and try again.",
  ]);
}

class ProviderFailure extends Failure {
  const ProviderFailure([
    super.message = 'Something went wrong while identifying this. Please try again.',
  ]);
}

class InvalidImageFailure extends Failure {
  const InvalidImageFailure([
    super.message = 'The captured image could not be processed.',
  ]);
}
