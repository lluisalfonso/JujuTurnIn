local addonName, addonTable = ...
addonTable.QuestHandler = {}
local QH = addonTable.QuestHandler

local function GetSmartQuestID()
    local U = addonTable.Utils
    local C = addonTable.Constants

    local bestQuestID = nil
    local maxCount = 0

    for questID, data in pairs(C.Quests) do
        local count = U:GetItemCount(data.ekoID)
        if count >= 3 and count > maxCount then
            maxCount = count
            bestQuestID = questID
        end
    end

    return bestQuestID, maxCount
end

function QH:OnGossipShow()
    local DB = addonTable.Database
    local U = addonTable.Utils
    local C = addonTable.Constants

    if not C.NPC_ID or not U:IsTargetMauari() then return end

    local targetQuestID
    local mode = DB:Get("mode")

    if mode == "smart" then
        local smartID, count = GetSmartQuestID()
        if smartID then
            targetQuestID = smartID
        else
            U:Print("Smart Mode: No E'kos available for turn-in.", U.Colors.Red)
            return
        end
    else
        targetQuestID = DB:Get("selectedQuestID")
        local questData = C.Quests[targetQuestID]
        if questData then
            local count = U:GetItemCount(questData.ekoID)
            if count < 3 then
                U:Print(string.format("Manual Mode: Not enough %s (have %d, need 3).", U:ColorString(questData.name, U.Colors.Blue), count), U.Colors.Red)
                return
            end
        end
    end

    local questData = C.Quests[targetQuestID]
    if not questData then return end

    -- 1. Check Active Quests (Ready to turn-in) using Blizzard IDs
    if C_GossipInfo and C_GossipInfo.GetActiveQuests then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        for _, questInfo in ipairs(activeQuests) do
            if questInfo.questID == targetQuestID then
                U:Print("Turning in: " .. U:ColorString(questData.juju, U.Colors.Green))
                C_GossipInfo.SelectActiveQuest(questInfo.questID)
                return
            end
        end
    end

    -- 2. Check Available Quests (Ready to pick up) using Blizzard IDs
    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        for _, questInfo in ipairs(availableQuests) do
            if questInfo.questID == targetQuestID then
                U:Print("Selecting quest: " .. U:ColorString(questData.title, U.Colors.Blue))
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                return
            end
        end
    end
end

function QH:HandleQuestDialog(event)
    local DB = addonTable.Database
    local U = addonTable.Utils
    if not DB:Get("autoComplete") or not U:IsTargetMauari() then return end

    if event == "QUEST_DETAIL" then
        AcceptQuest()
    elseif event == "QUEST_PROGRESS" then
        CompleteQuest()
    elseif event == "QUEST_COMPLETE" then
        GetQuestReward(1)
    end
end