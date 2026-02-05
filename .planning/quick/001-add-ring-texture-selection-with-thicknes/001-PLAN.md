---
quick: 001-add-ring-texture-selection-with-thicknes
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - SimpleCursorRing/Textures/RingThin.tga
  - SimpleCursorRing/Textures/RingMedium.tga
  - SimpleCursorRing/Textures/RingThick.tga
  - SimpleCursorRing/Core.lua
  - SimpleCursorRing/Settings.lua
autonomous: true

must_haves:
  truths:
    - "User can select different ring textures from a dropdown"
    - "Selected texture persists across sessions"
    - "Ring displays with chosen texture thickness"
  artifacts:
    - path: "SimpleCursorRing/Core.lua"
      provides: "Texture switching function (SetTexture)"
      exports: ["SetTexture"]
    - path: "SimpleCursorRing/Settings.lua"
      provides: "Texture dropdown control"
      contains: "textureDropdown"
    - path: "SimpleCursorRing/Textures/"
      provides: "Multiple ring textures with varying thickness"
  key_links:
    - from: "Settings.lua dropdown"
      to: "Core.lua SetTexture"
      via: "SimpleCursorRing.SetTexture(key)"
      pattern: "SimpleCursorRing\\.SetTexture"
---

<objective>
Add ring texture selection with thickness options to SimpleCursorRing.

Purpose: Allow users to choose between thin, medium, and thick ring styles, including an EnhanceQoL-compatible thick option for users who prefer that visual style.

Output: Working dropdown in settings panel that switches ring texture, with 3 texture variants stored and persisted.
</objective>

<execution_context>
@/home/sntanavaras/.claude/get-shit-done/workflows/execute-plan.md
@/home/sntanavaras/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@SimpleCursorRing/Core.lua
@SimpleCursorRing/Settings.lua
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create texture variants and add texture switching to Core.lua</name>
  <files>
    SimpleCursorRing/Textures/RingThin.tga
    SimpleCursorRing/Textures/RingMedium.tga
    SimpleCursorRing/Textures/RingThick.tga
    SimpleCursorRing/Core.lua
  </files>
  <action>
1. Create 3 ring texture TGA files (64x64, white ring on transparent background):
   - RingThin.tga: 2px stroke width (thinner than current)
   - RingMedium.tga: 4px stroke width (same as current Ring.tga)
   - RingThick.tga: 8px stroke width (EnhanceQoL-style thick)

   Use ImageMagick to generate:
   ```bash
   # Thin (2px stroke)
   convert -size 64x64 xc:transparent -fill none -stroke white -strokewidth 2 -draw "circle 32,32 32,4" RingThin.tga

   # Medium (4px stroke)
   convert -size 64x64 xc:transparent -fill none -stroke white -strokewidth 4 -draw "circle 32,32 32,6" RingMedium.tga

   # Thick (8px stroke)
   convert -size 64x64 xc:transparent -fill none -stroke white -strokewidth 8 -draw "circle 32,32 32,10" RingThick.tga
   ```

2. In Core.lua, add texture configuration table after defaults:
   ```lua
   local textureOptions = {
       thin = "Interface\\AddOns\\SimpleCursorRing\\Textures\\RingThin",
       medium = "Interface\\AddOns\\SimpleCursorRing\\Textures\\RingMedium",
       thick = "Interface\\AddOns\\SimpleCursorRing\\Textures\\RingThick",
   }
   ```

3. Add `texture = "medium"` to defaults table (medium = current behavior)

4. Create SetTexture function:
   ```lua
   local SetTexture
   SetTexture = function(textureKey)
       if textureOptions[textureKey] then
           SimpleCursorRingSaved.texture = textureKey
           ringTexture:SetTexture(textureOptions[textureKey])
       end
   end
   ```

5. Update initial texture setup (line 21) to use textureOptions.medium instead of hardcoded path

6. Update ApplySavedSettings to call SetTexture:
   ```lua
   SetTexture(SimpleCursorRingSaved.texture)
   ```

7. Expose SetTexture globally:
   ```lua
   SimpleCursorRing.SetTexture = SetTexture
   SimpleCursorRing.textureOptions = textureOptions  -- for dropdown labels
   ```
  </action>
  <verify>
    - All 3 TGA files exist in SimpleCursorRing/Textures/
    - Core.lua contains textureOptions table
    - Core.lua contains SetTexture function
    - SimpleCursorRing.SetTexture is exposed
  </verify>
  <done>
    - 3 ring texture files created with varying thickness
    - Core.lua exposes SetTexture(key) function
    - defaults.texture = "medium" set
    - ApplySavedSettings calls SetTexture
  </done>
</task>

<task type="auto">
  <name>Task 2: Add texture dropdown to Settings.lua</name>
  <files>
    SimpleCursorRing/Settings.lua
  </files>
  <action>
1. Add texture dropdown after the class color checkbox section (around line 127).

2. Create dropdown label:
   ```lua
   local textureLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
   textureLabel:SetPoint("TOPLEFT", classColorCheckbox, "BOTTOMLEFT", 0, -16)
   textureLabel:SetText("Ring Style")
   ```

3. Create dropdown using WoW's UIDropDownMenu:
   ```lua
   local textureDropdown = CreateFrame("Frame", "SimpleCursorRingTextureDropdown", panel, "UIDropDownMenuTemplate")
   textureDropdown:SetPoint("LEFT", textureLabel, "RIGHT", -8, -2)
   UIDropDownMenu_SetWidth(textureDropdown, 120)
   ```

4. Define dropdown options with display names:
   ```lua
   local textureLabels = {
       thin = "Thin",
       medium = "Medium",
       thick = "Thick (Bold)",
   }
   local textureOrder = {"thin", "medium", "thick"}
   ```

5. Create dropdown initialization function:
   ```lua
   local function TextureDropdown_Initialize(self, level)
       for _, key in ipairs(textureOrder) do
           local info = UIDropDownMenu_CreateInfo()
           info.text = textureLabels[key]
           info.value = key
           info.func = function(self)
               SimpleCursorRing.SetTexture(self.value)
               UIDropDownMenu_SetText(textureDropdown, textureLabels[self.value])
               CloseDropDownMenus()
           end
           info.checked = (SimpleCursorRingSaved.texture == key)
           UIDropDownMenu_AddButton(info, level)
       end
   end
   UIDropDownMenu_Initialize(textureDropdown, TextureDropdown_Initialize)
   ```

6. In InitializeControls(), add texture dropdown initialization:
   ```lua
   -- Texture dropdown
   UIDropDownMenu_SetText(textureDropdown, textureLabels[SimpleCursorRingSaved.texture] or "Medium")
   ```

7. Store reference for potential future use:
   ```lua
   panel.textureDropdown = textureDropdown
   ```
  </action>
  <verify>
    - Settings.lua contains textureDropdown frame creation
    - Dropdown appears below class color checkbox in settings panel
    - `/scr` opens settings and shows dropdown with 3 options
  </verify>
  <done>
    - Texture dropdown added to settings panel
    - Dropdown shows Thin/Medium/Thick options
    - Selection calls SimpleCursorRing.SetTexture()
    - Current selection persists and displays on panel open
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Ring texture selection with 3 thickness options (Thin, Medium, Thick)</what-built>
  <how-to-verify>
    1. Load WoW and enter game
    2. Type `/scr` to open settings panel
    3. Verify dropdown labeled "Ring Style" appears below "Use Class Color"
    4. Select each option (Thin, Medium, Thick) and observe ring thickness change
    5. Confirm "Thick (Bold)" option provides a visibly thicker ring similar to EnhanceQoL
    6. Reload UI (`/reload`) and verify selected texture persists
  </how-to-verify>
  <resume-signal>Type "approved" or describe any issues</resume-signal>
</task>

</tasks>

<verification>
1. File existence: `ls SimpleCursorRing/Textures/Ring*.tga` shows 4 files (original + 3 new)
2. Code integration: `grep -n "SetTexture" SimpleCursorRing/Core.lua` shows function
3. Settings integration: `grep -n "textureDropdown" SimpleCursorRing/Settings.lua` shows UI
4. SavedVariables: Check that `texture` key is in defaults
</verification>

<success_criteria>
- [ ] 3 texture files exist with distinct visual thickness
- [ ] SetTexture function in Core.lua switches ring texture
- [ ] Dropdown in Settings.lua allows texture selection
- [ ] Selected texture persists across /reload
- [ ] User can visually distinguish between Thin, Medium, and Thick options
</success_criteria>

<output>
After completion, create `.planning/quick/001-add-ring-texture-selection-with-thicknes/001-SUMMARY.md`
</output>
