# External Integrations

**Analysis Date:** 2026-06-17

## APIs & External Services

**World of Warcraft Client API:**
- WoW Addon API (Interface 120007) — the only "external" surface this addon integrates with. All runtime integration is via the WoW client's embedded API. Key subsystems used:
  - Frame system: `CreateFrame`, `UIParent`, frame strata/level APIs (`SimpleCursorRing/Core.lua`)
  - Cursor: `GetCursorPosition`, `UIParent:GetEffectiveScale()` (`SimpleCursorRing/Core.lua`)
  - Class colors: `UnitClass("player")`, `RAID_CLASS_COLORS`, `CUSTOM_CLASS_COLORS` (`SimpleCursorRing/Core.lua`)
  - Color picker: `ColorPickerFrame:SetupColorPickerAndShow`, `GetColorRGB`, `GetColorAlpha` (`SimpleCursorRing/Settings.lua`)
  - Interface Options: `Settings.RegisterCanvasLayoutCategory`, `Settings.RegisterAddOnCategory`, `Settings.OpenToCategory` (`SimpleCursorRing/Settings.lua`)
  - Slash commands: `SlashCmdList`, `SLASH_SIMPLECURSORRING1/2` (`SimpleCursorRing/Settings.lua`)
  - SDK/Client: WoW client (no separate SDK package)
  - Auth: Not applicable

## Data Storage

**Databases:**
- None — no external database

**SavedVariables (local persistence):**
- WoW SavedVariables mechanism — `SimpleCursorRingSaved` is written/read from the WoW client's per-character or per-account saved variables file on disk. Declared in `SimpleCursorRing/SimpleCursorRing.toc` line 6. Managed in `SimpleCursorRing/Core.lua` (`InitializeSavedVariables`, `ApplySavedSettings`, `UpdateRingSize`, `UpdateRingColor`, `SetUseClassColor`).

**File Storage:**
- Texture: `SimpleCursorRing/Textures/Default.tga` — static ring texture bundled with the addon, referenced in `SimpleCursorRing/Core.lua` via `Interface\\AddOns\\SimpleCursorRing\\Textures\\Default`.

**Caching:**
- None

## Authentication & Identity

**Auth Provider:**
- Not applicable — WoW addons run inside the authenticated game client; no separate auth is implemented.

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- None — no logging framework. Errors surface via the WoW client's built-in Lua error dialog.

## CI/CD & Deployment

**Hosting:**
- GitHub Releases — release artifacts are uploaded as zip assets to the GitHub Release that triggered the workflow.

**CI Pipeline:**
- GitHub Actions — `.github/workflows/release.yml`
  - Trigger: GitHub Release creation (`on: release: types: [created]`)
  - Steps: checkout → `zip -r SimpleCursorRing-<tag>.zip SimpleCursorRing/` → upload via `softprops/action-gh-release@v2`
  - Runner: `ubuntu-latest`
  - Release type set to `prerelease: true` by default

## Environment Configuration

**Required env vars:**
- None for the addon itself.
- CI uses `GITHUB_TOKEN` (automatically provided by GitHub Actions) for the release upload via `softprops/action-gh-release@v2`.

**Secrets location:**
- No project-managed secrets. GitHub Actions built-in token is used implicitly.

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- None — the addon does not make any network requests. All API calls are local to the WoW client process.

---

*Integration audit: 2026-06-17*
