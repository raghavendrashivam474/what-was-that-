# What Was That? ðŸ”

> *"See something unfamiliar? Point the camera and find out."*

**What Was That?** is a lightweight mobile application that answers one simple real-world question: **What was that?**

Point your camera at an unfamiliar object, plant, animal, connector, sign, or device â€” and receive a concise, structured identification in seconds.

---

## âœ¨ Current Release â€” v0.2.0 (Sprint 2: Discoveries & Local Memory)

The S3-A release turns your accumulated offline history into a highly navigable, structured database. It adds fast, real-time lexical search, chronological grouping, and polished discovery cards.

```text
Capture Image â†’ Identify via AI â†’ Structured Result â†’ Save Discovery â†’ My Discoveries â†’ Detail / Delete
```

### What Works Today
- ðŸ“· **Camera Capture** â€” Live viewfinder, single-tap capture, retake support
- ðŸ¤– **AI Visual Identification** â€” Powered by OpenAI Vision (GPT-4o-mini)
- ðŸ“‹ **Structured Results** â€” Object name, concise explanation, confidence level
- ðŸ’¾ **Local-First SQLite Storage** â€” Powered by Drift & SQLite with zero account requirement or cloud dependency
- ðŸ“‚ **Persistent Image Lifecycle** â€” Temporary camera images are copied to application-controlled document storage on save
- ðŸ—‚ï¸ï¸ **My Discoveries (History)** â€” Review past discoveries ordered newest first, with an interactive empty state
- ðŸ” **Discovery Detail & Deletion** â€” Revisit saved discoveries across app restarts or delete them permanently
- ðŸ›¡ï¸ï¸ **App Restart Survival** â€” Database and local files survive full process restarts
- ðŸš« **Honest Uncertainty** â€” The AI will say "I don't know" rather than fabricate answers
- ðŸ”„ **Error Recovery** â€” Graceful handling of network failures, database errors, and permission denials
- ðŸŽ¨ **Custom Branding** â€” Launcher icons across all Android densities

### What's NOT in S2 (Planned for S3+)
- Cloud sync / multi-device
- Search / categories / filtering
- Social sharing / public profiles
- Maps / GPS tagging
- Audio identification

---

## Quick Start

### Prerequisites
- Flutter SDK (3.x+ stable)
- Dart SDK (3.5+)
- Android SDK (API 21+)
- Android Physical Device or Emulator (Camera support required)
- Vision AI API provider key (OpenAI GPT-4o-mini)

### Installation & Configuration

#### 1. Clone the repository:
```bash
git clone https://github.com/raghavendrashivam474/what-was-that-.git
cd what-was-that-
```

#### 2. Create and configure your local environment file:
```bash
cp .env.example app/.env
```

#### 3. Open `app/.env` and add your OpenAI API key:
```env
AI_API_KEY=your_openai_api_key_here
AI_BASE_URL=https://api.openai.com/v1
AI_MODEL=gpt-4o-mini
```

#### 4. Install dependencies and generate database code:
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### 5. Run the application:
```bash
flutter run
```

---

## Project Architecture

```text
what-was-that/
â”œâ”€â”€ app/                              # Flutter mobile application
â”‚   â”œâ”€â”€ lib/
â”‚   â”‚   â”œâ”€â”€ core/
â”‚   â”‚   â”‚   â”œâ”€â”€ config/              # Environment and runtime configurations
â”‚   â”‚   â”‚   â””â”€â”€ errors/              # Typed failure and error classes
â”‚   â”‚   â”œâ”€â”€ features/
â”‚   â”‚   â”‚   â”œâ”€â”€ identification/      # S1 core capture & AI identification pipeline
â”‚   â”‚   â”‚   â”‚   â”œâ”€â”€ data/            # OpenAI Vision implementation
â”‚   â”‚   â”‚   â”‚   â”œâ”€â”€ domain/          # Entities and contracts (ImageIdentifier)
â”‚   â”‚   â”‚   â”‚   â””â”€â”€ presentation/    # UI Screens (Home, Camera, Result)
â”‚   â”‚   â”‚   â””â”€â”€ discovery/           # S2 persistent local history feature
â”‚   â”‚   â”‚       â”œâ”€â”€ data/            # Drift database, ImageStorageService, repository
â”‚   â”‚   â”‚       â”œâ”€â”€ domain/          # Discovery model & repository contract
â”‚   â”‚   â”‚       â””â”€â”€ presentation/    # DiscoveryListScreen, DiscoveryDetailScreen
â”‚   â”‚   â””â”€â”€ main.dart                # Application entry point & dependency wiring
â”‚   â”œâ”€â”€ test/                        # Unit and widget test suite
â”‚   â””â”€â”€ assets/                      # App launcher icons and visual assets
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ architecture.md              # Detailed architecture document
â”‚   â”œâ”€â”€ decisions/                   # Architecture Decision Records (ADRs)
â”‚   â””â”€â”€ sprints/                     # Post-sprint completion reports
â”œâ”€â”€ .env.example                     # Environment secrets template
â”œâ”€â”€ .gitignore
â””â”€â”€ README.md
```

### Core Architecture Highlights
- **Layered Feature Design**: UI widgets never call HTTP clients directly. Flow follows `Presentation -> Domain -> Data`.
- **AI Provider Abstraction**: Presentation consumes the domain contract `ImageIdentifier`, isolating the AI provider (`VisionImageIdentifier`).
- **Normalized Domain Results**: AI responses are parsed into an application-level `IdentificationResult` entity consumed by both the result screen and the discovery persistence layer.
- **SQLite Database via Drift**: Strongly-typed local database schema with safe upgrades and zero manual SQL query strings.
- **Durable Image Copying**: Captured images are copied from temporary cache to application persistent storage on user demand, preventing OS-level garbage collection.

For in-depth details, see [docs/architecture.md](docs/architecture.md), [ADR-0001](docs/decisions/ADR-0001-initial-architecture.md), and [ADR-0002](docs/decisions/ADR-0002-local-discovery-persistence.md).

---

## Testing & Quality Assurance

The codebase includes both unit and widget tests covering response parsing, local persistence, restart survival, and UI states.

### Run Automated Tests
```bash
cd app
flutter test
```

### Run Static Analysis
```bash
cd app
flutter analyze
```

### Test Suite Overview

* **`discovery_domain_test.dart`**:
  - Discovery entity wrapping IdentificationResult models
  - UUID generation, timestamps, and equality checks

* **`discovery_repository_test.dart`**:
  - Save, retrieve by ID, and newest-first ordering
  - Image file cleanup on discovery deletion

* **`database_restart_persistence_test.dart`**:
  - Full app process exit and SQLite database survival simulation

* **`discovery_widgets_test.dart`**:
  - HomeScreen "My Discoveries" button rendering
  - Empty state vs. populated discovery list
  - Delete confirmation dialog and ResultScreen save flow

* **`identification_model_test.dart`**:
  - Confidence string-to-enum parsing (case-insensitivity, null-safety, fallbacks)
  - Valid structured JSON deserialization to IdentificationResultModel
  - Handling of unidentifiable/uncertain results (identifiable: false)
  - Stripping markdown code fences (` ```json ... ``` `) from model responses
  - Safe fallbacks for missing/malformed JSON fields

* **`widget_test.dart`**:
  - HomeScreen rendering, title, subtitle, and camera trigger
  - ResultScreen layout with positive identification, explanation, and confidence badge
  - ResultScreen unidentifiable failure/retry guidance rendering

---

## Build Android APK

To build a standalone debug APK for device installation:
```bash
cd app
flutter build apk --debug
```

### Output artifact location:
- `app/build/app/outputs/flutter-apk/app-debug.apk`

---

## Security & Secrets Management

- API keys and provider URLs are stored locally in `app/.env` and loaded via `flutter_dotenv`.
- Local `.env` files are ignored by `.gitignore` across the entire repository.
- Never commit active API keys to version control. Use `.env.example` as a template for new environments.

---

## Roadmap

| Sprint | Focus | Status |
| :--- | :--- | :--- |
| **S1 â€” Capture** | Complete camera capture, AI identification, structured answer, error recovery loop | Complete (v0.1.0) |
| **S2 â€” Memory** | Local SQLite persistence, isolated image storage, detail views, and deletions | **Complete (v0.2.0)** |
| **S3 â€” Spatial** | GPS/Map tags, location-based categorization, spatial discovery recall | *Backlog* |
| **S4 â€” Offline** | On-device lightweight models, audio integration, OCR indexing | *Backlog* |

---

## License

Private project. All rights reserved.

