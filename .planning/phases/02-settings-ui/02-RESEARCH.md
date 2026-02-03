# Phase 02: Settings UI - Research

**Researched:** 2026-02-03
**Domain:** WoW Addon Settings UI (Retail API)
**Confidence:** MEDIUM

## Summary

WoW addon settings panels have undergone significant API changes. The old InterfaceOptions_AddCategory system was replaced by the Settings API in patch 10.0.0 (Dragonflight), with breaking changes continuing through patch 11.0.2. The modern approach uses Settings.RegisterCanvasLayoutCategory for custom UI frames, followed by Settings.RegisterAddOnCategory to place them in the AddOns section. For opening panels programmatically, Settings.OpenToCategory replaces the deprecated InterfaceOptionsFrame_OpenToCategory.

Standard UI controls (sliders, checkboxes, color pickers) are created with CreateFrame using templates like OptionsSliderTemplate and UICheckButtonTemplate. The ColorPickerFrame global provides color selection via callbacks. Live preview is achieved through OnValueChanged scripts with a userInput parameter to distinguish user interaction from programmatic updates.

**Primary recommendation:** Use Settings.RegisterCanvasLayoutCategory with manual frame layout. Create controls with CreateFrame + templates. Store settings in SimpleCursorRingSaved table. Implement live preview via OnValueChanged/OnClick callbacks that directly call SimpleCursorRing.UpdateRingSize/UpdateRingColor/SetUseClassColor.

## Standard Stack

The established libraries/tools for WoW addon settings UI:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Settings API | Retail 10.0+ | Panel registration | Official replacement for deprecated InterfaceOptions_AddCategory |
| CreateFrame | Built-in WoW API | UI widget creation | Native WoW UI framework, no external dependencies |
| ColorPickerFrame | Built-in global | Color selection dialog | Single global instance provided by Blizzard UI |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| OptionsSliderTemplate | Built-in template | Pre-configured slider widget | Standard Blizzard style sliders with labels |
| UICheckButtonTemplate | Built-in template | Pre-configured checkbox | Standard Blizzard style checkboxes |
| FontString | Built-in API | Text labels | Label creation for controls |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Settings Canvas | Settings Vertical Layout | Auto-layout but limited control over placement |
| Built-in templates | Custom frame styling | More work, less consistency with Blizzard UI |
| ColorPickerFrame | Custom RGB sliders | More control but reinvents standard WoW UX |

**Installation:**
```bash
# No installation needed - all APIs are built into WoW client
```

## Architecture Patterns

### Recommended Project Structure
```
SimpleCursorRing/
├── Core.lua              # Ring logic + API functions
├── Settings.lua          # NEW: Settings panel registration + UI
└── SimpleCursorRing.toc  # Load order: Core.lua, Settings.lua
```

### Pattern 1: Settings API Registration (Modern)
**What:** Register a custom frame as an addon settings category in the Settings UI
**When to use:** Retail WoW 10.0.0+ (Dragonflight and later)
**Example:**
```lua
-- Source: Warcraft Wiki Settings API + WebSearch verified patterns
local settingsFrame = CreateFrame("Frame")
settingsFrame.name = "SimpleCursorRing"

-- Create UI controls here (sliders, checkboxes, color picker button)

-- Register with Settings API (Dragonflight 10.0+)
local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "SimpleCursorRing")
Settings.RegisterAddOnCategory(category)

-- Store category reference for programmatic opening
SimpleCursorRing.settingsCategory = category
```

### Pattern 2: Backwards Compatibility Check
**What:** Support both old and new Settings APIs for cross-version compatibility
**When to use:** If supporting both Retail and Classic, or older Retail versions
**Example:**
```lua
-- Source: WebSearch community patterns (WoWInterface forums)
if Settings and Settings.RegisterCanvasLayoutCategory then
    -- Modern approach (Retail 10.0+)
    local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, "SimpleCursorRing")
    Settings.RegisterAddOnCategory(category)
else
    -- Legacy approach (Classic, older Retail)
    InterfaceOptions_AddCategory(settingsFrame)
end
```

### Pattern 3: Slider with Live Preview
**What:** Slider that updates ring immediately as user drags, shows numeric value
**When to use:** Any numeric setting that should preview in real-time
**Example:**
```lua
-- Source: Warcraft Wiki Slider API + PhanxConfig-Slider GitHub
local slider = CreateFrame("Slider", nil, settingsFrame, "OptionsSliderTemplate")
slider:SetPoint("TOPLEFT", 20, -40)
slider:SetMinMaxValues(20, 200)
slider:SetValueStep(1)
slider:SetObeyStepOnDrag(true)
slider:SetValue(SimpleCursorRingSaved.size)

-- Label above slider
local label = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
label:SetText("Ring Size")

-- Value display
local valueText = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
valueText:SetPoint("TOP", slider, "BOTTOM", 0, -4)
valueText:SetText(SimpleCursorRingSaved.size)

-- Live update callback
slider:SetScript("OnValueChanged", function(self, value, userInput)
    value = math.floor(value + 0.5) -- Round to integer
    valueText:SetText(value)
    if userInput then
        -- Only call API on user interaction, not programmatic SetValue
        SimpleCursorRing.UpdateRingSize(value)
    end
end)
```

### Pattern 4: Checkbox Toggle
**What:** Checkbox that toggles a boolean setting with live preview
**When to use:** Any on/off setting
**Example:**
```lua
-- Source: WoWWiki UICheckButtonTemplate examples
local checkbox = CreateFrame("CheckButton", nil, settingsFrame, "UICheckButtonTemplate")
checkbox:SetPoint("TOPLEFT", 20, -120)
checkbox:SetChecked(SimpleCursorRingSaved.useClassColor)

-- Label
local label = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
label:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
label:SetText("Use Class Color")

-- Live update callback
checkbox:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    SimpleCursorRing.SetUseClassColor(checked)
    -- Disable color picker when class color is enabled
    colorPickerButton:SetEnabled(not checked)
end)
```

### Pattern 5: Color Picker Button + Dialog
**What:** Button showing color swatch that opens ColorPickerFrame when clicked
**When to use:** Any RGB/RGBA color setting
**Example:**
```lua
-- Source: WoWWiki Using the ColorPickerFrame
local colorPickerButton = CreateFrame("Button", nil, settingsFrame)
colorPickerButton:SetSize(80, 20)
colorPickerButton:SetPoint("TOPLEFT", 20, -80)

-- Swatch texture showing current color
local swatch = colorPickerButton:CreateTexture(nil, "OVERLAY")
swatch:SetSize(16, 16)
swatch:SetPoint("LEFT", 4, 0)
local color = SimpleCursorRingSaved.color
swatch:SetColorTexture(color.r, color.g, color.b, color.a)

-- Button text
local buttonText = colorPickerButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buttonText:SetPoint("LEFT", swatch, "RIGHT", 4, 0)
buttonText:SetText("Choose Color")

-- Background for button appearance
colorPickerButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
colorPickerButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
colorPickerButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")

-- Label
local label = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
label:SetPoint("BOTTOMLEFT", colorPickerButton, "TOPLEFT", 0, 4)
label:SetText("Ring Color")

-- Color picker callback
local function ColorCallback(restore)
    local newR, newG, newB, newA
    if restore then
        -- User cancelled - restore previous color
        newR, newG, newB, newA = unpack(restore)
    else
        -- User selected new color
        newA = ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha() or 1.0
        newR, newG, newB = ColorPickerFrame:GetColorRGB()
    end
    -- Update swatch
    swatch:SetColorTexture(newR, newG, newB, newA)
    -- Live preview
    SimpleCursorRing.UpdateRingColor(newR, newG, newB, newA)
end

-- Open color picker on click
colorPickerButton:SetScript("OnClick", function(self)
    local color = SimpleCursorRingSaved.color
    ColorPickerFrame.hasOpacity = true
    ColorPickerFrame.opacity = color.a
    ColorPickerFrame.previousValues = {color.r, color.g, color.b, color.a}
    ColorPickerFrame.func = ColorCallback
    ColorPickerFrame.opacityFunc = ColorCallback
    ColorPickerFrame.cancelFunc = ColorCallback
    ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
    ColorPickerFrame:Hide() -- Trigger OnShow handler
    ColorPickerFrame:Show()
end)
```

### Pattern 6: Slash Command Registration
**What:** Register /simplecursorring command to open settings panel
**When to use:** Always - standard WoW addon UX pattern
**Example:**
```lua
-- Source: WoWWiki Creating a slash command
SLASH_SIMPLECURSORRING1 = "/simplecursorring"
SlashCmdList["SIMPLECURSORRING"] = function(msg)
    -- Modern API (10.0+)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(SimpleCursorRing.settingsCategory:GetID())
    -- Legacy fallback
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(SimpleCursorRing.settingsFrame)
    end
end
```

### Pattern 7: Control Disabling (Grayed Out)
**What:** Disable a control visually and functionally
**When to use:** When a control's state depends on another control (e.g., color picker disabled when class color is enabled)
**Example:**
```lua
-- Source: Wowpedia Button:SetEnabled + WebSearch patterns
colorPickerButton:SetEnabled(not SimpleCursorRingSaved.useClassColor)
-- SetEnabled handles both visual (grayed) and functional (unclickable) states
-- For additional visual feedback, can manually adjust alpha:
-- colorPickerButton:SetAlpha(SimpleCursorRingSaved.useClassColor and 0.5 or 1.0)
```

### Anti-Patterns to Avoid
- **Using InterfaceOptions_AddCategory directly:** Deprecated in Retail 10.0+, will break on modern clients
- **Forgetting userInput parameter:** OnValueChanged fires on both user drag AND SetValue() calls, causing feedback loops
- **Multiple ColorPickerFrame instances:** Only one global exists, trying to "create" another fails
- **Hardcoded panel opening without fallbacks:** Settings.OpenToCategory doesn't exist in Classic, needs conditional logic

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Color picker dialog | Custom RGB sliders in panel | ColorPickerFrame global | Single global instance, familiar WoW UX, handles HSV/RGB conversion |
| Slider styling | Custom texture + drag logic | OptionsSliderTemplate | Pre-configured Blizzard style, includes Low/High/Text labels |
| Checkbox appearance | Custom texture toggle | UICheckButtonTemplate | Standard WoW checkbox look, handles checked state visually |
| Panel registration | Custom frame parenting to UIParent | Settings.RegisterCanvasLayoutCategory | Properly integrates with Settings UI, handles navigation |
| Settings persistence | Custom file I/O or communication | SavedVariables in .toc | Automatic per-character storage, loaded before ADDON_LOADED |

**Key insight:** WoW's UI framework provides templates and globals specifically for settings panels. Custom implementations deviate from player expectations and require significantly more code for styling, state management, and event handling.

## Common Pitfalls

### Pitfall 1: Settings.OpenToCategory Only Opens General Panel
**What goes wrong:** Calling Settings.OpenToCategory(categoryName) opens the Settings UI but doesn't navigate to the addon's panel
**Why it happens:** The function signature changed - it now requires a category ID (number), not a name (string)
**How to avoid:** Store the category object returned by RegisterCanvasLayoutCategory and use category:GetID()
**Warning signs:** Settings UI opens but shows "General" or another panel instead of your addon

**Example:**
```lua
-- WRONG: Passing name string
Settings.OpenToCategory("SimpleCursorRing") -- Opens Settings but not your panel

-- CORRECT: Store category and use ID
local category = Settings.RegisterCanvasLayoutCategory(frame, "SimpleCursorRing")
SimpleCursorRing.settingsCategory = category
-- Later:
Settings.OpenToCategory(SimpleCursorRing.settingsCategory:GetID())
```

### Pitfall 2: OnValueChanged Infinite Loop
**What goes wrong:** Slider causes infinite updates, performance tanks, or saved settings flicker
**Why it happens:** OnValueChanged fires when SetValue() is called programmatically, not just user dragging. If your callback calls UpdateRingSize which triggers SetValue elsewhere, it loops.
**How to avoid:** Check the userInput parameter (3rd argument) - only act on true values
**Warning signs:** Slider feels laggy, FPS drops when dragging, or settings revert immediately after change

**Example:**
```lua
-- WRONG: Updates on every value change including programmatic
slider:SetScript("OnValueChanged", function(self, value)
    SimpleCursorRing.UpdateRingSize(value) -- Fires even when loading saved settings
end)

-- CORRECT: Only update on user interaction
slider:SetScript("OnValueChanged", function(self, value, userInput)
    if userInput then
        SimpleCursorRing.UpdateRingSize(value)
    end
end)
```

### Pitfall 3: ColorPickerFrame.opacity vs ColorPickerFrame:GetColorAlpha()
**What goes wrong:** Opacity/alpha value is ignored or returns nil, causing color to lose transparency
**Why it happens:** ColorPickerFrame stores opacity in ColorPickerFrame.opacity during setup, but retrieves it via ColorPickerFrame:GetColorAlpha() method. The property and method are not interchangeable.
**How to avoid:** Set hasOpacity and opacity during setup, read via GetColorAlpha() in callback
**Warning signs:** Alpha channel always returns 1.0 even when user adjusts opacity slider

**Example:**
```lua
-- WRONG: Reading opacity property in callback
ColorPickerFrame.opacity = color.a -- Setup is correct
local newA = ColorPickerFrame.opacity -- WRONG: Returns setup value, not current

-- CORRECT: Use GetColorAlpha() method
ColorPickerFrame.hasOpacity = true
ColorPickerFrame.opacity = color.a -- Initial value
local newA = ColorPickerFrame.hasOpacity and ColorPickerFrame:GetColorAlpha() or 1.0
```

### Pitfall 4: Forgetting Settings.RegisterAddOnCategory
**What goes wrong:** Panel registers but doesn't appear in AddOns section of Settings UI
**Why it happens:** RegisterCanvasLayoutCategory creates a category but doesn't add it to the AddOns list. Must call RegisterAddOnCategory separately.
**How to avoid:** Always call both functions in sequence
**Warning signs:** Panel is created but not findable in Settings UI under AddOns

**Example:**
```lua
-- WRONG: Only registering canvas layout
local category = Settings.RegisterCanvasLayoutCategory(frame, "SimpleCursorRing")
-- Panel exists but not in AddOns section

-- CORRECT: Register as AddOn category
local category = Settings.RegisterCanvasLayoutCategory(frame, "SimpleCursorRing")
Settings.RegisterAddOnCategory(category)
```

### Pitfall 5: Control SetEnabled vs SetAlpha Confusion
**What goes wrong:** Button appears enabled but won't click, or appears clickable but is visually grayed
**Why it happens:** SetEnabled(false) disables clicking but may not visually gray out the control on all elements. SetAlpha only changes appearance, not functionality.
**How to avoid:** Use SetEnabled for functional disabling. Optionally add SetAlpha(0.5) for stronger visual feedback if SetEnabled's graying is too subtle.
**Warning signs:** Disabled controls still highlight on mouseover, or grayed controls are still clickable

**Example:**
```lua
-- WRONG: Only visual, still clickable
colorPickerButton:SetAlpha(0.5)

-- BETTER: Functional disable (may have subtle graying)
colorPickerButton:SetEnabled(false)

-- BEST: Both functional and strong visual feedback
colorPickerButton:SetEnabled(false)
colorPickerButton:SetAlpha(0.5)
```

### Pitfall 6: ADDON_LOADED Timing for Settings Panel
**What goes wrong:** Settings panel tries to access SimpleCursorRingSaved before it's loaded, showing nil values
**Why it happens:** If Settings.lua runs initialization code at file load time (not in ADDON_LOADED event), SavedVariables aren't available yet
**How to avoid:** Defer settings panel creation to ADDON_LOADED event or use an initialization function called after Core.lua's ADDON_LOADED handler
**Warning signs:** Settings panel shows default values instead of saved values, or throws nil errors

**Example:**
```lua
-- WRONG: Immediate execution at file load
local slider = CreateFrame("Slider", ...)
slider:SetValue(SimpleCursorRingSaved.size) -- SimpleCursorRingSaved is nil!

-- CORRECT: Defer until ADDON_LOADED
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == "SimpleCursorRing" then
        self:UnregisterEvent("ADDON_LOADED")
        -- NOW create and populate settings panel
        local slider = CreateFrame("Slider", ...)
        slider:SetValue(SimpleCursorRingSaved.size) -- Safe - SavedVariables loaded
    end
end)
```

## Code Examples

Verified patterns from official sources:

### Minimal Complete Settings Panel
```lua
-- Source: Warcraft Wiki Settings API + community patterns
local addonName = "SimpleCursorRing"

-- Create settings frame
local settingsFrame = CreateFrame("Frame")
settingsFrame.name = addonName

-- Title (optional but recommended)
local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(addonName)

-- Size slider
local sizeSlider = CreateFrame("Slider", nil, settingsFrame, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", 20, -60)
sizeSlider:SetMinMaxValues(20, 200)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)

local sizeLabel = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sizeLabel:SetPoint("BOTTOMLEFT", sizeSlider, "TOPLEFT", 0, 4)
sizeLabel:SetText("Ring Size")

local sizeValue = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
sizeValue:SetPoint("TOP", sizeSlider, "BOTTOM", 0, -4)

sizeSlider:SetScript("OnValueChanged", function(self, value, userInput)
    value = math.floor(value + 0.5)
    sizeValue:SetText(value)
    if userInput then
        SimpleCursorRing.UpdateRingSize(value)
    end
end)

-- Initialize on load
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == addonName then
        self:UnregisterEvent("ADDON_LOADED")

        -- Set initial values from saved settings
        sizeSlider:SetValue(SimpleCursorRingSaved.size)

        -- Register with Settings API
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category = Settings.RegisterCanvasLayoutCategory(settingsFrame, addonName)
            Settings.RegisterAddOnCategory(category)
            SimpleCursorRing.settingsCategory = category
        elseif InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(settingsFrame)
        end
    end
end)

-- Slash command
SLASH_SIMPLECURSORRING1 = "/simplecursorring"
SlashCmdList["SIMPLECURSORRING"] = function()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(SimpleCursorRing.settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(settingsFrame)
    end
end
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| InterfaceOptions_AddCategory | Settings.RegisterCanvasLayoutCategory + Settings.RegisterAddOnCategory | Patch 10.0.0 (Dragonflight launch) | Breaking change - old function deprecated, must use new API for Retail |
| InterfaceOptionsFrame_OpenToCategory | Settings.OpenToCategory(category:GetID()) | Patch 10.0.0 | Breaking change - signature changed from string to number ID |
| Manual frame showing | Settings.OpenToCategory with scrollToElementName | Patch 11.0.2 | Enhancement - can now scroll to specific controls within panel |
| ColorPickerFrame.opacity property read | ColorPickerFrame:GetColorAlpha() method | Unknown (pre-10.0) | API inconsistency - setup uses property, reading uses method |

**Deprecated/outdated:**
- InterfaceOptions_AddCategory: Deprecated in 10.0.0, still works but generates warnings. Use Settings.RegisterCanvasLayoutCategory instead.
- InterfaceOptionsFrame_OpenToCategory: Deprecated in 10.0.0, doesn't exist on modern clients. Use Settings.OpenToCategory instead.
- OptionsSliderTemplate in Classic Era: Removed in patch 1.15.4 for Classic Era. Still available in Retail and Cataclysm Classic.

## Open Questions

Things that couldn't be fully resolved:

1. **Settings API Stability**
   - What we know: Breaking changes in 10.0.0 and 11.0.2, indicating API is still evolving
   - What's unclear: Whether further breaking changes are expected in future patches
   - Recommendation: Include backwards compatibility checks for at least one patch cycle behind current version

2. **OptionsSliderTemplate Styling Customization**
   - What we know: Template provides Low/High/Text label references (e.g., _G[name.."Low"])
   - What's unclear: Whether template exposes easy API to hide Low/High labels (user decision specifies no min/max labels)
   - Recommendation: Test if setting textLow/textHigh:SetText("") hides labels, or if :Hide() is needed. May need to create slider without template for full control.

3. **ColorPickerFrame Patch 10.2.5 API Change**
   - What we know: OpenColorPicker global was relocated to ColorPickerFrame:SetupColorPickerAndShow in 10.2.5
   - What's unclear: Whether the old approach (setting properties + Show()) still works, or if new method is required
   - Recommendation: Use traditional approach (set properties + Show()) which has broader version compatibility. New method is likely convenience wrapper.

4. **Control Spacing Standards**
   - What we know: User decision leaves exact pixel spacing to Claude's discretion
   - What's unclear: Blizzard's current spacing standards for settings panels in 2026
   - Recommendation: Use 40px vertical spacing between controls (standard seen in examples). Test in-game and adjust if feels too tight/loose compared to Blizzard panels.

## Sources

### Primary (HIGH confidence)
- [Warcraft Wiki: Settings API](https://warcraft.wiki.gg/wiki/Settings_API) - Modern Settings API documentation
- [Warcraft Wiki: Settings.OpenToCategory](https://warcraft.wiki.gg/wiki/API_Settings.OpenToCategory) - Function signature and parameters
- [Wowpedia: Using the ColorPickerFrame](https://wowpedia.fandom.com/wiki/Using_the_ColorPickerFrame) - Color picker callback patterns
- [Wowpedia: Button:SetEnabled](https://wowpedia.fandom.com/wiki/API_Button_SetEnabled) - Control disabling API
- [Wowpedia: OnValueChanged](https://wowpedia.fandom.com/wiki/UIHANDLER_OnValueChanged) - Slider callback parameters

### Secondary (MEDIUM confidence)
- [GitHub: PhanxConfig-Slider](https://github.com/phanx-wow/PhanxConfig-Slider/blob/master/PhanxConfig-Slider.lua) - Real-world slider implementation
- [WoWInterface: Opening addon settings panel](https://www.wowinterface.com/forums/showthread.php?t=59264) - Community discussion on Settings.OpenToCategory
- [WoWInterface: InterfaceOptionsFrame_OpenToCategory replacement](https://www.wowinterface.com/forums/showthread.php?t=60018) - Migration patterns from old to new API
- [AddOn Studio: Creating GUI configuration options](https://addonstudio.org/wiki/WoW:Creating_GUI_configuration_options) - Control templates and examples
- [Warcraft Wiki: Patch 10.0.0/API changes](https://warcraft.wiki.gg/wiki/Patch_10.0.0/API_changes) - Settings API breaking changes
- [Warcraft Wiki: Patch 11.0.2/API changes](https://warcraft.wiki.gg/wiki/Patch_11.0.2/API_changes) - Recent Settings API enhancements

### Tertiary (LOW confidence)
- [WoWWiki Archive: Creating a slash command](https://wowwiki-archive.fandom.com/wiki/Creating_a_slash_command) - Basic slash command pattern (pre-Dragonflight)
- [WoWWiki Archive: OptionsSliderTemplate](https://wowwiki-archive.fandom.com/wiki/UIOBJECT_Slider) - Slider template documentation (may be outdated)
- [Medium: World of Warcraft Addons Guide 2026](https://medium.com/@carolrodriguez598oscarol7rtkql/world-of-warcraft-addons-guide-2026-dc512bc7f7db) - General addon development overview

## Metadata

**Confidence breakdown:**
- Standard stack: MEDIUM - Settings API verified from official wiki, but documentation has SSL issues and some details rely on community sources
- Architecture: MEDIUM - Core patterns verified from multiple sources (wiki + GitHub + forums), but some implementation details extrapolated from older examples
- Pitfalls: MEDIUM - OnValueChanged userInput parameter and ColorPickerFrame opacity methods verified from official docs, but Settings.OpenToCategory issues primarily from community forums

**Research date:** 2026-02-03
**Valid until:** 2026-02-24 (21 days - WoW patches approximately every 2 months, API should remain stable)

**Notes:**
- SSL certificate issues prevented direct access to warcraft.wiki.gg, but WebSearch results provided sufficient API documentation excerpts
- Most concrete code examples are from pre-Dragonflight sources, but core patterns remain valid (CreateFrame, templates, callbacks)
- Settings API is the major change - all control creation patterns are backwards compatible
- User's CONTEXT.md decisions significantly constrain scope: no tooltips, no reset button, no description text, specific control layout. Research focused on these locked decisions rather than exploring alternatives.
