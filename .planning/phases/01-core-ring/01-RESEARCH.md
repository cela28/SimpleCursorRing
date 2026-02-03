# Phase 1: Core Ring - Research

**Researched:** 2026-02-03
**Domain:** World of Warcraft Addon Development (Lua/WoW API)
**Confidence:** MEDIUM

## Summary

World of Warcraft addons for retail (Patch 12.0.0 "Midnight") are built using Lua with the WoW API. The core cursor ring functionality requires creating a frame with a texture that follows mouse movement via OnUpdate script handlers, using GetCursorPosition() for cursor tracking with proper UI scale conversion.

The standard approach involves: a TOC file defining addon metadata and load order, Lua code for frame creation and cursor tracking, texture assets in TGA or BLP format (powers of 2 dimensions), and the new Settings API (introduced in 10.0, refined in 12.0) for configuration panels with SavedVariables for persistence.

Key technical requirements: throttled OnUpdate handlers (cursor following runs frequently but should be optimized), proper coordinate scaling using UIParent:GetEffectiveScale(), and ADDON_LOADED event pattern for initialization with SavedVariables access.

**Primary recommendation:** Use native WoW API (CreateFrame, SetScript OnUpdate, GetCursorPosition) with the new Settings API for configuration panel, avoiding external libraries to maintain standalone requirement.

## Standard Stack

The established libraries/tools for this domain:

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Lua | 5.1 | Scripting language | WoW's embedded Lua runtime |
| WoW API | 12.0.0 (120000) | Game interface | Only way to interact with WoW client |
| Settings API | 12.0.0+ | Configuration panels | Modern replacement for InterfaceOptionsPanel |
| SavedVariables | Built-in | Data persistence | Native WoW mechanism for addon settings |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Ace3 | Latest | Full framework | Large/complex addons (NOT for this project) |
| LibStub | Latest | Library loader | Only if using libraries (NOT needed) |
| AceConfig/AceGUI | Latest | Settings UI | Complex config needs (NOT needed - use Settings API) |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Settings API | Ace3 AceConfig | Ace3 adds dependencies, violates standalone requirement |
| Native frames | LibSharedMedia | Not needed for single texture, adds dependency |
| Manual SavedVariables | AceDB | AceDB overkill for simple settings, adds dependency |

**Installation:**
Not applicable - native WoW API requires no installation beyond having WoW installed.

## Architecture Patterns

### Recommended Project Structure
```
SimpleCursorRing/
├── SimpleCursorRing.toc        # Addon metadata, interface version, file load order
├── Core.lua                     # Main addon logic: frame creation, cursor tracking
├── Settings.lua                 # Settings panel registration, configuration UI
├── Textures/
│   └── Ring.tga                 # Ring texture asset (from EnhanceQoL)
└── (SavedVariables stored in WTF/ automatically)
```

### Pattern 1: Addon Initialization with ADDON_LOADED
**What:** Proper initialization ensuring SavedVariables are loaded before use
**When to use:** Always for addons with saved settings
**Example:**
```lua
-- Source: https://warcraft.wiki.gg/wiki/AddOn_loading_process
local addonName = "SimpleCursorRing"
local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        self:UnregisterEvent("ADDON_LOADED")

        -- Initialize saved variables with defaults if needed
        if not SimpleCursorRingSaved then
            SimpleCursorRingSaved = {
                size = 64,
                color = {r = 1, g = 1, b = 1, a = 1},
                useClassColor = false
            }
        end

        -- Now safe to initialize addon
        InitializeAddon()
    end
end)
```

### Pattern 2: Throttled OnUpdate for Cursor Following
**What:** Efficiently update frame position without killing performance
**When to use:** Any frame that needs continuous updates (cursor tracking, animations)
**Example:**
```lua
-- Source: https://wowwiki-archive.fandom.com/wiki/Using_OnUpdate_correctly
local UPDATE_INTERVAL = 0.01 -- 100 updates per second max

local function OnUpdate(self, elapsed)
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed

    while self.timeSinceLastUpdate > UPDATE_INTERVAL do
        -- Get cursor position and scale
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()

        -- Position frame at cursor
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)

        self.timeSinceLastUpdate = self.timeSinceLastUpdate - UPDATE_INTERVAL
    end
end

ringFrame:SetScript("OnUpdate", OnUpdate)
```

### Pattern 3: GetCursorPosition with Scale Conversion
**What:** Correctly translate cursor coordinates to frame positioning
**When to use:** Whenever positioning frames relative to cursor
**Example:**
```lua
-- Source: https://wowpedia.fandom.com/wiki/API_GetCursorPosition
-- GetCursorPosition returns coordinates at UIParent scale
local x, y = GetCursorPosition()
local scale = UIParent:GetEffectiveScale()

-- Convert to actual screen coordinates
-- Cursor coordinates use BOTTOMLEFT as origin (0,0)
frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)
```

### Pattern 4: Settings API Registration (12.0.0+)
**What:** Modern way to add settings panel in Blizzard UI
**When to use:** Any addon that needs user-configurable settings
**Example:**
```lua
-- Source: https://warcraft.wiki.gg/wiki/Settings_API
local category = Settings.RegisterVerticalLayoutCategory("SimpleCursorRing")

-- Register slider for ring size
local setting = Settings.RegisterAddOnSetting(
    category,
    "SimpleCursorRing_Size",
    "size",
    SimpleCursorRingSaved,
    "number",
    "Ring Size",
    64
)

setting:SetValueChangedCallback(function(setting, value)
    -- Update ring size when slider changes
    ringFrame:SetSize(value, value)
end)

-- Create slider control
Settings.CreateSlider(category, setting, {
    minValue = 20,
    maxValue = 200,
    step = 1,
    formatters = {
        [MinimalSliderWithSteppersMixin.Label.Right] = function(value)
            return string.format("%dpx", value)
        end
    }
})

Settings.RegisterAddOnCategory(category)
```

### Pattern 5: ColorPickerFrame Integration
**What:** Native color picker for user color selection
**When to use:** Any color customization feature
**Example:**
```lua
-- Source: https://wowpedia.fandom.com/wiki/Using_the_ColorPickerFrame
local function ShowColorPicker(r, g, b, a, callback)
    local info = {
        r = r, g = g, b = b,
        opacity = a,
        hasOpacity = true,
        swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = ColorPickerFrame:GetColorAlpha()
            callback(r, g, b, a)
        end,
        cancelFunc = function()
            callback(r, g, b, a) -- Restore original
        end,
    }
    ColorPickerFrame:SetupColorPickerAndShow(info)
end
```

### Pattern 6: Class Color Access
**What:** Get player's class color for ring customization
**When to use:** Features that use class colors
**Example:**
```lua
-- Source: https://github.com/phanx-wow/ClassColors/wiki
local _, class = UnitClass("player")
local classColor = RAID_CLASS_COLORS[class]

-- Check for custom class colors addon support
if CUSTOM_CLASS_COLORS then
    classColor = CUSTOM_CLASS_COLORS[class]
end

-- Apply to texture
ringTexture:SetVertexColor(classColor.r, classColor.g, classColor.b, 1.0)
```

### Anti-Patterns to Avoid
- **Unthrottled OnUpdate:** Running logic every frame (30-144 times per second) causes performance issues. Always throttle with elapsed time accumulation.
- **Global namespace pollution:** Creating global variables without addon prefix causes conflicts. Use local variables and a single namespaced global table.
- **Hardcoded paths:** Using absolute paths for textures breaks if user moves addon. Use addon-relative paths like `"Interface\\AddOns\\SimpleCursorRing\\Textures\\Ring"`.
- **Ignoring effective scale:** Using GetCursorPosition() values directly without dividing by scale causes positioning errors at non-100% UI scales.
- **SavedVariables before ADDON_LOADED:** Accessing SavedVariables during file load causes nil reference errors. Always wait for ADDON_LOADED event.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Settings persistence | Custom file I/O or serialization | SavedVariables (.toc directive) | WoW provides automatic save/load, file I/O APIs restricted |
| Settings UI panels | Manual frame/widget creation | Settings API (Settings.RegisterAddOnSetting) | Modern API handles layout, integration with Blizzard UI, proper styling |
| Color picker dialog | Custom color selection UI | ColorPickerFrame | Native picker with hex input (10.2.5+), opacity support, familiar to users |
| UI scaling math | Manual coordinate calculations | UIParent:GetEffectiveScale() | WoW handles multi-monitor, custom scales, resolution changes |
| Event dispatching | Manual event handler routing | Frame:RegisterEvent + SetScript("OnEvent") | Native event system, automatic cleanup, proper timing |

**Key insight:** WoW's API is comprehensive and battle-tested. Custom implementations introduce bugs (scale edge cases, SavedVariables corruption, memory leaks from improper event cleanup) that native solutions handle. Addons should be thin layers over WoW API, not reimplementations.

## Common Pitfalls

### Pitfall 1: TOC File Naming Mismatch
**What goes wrong:** Addon folder name doesn't match .toc filename, causing addon to not load at all
**Why it happens:** WoW requires exact match between folder name and TOC file name for addon discovery
**How to avoid:** Folder `SimpleCursorRing/` MUST contain `SimpleCursorRing.toc` (case-sensitive on some systems)
**Warning signs:** Addon doesn't appear in AddOns list at character select, no errors in chat (silently fails to load)

### Pitfall 2: Incorrect Interface Version
**What goes wrong:** Addon shows as "out of date" or fails to load in current patch
**Why it happens:** TOC file has wrong interface version number for current WoW version
**How to avoid:** Use `## Interface: 120000` for Patch 12.0.0 (Midnight); format is MajorMinorPatch without dots (12.0.0 → 120000)
**Warning signs:** Red addon text in character select, "load out of date addons" checkbox needed

### Pitfall 3: SavedVariables Declaration Missing
**What goes wrong:** Settings don't persist between sessions, addon resets to defaults every login
**Why it happens:** Forgot to add `## SavedVariables: SimpleCursorRingSaved` to TOC file
**How to avoid:** Must declare EVERY saved variable name in TOC file, one per line or comma-separated
**Warning signs:** Settings work during session but reset on logout/login, WTF/SavedVariables folder doesn't contain addon file

### Pitfall 4: Texture Dimension Requirements
**What goes wrong:** Texture doesn't display or shows corrupted/blank
**Why it happens:** WoW requires texture dimensions to be powers of 2 (e.g., 32, 64, 128, 256, 512)
**How to avoid:** Validate texture files are 32x32, 64x64, 128x128, 256x256, etc. (can be non-square: 256x128 is valid, 256x200 is not)
**Warning signs:** Frame visible but texture missing, WoW client console errors about texture loading

### Pitfall 5: Scale-Dependent Positioning Bugs
**What goes wrong:** Ring offset from cursor at non-100% UI scale settings
**Why it happens:** Using GetCursorPosition() without dividing by UIParent:GetEffectiveScale()
**How to avoid:** ALWAYS divide cursor coordinates by scale: `x/scale, y/scale`
**Warning signs:** Ring position correct at 100% UI scale but offset at other scales, reports from users with different UI scale settings

### Pitfall 6: Frame Strata Visibility Issues
**What goes wrong:** Ring appears behind game world, UI elements, or tooltips block ring
**Why it happens:** Default frame strata is "MEDIUM", which is below many UI elements
**How to avoid:** Set appropriate strata: `frame:SetFrameStrata("HIGH")` for cursor ring (above most UI but below tooltips)
**Warning signs:** Ring disappears when hovering over buttons/frames, inconsistent visibility

### Pitfall 7: OnUpdate Performance Degradation
**What goes wrong:** Game stutters, low FPS, addon causes performance issues
**Why it happens:** OnUpdate runs every frame (30-144+ fps) without throttling, especially problematic with multiple addons
**How to avoid:** Use elapsed time accumulation pattern (see Architecture Patterns), update only when time threshold exceeded
**Warning signs:** Performance issues reported, frame drops when addon enabled, "Interface" high in addon memory/CPU usage tools

### Pitfall 8: Settings API Breaking Changes (10.0+, 11.0+, 12.0+)
**What goes wrong:** Settings panel errors, addon fails to load, deprecated API usage
**Why it happens:** Settings API changed significantly across expansions (InterfaceOptionsPanel → Settings API 10.0, parameter changes in 11.0.2)
**How to avoid:** Use current Settings.RegisterAddOnSetting with correct parameter order: (category, variable, variableKey, variableTbl, variableType, name, defaultValue)
**Warning signs:** Lua errors mentioning Settings or InterfaceOptions, panel doesn't appear in interface options

### Pitfall 9: Class Color API Compatibility
**What goes wrong:** Class colors don't respect user's custom class color addons
**Why it happens:** Directly using RAID_CLASS_COLORS without checking for CUSTOM_CLASS_COLORS
**How to avoid:** Check `if CUSTOM_CLASS_COLORS then use CUSTOM_CLASS_COLORS else use RAID_CLASS_COLORS`
**Warning signs:** Users with custom class color addons report wrong colors, incompatibility reports with ClassColors addon

## Code Examples

Verified patterns from official sources:

### Complete Frame Setup with Texture
```lua
-- Source: Composite from WoW API documentation
local frame = CreateFrame("Frame", "SimpleCursorRingFrame", UIParent)
frame:SetSize(64, 64)
frame:SetFrameStrata("HIGH")
frame:SetFrameLevel(100)

local texture = frame:CreateTexture(nil, "ARTWORK")
texture:SetTexture("Interface\\AddOns\\SimpleCursorRing\\Textures\\Ring")
texture:SetAllPoints(frame)
texture:SetVertexColor(1, 1, 1, 1) -- White, full opacity

frame:Show()
```

### SavedVariables Initialization Pattern
```lua
-- Source: https://addonstudio.org/wiki/WoW:Saving_variables_between_game_sessions
-- In TOC file:
-- ## SavedVariables: SimpleCursorRingSaved

-- In Core.lua:
local defaults = {
    size = 64,
    color = {r = 1, g = 1, b = 1, a = 1},
    useClassColor = false
}

local function InitializeSavedVariables()
    -- Create table if doesn't exist
    if not SimpleCursorRingSaved then
        SimpleCursorRingSaved = {}
    end

    -- Apply defaults for missing keys
    for key, value in pairs(defaults) do
        if SimpleCursorRingSaved[key] == nil then
            SimpleCursorRingSaved[key] = value
        end
    end
end
```

### Complete Settings Panel with Slider
```lua
-- Source: https://warcraft.wiki.gg/wiki/Settings_API
local function CreateSettingsPanel()
    local category = Settings.RegisterVerticalLayoutCategory("SimpleCursorRing")

    -- Size slider
    local sizeSetting = Settings.RegisterAddOnSetting(
        category,
        "SimpleCursorRing_Size",
        "size",
        SimpleCursorRingSaved,
        "number",
        "Ring Size",
        64
    )

    sizeSetting:SetValueChangedCallback(function(_, value)
        UpdateRingSize(value)
    end)

    Settings.CreateSlider(category, sizeSetting, {
        minValue = 20,
        maxValue = 200,
        step = 1
    })

    -- Class color checkbox
    local classColorSetting = Settings.RegisterAddOnSetting(
        category,
        "SimpleCursorRing_UseClassColor",
        "useClassColor",
        SimpleCursorRingSaved,
        "boolean",
        "Use Class Color",
        false
    )

    classColorSetting:SetValueChangedCallback(function(_, value)
        UpdateRingColor(value)
    end)

    Settings.CreateCheckbox(category, classColorSetting, "Use your class color for the ring")

    Settings.RegisterAddOnCategory(category)
end
```

### Cursor Following with Proper Throttling
```lua
-- Source: https://wowwiki-archive.fandom.com/wiki/Using_OnUpdate_correctly
local CURSOR_UPDATE_INTERVAL = 0.01 -- 100 Hz max update rate

local function OnUpdateCursorPosition(self, elapsed)
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed

    while self.timeSinceLastUpdate > CURSOR_UPDATE_INTERVAL do
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()

        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/scale, y/scale)

        self.timeSinceLastUpdate = self.timeSinceLastUpdate - CURSOR_UPDATE_INTERVAL
    end
end

ringFrame:SetScript("OnUpdate", OnUpdateCursorPosition)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| InterfaceOptionsPanel | Settings API | Patch 10.0.0 (2022) | Must use Settings.RegisterAddOnSetting, old API removed |
| ColorPickerFrame.func | ColorPickerFrame:SetupColorPickerAndShow() | Patch 10.2.5 (2024) | Function signature changed, now includes hex input |
| Manual settings frames | Settings.CreateCheckbox/Slider/Dropdown | Patch 10.0.0 (2022) | Native controls with proper styling, less manual layout |
| ADDON_LOADED for all init | PLAYER_LOGIN for one-time init | Always available | PLAYER_LOGIN better for world-entry initialization, ADDON_LOADED for SavedVariables |
| Load-on-demand addons | Always-loaded with disabled modules | Trend in 2020s | Simpler addon management, less load-time optimization needed |

**Deprecated/outdated:**
- **InterfaceOptions_AddCategory()**: Removed in 10.0, use Settings API instead
- **OpenColorPicker()**: Renamed to ColorPickerFrame:SetupColorPickerAndShow() in 10.2.5
- **LibSharedMedia for simple addons**: Overkill for single texture, direct texture paths preferred for standalone addons
- **.toc SavedVariablesPerCharacter** for global settings: Use SavedVariables with nested character tables if needed, simpler data model

## Open Questions

Things that couldn't be fully resolved:

1. **EnhanceQoL Source Code Access**
   - What we know: EnhanceQoL exists on GitHub (R41z0r/EnhanceQoL), has mouse cursor ring feature
   - What's unclear: Exact implementation details, Mouse.tga asset location, whether code is directly reusable
   - Recommendation: Implement from scratch using WoW API patterns; reference EnhanceQoL only for texture asset and feature comparison. Original code may be more complex (part of larger addon framework) than needed for standalone ring.

2. **Optimal OnUpdate Throttle Rate**
   - What we know: Should throttle to avoid performance issues, common intervals are 0.01-0.03s (33-100 Hz)
   - What's unclear: Best balance between smooth cursor following and performance for cursor ring specifically
   - Recommendation: Start with 0.01s (100 Hz), make configurable if users report issues. Cursor following needs higher rate than most OnUpdate uses. Test with low-end hardware.

3. **Color Picker Integration with Settings API**
   - What we know: ColorPickerFrame exists and works, Settings API has CreateCheckbox/CreateSlider/CreateDropdown
   - What's unclear: Settings API doesn't have native CreateColorPicker, unclear if custom integration is expected or if manual button is standard
   - Recommendation: Create custom button in settings panel that opens ColorPickerFrame on click. This is current community pattern based on addon examples.

4. **Frame Strata for Cursor Ring**
   - What we know: Options are BACKGROUND, LOW, MEDIUM, HIGH, DIALOG, FULLSCREEN, FULLSCREEN_DIALOG, TOOLTIP
   - What's unclear: Best strata for cursor ring - HIGH keeps it above UI but below tooltips, but tooltips may obscure ring when hovering
   - Recommendation: Use "HIGH" as default. Ring should be visible over action bars/unit frames but tooltips legitimately need to appear on top. If users want ring over tooltips, make it configurable (allow TOOLTIP strata).

5. **Midnight (12.0) "Addon Apocalypse" Impact**
   - What we know: Combat addons restricted in 12.0, custom cursor ring is non-combat UI enhancement
   - What's unclear: Whether cursor tracking or OnUpdate restrictions apply to non-combat addons
   - Recommendation: Proceed with standard cursor tracking pattern. If restrictions apply, they'll surface during testing. Cursor ring is not a "computational aura" that automates mechanics, unlikely to be restricted.

## Sources

### Primary (HIGH confidence)
- [Warcraft Wiki - TOC format](https://warcraft.wiki.gg/wiki/TOC_format) - Official TOC file specification
- [Warcraft Wiki - Settings API](https://warcraft.wiki.gg/wiki/Settings_API) - Modern settings panel API
- [Warcraft Wiki - AddOn loading process](https://warcraft.wiki.gg/wiki/AddOn_loading_process) - ADDON_LOADED event pattern
- [Wowpedia - Using the ColorPickerFrame](https://wowpedia.fandom.com/wiki/Using_the_ColorPickerFrame) - Color picker integration
- [Wowpedia - API GetCursorPosition](https://wowpedia.fandom.com/wiki/API_GetCursorPosition) - Cursor coordinate retrieval

### Secondary (MEDIUM confidence)
- [WoWWiki Archive - Using OnUpdate correctly](https://wowwiki-archive.fandom.com/wiki/Using_OnUpdate_correctly) - Throttling pattern (verified across multiple sources)
- [AddOn Studio - UI coordinates](https://addonstudio.org/wiki/WoW:UI_coordinates) - Scale conversion math (verified with official wiki)
- [AddOn Studio - Saving variables between game sessions](https://addonstudio.org/wiki/WoW:Saving_variables_between_game_sessions) - SavedVariables pattern (verified with official wiki)
- [CurseForge - CursorFX addon](https://www.curseforge.com/wow/addons/cursorfx) - Recent (Jan 2026) cursor ring implementation example
- [GitHub - ClassColors wiki](https://github.com/phanx-wow/ClassColors/wiki) - CUSTOM_CLASS_COLORS support pattern

### Tertiary (LOW confidence - WebSearch only)
- [Medium articles about WoW addons 2026](https://medium.com/@FXMKL/how-to-install-addons-for-wow-the-complete-2026-guide-df1fc0029ee5) - General addon landscape, no technical verification
- [GitHub - WoWAddonDevGuide](https://github.com/Amadeus-/WoWAddonDevGuide) - Mentioned as comprehensive but not directly accessed
- Community forum discussions about Midnight addon changes - Conflicting information about scope of restrictions

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - WoW API is definitive, interface version confirmed from multiple official sources
- Architecture: MEDIUM - Patterns verified across multiple sources but some are from archived wikis (original WoWWiki), not current 12.0 documentation
- Pitfalls: MEDIUM - Based on community experience and documentation, but specific 12.0 pitfalls may not be fully discovered yet (patch is recent - Jan 2026)

**Research date:** 2026-02-03
**Valid until:** 2026-03-03 (30 days - stable domain but WoW patches frequently, Midnight just released)

**Notes:**
- WoW addon development is mature domain (20+ years) but API evolves with expansions
- Patch 12.0.0 (Midnight) just released Jan 2026, so cutting-edge issues may not be fully documented yet
- Settings API is current (introduced 10.0, refined through 12.0) but community examples lag behind latest changes
- Focus on standalone implementation (no Ace3/LibStub) aligns with "SimpleCursorRing" goal of minimal addon
