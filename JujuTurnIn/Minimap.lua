local addonName, addonTable = ...

function addonTable:InitializeMinimapButton()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    local icon = LibStub and LibStub("LibDBIcon-1.0", true)

    if LDB and icon then
        local jujuLDB = LDB:NewDataObject("JujuTurnIn", {
            type = "launcher",
            icon = "Interface\\Icons\\inv_misc_monsterscales_11",
            
            OnClick = function(self, button)
                if button == "LeftButton" then
                    if addonTable.OpenConfig then
                        addonTable:OpenConfig()
                    else
                        if Settings and Settings.OpenToCategory then
                            Settings.OpenToCategory("JujuTurnIn")
                        end
                    end
                elseif button == "RightButton" then
                    if SlashCmdList["JUJUTURNIN"] then
                        SlashCmdList["JUJUTURNIN"]("bags")
                    end
                end
            end,
            
            OnTooltipShow = function(tooltip)
                local U = addonTable.Utils
                tooltip:AddLine("JujuTurnIn", 1, 0.87, 0)
                if U then
                    tooltip:AddLine("Left Click: " .. U:ColorString("Addon Options", U.Colors.White))
                    tooltip:AddLine("Right Click: " .. U:ColorString("Show E'kos in Bags", U.Colors.White))
                else
                    tooltip:AddLine("Left Click: Addon Options")
                    tooltip:AddLine("Right Click: Show E'kos in Bags")
                end
            end,
        })

        icon:Register("JujuTurnIn", jujuLDB, JujuTurnInDB.minimap)
    end
end