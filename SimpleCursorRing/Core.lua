-- SimpleCursorRing: Displays a customizable ring around the mouse cursor
-- Core.lua - Main addon logic: frame creation and cursor tracking

local addonName = "SimpleCursorRing"

-- Throttled update configuration
local UPDATE_INTERVAL = 0.01 -- 100 Hz max update rate for smooth tracking

-- Create the main ring frame
local frame = CreateFrame("Frame", "SimpleCursorRingFrame", UIParent)
frame:SetSize(64, 64) -- Default size, customizable in Plan 02
frame:SetFrameStrata("HIGH") -- Above most UI, below tooltips
frame:SetFrameLevel(100)

-- Create the ring texture
local texture = frame:CreateTexture(nil, "ARTWORK")
texture:SetTexture("Interface\\AddOns\\SimpleCursorRing\\Textures\\Ring")
texture:SetAllPoints(frame)
texture:SetVertexColor(1, 1, 1, 1) -- White, full opacity (default)

-- Store texture reference for later customization
frame.texture = texture

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
frame:SetScript("OnUpdate", OnUpdate)

-- Show the ring
frame:Show()
