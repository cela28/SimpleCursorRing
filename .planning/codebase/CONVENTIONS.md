# Coding Conventions

**Analysis Date:** 2026-06-17

## Naming Patterns

**Files:**
- PascalCase for Lua source files: `Core.lua`, `Settings.lua`
- PascalCase for addon directory: `SimpleCursorRing/`
- Descriptive suffix-free names that reflect module role

**Functions:**
- PascalCase for module-level / forward-declared functions exposed via global namespace: `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `InitializeSavedVariables`, `ApplySavedSettings`, `InitializeControls`
- camelCase is not used; all multi-word function names use PascalCase
- Local helper functions are also PascalCase: `OnUpdate`, `InitializeSavedVariables`

**Variables:**
- camelCase for local variables: `addonName`, `ringFrame`, `ringTexture`, `sizeSlider`, `colorSwatch`, `swatchTexture`, `classColorCheckbox`, `loginFrame`, `colorLabel`, `sizeLabel`
- Descriptive names over abbreviations (e.g. `classColorCheckbox` not `cb`)
- Global namespace table uses addon name: `SimpleCursorRing` (table), `SimpleCursorRingSaved` (SavedVariables)

**Constants / Defaults:**
- `local defaults` table in `Core.lua` holds all default settings; keys match `SimpleCursorRingSaved` key names exactly

**Globals:**
- Global state exclusively via `SimpleCursorRingSaved` (WoW SavedVariables) and the `SimpleCursorRing` API table
- Slash command globals follow WoW convention: `SLASH_SIMPLECURSORRING1`, `SLASH_SIMPLECURSORRING2`, `SlashCmdList["SIMPLECURSORRING"]`

## Code Style

**Formatting:**
- No automated formatter detected (no `.editorconfig`, `.luarc`, or similar config files)
- 4-space indentation throughout both files
- Single blank line between logical sections; double blank line not used
- Opening `do` / `then` / `function` on same line as control structure

**Linting:**
- No linting tool configured (no `.luacheckrc` or equivalent)

**Comments:**
- File-level header block: two-line comment describing addon name and file purpose
  - Example: `-- SimpleCursorRing: Displays a customizable ring around the mouse cursor`
  - Example: `-- Core.lua - Main addon logic: frame creation, cursor tracking, and settings`
- Section comments precede logical groups: `-- Create the main ring frame`, `-- Slider callbacks`
- Inline comments explain non-obvious behavior: `-- Clamp to valid range (20-200 pixels)`, `-- Minimal frame size for reduced processing overhead`
- Requirement tags in comments: `-- Update ring size (RING-02)`, `-- Toggle class color mode (RING-04)` — maps to planning/spec identifiers

## Import Organization

**WoW Addon Loading:**
- No `require` / `import` — files loaded in order declared in `.toc`:
  1. `Core.lua` (creates `SimpleCursorRing` global table with API functions)
  2. `Settings.lua` (consumes `SimpleCursorRing.*` API and `SimpleCursorRingSaved`)
- Implicit dependency: `Settings.lua` depends on `Core.lua` having run first

## Error Handling

**Patterns:**
- No `pcall`/`xpcall` error boundaries — errors surface as Lua runtime errors in WoW error frame
- Defensive nil guards used for optional globals: `CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]`
- SavedVariables existence checked before access: `if not SimpleCursorRingSaved then ... end`
- Missing keys filled from defaults table with explicit `nil` check: `if SimpleCursorRingSaved[key] == nil then`
- Table-type defaults deep-copied manually to avoid shared-reference bugs (`Core.lua` lines 77–82)

## Logging

**Framework:** None — no logging library used

**Patterns:**
- No debug prints in production code
- Silent failures: if class color lookup fails (`classColor` is nil), vertex color is simply not updated

## Function Design

**Size:** Functions are small and single-purpose (10–20 lines each)

**Parameters:**
- Functions accept explicit value parameters: `UpdateRingSize(size)`, `UpdateRingColor(r, g, b, a)`
- Optional parameters use fallback from SavedVariables: `r = r or SimpleCursorRingSaved.color.r`

**Return Values:**
- Functions are void (no return values); state mutations go directly to `SimpleCursorRingSaved` and WoW API calls

## Module Design

**Exports:**
- Module API exposed via a single global table: `SimpleCursorRing = SimpleCursorRing or {}` with explicit assignment of each public function
- `Core.lua` lines 107–110 define the public surface: `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`
- All other functions remain file-local (`local function`)

**Barrel Files:** Not applicable — WoW addon uses `.toc` for load ordering

## Event-Driven Initialization Pattern

**Pattern:**
- Dedicated `CreateFrame("Frame")` event listeners for lifecycle events
- `Core.lua`: listens on `ADDON_LOADED` to initialize SavedVariables and apply settings, then unregisters
- `Settings.lua`: listens on `PLAYER_LOGIN` to initialize UI controls and register settings panel, then unregisters
- Anonymous handler functions inline on `SetScript("OnEvent", function(self, event, ...) ... end)`
- Always self-unregister after first use: `self:UnregisterEvent(event)`

## Frame Creation Pattern

**Pattern:**
- Frames created at module scope (file-level locals), not inside functions
- Explicit anchoring via `SetPoint` with named anchor strings
- UI controls reference sibling frames for relative positioning: `SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -24)`
- Texture references stored on parent frame: `ringFrame.texture = ringTexture`, `panel.colorSwatch = colorSwatch`

---

*Convention analysis: 2026-06-17*
