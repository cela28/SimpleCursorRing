---
status: testing
phase: 02-settings-ui
source: 01-01-SUMMARY.md, 01-02-SUMMARY.md, ROADMAP.md (Phase 2 success criteria), quick-001
started: 2026-02-06T09:30:00Z
updated: 2026-02-06T09:30:00Z
---

## Current Test

number: 1
name: Ring Displays and Follows Cursor
expected: |
  A white ring is visible on screen, centered on the mouse cursor. Moving the mouse causes the ring to follow smoothly without noticeable lag.
awaiting: user response

## Tests

### 1. Ring Displays and Follows Cursor
expected: A white ring is visible on screen, centered on the mouse cursor. Moving the mouse causes the ring to follow smoothly without noticeable lag.
result: [pending]

### 2. Open Settings via Slash Command
expected: Typing /scr in chat opens the SimpleCursorRing settings panel.
result: [pending]

### 3. Open Settings via Interface Options
expected: Opening Interface Options (Esc > Options > AddOns) shows SimpleCursorRing listed. Clicking it shows the settings panel.
result: [pending]

### 4. Size Slider
expected: Dragging the "Ring Size" slider changes the ring size in real-time. The value label updates. Moving to minimum (20) makes the ring very small, maximum (200) makes it very large.
result: [pending]

### 5. Color Picker
expected: Clicking the color swatch opens WoW's color picker. Selecting a color (e.g., red) changes the ring color immediately. Adjusting opacity makes the ring more transparent.
result: [pending]

### 6. Class Color Toggle
expected: Checking "Use Class Color" changes the ring to your character's class color. The color swatch becomes grayed out. Unchecking restores the custom color and re-enables the swatch.
result: [pending]

### 7. Ring Style Dropdown
expected: A "Ring Style" dropdown appears below the class color checkbox. It shows three options: Thin, Medium, Thick (Bold). Selecting each one visibly changes the ring thickness.
result: [pending]

### 8. Settings Persist After Reload
expected: After changing settings (size, color, texture), typing /reload preserves all changes. Opening /scr shows the same values you set.
result: [pending]

## Summary

total: 8
passed: 0
issues: 0
pending: 8
skipped: 0

## Gaps

[none yet]
