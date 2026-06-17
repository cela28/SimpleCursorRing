<!-- refreshed: 2026-06-17 -->
# Architecture

**Analysis Date:** 2026-06-17

## System Overview

```text
┌─────────────────────────────────────────────────────────────┐
│                    WoW Client (Host)                         │
│  World of Warcraft UI Engine / Lua 5.1 Runtime              │
└────────────┬──────────────────────────────────┬─────────────┘
             │ ADDON_LOADED event                │ PLAYER_LOGIN event
             ▼                                   ▼
┌────────────────────────┐         ┌─────────────────────────┐
│       Core.lua          │         │      Settings.lua        │
│  Ring frame + texture   │◄────────│  Settings panel + slash  │
│  Cursor tracking        │ global  │  commands                │
│  SavedVariables init    │  API    │  UI controls (slider,    │
│  Color/size functions   │         │  color picker, checkbox) │
└────────────────────────┘         └─────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   Persistence Layer                          │
│  SimpleCursorRingSaved (WoW SavedVariables — per-account)   │
│  Saved to WTF/Account/.../SavedVariables/SimpleCursorRing.lua│
└─────────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   Assets                                     │
│  `SimpleCursorRing/Textures/Default.tga`                     │
└─────────────────────────────────────────────────────────────┘
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| Ring Frame | Invisible parent frame positioned at cursor each frame | `SimpleCursorRing/Core.lua` |
| Ring Texture | Visible ring graphic rendered on the ring frame | `SimpleCursorRing/Core.lua` |
| UpdateRingSize | Clamp and apply size (20–200px) to texture, persist to SavedVariables | `SimpleCursorRing/Core.lua` |
| UpdateRingColor | Apply RGBA or class color to texture vertex color, persist | `SimpleCursorRing/Core.lua` |
| SetUseClassColor | Toggle class color mode, re-apply color | `SimpleCursorRing/Core.lua` |
| OnUpdate handler | Per-frame cursor position polling via `GetCursorPosition()` | `SimpleCursorRing/Core.lua` |
| SimpleCursorRing global | Namespace exposing Core functions to Settings module | `SimpleCursorRing/Core.lua` |
| Settings panel | WoW Interface Options canvas panel with size/color/class-color controls | `SimpleCursorRing/Settings.lua` |
| Slash commands | `/simplecursorring` and `/scr` open the settings panel | `SimpleCursorRing/Settings.lua` |
| Default.tga | Ring texture asset (TGA format, 43 KB) | `SimpleCursorRing/Textures/Default.tga` |

## Pattern Overview

**Overall:** Event-driven WoW addon with a single-frame render loop

**Key Characteristics:**
- Two-file addon split: `Core.lua` owns all state and logic; `Settings.lua` owns all UI
- Communication from `Settings.lua` to `Core.lua` is via the `SimpleCursorRing` global namespace table
- State is persisted entirely through the WoW `SavedVariables` mechanism (`SimpleCursorRingSaved`)
- Cursor tracking uses the WoW `OnUpdate` script (runs every client frame) rather than events
- No third-party libraries or dependencies; pure WoW Lua API

## Layers

**Core / Logic Layer:**
- Purpose: Frame creation, cursor tracking, state management, ring appearance
- Location: `SimpleCursorRing/Core.lua`
- Contains: Ring frame and texture setup, `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `InitializeSavedVariables`, `ApplySavedSettings`, `OnUpdate`
- Depends on: WoW global APIs (`CreateFrame`, `GetCursorPosition`, `UnitClass`, `RAID_CLASS_COLORS`), `SimpleCursorRingSaved`
- Used by: Settings.lua (via `SimpleCursorRing` global), WoW client (via registered frame scripts)

**Settings / Presentation Layer:**
- Purpose: User-facing controls for customizing the ring
- Location: `SimpleCursorRing/Settings.lua`
- Contains: Settings panel frame, size slider, color swatch, class color checkbox, slash command registration, `InitializeControls`
- Depends on: `SimpleCursorRing` global (set by Core.lua), `SimpleCursorRingSaved`, WoW `Settings` API, `ColorPickerFrame`
- Used by: WoW Interface Options UI, slash command handler

**Persistence Layer:**
- Purpose: Cross-session storage of user preferences
- Location: WoW-managed `SimpleCursorRingSaved` global (declared in `SimpleCursorRing/SimpleCursorRing.toc`)
- Contains: `size` (number), `color` (table: r/g/b/a), `useClassColor` (boolean)
- Depends on: WoW SavedVariables system
- Used by: Both Core.lua and Settings.lua read/write directly

**Asset Layer:**
- Purpose: Ring graphic
- Location: `SimpleCursorRing/Textures/Default.tga`
- Referenced as: `"Interface\\AddOns\\SimpleCursorRing\\Textures\\Default"` in `Core.lua:23`

## Data Flow

### Addon Initialization

1. WoW loads files in `.toc` order: `Core.lua` first, then `Settings.lua` (`SimpleCursorRing/SimpleCursorRing.toc:8-9`)
2. `Core.lua` creates ring frame and registers `ADDON_LOADED` event (`Core.lua:96-104`)
3. `ADDON_LOADED` fires → `InitializeSavedVariables()` merges defaults into `SimpleCursorRingSaved` (`Core.lua:69-87`)
4. `ApplySavedSettings()` applies persisted size and color to ring texture (`Core.lua:90-93`)
5. `Settings.lua` registers `PLAYER_LOGIN` event (`Settings.lua:153-175`)
6. `PLAYER_LOGIN` fires → `InitializeControls()` reads `SimpleCursorRingSaved` and sets slider/swatch/checkbox values (`Settings.lua:130-149`)
7. Settings panel registered with WoW Interface Options; slash commands bound (`Settings.lua:162-174`)

### Per-Frame Cursor Tracking

1. `OnUpdate` fires every client frame (`Core.lua:113-118`)
2. `GetCursorPosition()` returns raw screen pixel coordinates
3. Coordinates divided by `UIParent:GetEffectiveScale()` to convert to UI units
4. `ringFrame:SetPoint(...)` repositions the frame to cursor center

### User Changes a Setting

1. User interacts with Settings panel control (slider drag, color picker, checkbox click)
2. Control script calls `SimpleCursorRing.UpdateRingSize(value)` / `SimpleCursorRing.UpdateRingColor(r,g,b,a)` / `SimpleCursorRing.SetUseClassColor(checked)` (`Settings.lua:37, 83, 113`)
3. Core function clamps/validates input, persists to `SimpleCursorRingSaved`, applies to ring texture immediately

**State Management:**
- All persistent state lives in `SimpleCursorRingSaved` (WoW-managed global)
- No in-memory state diverges from `SimpleCursorRingSaved` after initialization
- `Core.lua` is the single writer for `SimpleCursorRingSaved`; `Settings.lua` reads it directly for UI initialization

## Key Abstractions

**SimpleCursorRing global namespace:**
- Purpose: Public API bridge between Core and Settings modules
- Examples: `SimpleCursorRing/Core.lua:107-110`
- Pattern: Module pattern via table — `SimpleCursorRing = SimpleCursorRing or {}` then assign functions

**ringFrame / ringTexture:**
- Purpose: The visual element — an invisible 1×1 frame with a texture sized to user preference
- Examples: `SimpleCursorRing/Core.lua:14-29`
- Pattern: Parent frame handles positioning; child texture handles rendering

## Entry Points

**ADDON_LOADED event:**
- Location: `SimpleCursorRing/Core.lua:96-104`
- Triggers: WoW client fires when addon files finish loading
- Responsibilities: SavedVariables initialization, applying saved settings to ring

**PLAYER_LOGIN event:**
- Location: `SimpleCursorRing/Settings.lua:153-175`
- Triggers: WoW client fires after player character data is available
- Responsibilities: Populating UI controls from saved settings, registering settings panel, binding slash commands

**OnUpdate script:**
- Location: `SimpleCursorRing/Core.lua:113-121`
- Triggers: Every rendered client frame
- Responsibilities: Reading cursor position and repositioning ring frame

**Slash commands `/simplecursorring` and `/scr`:**
- Location: `SimpleCursorRing/Settings.lua:169-174`
- Triggers: User types command in chat
- Responsibilities: Opens Interface Options to SimpleCursorRing category

## Architectural Constraints

- **Threading:** Single-threaded Lua coroutine environment. WoW addon Lua is not preemptively multithreaded. The `OnUpdate` callback runs synchronously on the main game thread every frame.
- **Global state:** `SimpleCursorRingSaved` is a WoW-managed global. `SimpleCursorRing` is a module-level global namespace table defined in `Core.lua:107`.
- **Load order:** `Core.lua` must load before `Settings.lua` because Settings reads `SimpleCursorRing` global set by Core. This is enforced by `.toc` file order.
- **Circular imports:** None. Lua in WoW addons does not use `require`; all globals are shared.
- **WoW API version:** Targeting Interface 120007 (The War Within 1.2.x era).

## Anti-Patterns

### Direct SavedVariables access from Settings.lua

**What happens:** `Settings.lua` reads `SimpleCursorRingSaved.color`, `SimpleCursorRingSaved.size`, and `SimpleCursorRingSaved.useClassColor` directly in `InitializeControls` and in the color picker `OnClick` callback (`Settings.lua:67-68, 132-138`).
**Why it's wrong:** Two modules write/read the same global table without a defined ownership boundary. If logic for reading saved state ever diverges or defaults change, Settings.lua can operate on stale or malformed data.
**Do this instead:** Add getter functions to the `SimpleCursorRing` API in `Core.lua` (e.g., `SimpleCursorRing.GetSettings()`) so Settings.lua never reads `SimpleCursorRingSaved` directly.

## Error Handling

**Strategy:** No explicit error handling present. The addon relies on WoW's default Lua error dialog for unhandled errors.

**Patterns:**
- `UpdateRingSize` clamps input via `math.max`/`math.min` to avoid invalid sizes (`Core.lua:37`)
- `UpdateRingColor` guards against missing class color data with a nil check on `classColor` (`Core.lua:49`)
- No `pcall`/`xpcall` wrappers used anywhere

## Cross-Cutting Concerns

**Logging:** None — no debug or informational output to chat or console.
**Validation:** Input clamping only (`UpdateRingSize`). No type validation on color values.
**Authentication:** Not applicable — client-side addon with no network calls.

---

*Architecture analysis: 2026-06-17*
