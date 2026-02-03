-- SimpleCursorRing: Displays a customizable ring around the mouse cursor
-- Core.lua - Main addon logic: frame creation, cursor tracking, and settings

local addonName = "SimpleCursorRing"

-- Default settings (applied if SavedVariables missing)
local defaults = {
    size = 64,
    color = {r = 1, g = 1, b = 1, a = 1},
    useClassColor = false
}

-- Throttled update configuration
local UPDATE_INTERVAL = 0.01 -- 100 Hz max update rate for smooth tracking

-- Create the main ring frame
local ringFrame = CreateFrame("Frame", "SimpleCursorRingFrame", UIParent)
ringFrame:SetSize(64, 64) -- Default size, customizable via settings
ringFrame:SetFrameStrata("HIGH") -- Above most UI, below tooltips
ringFrame:SetFrameLevel(100)

-- Create the ring texture
local ringTexture = ringFrame:CreateTexture(nil, "ARTWORK")
ringTexture:SetTexture("Interface\\AddOns\\SimpleCursorRing\\Textures\\Ring")
ringTexture:SetAllPoints(ringFrame)
ringTexture:SetVertexColor(1, 1, 1, 1) -- White, full opacity (default)

-- Store texture reference for later customization
ringFrame.texture = ringTexture

-- Forward declarations for customization functions
local UpdateRingSize, UpdateRingColor, SetUseClassColor

-- Update ring size (RING-02)
UpdateRingSize = function(size)
    -- Clamp to valid range (20-200 pixels)
    size = math.max(20, math.min(200, size))
    SimpleCursorRingSaved.size = size
    ringFrame:SetSize(size, size)
end

-- Update ring color (RING-03, RING-04)
UpdateRingColor = function(r, g, b, a)
    if SimpleCursorRingSaved.useClassColor then
        -- Get player's class color
        local _, class = UnitClass("player")
        local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
        if classColor then
            ringTexture:SetVertexColor(classColor.r, classColor.g, classColor.b, 1.0)
        end
    else
        -- Use custom color (from parameters or saved settings)
        r = r or SimpleCursorRingSaved.color.r
        g = g or SimpleCursorRingSaved.color.g
        b = b or SimpleCursorRingSaved.color.b
        a = a or SimpleCursorRingSaved.color.a
        SimpleCursorRingSaved.color = {r = r, g = g, b = b, a = a}
        ringTexture:SetVertexColor(r, g, b, a)
    end
end

-- Toggle class color mode (RING-04)
SetUseClassColor = function(enabled)
    SimpleCursorRingSaved.useClassColor = enabled
    UpdateRingColor()
end

-- Initialize SavedVariables with defaults
local function InitializeSavedVariables()
    if not SimpleCursorRingSaved then
        SimpleCursorRingSaved = {}
    end

    -- Apply defaults for missing keys
    for key, value in pairs(defaults) do
        if SimpleCursorRingSaved[key] == nil then
            if type(value) == "table" then
                SimpleCursorRingSaved[key] = {}
                for k, v in pairs(value) do
                    SimpleCursorRingSaved[key][k] = v
                end
            else
                SimpleCursorRingSaved[key] = value
            end
        end
    end
end

-- Apply saved settings to ring
local function ApplySavedSettings()
    UpdateRingSize(SimpleCursorRingSaved.size)
    UpdateRingColor()
end

-- Event frame for ADDON_LOADED handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        self:UnregisterEvent("ADDON_LOADED")
        InitializeSavedVariables()
        ApplySavedSettings()
    end
end)

-- Expose functions globally for Settings UI (Phase 2)
SimpleCursorRing = SimpleCursorRing or {}
SimpleCursorRing.UpdateRingSize = UpdateRingSize
SimpleCursorRing.UpdateRingColor = UpdateRingColor
SimpleCursorRing.SetUseClassColor = SetUseClassColor

-- Throttled OnUpdate handler for cursor following
local function OnUpdate(self, elapsed)
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed

    while self.timeSinceLastUpdate > UPDATE_INTERVAL do
        -- Get cursor position (returns coordinates at UIParent scale)
        local x, y = GetCursorPosition()

        -- CRITICAL: Divide by effective scale for proper positioning at any UI scale
        local scale = UIParent:GetEffectiveScale()

        -- Position frame centered on cursor
        -- Cursor coordinates use BOTTOMLEFT as origin (0,0)
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)

        self.timeSinceLastUpdate = self.timeSinceLastUpdate - UPDATE_INTERVAL
    end
end

-- Initialize the OnUpdate handler
ringFrame:SetScript("OnUpdate", OnUpdate)

-- Show the ring
ringFrame:Show()
