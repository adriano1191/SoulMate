if not SM_Config then 
SM_Config = {} 
end 

if not SM_Config.maxShards then 
SM_Config.maxShards = 20 
end

-- Create the main options panel
local panel = CreateFrame("Frame")
panel.name = "SoulMate"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("SoulMate - Settings")

-- Description
local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText("Set the maximum number of Soul Shards allowed in your bags.")

-- Input box for shard limit
local editBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
editBox:SetSize(50, 30)
editBox:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, 0)
editBox:SetAutoFocus(false)

-- Label next to the input box 
local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal") 
label:SetPoint("LEFT", editBox, "RIGHT", 10, 0) 
label:SetText("Soul Shard Limit")

--[[
-- Slider for shard limit (1–32)
local slider = CreateFrame("Slider", "SoulMateSlider", panel, "UISliderTemplateWithLabels")
slider:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, 0)
slider:SetMinMaxValues(1, 32)
slider:SetValueStep(1)
slider:SetObeyStepOnDrag(true)
slider:SetWidth(150)
slider:SetHeight(20)
slider:SetValue(20)



-- Text slider
SoulMateSliderLow:SetText("1")
SoulMateSliderHigh:SetText("32")


-- Aktualizacja wartości w trakcie przesuwania
slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    editBox:SetText(value)          -- synchronizacja z input boxem
end)
--]]

-- Label
local sizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sizeLabel:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -40)
sizeLabel:SetText("Button Size")

local sizeLabel2 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
sizeLabel2:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -10)
sizeLabel2:SetTextColor(1, 1, 1, 1)
sizeLabel2:SetText("Width x Height in pixels.")

local widthBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
widthBox:SetSize(50, 30)
widthBox:SetPoint("TOPLEFT", sizeLabel2, "BOTTOMLEFT", 0, 0)
widthBox:SetAutoFocus(false)

local xLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
xLabel:SetPoint("LEFT", widthBox, "RIGHT", 8, 0)
xLabel:SetText("x")

local heightBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
heightBox:SetSize(50, 30)
heightBox:SetPoint("LEFT", xLabel, "RIGHT", 8, 0)
heightBox:SetAutoFocus(false)



-- Save button
local saveButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
saveButton:SetSize(100, 25)
saveButton:SetPoint("TOPLEFT", widthBox, "BOTTOMLEFT", 0, -40)
saveButton:SetText("Save")
saveButton:SetScript("OnClick", function()
    -- Max shards
    local value = tonumber(editBox:GetText())
    if value then
        SM_Config.maxShards = value
        print("|cff55ff55[SM]|r Soul Shard limit set to " .. value)
    else
        print("|cffff5555[SM]|r Please enter a valid number.")
    end

	-- wywołanie funkcji z Soulmate.lua 
	if UpdateDeleteButtonText then 
		UpdateDeleteButtonText() 
	end
    -- Button size
    local w = tonumber(widthBox:GetText())
    local h = tonumber(heightBox:GetText())

    if w and h then
        SM_Config.buttonWidth = w
        SM_Config.buttonHeight = h

        if SM_DeleteShardButton then
            SM_DeleteShardButton:SetSize(w, h)
        end

        print("|cff55ff55[SM]|r Button size set to " .. w .. "x" .. h)
    else
        print("|cffff5555[SM]|r Invalid button size.")
    end
end)


-- Refresh function (called when openin  =g the panel)
panel:SetScript("OnShow", function()
    if not SM_Config.maxShards then
        SM_Config.maxShards = 20
    end
    editBox:SetText(SM_Config.maxShards)
	widthBox:SetText(SM_Config.buttonWidth or 64) 
	heightBox:SetText(SM_Config.buttonHeight or 64)
end)


-- Register panel in the new Settings API (TBC 2.5.5 compatible)
local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
Settings.RegisterAddOnCategory(category)
