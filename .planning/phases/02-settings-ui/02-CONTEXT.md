# Phase 2: Settings UI - Context

**Gathered:** 2026-02-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Users access and modify ring settings through a `/simplecursorring` slash command and Interface Options panel. Both entry points expose the same controls: size slider, color picker, and class color toggle. The ring customization functionality already exists from Phase 1 — this phase creates the UI to access it.

</domain>

<decisions>
## Implementation Decisions

### Panel Layout
- Single section with all controls together (no groupings)
- Control order: Size slider → Color picker → Class color toggle
- Compact vertical spacing — minimal padding between controls

### Control Behavior
- Live preview — changes apply instantly as user adjusts controls
- Size slider shows numeric value (e.g., "Size: 64")
- No reset-to-defaults button
- When class color toggle is ON, color picker is disabled but visible (grayed out)

### Visual Styling
- Match WoW default addon style — standard Blizzard UI look
- Clear labels only: "Ring Size", "Ring Color", "Use Class Color"
- No description text under controls
- Color picker: swatch showing current color + button to open full picker
- Slider shows current value only (no min/max labels)

### Feedback & States
- No explicit "saved" feedback — settings auto-persist (standard WoW behavior)
- No tooltips on controls — labels are self-explanatory
- Disabled color picker appears grayed out/desaturated
- Slash command opens panel silently (no chat message)

### Claude's Discretion
- Whether to include a title header in the panel
- Exact pixel spacing values
- Color picker implementation (use existing WoW API or simple RGB sliders)

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard WoW addon approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-settings-ui*
*Context gathered: 2026-02-03*
