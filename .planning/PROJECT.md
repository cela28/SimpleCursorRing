# SimpleCursorRing

## What This Is

A standalone World of Warcraft addon that displays a customizable ring around the mouse cursor. Extracted from EnhanceQoL's Mouse module to provide this single feature without requiring the full addon. Targets players who want cursor visibility enhancement without extra bloat.

## Core Value

A visible, customizable ring follows the cursor — helping players track their mouse position during gameplay, especially in combat.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Ring displays around cursor and follows mouse movement
- [ ] Ring size is adjustable via slider (20-200px)
- [ ] Ring color is customizable via color picker
- [ ] Option to use player's class color for ring
- [ ] Settings accessible via /simplecursorring slash command
- [ ] Settings accessible via Interface Options addon panel

### Out of Scope

- Center dot — user explicitly excluded, not wanted in any version
- Combat-only mode — deferred to v2
- Right-click-only mode — deferred to v2
- Combat override (separate size/color) — deferred to v2
- Combat overlay (second ring) — deferred to v2
- Mouse trail feature — user requested ring only
- Any other EnhanceQoL features — this is a single-purpose addon
- Multi-language localization for v1 — English only initially

## Context

- Source: EnhanceQoL addon by R41z0r (https://github.com/R41z0r/EnhanceQoL)
- Specifically extracting: `EnhanceQoL/Modules/Mouse/` module (ring portion only)
- Assets needed: `Mouse.tga` from `Assets/Mouse/`
- Original uses EnhanceQoL's settings framework — we'll need a standalone settings UI
- WoW addon structure: `.toc` file, Lua code, XML templates, texture assets

## Constraints

- **Platform**: World of Warcraft retail (current version)
- **Dependencies**: None — must be fully standalone
- **Settings Framework**: Cannot use EnhanceQoL's framework — need self-contained settings UI
- **Compatibility**: Standard WoW addon APIs only

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Ring only, no trail | User preference — keep it simple | — Pending |
| No center dot | User explicitly excluded, not wanted in any version | — Pending |
| Named "SimpleCursorRing" | Matches project folder, descriptive | — Pending |
| English only for v1 | Reduce scope, can add locales later | — Pending |
| v1 = basic ring + settings | Combat features deferred to v2 | — Pending |

---
*Last updated: 2026-02-03 after requirements scoping*
