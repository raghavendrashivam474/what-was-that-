# What Was That?

> *"See something unfamiliar? Point the camera and find out."*

**What Was That?** is a lightweight mobile application that answers one simple real-world question: **What was that?**

Point your camera at an unfamiliar object, plant, animal, connector, sign, or device — and receive a concise, structured identification in seconds.

---
## ✨ Current Release — v0.1.0 (Sprint 1: Capture)

The S1 vertical slice delivers the complete end-to-end identification loop:

```text
Open App → Capture Image → Preview → Identify via AI → Structured Result → Try Again
```

### What Works Today
- 📷 **Camera Capture** — Live viewfinder, single-tap capture, retake support
- 🤖 **AI Visual Identification** — Powered by OpenAI Vision (GPT-4o-mini)
- 📋 **Structured Results** — Object name, concise explanation, confidence level
- 🚫 **Honest Uncertainty** — The AI will say "I don't know" rather than fabricate answers
- 🔄 **Error Recovery** — Graceful handling of network failures, permission denials, and unidentifiable images
- 🎨 **Custom Branding** — Launcher icons across all Android densities

### What's NOT in S1 (Planned for S2+)
- User accounts / authentication
- Discovery history / saved identifications
- Local database persistence
- Maps / GPS tagging
- Audio identification
- Social sharing

---
## Quick Start

### Prerequisites
- Flutter SDK (3.x+ stable)
- Dart SDK (3.5+)
- Android SDK (API 21+)
- Android Physical Device or Emulator (Camera support required)
- Vision AI API provider key (e.g. OpenAI GPT-4o-mini)

### Installation & Configuration

#### 1. Clone the repository:
   ```bash
   git clone https://github.com/raghavendrashivam474/what-was-that-.git
   cd what-was-that-
   ```

#### 2. Create and configure your local environment file:

```Bash
cp .env.example app/.env
```

#### 3. Open app/.env and add your OpenAI API key and configure parameters:

```env
AI_API_KEY=your_openai_api_key_here
AI_BASE_URL=https://api.openai.com/v1
AI_MODEL=gpt-4o-mini
```

#### 4. Install Flutter packages:

```Bash
cd app
flutter pub get
```

#### 5. Run the application:

```Bash
flutter run
```

## Project Architecture

```text
what-was-that/
├── app/ # Flutter mobile application
│ ├── lib/
│ │ ├── core/
│ │ │ ├── config/ # Environment and runtime configurations
│ │ │ └── errors/ # Typed failure and error classes
│ │ ├── features/
│ │ │ └── identification/
│ │ │ ├── data/ # AI API data source, models & JSON parsing
│ │ │ ├── domain/ # Entities and contracts (ImageIdentifier)
│ │ │ └── presentation/ # UI Screens (Home, Camera, Result)
│ │ └── main.dart # Application entry point
│ ├── test/ # Unit and widget test suite
│ └── assets/ # App launcher icons and visual assets
├── docs/
│ ├── architecture.md # Detailed architecture document
│ ├── decisions/ # Architecture Decision Records (ADRs)
│ └── sprints/ # Post-sprint completion reports
├── .env.example # Environment secrets template
├── .gitignore
└── README.md
```

### Core Architecture Highlights
- **Layered Feature Design**: UI widgets never call HTTP clients directly. Flow follows `Presentation -> Domain -> Data`.
- **AI Provider Abstraction**: Presentation consumes the domain contract `ImageIdentifier`, isolating the AI provider (`VisionImageIdentifier`).
- **Normalized Domain Results**: AI responses are parsed into an application-level `IdentificationResult` entity, enabling seamless extension for S2 local persistence.

For in-depth details, see [docs/architecture.md](docs/architecture.md) and [ADR-0001](docs/decisions/ADR-0001-initial-architecture.md).

---
## Testing & Quality Assurance

The codebase includes both unit and widget tests covering response parsing, edge cases, and UI states.

### Run Automated Tests
```bash
cd app
flutter test
```

### Run Static Analysis

```Bash
cd app
flutter analyze
```

### Test Suite Overview

* **`identification_model_test.dart`**:
    - Confidence string-to-enum parsing (case-insensitivity, null-safety, fallbacks)
    - Valid structured JSON deserialization to IdentificationResultModel
    - Handling of unidentifiable/uncertain results (identifiable: false)
    - Stripping markdown code fences (```json ... ```) from model responses
    - Safe fallbacks for missing/malformed JSON fields

* **`widget_test.dart`**:

    - HomeScreen rendering, title, subtitle, and camera trigger
    - ResultScreen layout with positive identification, explanation, and confidence badge
    - ResultScreen unidentifiable failure/retry guidance rendering
## Build Android APK

To build a standalone debug APK for device installation:

```bash
cd app
flutter build apk --debug
```

### Output artifact location:

- `app/build/app/outputs/flutter-apk/app-debug.apk`

## Security & Secrets Management

- API keys and provider URLs are stored locally in app/.env and loaded via flutter_dotenv.
- Local .env files are ignored by .gitignore across the entire repository.
- Never commit active API keys to version control. Use .env.example as a 
  template for new environments.

## Roadmap

| Sprint | Focus | Status |
| :--- | :--- | :--- |
| **S1 — Capture** | Complete camera capture, AI identification, structured answer, error recovery loop | Complete (v0.1.0) |
| **S2 — Archive** | Local persistence (SQLite/Drift), discovery history, saved images & timestamps | Next Up |
| **S3 — Context** | GPS & location tagging, map view, spatial discovery recall | Backlog |
| **S4 — Expand** | Multi-modal expansion (Audio identification, OCR, on-device models) | Backlog |

## License

Private project. All rights reserved.