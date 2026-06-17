# Codebase Structure

**Analysis Date:** 2026-06-17

## Directory Layout

```
SimpleCursorRing/                  # Repo root
├── .claude/                       # Claude Code project config
│   └── settings.json              # Claude permissions/settings
├── .github/
│   └── workflows/
│       └── release.yml            # GitHub Actions: zip and upload release asset on tag
├── .planning/
│   └── codebase/                  # GSD codebase analysis documents
├── SimpleCursorRing/              # Addon deliverable directory (what gets zipped for release)
│   ├── Core.lua                   # Core logic: ring frame, cursor tracking, state
│   ├── Settings.lua               # Settings UI: panel, controls, slash commands
│   ├── SimpleCursorRing.toc       # WoW addon manifest (Interface version, load order, SavedVariables)
│   └── Textures/
│       └── Default.tga            # Ring texture asset (43 KB, TGA format)
├── .gitignore
└── README.md
```

## Directory Purposes

**`SimpleCursorRing/` (addon directory):**
- Purpose: The complete, self-contained WoW addon. This entire directory is what WoW loads and what gets zipped for distribution.
- Contains: `.toc` manifest, all `.lua` source files, and the `Textures/` subdirectory
- Key files: `SimpleCursorRing.toc`, `Core.lua`, `Settings.lua`

**`SimpleCursorRing/Textures/`:**
- Purpose: Addon texture assets referenced by the Lua code
- Contains: `.tga` texture files loaded via WoW's `SetTexture` API
- Key files: `Default.tga` — the ring graphic rendered around the cursor

**`.github/workflows/`:**
- Purpose: CI/CD automation
- Contains: `release.yml` — triggered on GitHub Release creation; zips `SimpleCursorRing/` directory and uploads as release asset

**`.claude/`:**
- Purpose: Claude Code project configuration
- Contains: `settings.json`

**`.planning/codebase/`:**
- Purpose: GSD codebase analysis documents (auto-generated, not committed to main)
- Generated: Yes
- Committed: No (do not merge to main per project conventions)

## Key File Locations

**Entry Points:**
- `SimpleCursorRing/Core.lua`: Addon core — loaded first per `.toc`; registers `ADDON_LOADED` event, creates ring frame, exposes global API
- `SimpleCursorRing/Settings.lua`: Settings layer — loaded second; registers `PLAYER_LOGIN` event, builds UI panel

**Configuration:**
- `SimpleCursorRing/SimpleCursorRing.toc`: WoW addon manifest — sets Interface version (120007), declares `SimpleCursorRingSaved` as a SavedVariable, defines file load order
- `.github/workflows/release.yml`: Release pipeline configuration

**Core Logic:**
- `SimpleCursorRing/Core.lua`: All runtime logic — `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `OnUpdate` cursor tracking, SavedVariables initialization

**Assets:**
- `SimpleCursorRing/Textures/Default.tga`: Ring texture, referenced in code as `"Interface\\AddOns\\SimpleCursorRing\\Textures\\Default"`

## Naming Conventions

**Files:**
- Lua files use PascalCase: `Core.lua`, `Settings.lua`
- Texture files use PascalCase: `Default.tga`
- `.toc` file matches the addon directory name exactly: `SimpleCursorRing.toc`

**Directories:**
- Addon directory matches the addon name exactly: `SimpleCursorRing/` — WoW requires this
- Subdirectories use PascalCase: `Textures/`

**Lua Identifiers:**
- Global namespace table: `SimpleCursorRing` (PascalCase, matches addon name)
- SavedVariables global: `SimpleCursorRingSaved` (PascalCase + `Saved` suffix)
- Local functions: camelCase — `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`, `InitializeSavedVariables`, `ApplySavedSettings`, `InitializeControls`
- Local frame variables: camelCase — `ringFrame`, `ringTexture`, `eventFrame`, `sizeSlider`, `colorSwatch`

## Where to Add New Code

**New ring behavior / visual effect:**
- Primary code: `SimpleCursorRing/Core.lua`
- Expose via `SimpleCursorRing` global table if Settings UI needs to call it
- Persist new setting in `SimpleCursorRingSaved` with a default in the `defaults` table (Core.lua:7-11)

**New UI control in settings panel:**
- Implementation: `SimpleCursorRing/Settings.lua`
- Read initial value from `SimpleCursorRingSaved` inside `InitializeControls()` (Settings.lua:130-149)
- Call the appropriate `SimpleCursorRing.*` function on user interaction

**New texture variant:**
- Asset: `SimpleCursorRing/Textures/NewName.tga`
- Reference in code as: `"Interface\\AddOns\\SimpleCursorRing\\Textures\\NewName"`

**New slash command:**
- Implementation: `SimpleCursorRing/Settings.lua` inside the `PLAYER_LOGIN` handler (Settings.lua:169-174)
- Pattern: `SLASH_SIMPLECURSORRING{N} = "/command"` then `SlashCmdList["SIMPLECURSORRING"]`

## Special Directories

**`SimpleCursorRing/` (addon deliverable):**
- Purpose: The directory WoW installs into `Interface/AddOns/SimpleCursorRing/`
- Generated: No (hand-authored source)
- Committed: Yes — this is the primary source of truth

**`.planning/codebase/`:**
- Purpose: Auto-generated architecture analysis documents
- Generated: Yes (by GSD map-codebase)
- Committed: No (per `.claude/` and planning conventions — do not merge to main)

---

*Structure analysis: 2026-06-17*
