# Milestones: SimpleCursorRing

## v1.0 — Core Ring + Settings

**Completed:** 2026-02-06
**Duration:** 3 days (2026-02-03 → 2026-02-06)
**Release:** [v1.0.0](https://github.com/sntanavaras/SimpleCursorRing/releases/tag/v1.0.0)

### What Shipped

A standalone WoW addon that displays a customizable ring around the mouse cursor with full settings UI.

- Cursor-following ring with smooth 100Hz tracking
- Size slider (20-200px)
- Color picker (RGBA) with opacity
- Class color toggle with CUSTOM_CLASS_COLORS support
- Three ring styles: Thin, Medium, Thick
- Settings via `/simplecursorring` (or `/scr`) and Interface Options panel
- Optimized 1x1 frame with independent texture sizing

### Stats

| Metric | Value |
|--------|-------|
| Phases | 3 |
| Plans | 4 |
| Requirements | 6/6 satisfied |
| LOC (Lua) | ~358 |
| Files | 8 |

### Phases

1. **Core Ring** — Ring display, cursor tracking, SavedVariables, customization API
2. **Settings UI** — Slider, color picker, class color checkbox, texture dropdown, slash commands
3. **Optimize Cursor Ring Frame** — 1x1 frame, disabled input, independent texture sizing

### Tech Debt Accepted

- Legacy `Ring.tga` texture file (superseded by RingThin/Medium/Thick)

### Archive

- [v1.0-ROADMAP.md](milestones/v1.0-ROADMAP.md)
- [v1.0-REQUIREMENTS.md](milestones/v1.0-REQUIREMENTS.md)
- [v1.0-MILESTONE-AUDIT.md](milestones/v1.0-MILESTONE-AUDIT.md)

---
*Milestone completed: 2026-02-06*
