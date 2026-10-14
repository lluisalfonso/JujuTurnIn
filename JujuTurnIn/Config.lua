local addonName, addonTable = ...
addonTable.Config = {}
local Config = addonTable.Config

function Config:CreatePanel()
    local DB = addonTable.Database
    local U = addonTable.Utils
    local C = addonTable.Constants

    local panel = CreateFrame("Frame", "JujuTurnInPanel", UIParent)
    panel.name = "JujuTurnIn"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("JujuTurnIn " .. U:ColorString("v1.0.0", U.Colors.Gold))

    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetText("Automates E'ko turn-ins with Witch Doctor Mau'ari in Winterspring.")

    -- Addon status checkbox
    local cbEnabled = CreateFrame("CheckButton", "JTI_CbEnabled", panel, "InterfaceOptionsCheckButtonTemplate")
    cbEnabled:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -16)
    _G[cbEnabled:GetName() .. "Text"]:SetText("Enable JujuTurnIn")
    cbEnabled.tooltipText = "Toggle the addon on or off entirely."
    cbEnabled:SetScript("OnClick", function(self)
        DB:Set("enabled", self:GetChecked())
    end)

    -- Auto-complete checkbox
    local cbAuto = CreateFrame("CheckButton", "JTI_CbAuto", panel, "InterfaceOptionsCheckButtonTemplate")
    cbAuto:SetPoint("TOPLEFT", cbEnabled, "BOTTOMLEFT", 0, -8)
    _G[cbAuto:GetName() .. "Text"]:SetText("Automatically complete quests")
    cbAuto.tooltipText = "Instantly complete quests without manual interaction."
    cbAuto:SetScript("OnClick", function(self)
        DB:Set("autoComplete", self:GetChecked())
    end)

    -- Smart mode checkbox
    local cbSmart = CreateFrame("CheckButton", "JTI_CbSmart", panel, "InterfaceOptionsCheckButtonTemplate")
    cbSmart:SetPoint("TOPLEFT", cbAuto, "BOTTOMLEFT", 0, -8)
    _G[cbSmart:GetName() .. "Text"]:SetText("Smart Mode (Prioritize highest count)")
    cbSmart.tooltipText = "Prioritizes turning in the E'kos you have the most of."
    cbSmart:SetScript("OnClick", function(self)
        DB:Set("mode", self:GetChecked() and "smart" or "manual")
    end)

    -- Minimap button checkbox
    local cbMinimap = CreateFrame("CheckButton", "JTI_CbMinimap", panel, "InterfaceOptionsCheckButtonTemplate")
    cbMinimap:SetPoint("TOPLEFT", cbSmart, "BOTTOMLEFT", 0, -8)
    _G[cbMinimap:GetName() .. "Text"]:SetText("Show minimap button")
    cbMinimap.tooltipText = "Show or hide the JujuTurnIn minimap button."
    cbMinimap:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        local hide = not checked
        
        if JujuTurnInDB and JujuTurnInDB.minimap then
            JujuTurnInDB.minimap.hide = hide
        end
        
        local icon = LibStub and LibStub("LibDBIcon-1.0", true)
        if icon then
            if hide then
                icon:Hide("JujuTurnIn")
            else
                icon:Show("JujuTurnIn")
            end
        end
    end)

    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetSize(350, 1)
    line:SetPoint("TOPLEFT", cbMinimap, "BOTTOMLEFT", 0, -16)
    line:SetColorTexture(0.3, 0.3, 0.3, 0.6)

    -- Manual Juju Selection List
    local radioLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    radioLabel:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -16)
    radioLabel:SetText("Favorite Juju (Used in Manual Mode):")

    local jujus = {
        { id = 4806, name = "Juju Might (+Attack Power)" },
        { id = 4802, name = "Juju Power (+Strength)" },
        { id = 4801, name = "Juju Flurry (+Attack Speed)" },
        { id = 4803, name = "Juju Ember (+Fire Resistance)" },
        { id = 4804, name = "Juju Chill (+Frost Resistance)" },
        { id = 4805, name = "Juju Escape (+Dodge)" },
        { id = 4807, name = "Juju Guile (+Intellect)" },
    }

    local radioButtons = {}
    local function UpdateRadioButtons(selectedID)
        for id, button in pairs(radioButtons) do
            button:SetChecked(id == selectedID)
        end
    end

    local lastAnchor = radioLabel
    for i, jujuData in ipairs(jujus) do
        local rb = CreateFrame("CheckButton", "JTI_RB_" .. jujuData.id, panel, "UIRadioButtonTemplate")
        rb:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", (i == 1 and 8 or 0), -8)
        _G[rb:GetName() .. "Text"]:SetText(U:ColorString(jujuData.name, U.Colors.White))
        rb.questID = jujuData.id
        
        rb:SetScript("OnClick", function(self)
            DB:Set("selectedQuestID", self.questID)
            UpdateRadioButtons(self.questID)
            U:Print("Favorite Juju saved: " .. U:ColorString(jujuData.name, U.Colors.Blue))
        end)
        
        radioButtons[jujuData.id] = rb
        lastAnchor = rb
    end

    panel:SetScript("OnShow", function()
        cbEnabled:SetChecked(DB:Get("enabled"))
        cbAuto:SetChecked(DB:Get("autoComplete"))
        cbSmart:SetChecked(DB:Get("mode") == "smart")
        
        local hideMinimap = JujuTurnInDB and JujuTurnInDB.minimap and JujuTurnInDB.minimap.hide
        cbMinimap:SetChecked(not hideMinimap)
        
        UpdateRadioButtons(DB:Get("selectedQuestID"))
    end)

    local category
    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, "JujuTurnIn")
        if Settings.RegisterAddOnCategory then
            Settings.RegisterAddOnCategory(category)
        end
        addonTable.settingsCategory = category
    else
        panel.name = "JujuTurnIn"
        InterfaceOptions_AddCategory(panel)
    end
end

function addonTable:OpenConfig()
    local opened = false
    if addonTable.settingsCategory then
        if addonTable.settingsCategory.GetID then
            local categoryID = addonTable.settingsCategory:GetID()
            if categoryID then
                opened = pcall(function() Settings.OpenToCategory(categoryID) end)
            end
        end
        if not opened then
            opened = pcall(function() Settings.OpenToCategory(addonTable.settingsCategory) end)
        end
    end
    
    if not opened then
        local ok = pcall(function() Settings.OpenToCategory("JujuTurnIn") end)
        if not ok and JujuTurnInPanel then
            pcall(function() 
                InterfaceOptionsFrame_OpenToCategory(JujuTurnInPanel)
                InterfaceOptionsFrame_OpenToCategory(JujuTurnInPanel)
            end)
        end
    end
end