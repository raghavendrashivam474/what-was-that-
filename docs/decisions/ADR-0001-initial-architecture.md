# ADR-0001: Initial Architecture and AI Provider Abstraction

## Status
Accepted

## Context
What Was That? requires a rapid S1 MVP on Android proving the core capture-and-identify loop. We need an architecture that prevents UI widgets from tightly coupling to AI provider network calls or JSON formats, while strictly avoiding over-architecting.

## Decision
1. Use Flutter with Android-first focus.
2. Structure by feature with three simple layers: presentation, domain, and data.
3. Introduce a single domain boundary interface ImageIdentifier separating UI/orchestration from remote AI APIs.
4. Enforce structured JSON responses from the AI provider, mapping to a domain model IdentificationResult.

## Consequences
- **Positive**: AI providers can be swapped or mocked in unit tests with zero changes to UI.
- **Positive**: Clean path to S2 (adding local database/history) by persisting IdentificationResult.
- **Positive**: No unnecessary boilerplate or heavy dependency injection frameworks.
- **Negative**: Requires writing simple DTO-to-Domain mapping classes.
