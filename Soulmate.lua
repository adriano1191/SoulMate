-- SavedVariables table
SM_Config = SM_Config or {}

-- Default settings
local DEFAULT_MAX_SHARDS = 20
local SOUL_SHARD_ID = 6265 -- Soul Shard item ID in TBC

-- Returns the configured maximum shard limit
local function GetMaxShards()
    if type(SM_Config.maxShards) ~= "number" then
        SM_Config.maxShards = DEFAULT_MAX_SHARDS
    end
    return SM_Config.maxShards
end

-- Sets the maximum allowed Soul Shards
local function SetMaxShards(value)
    local num = tonumber(value)
    if not num or num < 0 then
        print("|cffff5555[SM]|r Please enter a number >= 0.")
        return
    end

    SM_Config.maxShards = num
    print("|cff55ff55[SM]|r Soul Shard limit set to: " .. num)
end

-- Slash command: /sm
SLASH_SM1 = "/sm"
SlashCmdList["SM"] = function(msg)
    msg = msg and msg:match("^%s*(.-)%s*$") or ""

    if msg == "" then
        print("|cff55ff55[SM]|r Available commands:")
        print("  /sm <number>  - Set max Soul Shards")
        print("  /sm delete    - Delete excess Soul Shards")
        print("  /sm reset     - Reset all settings to default")
        return
    end

    if msg == "delete" then
        DeleteExtraShards()
        return
    end

    if msg == "reset" then
        SM_ResetConfig()
        UpdateDeleteButtonText()
        return
    end

    local num = tonumber(msg)
    if num then
        SetMaxShards(num)
		UpdateDeleteButtonText()
        return
    end

    print("|cffff5555[SM]|r Unknown command:", msg)
end



-- Scans all bags and returns total shard count + their locations
local function FindAllSoulShards()
    local total = 0
    local slots = {}

    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID == SOUL_SHARD_ID then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    total = total + info.stackCount
                    table.insert(slots, { bag = bag, slot = slot, count = info.stackCount })
                end
            end
        end
    end

    return total, slots
end

-- Deletes excess Soul Shards above the configured limit
function DeleteExtraShards()

	if UnitAffectingCombat("player") or InCombatLockdown() then
		print("Cannot delete now, leave combat first")
		return
	end

	

    local maxShards = GetMaxShards()
    local total, slots = FindAllSoulShards()

    if total <= maxShards then
        print("|cff55ff55[SM]|r No excess Soul Shards.")
        return
    end

    local shard = slots[1]
    if not shard then
        print("|cffff0000[SM]|r No Soul Shard found.")
        return
    end

    ClearCursor()
    C_Container.PickupContainerItem(shard.bag, shard.slot)

    if not GetCursorInfo() then
        print("|cffffaa00[SM]|r Failed to pick up Soul Shard.")
        return
    end

    DeleteCursorItem()
    ClearCursor()

    print("|cff55ff55[SM]|r Removed 1 excess Soul Shard.")
end







-- Slash command for manual deletion
SLASH_SMDELETE1 = "/smdelete"
SlashCmdList["SMDELETE"] = DeleteExtraShards




local deleteButton = CreateFrame("Button", "SM_DeleteShardButton", UIParent, "BackdropTemplate")

deleteButton:SetSize(
    SM_Config.buttonWidth or 64,
    SM_Config.buttonHeight or 64
)

deleteButton:SetPoint("CENTER", UIParent, "CENTER", SM_Config.buttonX or 0, SM_Config.buttonY or -200)

deleteButton:SetMovable(true)
deleteButton:EnableMouse(true)
deleteButton:RegisterForDrag("LeftButton")
deleteButton:SetScript("OnDragStart", function(self)
    if IsAltKeyDown() then
        self:StartMoving()
    end
end)


deleteButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, _, x, y = self:GetPoint()
    SM_Config.buttonX = x
    SM_Config.buttonY = y
end)



-- Ikona
local icon = deleteButton:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
icon:SetTexture("Interface\\Icons\\INV_Misc_Gem_Amethyst_02")
deleteButton.icon = icon

-- Ramka
deleteButton:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
})
deleteButton:SetBackdropBorderColor(1, 1, 1, 1)

-- Highlight (po najechaniu)
local highlight = deleteButton:CreateTexture(nil, "HIGHLIGHT")
highlight:SetColorTexture(1, 1, 1, 0.2)
highlight:SetAllPoints()

-- Pushed (po kliknięciu)
local pushed = deleteButton:CreateTexture(nil, "ARTWORK")
pushed:SetColorTexture(0, 0, 0, 0.3)
pushed:SetAllPoints()
deleteButton:SetPushedTexture(pushed)

-- Kliknięcie
deleteButton:SetScript("OnClick", function()
    DeleteExtraShards()
end)

local text = deleteButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER", deleteButton, "CENTER", 0, 0)
text:SetText("Delete")

text:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- obrys
deleteButton.text = text


--deleteButton:Hide()

function UpdateDeleteButtonText()
    local total = select(1, FindAllSoulShards())
    local maxShards = GetMaxShards()
	if total > maxShards then
		text:SetTextColor(1, 0.2, 0.2, 1) -- czerwony 
	else
		text:SetTextColor(1, 1, 1, 1) -- biały 
	end
	
    deleteButton.text:SetText(total .. " / " .. maxShards)
end

function SM_ResetConfig()
    -- Reset wartości w SavedVariables
    SM_Config.maxShards = 32
    SM_Config.buttonWidth = 64
    SM_Config.buttonHeight = 64
    SM_Config.buttonX = 0
    SM_Config.buttonY = -200  -- środek ekranu, lekko niżej

    -- Jeśli guzik istnieje, zresetuj go natychmiast
    if SM_DeleteShardButton then
        SM_DeleteShardButton:SetSize(64, 64)
        SM_DeleteShardButton:ClearAllPoints()
        SM_DeleteShardButton:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    end

    print("|cff55ff55[SM]|r Settings reset to defaults.")
end



-- Event handler frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        print("|cff55ff55[SM]|r SoulMate loaded. Current limit: " .. GetMaxShards())
		print("|cff55ff55[SM]|r ALT + Left Click to move the Soul Shard button ")
		deleteButton:SetSize(
			SM_Config.buttonWidth or 64,
			SM_Config.buttonHeight or 64
		)
		UpdateDeleteButtonText()
    elseif event == "BAG_UPDATE" then
		UpdateDeleteButtonText()
	elseif event == "PLAYER_REGEN_ENABLED" then
		UpdateDeleteButtonText()	
	end

end)