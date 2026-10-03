# Architecture — What Was That? (Sprint 1)

## Purpose
What Was That? is a mobile application for real-world visual identification.
Given a photo captured by the user, it answers: "What was that?"

## S1 Scope
- **In Scope**: Camera capture, preview, AI-based visual identification, structured result display, and error recovery.
- **Out of Scope**: Auth, database, history/archive, maps, audio, push notifications.

## High-Level Layers

```text
Presentation (Screens, State, Widgets)
↓
Domain (Entities: IdentificationResult, Contract: ImageIdentifier)
↓
Data (OpenAI Vision Client, Response Parsing, DTOs)
```

## AI Provider Boundary
The UI interacts exclusively with the abstract contract ImageIdentifier:
```dart
abstract class ImageIdentifier {
  Future<IdentificationResult> identify(String imagePath);
}
```

The implementation (VisionImageIdentifier) sits in the data layer. This decouples the UI from any specific AI vendor (OpenAI, Gemini, local model).

## Error Strategy

- Camera permission denial -> Actionable permission guidance
- Network failure -> Offline notice + Retry
- Provider failure -> Generic user-friendly message + Try Again
- Unidentifiable object -> Advice on framing/lighting + Retake
