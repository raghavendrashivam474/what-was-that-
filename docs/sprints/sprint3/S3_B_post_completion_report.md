---

# Sprint S3-B Completion Report — Spatial Recall

**Project:** What Was That?
**Sprint:** S3-B — Spatial Recall
**Target Release:** v0.3.0-B
**Baseline:** v0.3.0-A (commit `3ff32c4`)
**Branch:** `sprint/s3-b-spatial`
**Platform:** Flutter / Dart / Android-first
**Date:** 2026-03-10
**Status:** ✅ Complete — All tests passing, zero analysis issues

---

## 1. Executive Summary

S3-B extends the existing discovery persistence model with optional geographic context. When a user saves a discovery, the application now attempts to capture the device's current coordinates. If location is available and permitted, the coordinates are persisted alongside the discovery. If location is unavailable for any reason — permission denied, services disabled, timeout, or hardware error — the discovery saves normally without location data. A new map-based recall surface allows users to visualize all location-enabled discoveries spatially.

**Core principle preserved throughout:** Location failure must never become a discovery save failure.

---

## 2. What Was Implemented

### 2.1 Location Domain Model

A new value object `DiscoveryLocation` was introduced in the discovery domain layer:

```
DiscoveryLocation
 ├── latitude  (double)
 └── longitude (double)
```

This is deliberately minimal. Altitude, accuracy, speed, heading, and address data are explicitly excluded from S3-B per the sprint brief. The object supports value equality and is nullable within the `Discovery` entity — `null` means "no location captured," which is semantically distinct from any coordinate pair including `(0.0, 0.0)`.

### 2.2 Location Provider Abstraction

A `LocationProvider` interface was created to decouple the UI and save flow from any specific GPS implementation:

```dart
abstract class LocationProvider {
  Future<DiscoveryLocation?> getCurrentLocation();
}
```

The production implementation, `GeolocatorLocationProvider`, wraps the `geolocator` package and handles the full permission lifecycle:
1. Checks if location services are enabled.
2. Checks current permission status.
3. Requests permission if currently denied.
4. Returns `null` immediately if permission is denied forever.
5. Acquires position with `LocationAccuracy.medium` and a 5-second timeout.
6. Returns `null` on any exception — no crashes, no hangs.

### 2.3 Discovery Entity Extension

The existing `Discovery` entity was extended with a single optional field:

```dart
final DiscoveryLocation? location;
```

Both the primary constructor and the `Discovery.create` factory accept this field. All existing call sites that do not pass `location` continue to work unchanged — the field defaults to `null`. The `==` operator and `hashCode` were updated to include `location` in equality checks.

### 2.4 Drift Database Schema Migration

The Drift `Discoveries` table gained two nullable columns:

```dart
RealColumn get latitude => real().nullable()();
RealColumn get longitude => real().nullable()();
```

The schema version was bumped from **1 → 2** with an explicit migration strategy:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    await m.addColumn(discoveries, discoveries.latitude);
    await m.addColumn(discoveries, discoveries.longitude);
  }
}
```

This ensures that existing databases from S1/S2/S3-A upgrade cleanly. Old discovery records retain `null` for both columns, which maps correctly to `location = null` in the domain entity.

### 2.5 Repository Mapping Update

`DriftDiscoveryRepository` was updated in two places:

- **Save path:** `DiscoveriesCompanion.insert` now includes `latitude: Value(discovery.location?.latitude)` and `longitude: Value(discovery.location?.longitude)`. The `Value()` wrapper correctly handles nulls for nullable Drift columns.
- **Read path:** `_mapEntryToDiscovery` reconstructs a `DiscoveryLocation` only when both `entry.latitude` and `entry.longitude` are non-null.

### 2.6 Save Flow Integration (ResultScreen)

The save flow in `ResultScreen._saveDiscovery()` was extended with a non-blocking location acquisition step:

```
Save pressed
     ↓
Attempt location capture (try/catch, never throws outward)
     ↓
Success → attach DiscoveryLocation
Failure → location = null
     ↓
Persist image (existing)
     ↓
Create Discovery with optional location
     ↓
Save to repository (existing)
```

Key behaviors:
- `LocationProvider` is injected via constructor parameter, defaulting to `GeolocatorLocationProvider` in production.
- The entire location acquisition is wrapped in its own `try/catch` block, completely isolated from the image persistence and database save logic.
- No UI changes to the save button or flow — the user sees the same "Saving..." → "Saved to your discoveries" progression.

### 2.7 Discovery Detail Screen — Location Context

The existing `DiscoveryDetailScreen` gained a "Location Context" section below the confidence badge:

- **When location exists:** Displays formatted coordinates (`Lat: XX.XXXXX, Lon: XX.XXXXX`) and a "View on Map" button that navigates to `DiscoveryMapScreen` with `initialDiscoveryId` pre-set.
- **When location is null:** Displays a subdued message: "Location context was not captured for this discovery." No map button is shown.

### 2.8 Discovery Map Screen (New)

A new `DiscoveryMapScreen` was created using `flutter_map` + `latlong2` (OpenStreetMap tiles, no API key required):

- Loads all discoveries from the repository and filters to those with non-null locations.
- Renders each located discovery as a red `Icons.location_on` marker.
- Tapping a marker selects it (enlarges, changes to primary color) and displays a floating preview card at the bottom of the screen.
- Tapping the preview card navigates to the existing `DiscoveryDetailScreen` — no duplicate detail UI.
- Tapping the map background deselects the current marker.
- Empty state: "No mapped discoveries yet" with explanatory text when no discoveries have location data.
- Error state with retry button if repository access fails.
- Accepts `enableTileLayer` and `tileProvider` parameters for testability (see §4).

### 2.9 Navigation Entry Point

A map icon button (`Icons.map_outlined`) was added to the `DiscoveryListScreen` AppBar actions. Tapping it pushes `DiscoveryMapScreen`. On return, the discovery list reloads to reflect any deletions made via the map → detail flow.

### 2.10 Android Permissions

`ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions were added to `AndroidManifest.xml`.

---

## 3. Architecture Decisions

### 3.1 Map Provider Selection

**Decision:** Use `flutter_map` + `latlong2` with OpenStreetMap tiles.

**Rationale:**
- No API key required — eliminates secret management concerns.
- Fully open-source (BSD license).
- No paid tier or usage limits for reasonable consumer use.
- Android-compatible out of the box.
- Tile network access is required for map imagery, but discovery coordinates remain fully local and offline-accessible.

**Alternatives considered:**
- `google_maps_flutter`: Requires API key, Google Cloud billing setup, and introduces a proprietary dependency. Rejected for S3-B scope.
- `mapbox_gl`: Requires access token and Mapbox account. Rejected.
- Custom tile rendering: Excessive complexity for S3-B.

### 3.2 Location as Discovery Metadata, Not a Separate Domain

**Decision:** Location is a nullable field on the existing `Discovery` entity, not a separate `MapDiscovery` or `SpatialDiscovery` class.

**Rationale:** The sprint brief explicitly states "The existing Discovery should remain the central product concept. Location is metadata attached to a Discovery, not a new product domain." This preserves the single-entity architecture established in S1/S2.

### 3.3 No Reverse Geocoding

**Decision:** Store and display raw coordinates only. No address/city/country lookup.

**Rationale:** Reverse geocoding would require an additional network service (Nominatim, Google Geocoding API, etc.), introduce latency, and add complexity disproportionate to S3-B's scope. The sprint brief explicitly lists reverse geocoding as out of scope.

### 3.4 No Clustering

**Decision:** Simple individual markers only.

**Rationale:** At the expected discovery count for a personal local-first app, clustering is premature optimization. If performance issues emerge at scale, clustering can be added in a future sprint with documented justification.

---

## 4. Problems Encountered & Mitigations

### Problem 1: `LocationAccuracy.balanced` Enum Does Not Exist

**Symptom:** `flutter analyze` reported `undefined_enum_constant` at `geolocator_location_provider.dart:33`. The `geolocator` v13 `LocationAccuracy` enum does not include a `balanced` value.

**Root Cause:** Incorrect assumption about the `geolocator` API surface. The available values are `lowest`, `low`, `medium`, `high`, `highAccuracy`, and `best`.

**Mitigation:** Changed to `LocationAccuracy.medium`, which provides a reasonable balance between accuracy and battery consumption for a one-shot capture during save.

---

### Problem 2: `flutter_map` TileLayer Network Requests in Widget Tests

**Symptom:** The `DiscoveryMapScreen` widget test for the populated state caused cascading `ClientException: Request to https://tile.openstreetmap.org/... failed with status 400` errors and ultimately a `Timer is still pending even after the widget tree was disposed` assertion failure. `pumpAndSettle` could not complete because the `TileLayer` spawned continuous asynchronous HTTP image requests.

**Root Cause:** `flutter_map`'s `TileLayer` uses `NetworkImage` internally, which makes real HTTP requests even in the Flutter test environment. The test HTTP client returns 400 for OSM tile URLs, triggering retry loops and pending timers.

**Mitigation:** Added an `enableTileLayer` boolean parameter to `DiscoveryMapScreen` (defaults to `true` in production). Widget tests pass `enableTileLayer: false`, which omits the `TileLayer` from the widget tree entirely while still rendering the `FlutterMap` container and `MarkerLayer`. This allows testing marker presence, selection behavior, and preview card interaction without network dependencies.

---

### Problem 3: `GeolocatorLocationProvider` Platform Channel Hangs in Tests

**Symptom:** The existing `discovery_widgets_test.dart` test "ResultScreen saves discovery on button tap and updates UI" began timing out on `pumpAndSettle` after S3-B changes. The `ResultScreen` was instantiating `GeolocatorLocationProvider` as the default when no `locationProvider` was injected, and the Geolocator's platform channel calls (`isLocationServiceEnabled`, `checkPermission`) hung indefinitely in the test environment where no native platform is available.

**Root Cause:** The default fallback `const GeolocatorLocationProvider()` in `ResultScreen._saveDiscovery()` attempted real platform channel communication during widget tests.

**Mitigation:** Two-part fix:
1. The `ResultScreen` now checks `widget.locationProvider != null` before attempting location acquisition. If a provider is explicitly injected, it is used. If not, the `GeolocatorLocationProvider` fallback is still attempted but wrapped in its own `try/catch` that silently returns `null`.
2. All widget tests that exercise `ResultScreen` now inject a `FakeNoOpLocationProvider` that immediately returns `null`, bypassing platform channels entirely.

---

### Problem 4: `discovery_widgets_test.dart` Import and Interface Errors

**Symptom:** After adding `locationProvider` to `ResultScreen`, the existing `discovery_widgets_test.dart` failed to compile with: (a) `avoid_relative_lib_imports` lint warnings from relative `../lib/` paths, and (b) `MockImageIdentifier` missing the `identify` method (the actual `ImageIdentifier` interface defines `identify(String imagePath)`, not `identifyImage(File imageFile)`).

**Root Cause:** The original test file used relative imports and had a stale mock that didn't match the current `ImageIdentifier` interface. These issues were latent but surfaced when the file needed modification for the `locationProvider` parameter.

**Mitigation:** Rewrote `discovery_widgets_test.dart` with:
- Proper `package:what_was_that/...` imports throughout.
- `FakeImageIdentifier` implementing `identify(String imagePath)` to match the actual interface.
- `FakeNoOpLocationProvider` injected into `ResultScreen` in the save test.

---

## 5. Database Migration Details

| Aspect | Detail |
|--------|--------|
| Previous schema version | 1 |
| New schema version | 2 |
| Migration type | Additive (new nullable columns) |
| Columns added | `latitude REAL NULL`, `longitude REAL NULL` |
| Data loss risk | None — existing rows receive `NULL` for both columns |
| Backward compatibility | Old `Discovery` records load with `location = null` |
| Forward compatibility | New records with location are unreadable by v0.3.0-A (expected) |
| Generated code | `discovery_database.g.dart` regenerated via `dart run build_runner build` |

---

## 6. Dependencies Added

| Package | Version | Purpose |
|---------|---------|---------|
| `geolocator` | ^13.0.2 | Platform location acquisition |
| `flutter_map` | ^7.0.2 | OpenStreetMap tile rendering |
| `latlong2` | ^0.9.1 | Coordinate math for flutter_map |

No existing dependencies were removed or version-changed.

---

## 7. Test Coverage

**Baseline (v0.3.0-A):** 29 tests passing
**After S3-B:** 42 tests passing (+13 new)

### New Test Files

| File | Tests | Coverage |
|------|-------|----------|
| `discovery_spatial_domain_test.dart` | 3 | `DiscoveryLocation` instantiation, value equality, `Discovery` with/without location |
| `discovery_spatial_persistence_test.dart` | 3 | Drift save/retrieve with location, without location, mixed ordering |
| `result_screen_location_test.dart` | 3 | Save with successful location, save with null location (denied), save with throwing provider (timeout) |
| `discovery_map_and_detail_spatial_test.dart` | 4 | Detail screen location section (present/absent), map empty state, map populated state with marker interaction |

### Regression Verification

All 29 pre-existing tests from S1, S2, and S3-A continue to pass without modification to their test logic. The only change to an existing test file was `discovery_widgets_test.dart`, which required `FakeNoOpLocationProvider` injection and import path corrections (see Problem 4).

---

## 8. Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `geolocator`, `flutter_map`, `latlong2` |
| `android/app/src/main/AndroidManifest.xml` | Added `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` |
| `lib/.../domain/entities/discovery.dart` | Added `DiscoveryLocation? location` field |
| `lib/.../data/datasources/discovery_database.dart` | Added `latitude`, `longitude` columns; schema v2 migration |
| `lib/.../data/datasources/discovery_database.g.dart` | Auto-regenerated |
| `lib/.../data/repositories/drift_discovery_repository.dart` | Map coordinates in save/read |
| `lib/.../presentation/screens/result_screen.dart` | Location acquisition in save flow |
| `lib/.../presentation/screens/discovery_detail_screen.dart` | Location context section |
| `lib/.../presentation/screens/discovery_list_screen.dart` | Map icon in AppBar |
| `test/discovery_widgets_test.dart` | Import fixes, `FakeNoOpLocationProvider` injection |

## 9. Files Created

| File | Purpose |
|------|---------|
| `lib/.../domain/entities/discovery_location.dart` | Location value object |
| `lib/.../domain/providers/location_provider.dart` | Location abstraction interface |
| `lib/.../data/providers/geolocator_location_provider.dart` | Geolocator implementation |
| `lib/.../presentation/screens/discovery_map_screen.dart` | Map recall surface |
| `test/discovery_spatial_domain_test.dart` | Domain model tests |
| `test/discovery_spatial_persistence_test.dart` | Repository/migration tests |
| `test/result_screen_location_test.dart` | Save flow fallback tests |
| `test/discovery_map_and_detail_spatial_test.dart` | Map & detail widget tests |

---

## 10. Verification Matrix

| Scenario | Expected | Result |
|----------|----------|--------|
| Permission granted | Discovery saves with location | ✅ |
| Permission denied | Discovery saves without location | ✅ |
| Location service disabled | Discovery saves without location | ✅ |
| Location timeout/error | Discovery saves without location | ✅ |
| Existing old Discovery (pre-S3-B) | Opens normally, location = null | ✅ |
| Located Discovery | Appears on map as marker | ✅ |
| Unlocated Discovery | Does not appear on map | ✅ |
| S3-A search | Title/explanation search unchanged | ✅ |
| Delete Discovery | Disappears from list and map | ✅ |
| App restart | Location persists in database | ✅ |
| Detail screen (located) | Shows coordinates + "View on Map" | ✅ |
| Detail screen (unlocated) | Shows "not captured" message | ✅ |
| `flutter analyze` | 0 issues | ✅ |
| `flutter test` | 42/42 passing | ✅ |

---

## 11. Known Limitations & Future Considerations

1. **Map tiles require network.** The OSM tile layer needs internet connectivity. Coordinates are stored locally and survive offline, but the map background will be blank without network. This is acceptable per the sprint brief's offline-first requirement (data is local; tiles are a display concern).

2. **No clustering.** At high marker densities, overlapping markers may be difficult to interact with. Clustering can be added in a future sprint if needed.

3. **No reverse geocoding.** Coordinates are displayed as raw lat/lon. Human-readable addresses could be added later via Nominatim or similar.

4. **Single-shot location only.** Location is captured at save time. If the user moves between identifying and saving, the location reflects the save moment, not the capture moment. This is a known trade-off for simplicity.

5. **No location editing.** Users cannot manually add or correct location after save. This could be a future enhancement.

---

## 12. Definition of Done

- [x] Location captured during save when available
- [x] Location optional — permission denial does not prevent saving
- [x] Location failure does not prevent saving
- [x] No background location tracking
- [x] No cloud location upload
- [x] Location persists with Discovery across restarts
- [x] Existing discoveries without location remain valid
- [x] Map screen displays located discoveries as markers
- [x] Unlocated discoveries excluded from map
- [x] Marker tap → preview → existing detail screen
- [x] Empty map state exists
- [x] Detail screen shows location context
- [x] S3-A search fully regressed and passing
- [x] All 42 tests pass
- [x] `flutter analyze` clean
- [x] No secrets committed
- [x] No unrelated files modified

---

**Prepared by:** S3-B Implementation
**Reviewed against:** Sprint S3-B Implementation Brief, Sections 1–49
**Next steps:** Tag `v0.3.0-B`, merge `sprint/s3-b-spatial` to `main`, begin S4 planning.