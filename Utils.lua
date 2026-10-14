local addonName, addonTable = ...
addonTable.Utils = {}
local U = addonTable.Utils

U.Colors = {
    Gold  = "ffdf00",
    Blue  = "00c0ff",
    Green = "00ff00",
    Red   = "ff0000",
    White = "ffffff"
}

function U:ColorString(text, hexColor)
    return string.format("|cff%s%s|r", hexColor or self.Colors.White, text)
end

function U:Print(msg, colorHex)
    local prefix = string.format("[%s]", self:ColorString(addonName, self.Colors.Gold))
    local formattedMsg = colorHex and self:ColorString(msg, colorHex) or msg
    print(prefix .. " " .. tostring(formattedMsg))
end

function U:IsTargetMauari()
    local guid = UnitGUID("target")
    if not guid then return false end
    
    local type, _, _, _, _, npcID = strsplit("-", guid)
    return type == "Creature" and tonumber(npcID) == addonTable.Constants.NPC_ID
end

function U:GetItemCount(targetItemID)
    if not targetItemID then return 0 end
    local count = 0
    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        if numSlots and numSlots > 0 then
            for slot = 1, numSlots do
                local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
                if containerInfo and containerInfo.itemID == targetItemID then
                    count = count + (containerInfo.stackCount or 0)
                end
            end
        end
    end
    return count
end