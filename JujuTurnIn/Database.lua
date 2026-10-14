local addonName, addonTable = ...
addonTable.Database = {}
local DB = addonTable.Database

local defaults = {
    enabled = true,
    selectedQuestID = 4802, -- Default: Juju Power
    autoComplete = true,
    mode = "smart" -- Default: Smart Mode enabled
}

function DB:Initialize()
    if not JujuTurnInDB then
        JujuTurnInDB = {}
    end

    for key, value in pairs(defaults) do
        if JujuTurnInDB[key] == nil then
            JujuTurnInDB[key] = value
        end
    end
    
    if not JujuTurnInDB.minimap then
        JujuTurnInDB.minimap = {
            hide = false, -- Default: Shown
            minimapPos = 45
        }
    end
    
    addonTable.Utils:Print("Configuration database loaded.", addonTable.Utils.Colors.Green)
end

function DB:Get(key)
    if not JujuTurnInDB then return defaults[key] end
    return JujuTurnInDB[key]
end

function DB:Set(key, value)
    if JujuTurnInDB then
        JujuTurnInDB[key] = value
    end
end