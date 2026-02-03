-- SimpleCursorRing: Settings UI
-- Settings.lua - Settings panel with controls for ring customization

local addonName = "SimpleCursorRing"

-- Create main settings panel frame
local panel = CreateFrame("Frame", "SimpleCursorRingSettingsPanel", UIParent)
panel.name = "SimpleCursorRing"
panel:SetSize(300, 200)

-- Title text
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("SimpleCursorRing Settings")

-- Size Slider (Ring Size)
local sizeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
sizeSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -24)
sizeSlider:SetMinMaxValues(20, 200)
sizeSlider:SetValueStep(1)
sizeSlider:SetObeyStepOnDrag(true)
sizeSlider:SetWidth(200)

-- Slider label
local sizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sizeLabel:SetPoint("BOTTOMLEFT", sizeSlider, "TOPLEFT", 0, 2)
sizeLabel:SetText("Ring Size")

-- Slider value text
local sizeValue = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
sizeValue:SetPoint("BOTTOMRIGHT", sizeSlider, "TOPRIGHT", 0, 2)

-- Slider callbacks
sizeSlider:SetScript("OnValueChanged", function(self, value, userInput)
    sizeValue:SetText(string.format("%d", value))
    if userInput then
        SimpleCursorRing.UpdateRingSize(value)
    end
end)

-- Color Picker (Ring Color)
local colorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
colorLabel:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -16)
colorLabel:SetText("Ring Color")

-- Color swatch button
local colorSwatch = CreateFrame("Button", nil, panel)
colorSwatch:SetPoint("LEFT", colorLabel, "RIGHT", 8, 0)
colorSwatch:SetSize(32, 32)

-- Swatch texture (shows current color)
local swatchTexture = colorSwatch:CreateTexture(nil, "BACKGROUND")
swatchTexture:SetAllPoints()
swatchTexture:SetColorTexture(1, 1, 1, 1)

-- Swatch border
local swatchBorder = colorSwatch:CreateTexture(nil, "BORDER")
swatchBorder:SetAllPoints()
swatchBorder:SetColorTexture(0.2, 0.2, 0.2, 1)
swatchBorder:SetPoint("TOPLEFT", -1, 1)
swatchBorder:SetPoint("BOTTOMRIGHT", 1, -1)

-- Store reference for disable/enable
panel.colorSwatch = colorSwatch

-- Color picker callback
colorSwatch:SetScript("OnClick", function(self)
    local r, g, b, a = SimpleCursorRingSaved.color.r, SimpleCursorRingSaved.color.g,
                       SimpleCursorRingSaved.color.b, SimpleCursorRingSaved.color.a

    -- Store original color for cancel
    local originalR, originalG, originalB, originalA = r, g, b, a

    ColorPickerFrame:SetupColorPickerAndShow({
        hasOpacity = true,
        opacity = a,
        r = r,
        g = g,
        b = b,

        swatchFunc = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = ColorPickerFrame:GetColorAlpha()
            SimpleCursorRing.UpdateRingColor(newR, newG, newB, newA)
            swatchTexture:SetColorTexture(newR, newG, newB, newA)
        end,

        opacityFunc = function()
            local newR, newG, newB = ColorPickerFrame:GetColorRGB()
            local newA = ColorPickerFrame:GetColorAlpha()
            SimpleCursorRing.UpdateRingColor(newR, newG, newB, newA)
            swatchTexture:SetColorTexture(newR, newG, newB, newA)
        end,

        cancelFunc = function()
            SimpleCursorRing.UpdateRingColor(originalR, originalG, originalB, originalA)
            swatchTexture:SetColorTexture(originalR, originalG, originalB, originalA)
        end,
    })
end)

-- Class Color Toggle (Use Class Color)
local classColorCheckbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
classColorCheckbox:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", 0, -16)
classColorCheckbox:SetSize(24, 24)

-- Checkbox label
local classColorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
classColorLabel:SetPoint("LEFT", classColorCheckbox, "RIGHT", 4, 0)
classColorLabel:SetText("Use Class Color")

-- Checkbox callback
classColorCheckbox:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    SimpleCursorRing.SetUseClassColor(checked)

    -- Disable/enable color picker based on checkbox state
    if checked then
        colorSwatch:SetEnabled(false)
        colorSwatch:SetAlpha(0.5)
    else
        colorSwatch:SetEnabled(true)
        colorSwatch:SetAlpha(1.0)
    end
end)

-- Store reference for initialization
panel.classColorCheckbox = classColorCheckbox

-- Initialize controls from saved settings (called after PLAYER_LOGIN)
local function InitializeControls()
    -- Size slider
    sizeSlider:SetValue(SimpleCursorRingSaved.size)

    -- Color swatch
    local c = SimpleCursorRingSaved.color
    swatchTexture:SetColorTexture(c.r, c.g, c.b, c.a)

    -- Class color checkbox
    classColorCheckbox:SetChecked(SimpleCursorRingSaved.useClassColor)

    -- Apply initial disabled state to color picker if class color is enabled
    if SimpleCursorRingSaved.useClassColor then
        colorSwatch:SetEnabled(false)
        colorSwatch:SetAlpha(0.5)
    else
        colorSwatch:SetEnabled(true)
        colorSwatch:SetAlpha(1.0)
    end
end

-- Panel registration and slash command setup (Task 2)
-- Wrapped in PLAYER_LOGIN to ensure Settings API is ready
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent("PLAYER_LOGIN")

    -- Initialize controls with saved values
    InitializeControls()

    -- Register panel with Interface Options
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)

    -- Store category reference for slash command
    panel.category = category

    -- Create slash commands
    SLASH_SIMPLECURSORRING1 = "/simplecursorring"
    SLASH_SIMPLECURSORRING2 = "/scr"

    SlashCmdList["SIMPLECURSORRING"] = function(msg)
        Settings.OpenToCategory(category:GetID())
    end
end)
