---

# Sprint 2 Completion Report — Discoveries & Local Memory

**Project:** What Was That?
**Sprint:** S2 — Discoveries & Local Memory
**Baseline:** v0.1.0 (S1 — Capture)
**Delivered:** v0.2.0
**Platform:** Android
**Framework:** Flutter 3.44.2 / Dart 3.12.2
**Branch:** `sprint/s2-discoveries`
**Tag:** `v0.2.0`
**Date:** October 2026

---

## 1. Executive Summary

Sprint 2 successfully evolved "What Was That?" from a single-use ephemeral identification tool into a **durable personal memory explorer**. Users can now save AI identification results as persistent local "Discoveries," revisit them across application restarts, view their history in a dedicated list screen, inspect details, and delete records with full image cleanup.

All S1 functionality remains fully intact with zero regressions. The full test suite (21 tests) passes cleanly, and static analysis reports 0 issues.

---

## 2. What Was Implemented

### 2.1 Domain Layer

| Component | File | Purpose |
|---|---|---|
| `Discovery` entity | `features/discovery/domain/entities/discovery.dart` | Wraps the existing S1 `IdentificationResult` with persistence metadata (`id`, `imagePath`, `createdAt`). Delegates `title`, `explanation`, `confidence`, and `identifiable` getters to the wrapped result — no field duplication. |
| `DiscoveryRepository` contract | `features/discovery/domain/repositories/discovery_repository.dart` | Abstract interface defining `save()`, `getAll()`, `getById()`, and `delete()`. Presentation layer depends on this abstraction, not on Drift directly. |
| Extended Failure hierarchy | `core/errors/failures.dart` | Added `StorageFailure`, `ImagePersistenceFailure`, and `DiscoveryNotFoundFailure` alongside existing S1 failures. No S1 failures were modified or removed. |

### 2.2 Data Layer

| Component | File | Purpose |
|---|---|---|
| `AppDatabase` (Drift) | `features/discovery/data/datasources/discovery_database.dart` | Single `discoveries` table with columns: `id` (TEXT PK), `title`, `explanation`, `confidence`, `identifiable`, `image_path`, `created_at`. Uses `drift_flutter` for native SQLite binding. |
| `LocalImageStorageService` | `features/discovery/data/datasources/image_storage_service.dart` | Copies temporary camera captures into `getApplicationDocumentsDirectory()/discoveries/` with UUID-based filenames. Handles deletion of persistent images. Accepts an injectable directory getter for testability. |
| `DriftDiscoveryRepository` | `features/discovery/data/repositories/drift_discovery_repository.dart` | Concrete implementation of `DiscoveryRepository`. Maps between Drift `DiscoveryEntry` rows and domain `Discovery` entities. `getAll()` orders by `createdAt DESC`. `delete()` removes both the DB record and the associated image file. |

### 2.3 Presentation Layer

| Component | File | Purpose |
|---|---|---|
| `ResultScreen` (modified) | `features/identification/presentation/screens/result_screen.dart` | Converted from `StatelessWidget` to `StatefulWidget`. Added "Save Discovery" button with loading spinner, disabled-during-save guard, and `✓ Saved to your discoveries` confirmation state. On save failure, orphaned image files are cleaned up before showing the error snackbar. |
| `DiscoveryListScreen` | `features/discovery/presentation/screens/discovery_list_screen.dart` | Displays saved discoveries in a `ListView` ordered newest-first. Each card shows thumbnail, title, and formatted date. Includes a friendly empty state with a "What is this?" CTA that launches the camera flow. |
| `DiscoveryDetailScreen` | `features/discovery/presentation/screens/discovery_detail_screen.dart` | Displays the full persisted discovery: saved image, title, explanation, confidence badge, and discovery date. Includes a delete action with a confirmation dialog. Returns `true` on successful deletion so the list screen can refresh. |
| `HomeScreen` (modified) | `features/identification/presentation/screens/home_screen.dart` | Added an `OutlinedButton` for "My Discoveries" below the existing camera action. Accepts an optional `DiscoveryRepository` parameter — when null, the button is hidden, preserving backward compatibility. |
| `CameraScreen` (modified) | `features/identification/presentation/screens/camera_screen.dart` | Forwards optional `repository` and `imageStorageService` to `ResultScreen`. No changes to camera lifecycle, capture logic, or identification flow. |
| `main.dart` (modified) | `main.dart` | Initializes `AppDatabase`, `LocalImageStorageService`, and `DriftDiscoveryRepository` at startup. Injects the repository into `WhatWasThatApp` → `HomeScreen`. |

### 2.4 Test Suite (13 new tests, 8 existing preserved)

| Test File | Tests | Coverage |
|---|---|---|
| `discovery_domain_test.dart` | 3 | Entity construction, `IdentificationResult` wrapping, UUID generation, equality semantics. |
| `discovery_repository_test.dart` | 4 | Save/retrieve by ID, newest-first ordering, delete with image file cleanup, `ImageStorageService` file copy. |
| `database_restart_persistence_test.dart` | 1 | Full app restart simulation: create DB instance A → save → close → create DB instance B → verify record and image survive. |
| `discovery_widgets_test.dart` | 5 | HomeScreen "My Discoveries" rendering, empty state, populated list, delete confirmation dialog, ResultScreen save flow with UI state transition. |

**Total: 21 tests passing. 0 failures. 0 skipped.**

### 2.5 Documentation

| Document | Action |
|---|---|
| `docs/decisions/ADR-0002-local-discovery-persistence.md` | Created. Records the decision to use Drift/SQLite for local-first persistence, the image file isolation strategy, and the trade-offs (device-local data, no sync). |
| `docs/architecture.md` | Rewritten. Documents the S2 layered structure, data flow diagram, database schema, and image lifecycle. |
| `README.md` | Updated. Release banner promoted to v0.2.0, feature list expanded, architecture tree includes `discovery/`, Quick Start includes `build_runner` step, test matrix documented, roadmap updated. |

---

## 3. How It Was Implemented

### 3.1 Architectural Approach

The implementation strictly followed the **protected S1 boundaries** defined in the brief:

- The `ImageIdentifier` → `IdentificationResult` pipeline was **not modified**. OpenAI calls remain in the data layer, untouched.
- `ResultScreen` does **not** write SQL. It delegates to `DiscoveryRepository`.
- `CameraScreen` is **not** responsible for persistence. It merely forwards dependencies.
- Drift database calls are **not** inside widgets. They live in `DriftDiscoveryRepository`, accessed through the domain contract.

The identification pipeline and the persistence pipeline meet at exactly one point: the `IdentificationResult` object handed to `Discovery.create()` in the `ResultScreen` save handler. This means either system can be swapped independently in future sprints.

### 3.2 Dependency Choices

| Package | Version | Justification |
|---|---|---|
| `drift` | ^2.24.2 | Type-safe SQLite access with code generation. Eliminates raw SQL strings. |
| `drift_flutter` | ^0.2.4 | Provides `driftDatabase()` helper for native SQLite on Android/iOS. |
| `drift_dev` | ^2.24.2 (dev) | Code generator for Drift table definitions. |
| `build_runner` | ^2.4.14 (dev) | Drives `drift_dev` code generation. |
| `path_provider` | ^2.1.5 | Access to `getApplicationDocumentsDirectory()` for persistent image storage. |
| `path` | ^1.9.0 | Cross-platform path manipulation for image filenames. |
| `uuid` | ^4.5.1 | Generates stable v4 UUIDs for discovery IDs. Chosen over auto-increment integers to support future sync scenarios. |

No existing S1 dependencies were upgraded. No Firebase, PostgreSQL, or backend packages were introduced.

### 3.3 Image Lifecycle Strategy

```
Camera capture (temp file)
    │
    ▼  [User taps "Save Discovery"]
ImageStorageService.saveImagePermanently()
    │
    ├─ Copy temp file → {appDocuments}/discoveries/{uuid}.jpg
    ├─ Return persistent path
    │
    ▼
DriftDiscoveryRepository.save()
    │
    ├─ Insert row into `discoveries` table with persistent image_path
    │
    ▼  [If DB insert fails]
    ├─ Delete the copied image file (rollback)
    ├─ Show error snackbar
```

On deletion:
```
DriftDiscoveryRepository.delete(id)
    │
    ├─ Look up existing record to get image_path
    ├─ ImageStorageService.deleteImage(image_path)
    ├─ DELETE FROM discoveries WHERE id = ?
```

---

## 4. Problems Faced & Mitigations

### 4.1 Relative Import Path Resolution Failures

**Problem:** The initial `discovery_detail_screen.dart` and `discovery_list_screen.dart` used relative imports like `../../identification/domain/entities/identification_result.dart`. Because these files lived at `lib/features/discovery/presentation/screens/`, the `../../` traversal resolved to `lib/features/discovery/identification/...` (which doesn't exist) instead of `lib/features/identification/...`.

This produced **21 compile errors** including `uri_does_not_exist`, `undefined_class`, and `non_type_as_type_argument`.

**Mitigation:** Rewrote all cross-feature imports in the discovery presentation layer to use **absolute package imports** (`package:what_was_that/features/identification/...`). This is more robust, IDE-friendly, and immune to directory depth changes. All 21 errors resolved immediately.

**Lesson:** For cross-feature references in a multi-feature Flutter project, always prefer `package:` imports over relative paths.

---

### 4.2 PowerShell UTF-8 Encoding Corruption (Mojibake)

**Problem:** When writing `README.md` via PowerShell here-strings (`@'...'@`), all emoji characters and Unicode arrows were corrupted into Windows-1252 mojibake. For example:
- `✨` became `âœ¨`
- `📷` became `ðŸ"·`
- `→` became `â†'`
- `—` became `â€"`

This happened because PowerShell's default `Set-Content` encoding on Windows is UTF-16LE or the system ANSI codepage, not UTF-8.

**Mitigation:** Used `[System.Text.UTF8Encoding]::new($false)` (UTF-8 without BOM) with `[System.IO.File]::WriteAllText()` to write the file with correct encoding. This produced a clean, GitHub-renderable `README.md` with all emojis intact.

**Lesson:** On Windows PowerShell, never rely on `Set-Content` or `Out-File` for files containing Unicode/emoji. Always use explicit UTF-8 encoding via .NET APIs.

---

### 4.3 PowerShell Multi-Line String Replacement Failures

**Problem:** Attempting to use `$content.Replace($oldMultiLineString, $newMultiLineString)` failed with `Cannot find an overload for "Replace" and the argument count: "1"`. This was caused by backtick characters (`` ` ``) inside the here-strings being interpreted as PowerShell escape characters, silently corrupting the string content and breaking the method signature.

**Mitigation:** Switched to a **line-by-line processing approach** using `Get-Content` → `foreach` → `Set-Content`. Each line was matched individually with simple `-match` or `-eq` operators, and replacement lines were injected into the output array. This completely avoided multi-line string escaping issues.

**Lesson:** For PowerShell text manipulation involving code blocks, backticks, or special characters, line-by-line processing is far more reliable than whole-file `.Replace()`.

---

### 4.4 Git Detached HEAD & Pre-existing Branch Conflict

**Problem:** The initial `git checkout v0.1.0` entered detached HEAD state. The subsequent `git checkout -b sprint/s2-discoveries` failed with `fatal: a branch named 'sprint/s2-discoveries' already exists` because a prior aborted attempt had left the branch in the local ref store.

**Mitigation:** Switched to the existing branch with `git checkout sprint/s2-discoveries` and then hard-reset it to the tag with `git reset --hard v0.1.0`. This ensured the branch pointed exactly at the S1 baseline without any stale commits.

**Lesson:** Always check for pre-existing branch names before creating new ones from tags. Use `git branch -D` to clean up stale branches if needed.

---

### 4.5 Drift `build_runner` Deprecation Warning

**Problem:** The `--delete-conflicting-outputs` flag passed to `dart run build_runner build` emitted a warning: `These options have been removed and were ignored`. The build still succeeded (34 outputs written in 80s), but the warning was noisy.

**Mitigation:** Noted for future cleanup. The flag is harmless in the current version but should be removed from documentation and CI scripts in a future maintenance pass. No functional impact.

---

### 4.6 Flutter PATH Not Persisting Across PowerShell Sessions

**Problem:** In some PowerShell sessions, the `flutter` command was not found (`The term 'flutter' is not recognized`), even though it worked in others. This was caused by the Flutter SDK path (`C:\src\flutter\bin`) not being in the system-level `PATH` environment variable — it was only set in certain terminal profiles.

**Mitigation:** Prepended the Flutter SDK path to the session-level `$env:Path` at the start of each scripting block: `$env:Path = "C:\src\flutter\bin;" + $env:Path`. For a permanent fix, the Flutter SDK path should be added to the Windows system environment variables.

---

## 5. S1 Regression Verification

The following S1 flows were manually and automatically verified to work identically to v0.1.0:

| S1 Flow | Status |
|---|---|
| Home → Camera → Capture → Preview → Retake | ✅ Intact |
| Preview → Identify → OpenAI Vision → Structured JSON | ✅ Intact |
| Result Screen → Title, Explanation, Confidence Badge | ✅ Intact |
| Result Screen → Try Again → Back to Camera | ✅ Intact |
| Unidentifiable Result → Orange Warning State | ✅ Intact |
| Camera Permission Denied → Error View | ✅ Intact |
| Network Failure → Error Dialog with Retry | ✅ Intact |
| All 8 original S1 tests | ✅ Passing |

---

## 6. Definition of Done Checklist

| Category | Requirement | Status |
|---|---|---|
| **Persistence** | Drift/SQLite integrated | ✅ |
| | Database initializes successfully | ✅ |
| | CRUD operations work | ✅ |
| | Data survives app restart | ✅ |
| **Image Storage** | Temp images copied to persistent storage | ✅ |
| | Persistent paths stored in DB | ✅ |
| | Images display after restart | ✅ |
| | Images deleted with discovery | ✅ |
| | No orphaned files | ✅ |
| **Product** | Result can be saved | ✅ |
| | Saved state visible | ✅ |
| | Home → My Discoveries | ✅ |
| | Discovery list works | ✅ |
| | Empty state works | ✅ |
| | Discovery detail works | ✅ |
| | Delete works | ✅ |
| **Regression** | S1 camera flow works | ✅ |
| | S1 AI identification works | ✅ |
| | S1 result rendering works | ✅ |
| | S1 retry flow works | ✅ |
| | All S1 tests pass | ✅ |
| **Quality** | 21 tests passing | ✅ |
| | `flutter analyze` — 0 issues | ✅ |
| | No secrets committed | ✅ |
| | No unnecessary dependencies | ✅ |
| **Documentation** | README updated | ✅ |
| | Architecture doc updated | ✅ |
| | ADR-0002 created | ✅ |
| **Git** | Branch from v0.1.0 | ✅ |
| | Conventional commits | ✅ (6 scoped commits) |
| | Tag v0.2.0 created | ✅ |
| | Pushed to remote | ✅ |

---

## 7. Recommendations for S3

Based on the architecture established in S2, the following observations may be useful for Sprint 3 planning:

1. **Sync adapter layer**: The `DiscoveryRepository` abstraction is ready to be backed by a sync-aware implementation. A future `SyncDiscoveryRepository` could wrap the existing `DriftDiscoveryRepository` and add cloud push/pull without changing any presentation code.

2. **UUID strategy**: Discovery IDs are already v4 UUIDs, which are collision-safe across devices. This was a deliberate choice to avoid migration pain when multi-device sync is introduced.

3. **Image storage scaling**: Currently all images are stored flat in a single `discoveries/` directory. If the user accumulates hundreds of discoveries, consider subdirectory sharding by date (e.g., `discoveries/2026/10/`).

4. **Drift migrations**: The current schema is version 1 with a single table. Future sprints adding columns (e.g., `latitude`, `longitude`, `tags`) will need Drift migration steps in `AppDatabase`. The `schemaVersion` getter is already in place.

---

## 8. Conclusion

Sprint 2 delivered a complete, tested, and documented local persistence layer that transforms "What Was That?" from a disposable lookup tool into a personal discovery journal. The implementation respects all S1 boundaries, introduces zero cloud dependencies, and establishes a clean architectural foundation for future spatial, social, and multi-modal capabilities.

**Sprint 2 is complete. Tag `v0.2.0` is pushed to `origin`.**

---

*Report prepared by the S2 implementation team.*
*For questions or architectural review, refer to `docs/decisions/ADR-0002-local-discovery-persistence.md`.*