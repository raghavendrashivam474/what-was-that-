# What Was That? 🔍

> *"See something unfamiliar? Point the camera and find out."*

**What Was That?** is a lightweight mobile application that answers one simple real-world question: **What was that?**

Point your camera at an unfamiliar object, plant, animal, connector, sign, or device — and receive a concise, structured identification in seconds.

---

## ✨ Current Release — v0.2.0 (Sprint 2: Discoveries & Local Memory)

The S3-A release turns your accumulated offline history into a highly navigable, structured database. It adds fast, real-time lexical search, chronological grouping, and polished discovery cards.

```text
Capture Image → Identify via AI → Structured Result → Save Discovery → My Discoveries → Detail / Delete

```

### What Works Today

* 📷 **Camera Capture** — Live viewfinder, single-tap capture, retake support
* 🤖 **AI Visual Identification** — Powered by OpenAI Vision (GPT-4o-mini)
* 📋 **Structured Results** — Object name, concise explanation, confidence level
* 💾 **Local-First SQLite Storage** — Powered by Drift & SQLite with zero account requirement or cloud dependency
* 📁 **Persistent Image Lifecycle** — Temporary camera images are copied to application-controlled document storage on save
* 🗂️ **My Discoveries (History)** — Review past discoveries ordered newest first, with an interactive empty state
* 🔍 **Discovery Detail & Deletion** — Revisit saved discoveries across app restarts or delete them permanently
* 🛡️ **App Restart Survival** — Database and local files survive full process restarts
* 🚫 **Honest Uncertainty** — The AI will say "I don't know" rather than fabricate answers
* 🔄 **Error Recovery** — Graceful handling of network failures, database errors, and permission denials
* 🎨 **Custom Branding** — Launcher icons across all Android densities

### What's NOT in S2 (Planned for S3+)

* Cloud sync / multi-device
* Search / categories / filtering
* Social sharing / public profiles
* Maps / GPS tagging
* Audio identification

---

## Quick Start

### Prerequisites

* Flutter SDK (3.x+ stable)
* Dart SDK (3.5+)
* Android SDK (API 21+)
* Android Physical Device or Emulator (Camera support required)
* Vision AI API provider key (OpenAI GPT-4o-mini)

### Installation & Configuration

#### 1. Clone the repository:

```bash
git clone [https://github.com/raghavendrashivam474/what-was-that-.git](https://github.com/raghavendrashivam474/what-was-that-.git)
cd what-was-that-

```

#### 2. Create and configure your local environment file:

```bash
cp .env.example app/.env

```

#### 3. Open `app/.env` and add your OpenAI API key:

```env
AI_API_KEY=your_openai_api_key_here
AI_BASE_URL=[https://api.openai.com/v1](https://api.openai.com/v1)
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
├── app/                                # Flutter mobile application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/                # Environment and runtime configurations
│   │   │   └── errors/                # Typed failure and error classes
│   │   ├── features/
│   │   │   ├── identification/        # S1 core capture & AI identification pipeline
│   │   │   │   ├── data/              # OpenAI Vision implementation
│   │   │   │   ├── domain/            # Entities and contracts (ImageIdentifier)
│   │   │   │   └── presentation/      # UI Screens (Home, Camera, Result)
│   │   │   └── discovery/             # S2 persistent local history feature
│   │   │       ├── data/              # Drift database, ImageStorageService, repository
│   │   │       ├── domain/            # Discovery model & repository contract
│   │   │       └── presentation/      # DiscoveryListScreen, DiscoveryDetailScreen
│   │   └── main.dart                  # Application entry point & dependency wiring
│   ├── test/                          # Unit and widget test suite
│   └── assets/                        # App launcher icons and visual assets
├── docs/
│   ├── architecture.md                # Detailed architecture document
│   ├── decisions/                     # Architecture Decision Records (ADRs)
│   └── sprints/                       # Post-sprint completion reports
├── .env.example                       # Environment secrets template
├── .gitignore
└── README.md

```

### Core Architecture Highlights

* **Layered Feature Design**: UI widgets never call HTTP clients directly. Flow follows `Presentation -> Domain -> Data`.
* **AI Provider Abstraction**: Presentation consumes the domain contract `ImageIdentifier`, isolating the AI provider (`VisionImageIdentifier`).
* **Normalized Domain Results**: AI responses are parsed into an application-level `IdentificationResult` entity consumed by both the result screen and the discovery persistence layer.
* **SQLite Database via Drift**: Strongly-typed local database schema with safe upgrades and zero manual SQL query strings.
* **Durable Image Copying**: Captured images are copied from temporary cache to application persistent storage on user demand, preventing OS-level garbage collection.

For in-depth details, see [docs/architecture.md](https://www.google.com/search?q=docs/architecture.md), [ADR-0001](https://www.google.com/search?q=docs/decisions/ADR-0001-initial-architecture.md), and [ADR-0002](https://www.google.com/search?q=docs/decisions/ADR-0002-local-discovery-persistence.md).

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
* Discovery entity wrapping IdentificationResult models
* UUID generation, timestamps, and equality checks


* **`discovery_repository_test.dart`**:
* Save, retrieve by ID, and newest-first ordering
* Image file cleanup on discovery deletion


* **`database_restart_persistence_test.dart`**:
* Full app process exit and SQLite database survival simulation


* **`discovery_widgets_test.dart`**:
* HomeScreen "My Discoveries" button rendering
* Empty state vs. populated discovery list
* Delete confirmation dialog and ResultScreen save flow


* **`identification_model_test.dart`**:
* Confidence string-to-enum parsing (case-insensitivity, null-safety, fallbacks)
* Valid structured JSON deserialization to IdentificationResultModel
* Handling of unidentifiable/uncertain results (identifiable: false)
* Stripping markdown code fences (````json ... ````) from model responses
* Safe fallbacks for missing/malformed JSON fields


* **`widget_test.dart`**:
* HomeScreen rendering, title, subtitle, and camera trigger
* ResultScreen layout with positive identification, explanation, and confidence badge
* ResultScreen unidentifiable failure/retry guidance rendering



---

## Build Android APK

To build a standalone debug APK for device installation:

```bash
cd app
flutter build apk --debug

```

### Output artifact location:

* `app/build/app/outputs/flutter-apk/app-debug.apk`

---

## Security & Secrets Management

* API keys and provider URLs are stored locally in `app/.env` and loaded via `flutter_dotenv`.
* Local `.env` files are ignored by `.gitignore` across the entire repository.
* Never commit active API keys to version control. Use `.env.example` as a template for new environments.

---

## Roadmap

| Sprint | Focus | Status |
| --- | --- | --- |
| **S1 — Capture** | Complete camera capture, AI identification, structured answer, error recovery loop | Complete (v0.1.0) |
| **S2 — Memory** | Local SQLite persistence, isolated image storage, detail views, and deletions | **Complete (v0.2.0)** |
| **S3 — Spatial** | GPS/Map tags, location-based categorization, spatial discovery recall | *Backlog* |
| **S4 — Offline** | On-device lightweight models, audio integration, OCR indexing | *Backlog* |

---

## License

Private project. All rights reserved.
