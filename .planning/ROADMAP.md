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

**Plans:** 1 plan

Plans:
- [x] 02-01-PLAN.md — Settings panel with controls + slash command + Interface Options registration (SETT-01, SETT-02)

**Success Criteria:**
1. Typing /simplecursorring opens settings panel
2. Settings panel appears in Interface Options under AddOns section
3. All ring options (size slider, color picker, class color toggle) are accessible from both entry points
4. Changes made in settings panel immediately affect ring appearance

---

### Phase 3: Optimize Cursor Ring Frame

**Goal:** Optimize the cursor ring frame setup to match AzortharionUI's approach — 1x1 frame, disabled input, independent texture sizing — for reduced per-frame overhead.

**Dependencies:** Phase 1 (ring frame must exist)

**Requirements:** None (performance optimization)

**Plans:** 1 plan

Plans:
- [x] 03-01-PLAN.md — Optimize frame to 1x1 with disabled input and independent texture sizing

**Success Criteria:**
1. Ring frame uses 1x1 size with independent texture sizing
2. Mouse and keyboard input disabled on ring frame
3. Ring still follows cursor smoothly with all existing features working
4. No visual or functional regression

---

## Progress

| Phase | Status | Requirements |
|-------|--------|--------------|
| 1 - Core Ring | ✓ Complete | RING-01, RING-02, RING-03, RING-04 |
| 2 - Settings UI | ✓ Complete | SETT-01, SETT-02 |
| 3 - Optimize Cursor Ring Frame | ✓ Complete | — |

**Coverage:** 6/6 requirements mapped

---
*Roadmap created: 2026-02-03*
*Phase 1 planned: 2026-02-03*
*Phase 1 complete: 2026-02-03*
*Phase 2 planned: 2026-02-03*
*Phase 3 added: 2026-02-06*
*Phase 3 planned: 2026-02-06*
*Phase 2 complete: 2026-02-06*
*Phase 3 complete: 2026-02-06*
