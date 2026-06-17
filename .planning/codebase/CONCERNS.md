# Codebase Concerns

**Analysis Date:** 2026-06-17

## Tech Debt

**Every-frame OnUpdate cursor tracking:**
- Issue: `Core.lua` line 121 runs `OnUpdate` on every single rendered frame with no throttling. The handler calls `GetCursorPosition()`, `GetEffectiveScale()`, and `ClearAllPoints()` + `SetPoint()` unconditionally every frame (~60+ times/second), even when the cursor has not moved.
- Files: `SimpleCursorRing/Core.lua` (lines 113-121)
- Impact: Unnecessary CPU overhead; `ClearAllPoints()` + `SetPoint()` on every frame causes constant anchor recalculation even during stillness. Minor performance drain, but scales poorly if the pattern is copied.
- Fix approach: Cache the previous `x, y` values and skip `ClearAllPoints` / `SetPoint` when position is unchanged. Or use an `elapsed` accumulator to throttle updates to ~30 Hz.

**Global namespace pollution via `SimpleCursorRing` table:**
- Issue: `Core.lua` lines 107-110 expose `UpdateRingSize`, `UpdateRingColor`, and `SetUseClassColor` on the global `SimpleCursorRing` table. Any other addon can call or overwrite these functions.
- Files: `SimpleCursorRing/Core.lua` (lines 107-110)
- Impact: Accidental collision with another addon that defines `SimpleCursorRing` as a global. The guard `SimpleCursorRing = SimpleCursorRing or {}` (line 107) partially mitigates this but does not protect individual function keys.
- Fix approach: Use a module-local table and pass it to `Settings.lua` via the addon's `OnLoad` callback, or scope communications through the addon's event system rather than globals.

**`SimpleCursorRingSaved` accessed before nil-guard in `UpdateRingColor`:**
- Issue: `UpdateRingColor` (lines 43-59) reads `SimpleCursorRingSaved.useClassColor` and `SimpleCursorRingSaved.color.*` without checking if `SimpleCursorRingSaved` is non-nil. The function is exposed globally (line 109), so any caller — including another addon — could invoke it before `ADDON_LOADED` fires and `InitializeSavedVariables` has run.
- Files: `SimpleCursorRing/Core.lua` (lines 43-59)
- Impact: Nil-dereference Lua error if `UpdateRingColor` is called before `ADDON_LOADED`.
- Fix approach: Add a guard at the top of `UpdateRingColor`: `if not SimpleCursorRingSaved then return end`.

**Shallow defaults copy does not deep-copy nested tables for new keys:**
- Issue: `InitializeSavedVariables` (lines 69-87) iterates `defaults` and deep-copies tables one level deep. If the `color` sub-table gains new keys in a future version (e.g., `hdr`), existing SavedVariables will have a `color` table present but missing the new key — the `if SimpleCursorRingSaved[key] == nil` guard skips the entire `color` table because it already exists.
- Files: `SimpleCursorRing/Core.lua` (lines 69-87)
- Impact: Future settings additions to nested tables will silently not be applied to existing user profiles without a manual migration step.
- Fix approach: Recursively merge defaults into saved values rather than skipping existing tables entirely.

**`Author` field empty in `.toc`:**
- Issue: `SimpleCursorRing.toc` line 4 has `## Author:` with no value.
- Files: `SimpleCursorRing/SimpleCursorRing.toc` (line 4)
- Impact: No functional impact, but CurseForge / WoWInterface metadata parsing and addon listing attribution will be blank.
- Fix approach: Add the author name.

## Known Bugs

**`swatchFunc` and `opacityFunc` are duplicates:**
- Symptoms: The color picker in `Settings.lua` registers both `swatchFunc` (line 80-85) and `opacityFunc` (line 87-92) with identical bodies. In the WoW 10.x `ColorPickerFrame` API, `opacityFunc` is called when the opacity slider changes; having the same callback for both is intentional in simple addons, but the duplication is a maintenance hazard.
- Files: `SimpleCursorRing/Settings.lua` (lines 80-92)
- Trigger: Opening the color picker and adjusting opacity.
- Workaround: None needed functionally, but a single shared local function should be assigned to both keys to avoid divergence.

**`cancelFunc` does not restore `SimpleCursorRingSaved.color`:**
- Symptoms: When the user cancels the color picker, `cancelFunc` calls `UpdateRingColor(originalR, originalG, originalB, originalA)` which correctly restores the visual, but `UpdateRingColor` always writes back `SimpleCursorRingSaved.color = {r, g, b, a}` (line 57). The cancel therefore correctly restores the color but also redundantly rewrites the save data — if another code path had already written an intermediate color to `SimpleCursorRingSaved`, cancel will overwrite it with the pre-open snapshot. This is subtle and currently harmless but becomes a bug if save logic is extended.
- Files: `SimpleCursorRing/Settings.lua` (lines 94-97), `SimpleCursorRing/Core.lua` (line 57)
- Trigger: Opening the color picker, changing the color, then cancelling.
- Workaround: None needed currently.

## Security Considerations

**No input validation on slash command arguments:**
- Risk: `SlashCmdList["SIMPLECURSORRING"]` (Settings.lua line 172-174) ignores `msg` entirely and just opens the settings panel. This is safe as-is, but if future phases add slash command argument parsing (e.g., `/scr size 100`), passing unsanitised user input directly to `UpdateRingSize` or `UpdateRingColor` would expose numeric injection.
- Files: `SimpleCursorRing/Settings.lua` (lines 172-174)
- Current mitigation: No argument parsing exists today.
- Recommendations: If slash argument parsing is added, validate with `tonumber()` and apply the existing min/max clamp in `UpdateRingSize`.

## Performance Bottlenecks

**Unconditional `ClearAllPoints` + `SetPoint` every frame:**
- Problem: `OnUpdate` runs on every frame and unconditionally clears and resets the frame anchor even when the cursor hasn't moved.
- Files: `SimpleCursorRing/Core.lua` (lines 113-121)
- Cause: No position delta check before calling layout-invalidating API calls.
- Improvement path: Cache last `x, y`; only call `ClearAllPoints` + `SetPoint` when values differ. Example:
  ```lua
  local lastX, lastY
  local function OnUpdate(self)
      local x, y = GetCursorPosition()
      if x == lastX and y == lastY then return end
      lastX, lastY = x, y
      local scale = UIParent:GetEffectiveScale()
      self:ClearAllPoints()
      self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
  end
  ```

## Fragile Areas

**Settings panel registered in `PLAYER_LOGIN` depends on `Core.lua` globals being set first:**
- Files: `SimpleCursorRing/Settings.lua` (lines 153-175), `SimpleCursorRing/Core.lua` (lines 107-110)
- Why fragile: `Settings.lua` calls `SimpleCursorRing.UpdateRingSize` etc. via the global table set in `Core.lua`. If load order ever changes (e.g., `Settings.lua` is listed before `Core.lua` in the `.toc`), the `SimpleCursorRing` global table would be nil when `Settings.lua` runs its top-level code, causing errors on the `CreateFrame` / callback closures that reference it. Currently safe because `Core.lua` is listed first in the `.toc`.
- Safe modification: Keep `Core.lua` first in the `.toc` file at all times. A more robust approach is to use `AceAddon` or a local module reference passed between files.
- Test coverage: No automated tests exist.

**`InitializeControls` called before `SimpleCursorRingSaved` is guaranteed non-nil:**
- Files: `SimpleCursorRing/Settings.lua` (lines 130-149), called at line 159
- Why fragile: `InitializeControls` reads `SimpleCursorRingSaved.size` and `SimpleCursorRingSaved.color` directly. It is called inside the `PLAYER_LOGIN` handler, which fires after `ADDON_LOADED` — so `InitializeSavedVariables` should have already run. However, if `Core.lua` fails to load (e.g., syntax error), `SimpleCursorRingSaved` may be nil and `InitializeControls` will throw a nil-index error.
- Safe modification: Add a nil-guard: `if not SimpleCursorRingSaved then return end` at the top of `InitializeControls`.

## Scaling Limits

**Single texture, no LOD or resolution variants:**
- Current capacity: One 64x64 `.tga` texture at `SimpleCursorRing/Textures/Default.tga`.
- Limit: At sizes near 200px the texture will appear visibly blurry due to upscaling from 64px source.
- Scaling path: Provide a higher-resolution texture (e.g., 256x256) and let WoW's renderer downsample, or add a `Default_HD.tga` variant for HiDPI displays.

## Dependencies at Risk

**`OptionsSliderTemplate` (deprecated in TWW/Retail):**
- Risk: `Settings.lua` line 17 uses `OptionsSliderTemplate` which was deprecated in Dragonflight and may be removed in a future major patch. The addon targets interface `120007` (The War Within).
- Impact: The size slider widget may break or display incorrectly in a future WoW patch.
- Migration plan: Replace with `MinimalSliderWithStepperTemplate` or use `Settings.CreateSlider` via the modern Settings API (already partially used elsewhere in the file with `Settings.RegisterCanvasLayoutCategory`).

**`softprops/action-gh-release@v2` pinned without SHA:**
- Risk: The release workflow pins to `@v2` tag, not a commit SHA. A compromised or force-pushed `v2` tag in that third-party action could execute arbitrary code in CI.
- Impact: Supply chain attack vector in the release pipeline.
- Migration plan: Pin to a specific commit SHA (e.g., `softprops/action-gh-release@v0.1.15` → SHA) and enable Dependabot for GitHub Actions.

## Missing Critical Features

**No hide/disable toggle:**
- Problem: There is no way to temporarily hide the ring without disabling the entire addon. The ring is always shown after load.
- Blocks: Users who want to toggle visibility during gameplay (e.g., for screenshots or specific content) have no option short of `/reload`.
- Suggested fix: Add a `/scr toggle` slash command and a checkbox in the settings panel.

**No per-character vs. account-wide save distinction:**
- Problem: `SimpleCursorRingSaved` is declared as `SavedVariables` (account-wide) in the `.toc`. There is no `SavedVariablesPerCharacter` option.
- Blocks: Users who want different ring colors per character (e.g., matching class color per alt) cannot do so.

## Test Coverage Gaps

**No automated tests of any kind:**
- What's not tested: All logic — cursor tracking, SavedVariables initialization, color/size update functions, settings UI callbacks.
- Files: All of `SimpleCursorRing/Core.lua`, `SimpleCursorRing/Settings.lua`
- Risk: Any refactor could silently break cursor tracking or settings persistence with no regression signal.
- Priority: Medium — the codebase is small, but the absence of even basic smoke tests (e.g., via `WoWUnit` or `busted` with stub WoW globals) means all verification is manual.

---

*Concerns audit: 2026-06-17*
