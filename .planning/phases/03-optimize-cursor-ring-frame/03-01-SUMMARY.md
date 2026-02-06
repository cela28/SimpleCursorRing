---
phase: 03-optimize-cursor-ring-frame
plan: 01
subsystem: perf
tags: [wow-api, frame-optimization, cursor-tracking]

requires:
  - phase: 01-core-ring
    provides: "Ring frame and texture setup in Core.lua"
provides:
  - "Optimized 1x1 ring frame with disabled input and independent texture sizing"
affects: []

tech-stack:
  added: []
  patterns:
    - "1x1 frame with independent texture sizing pattern"
    - "Explicit EnableMouse(false)/EnableKeyboard(false) on non-interactive frames"

key-files:
  created: []
  modified:
    - "SimpleCursorRing/Core.lua"

key-decisions:
  - "Frame stays at 1x1, texture sized independently via SetSize()+SetPoint('CENTER')"
  - "UpdateRingSize targets texture instead of frame"

duration: 2min
completed: 2026-02-06
---

# Phase 3 Plan 01: Optimize Ring Frame Summary

**1x1 frame with disabled input and independent texture sizing — reduces per-frame overhead by minimizing frame dimensions and hit-testing area**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-06T13:50:00Z
- **Completed:** 2026-02-06T13:52:41Z
- **Tasks:** 1/2 (checkpoint deferred to user in-game testing)
- **Files modified:** 1

## Accomplishments
- Ring frame minimized to 1x1 pixels (was 64x64)
- Mouse and keyboard input disabled on ring frame
- Texture sized independently via SetSize(64,64) + SetPoint("CENTER") instead of SetAllPoints
- UpdateRingSize now targets texture directly instead of frame

## Task Commits

1. **Task 1: Optimize ring frame** - `1c289fd` (perf)
2. **Task 2: In-game verification** - deferred to user testing via release

## Files Created/Modified
- `SimpleCursorRing/Core.lua` - Frame setup optimized: 1x1 size, disabled input, independent texture sizing, UpdateRingSize targets texture

## Decisions Made
- Kept ClearAllPoints() in OnUpdate handler — required to prevent anchor stacking per WoW API behavior
- Deferred in-game verification to user testing via release

## Deviations from Plan

None — plan executed exactly as written for Task 1. Task 2 (human-verify checkpoint) deferred to release testing.

## Issues Encountered
None

## Next Phase Readiness
- Phase 3 complete, optimization applied
- User testing via release will confirm no visual/functional regression

---
*Phase: 03-optimize-cursor-ring-frame*
*Completed: 2026-02-06*
