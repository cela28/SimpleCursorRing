# Technology Stack

**Analysis Date:** 2026-06-17

## Languages

**Primary:**
- Lua (no specific version pinned) - All addon logic in `SimpleCursorRing/Core.lua` and `SimpleCursorRing/Settings.lua`

**Secondary:**
- None

## Runtime

**Environment:**
- World of Warcraft client (retail) — the WoW game client embeds a sandboxed Lua runtime (LuaJIT-based). Interface API version `120007` (declared in `SimpleCursorRing/SimpleCursorRing.toc`).

**Package Manager:**
- None — this is a WoW addon; no external package manager is used. Files are distributed as a zip archive.
- Lockfile: Not applicable

## Frameworks

**Core:**
- World of Warcraft Addon API — provides `CreateFrame`, `UIParent`, `GetCursorPosition`, `UnitClass`, `RAID_CLASS_COLORS`, `CUSTOM_CLASS_COLORS`, `ColorPickerFrame`, `Settings` (Interface Options), `SlashCmdList` and all UI primitives used throughout `Core.lua` and `Settings.lua`.

**Testing:**
- None detected

**Build/Dev:**
- GitHub Actions (`ubuntu-latest`) — release workflow at `.github/workflows/release.yml` uses `zip` to bundle the addon and uploads it as a GitHub Release asset via `softprops/action-gh-release@v2`.

## Key Dependencies

**Critical:**
- WoW Client Interface API 120007 — the entire addon depends on the retail WoW client's embedded Lua environment. No third-party Lua libraries are used.
- `actions/checkout@v4` — CI checkout step (`.github/workflows/release.yml`)
- `softprops/action-gh-release@v2` — CI release asset upload (`.github/workflows/release.yml`)

**Infrastructure:**
- None beyond the WoW client runtime

## Configuration

**Environment:**
- No `.env` files. Addon configuration is persisted through the WoW `SavedVariables` mechanism: the variable `SimpleCursorRingSaved` is declared in `SimpleCursorRing/SimpleCursorRing.toc` and populated with defaults in `SimpleCursorRing/Core.lua` (`InitializeSavedVariables`).
- Saved keys: `size` (integer, 20–200), `color` (`{r,g,b,a}` table), `useClassColor` (boolean)

**Build:**
- `SimpleCursorRing/SimpleCursorRing.toc` — WoW Table of Contents file; declares interface version, addon metadata, and file load order (`Core.lua`, `Settings.lua`)
- `.github/workflows/release.yml` — CI release packaging

## Platform Requirements

**Development:**
- No build toolchain required; plain text Lua files edited directly.
- A World of Warcraft retail installation is required for in-game testing.

**Production:**
- WoW retail client (Interface 120007+)
- Addon distributed as `SimpleCursorRing-<tag>.zip` containing the `SimpleCursorRing/` directory, uploaded automatically on GitHub Release creation.

---

*Stack analysis: 2026-06-17*
