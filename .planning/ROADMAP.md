# Roadmap: SimpleCursorRing

## Milestone: v1.0

A standalone WoW addon that displays a customizable ring around the mouse cursor. Two phases: first get the ring working with all customization options, then expose those options through accessible settings UI.

---

### Phase 1: Core Ring

**Goal:** A customizable ring follows the cursor with adjustable size and color options.

**Dependencies:** None (foundation phase)

**Requirements:** RING-01, RING-02, RING-03, RING-04

**Plans:** 2 plans

Plans:
- [x] 01-01-PLAN.md — Addon foundation + ring display (RING-01)
- [x] 01-02-PLAN.md — Settings infrastructure + customization (RING-02, RING-03, RING-04)

**Success Criteria:**
1. Ring texture displays centered on cursor and moves smoothly with mouse
2. Slider adjusts ring size between 20-200px with visible change
3. Color picker changes ring color and persists across sessions
4. Class color toggle applies current character's class color to ring

---

### Phase 2: Settings UI

**Goal:** Users can access and modify ring settings through standard WoW interfaces.

**Dependencies:** Phase 1 (ring customization must exist to expose)

**Requirements:** SETT-01, SETT-02

**Success Criteria:**
1. Typing /simplecursorring opens settings panel
2. Settings panel appears in Interface Options under AddOns section
3. All ring options (size slider, color picker, class color toggle) are accessible from both entry points
4. Changes made in settings panel immediately affect ring appearance

---

## Progress

| Phase | Status | Requirements |
|-------|--------|--------------|
| 1 - Core Ring | ✓ Complete | RING-01, RING-02, RING-03, RING-04 |
| 2 - Settings UI | Not Started | SETT-01, SETT-02 |

**Coverage:** 6/6 requirements mapped

---
*Roadmap created: 2026-02-03*
*Phase 1 planned: 2026-02-03*
*Phase 1 complete: 2026-02-03*
