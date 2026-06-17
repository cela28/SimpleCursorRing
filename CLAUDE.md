<!-- GSD:project-start source:PROJECT.md -->
## Project

**SimpleCursorRing**

A World of Warcraft addon that displays a customizable ring around the mouse cursor. It helps players track their cursor position during gameplay, with settings for ring size, color, and class-based coloring.

**Core Value:** The cursor ring must render at the correct position every frame with zero perceptible lag — if the ring doesn't follow the cursor smoothly, nothing else matters.

### Constraints

- **Runtime**: WoW client sandboxed Lua (LuaJIT-based) — no external libraries, no filesystem, no network
- **Performance**: OnUpdate runs every client frame — must stay lightweight
- **API**: Must target retail WoW Interface API (currently 120007)
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- Lua (no specific version pinned) - All addon logic in `SimpleCursorRing/Core.lua` and `SimpleCursorRing/Settings.lua`
- None
## Runtime
- World of Warcraft client (retail) — the WoW game client embeds a sandboxed Lua runtime (LuaJIT-based). Interface API version `120007` (declared in `SimpleCursorRing/SimpleCursorRing.toc`).
- None — this is a WoW addon; no external package manager is used. Files are distributed as a zip archive.
- Lockfile: Not applicable
## Frameworks
- World of Warcraft Addon API — provides `CreateFrame`, `UIParent`, `GetCursorPosition`, `UnitClass`, `RAID_CLASS_COLORS`, `CUSTOM_CLASS_COLORS`, `ColorPickerFrame`, `Settings` (Interface Options), `SlashCmdList` and all UI primitives used throughout `Core.lua` and `Settings.lua`.
- None detected
- GitHub Actions (`ubuntu-latest`) — release workflow at `.github/workflows/release.yml` uses `zip` to bundle the addon and uploads it as a GitHub Release asset via `softprops/action-gh-release@v2`.
## Key Dependencies
- WoW Client Interface API 120007 — the entire addon depends on the retail WoW client's embedded Lua environment. No third-party Lua libraries are used.
- `actions/checkout@v4` — CI checkout step (`.github/workflows/release.yml`)
- `softprops/action-gh-release@v2` — CI release asset upload (`.github/workflows/release.yml`)
- None beyond the WoW client runtime
## Configuration
- No `.env` files. Addon configuration is persisted through the WoW `SavedVariables` mechanism: the variable `SimpleCursorRingSaved` is declared in `SimpleCursorRing/SimpleCursorRing.toc` and populated with defaults in `SimpleCursorRing/Core.lua` (`InitializeSavedVariables`).
- Saved keys: `size` (integer, 20–200), `color` (`{r,g,b,a}` table), `useClassColor` (boolean)
- `SimpleCursorRing/SimpleCursorRing.toc` — WoW Table of Contents file; declares interface version, addon metadata, and file load order (`Core.lua`, `Settings.lua`)
- `.github/workflows/release.yml` — CI release packaging
## Platform Requirements
- No build toolchain required; plain text Lua files edited directly.
- A World of Warcraft retail installation is required for in-game testing.
- WoW retail client (Interface 120007+)
- Addon distributed as `SimpleCursorRing-<tag>.zip` containing the `SimpleCursorRing/` directory, uploaded automatically on GitHub Release creation.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Naming Patterns
- PascalCase for Lua source files: `Core.lua`, `Settings.lua`
- PascalCase for addon directory: `SimpleCursorRing/`
- Descriptive suffix-free names that reflect module role
- PascalCase for module-level / forward-declared functions exposed via global namespace: `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `InitializeSavedVariables`, `ApplySavedSettings`, `InitializeControls`
- camelCase is not used; all multi-word function names use PascalCase
- Local helper functions are also PascalCase: `OnUpdate`, `InitializeSavedVariables`
- camelCase for local variables: `addonName`, `ringFrame`, `ringTexture`, `sizeSlider`, `colorSwatch`, `swatchTexture`, `classColorCheckbox`, `loginFrame`, `colorLabel`, `sizeLabel`
- Descriptive names over abbreviations (e.g. `classColorCheckbox` not `cb`)
- Global namespace table uses addon name: `SimpleCursorRing` (table), `SimpleCursorRingSaved` (SavedVariables)
- `local defaults` table in `Core.lua` holds all default settings; keys match `SimpleCursorRingSaved` key names exactly
- Global state exclusively via `SimpleCursorRingSaved` (WoW SavedVariables) and the `SimpleCursorRing` API table
- Slash command globals follow WoW convention: `SLASH_SIMPLECURSORRING1`, `SLASH_SIMPLECURSORRING2`, `SlashCmdList["SIMPLECURSORRING"]`
## Code Style
- No automated formatter detected (no `.editorconfig`, `.luarc`, or similar config files)
- 4-space indentation throughout both files
- Single blank line between logical sections; double blank line not used
- Opening `do` / `then` / `function` on same line as control structure
- No linting tool configured (no `.luacheckrc` or equivalent)
- File-level header block: two-line comment describing addon name and file purpose
- Section comments precede logical groups: `-- Create the main ring frame`, `-- Slider callbacks`
- Inline comments explain non-obvious behavior: `-- Clamp to valid range (20-200 pixels)`, `-- Minimal frame size for reduced processing overhead`
- Requirement tags in comments: `-- Update ring size (RING-02)`, `-- Toggle class color mode (RING-04)` — maps to planning/spec identifiers
## Import Organization
- No `require` / `import` — files loaded in order declared in `.toc`:
- Implicit dependency: `Settings.lua` depends on `Core.lua` having run first
## Error Handling
- No `pcall`/`xpcall` error boundaries — errors surface as Lua runtime errors in WoW error frame
- Defensive nil guards used for optional globals: `CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]`
- SavedVariables existence checked before access: `if not SimpleCursorRingSaved then ... end`
- Missing keys filled from defaults table with explicit `nil` check: `if SimpleCursorRingSaved[key] == nil then`
- Table-type defaults deep-copied manually to avoid shared-reference bugs (`Core.lua` lines 77–82)
## Logging
- No debug prints in production code
- Silent failures: if class color lookup fails (`classColor` is nil), vertex color is simply not updated
## Function Design
- Functions accept explicit value parameters: `UpdateRingSize(size)`, `UpdateRingColor(r, g, b, a)`
- Optional parameters use fallback from SavedVariables: `r = r or SimpleCursorRingSaved.color.r`
- Functions are void (no return values); state mutations go directly to `SimpleCursorRingSaved` and WoW API calls
## Module Design
- Module API exposed via a single global table: `SimpleCursorRing = SimpleCursorRing or {}` with explicit assignment of each public function
- `Core.lua` lines 107–110 define the public surface: `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`
- All other functions remain file-local (`local function`)
## Event-Driven Initialization Pattern
- Dedicated `CreateFrame("Frame")` event listeners for lifecycle events
- `Core.lua`: listens on `ADDON_LOADED` to initialize SavedVariables and apply settings, then unregisters
- `Settings.lua`: listens on `PLAYER_LOGIN` to initialize UI controls and register settings panel, then unregisters
- Anonymous handler functions inline on `SetScript("OnEvent", function(self, event, ...) ... end)`
- Always self-unregister after first use: `self:UnregisterEvent(event)`
## Frame Creation Pattern
- Frames created at module scope (file-level locals), not inside functions
- Explicit anchoring via `SetPoint` with named anchor strings
- UI controls reference sibling frames for relative positioning: `SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -24)`
- Texture references stored on parent frame: `ringFrame.texture = ringTexture`, `panel.colorSwatch = colorSwatch`
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## System Overview
```text
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
- Two-file addon split: `Core.lua` owns all state and logic; `Settings.lua` owns all UI
- Communication from `Settings.lua` to `Core.lua` is via the `SimpleCursorRing` global namespace table
- State is persisted entirely through the WoW `SavedVariables` mechanism (`SimpleCursorRingSaved`)
- Cursor tracking uses the WoW `OnUpdate` script (runs every client frame) rather than events
- No third-party libraries or dependencies; pure WoW Lua API
## Layers
- Purpose: Frame creation, cursor tracking, state management, ring appearance
- Location: `SimpleCursorRing/Core.lua`
- Contains: Ring frame and texture setup, `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `InitializeSavedVariables`, `ApplySavedSettings`, `OnUpdate`
- Depends on: WoW global APIs (`CreateFrame`, `GetCursorPosition`, `UnitClass`, `RAID_CLASS_COLORS`), `SimpleCursorRingSaved`
- Used by: Settings.lua (via `SimpleCursorRing` global), WoW client (via registered frame scripts)
- Purpose: User-facing controls for customizing the ring
- Location: `SimpleCursorRing/Settings.lua`
- Contains: Settings panel frame, size slider, color swatch, class color checkbox, slash command registration, `InitializeControls`
- Depends on: `SimpleCursorRing` global (set by Core.lua), `SimpleCursorRingSaved`, WoW `Settings` API, `ColorPickerFrame`
- Used by: WoW Interface Options UI, slash command handler
- Purpose: Cross-session storage of user preferences
- Location: WoW-managed `SimpleCursorRingSaved` global (declared in `SimpleCursorRing/SimpleCursorRing.toc`)
- Contains: `size` (number), `color` (table: r/g/b/a), `useClassColor` (boolean)
- Depends on: WoW SavedVariables system
- Used by: Both Core.lua and Settings.lua read/write directly
- Purpose: Ring graphic
- Location: `SimpleCursorRing/Textures/Default.tga`
- Referenced as: `"Interface\\AddOns\\SimpleCursorRing\\Textures\\Default"` in `Core.lua:23`
## Data Flow
### Addon Initialization
### Per-Frame Cursor Tracking
### User Changes a Setting
- All persistent state lives in `SimpleCursorRingSaved` (WoW-managed global)
- No in-memory state diverges from `SimpleCursorRingSaved` after initialization
- `Core.lua` is the single writer for `SimpleCursorRingSaved`; `Settings.lua` reads it directly for UI initialization
## Key Abstractions
- Purpose: Public API bridge between Core and Settings modules
- Examples: `SimpleCursorRing/Core.lua:107-110`
- Pattern: Module pattern via table — `SimpleCursorRing = SimpleCursorRing or {}` then assign functions
- Purpose: The visual element — an invisible 1×1 frame with a texture sized to user preference
- Examples: `SimpleCursorRing/Core.lua:14-29`
- Pattern: Parent frame handles positioning; child texture handles rendering
## Entry Points
- Location: `SimpleCursorRing/Core.lua:96-104`
- Triggers: WoW client fires when addon files finish loading
- Responsibilities: SavedVariables initialization, applying saved settings to ring
- Location: `SimpleCursorRing/Settings.lua:153-175`
- Triggers: WoW client fires after player character data is available
- Responsibilities: Populating UI controls from saved settings, registering settings panel, binding slash commands
- Location: `SimpleCursorRing/Core.lua:113-121`
- Triggers: Every rendered client frame
- Responsibilities: Reading cursor position and repositioning ring frame
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
## Error Handling
- `UpdateRingSize` clamps input via `math.max`/`math.min` to avoid invalid sizes (`Core.lua:37`)
- `UpdateRingColor` guards against missing class color data with a nil check on `classColor` (`Core.lua:49`)
- No `pcall`/`xpcall` wrappers used anywhere
## Cross-Cutting Concerns
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
