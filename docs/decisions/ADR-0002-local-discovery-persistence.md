# ADR-0002: Local Discovery Persistence

## Status
Accepted

## Context
Sprint 1 (v0.1.0) provides an ephemeral identification flow: the user captures an image, sends it to the vision provider, and views the structured `IdentificationResult`. Once the user navigates away, the result and temporary camera image are lost.

Sprint 2 (v0.2.0) requires persisting identifications as personal "Discoveries" so the user can review them across application restarts, inspect details, and delete them.
There is currently no account system, backend, or cloud synchronization requirement.

## Decision
1. **Local-First SQLite Database via Drift**:
   - Use `drift` and `drift_flutter` with SQLite for strongly typed, reactive, and migration-friendly local storage.
   - Introduce a single primary table `discoveries` with columns for `id` (TEXT/UUID PK), `title` (TEXT), `explanation` (TEXT), `confidence` (TEXT), `identifiable` (BOOLEAN), `image_path` (TEXT), and `created_at` (INTEGER/DATETIME).

2. **Decoupled Image File Lifecycle**:
   - Camera captures are temporary files subject to OS cleanup.
   - When a user explicitly saves a Discovery, the temporary image is copied to the application's persistent documents directory (`path_provider`).
   - The persistent file path is stored in the database record.
   - Deleting a Discovery deletes both the database record and the persistent image file, preventing orphaned files.

3. **Domain Separation**:
   - The `Discovery` entity wraps `IdentificationResult` along with discovery metadata (`id`, `imagePath`, `createdAt`).
   - The identification pipeline (Camera -> `ImageIdentifier` -> `IdentificationResult`) remains decoupled from storage.
   - UI interacts solely with `DiscoveryRepository`, not directly with Drift DAOs or raw SQL.

## Consequences
### Positive
- Zero external backend or authentication dependencies required.
- Fast, offline-first user experience.
- Strong type safety via Drift code generation.
- Clean separation between ephemeral identification and durable personal memory.

### Trade-offs
- Data is device-local; uninstalling the app may delete stored discoveries.
- Multi-device sync will require a synchronization adapter in a future sprint.
