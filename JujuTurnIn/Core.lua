local addonName, addonTable = ...

local frame = CreateFrame("Frame")
addonTable.CoreFrame = frame

local function OnEvent(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addonTable.Database:Initialize()
        
        if addonTable.Config and addonTable.Config.CreatePanel then
            local success, err = pcall(addonTable.Config.CreatePanel, addonTable.Config)
            if not success then
                addonTable.Utils:Print("Warning: Failed to load config panel (Error: " .. tostring(err) .. ")", addonTable.Utils.Colors.Red)
            end
        end
        
        if addonTable.InitializeMinimapButton then
            addonTable:InitializeMinimapButton()
        end
        
        addonTable.Utils:Print("Version 1.0.0 loaded successfully.", addonTable.Utils.Colors.Green)
        self:UnregisterEvent("ADDON_LOADED")
        
    elseif event == "GOSSIP_SHOW" then
        if addonTable.Database:Get("enabled") and addonTable.Utils:IsTargetMauari() then
            addonTable.QuestHandler:OnGossipShow()
        end
        
    elseif event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
        if addonTable.Database:Get("enabled") then
            addonTable.QuestHandler:HandleQuestDialog(event)
        end
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
frame:SetScript("OnEvent", OnEvent)

local function SetSelectedJuju(questID, jujuName)
    addonTable.Database:Set("selectedQuestID", questID)
    addonTable.Utils:Print("Favorite Juju saved: " .. addonTable.Utils:ColorString(jujuName, addonTable.Utils.Colors.Blue))
end

SLASH_JUJUTURNIN1 = "/juju"
SlashCmdList["JUJUTURNIN"] = function(msg)
    msg = msg and msg:trim():lower() or ""
    local U = addonTable.Utils
    local DB = addonTable.Database
    local C = addonTable.Constants
    
    if msg == "flurry" or msg == "4801" then SetSelectedJuju(4801, "Juju Flurry")
    elseif msg == "power" or msg == "4802" then SetSelectedJuju(4802, "Juju Power")
    elseif msg == "ember" or msg == "4803" then SetSelectedJuju(4803, "Juju Ember")
    elseif msg == "chill" or msg == "4804" then SetSelectedJuju(4804, "Juju Chill")
    elseif msg == "escape" or msg == "4805" then SetSelectedJuju(4805, "Juju Escape")
    elseif msg == "might" or msg == "4806" then SetSelectedJuju(4806, "Juju Might")
    elseif msg == "guile" or msg == "4807" then SetSelectedJuju(4807, "Juju Guile")
    
    elseif msg == "mode" then
        local currentMode = DB:Get("mode")
        local newMode = (currentMode == "manual") and "smart" or "manual"
        DB:Set("mode", newMode)
        
        local modeText = (newMode == "smart") 
            and U:ColorString("SMART", U.Colors.Green)
            or U:ColorString("MANUAL", U.Colors.Blue)
        U:Print("Selection mode changed to: " .. modeText)
        
    elseif msg == "bags" then
        U:Print("--- E'KO INVENTORY REPORT ---", U.Colors.Gold)
        for _, data in pairs(C.Quests) do
            local count = U:GetItemCount(data.ekoID)
            
            if count == 0 then
                U:Print(string.format("  - %s: %s", 
                    U:ColorString(data.name, U.Colors.White), 
                    U:ColorString("0 E'kos", "808080")
                ))
            else
                local turnins = math.floor(count / 3)
                local leftovers = count % 3
                local countColor = (count >= 3) and U.Colors.Green or U.Colors.Red
                local leftoverText = (leftovers > 0) and string.format(" (%s leftover!)", U:ColorString(tostring(leftovers), U.Colors.Gold)) or ""
                local deliveryWord = (turnins == 1) and "turn-in" or "turn-ins"
                
                U:Print(string.format("  - %s: %s E'kos -> %s %s%s", 
                    U:ColorString(data.name, U.Colors.Blue), 
                    U:ColorString(tostring(count), countColor),
                    U:ColorString(tostring(turnins), U.Colors.Green),
                    deliveryWord,
                    leftoverText
                ))
            end
        end
        
    elseif msg == "toggle" then
        local newState = not DB:Get("enabled")
        DB:Set("enabled", newState)
        local statusText = newState and U:ColorString("ENABLED", U.Colors.Green) or U:ColorString("DISABLED", U.Colors.Red)
        U:Print("Addon is now: " .. statusText)
        
    elseif msg == "autocomplete" then
        local newState = not DB:Get("autoComplete")
        DB:Set("autoComplete", newState)
        local statusText = newState and U:ColorString("ENABLED", U.Colors.Green) or U:ColorString("DISABLED", U.Colors.Red)
        U:Print("Automatic quest completion: " .. statusText)
        
    elseif msg == "minimap" then
        local icon = LibStub and LibStub("LibDBIcon-1.0", true)
        if icon and JujuTurnInDB and JujuTurnInDB.minimap then
            JujuTurnInDB.minimap.hide = not JujuTurnInDB.minimap.hide
            if JujuTurnInDB.minimap.hide then
                icon:Hide("JujuTurnIn")
                U:Print("Minimap button: " .. U:ColorString("HIDDEN", U.Colors.Red))
            else
                icon:Show("JujuTurnIn")
                U:Print("Minimap button: " .. U:ColorString("SHOWN", U.Colors.Green))
            end
        else
            U:Print("Cannot toggle minimap. LibDBIcon is not active.", U.Colors.Red)
        end
        
    elseif msg == "" or msg == "help" then
        U:Print("JujuTurnIn Command Options:")
        U:Print("  /juju [might|power...] - Change favorite Juju.")
        U:Print("  /juju mode             - Toggle between Manual and Smart mode.")
        U:Print("  /juju bags             - Check E'kos in bags.")
        U:Print("  /juju minimap          - Show or hide the minimap button.")
        U:Print("  /juju toggle           - Enable/disable the addon.")
        U:Print("  /juju autocomplete     - Toggle automatic completion.")
        U:Print("  /juju status           - Show current status.")
        
    elseif msg == "status" then
        local activeJuju = C.Quests[DB:Get("selectedQuestID")].juju
        U:Print("--- JUJUTURNIN CURRENT STATUS ---", U.Colors.Gold)
        U:Print("General Status: " .. (DB:Get("enabled") and U:ColorString("Active", U.Colors.Green) or U:ColorString("Inactive", U.Colors.Red)))
        U:Print("Favorite Juju: " .. U:ColorString(activeJuju, U.Colors.Blue))
        U:Print("Selection Mode: " .. U:ColorString(DB:Get("mode"):upper(), U.Colors.Blue))
        U:Print("Auto-Complete: " .. (DB:Get("autoComplete") and U:ColorString("Yes", U.Colors.Green) or U:ColorString("No", U.Colors.Red)))
    else
        U:Print("Unknown command. Type /juju for help.", U.Colors.Red)
    end
end