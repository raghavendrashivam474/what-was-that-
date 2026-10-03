# Architecture Documentation: What Was That?

## Overview
"What Was That?" is an Android-first mobile application built with Flutter, designed to help users identify unfamiliar real-world objects using on-device capture and cloud vision AI, and save them as persistent local discoveries.

---

## Architectural Principles
1. **Separation of Concerns**: High cohesion and low coupling across features.
2. **Local-First Persistence**: Discoveries and associated image files persist entirely on the device without requiring accounts, remote databases, or cloud synchronization.
3. **Protected Core Identification Pipeline**: The identification provider (`ImageIdentifier`) produces structured `IdentificationResult` models without knowing anything about SQLite or UI state.
4. **Decoupled Image Lifecycle**: Ephemeral camera captures are converted into persistent assets in application-controlled storage only when the user explicitly saves a discovery.

---

## Layered Structure

```text
lib/
├── core/
│ ├── config/ # Environment & application configuration
│ └── errors/ # Domain failure definitions
├── features/
│ ├── identification/ # S1 Core Identification
│ │ ├── data/ # OpenAI Vision implementation
│ │ ├── domain/ # IdentificationResult & ImageIdentifier contract
│ │ └── presentation/ # CameraScreen, ResultScreen, HomeScreen
│ └── discovery/ # S2 Persistence & History
│ ├── data/ # Drift SQLite database, ImageStorageService, DriftDiscoveryRepository
│ ├── domain/ # Discovery entity & DiscoveryRepository contract
│ └── presentation/ # DiscoveryListScreen, DiscoveryDetailScreen
└── main.dart # Composition root & dependency wiring
```

---

## S2 Data & Component Flow

```text
                 ┌───────────────────┐
                 │    Camera Flow    │
                 └─────────┬─────────┘
                           │
                           ▼
                 ┌───────────────────┐
                 │  ImageIdentifier  │
                 └─────────┬─────────┘
                           │
                           ▼
                 IdentificationResult
                           │
                           ▼
                 ┌───────────────────┐
                 │   Result Screen   │
                 └─────────┬─────────┘
                           │
                    [Save Discovery]
                           │
                           ▼
                 ┌───────────────────┐
                 │ Discovery Domain  │
                 └─────────┬─────────┘
                           │
                           ▼
                  DiscoveryRepository
                           │
         ┌─────────────────┴─────────────────┐
         ▼                                   ▼
┌───────────────────┐               ┌───────────────────┐
│   Drift / SQLite  │               │ ImageStorageService│
│ (discoveries table)│              │(App Doc Directory)│
└───────────────────┘               └───────────────────┘
```
---

## Storage & Persistence Strategy

### 1. SQLite Database Schema (Drift)

- Table: `discoveries`
  - `id` (TEXT, PK): Unique UUID v4 string.
  - `title` (TEXT): Identified object title.
  - `explanation` (TEXT): Identified object description.
  - `confidence` (TEXT): High, Medium, Low, Unknown.
  - `identifiable` (BOOLEAN): Flag indicating if identification was confident.
  - `image_path` (TEXT): Path to the locally stored persistent image.
  - `created_at` (INTEGER/DATETIME): Timestamp for ordering (newest first).

### 2. Image Lifecycle & Rollback
- Camera captures write to a temporary file.
- On saving, `ImageStorageService` copies the temp image to the persistent application document directory (`discoveries/` subfolder).
- If the database transaction fails after copying, the newly copied image is immediately cleaned up.
- On deleting a discovery, both the SQLite record and the associated persistent image file are removed.
