local commandsHandler = {
    --- @param playerID number
    --- @param args table
    --- @param argsCount number
    --- @param silent boolean
    show = function(playerID, args, argsCount, silent)
        return MenuManager:ShowMainMenu(playerID)
    end,
    --- @param playerID number
    --- @param args table
    --- @param argsCount number
    --- @param silent boolean
    active = function(playerID, args, argsCount, silent)
        if argsCount < 2 then return end
        local handlers = {
            list = function(playerID, args, argsCount, silent)
                return MenuManager:ShowActiveQuestsList(playerID)
            end,
            set = function(playerID, args, argsCount, silent)
                if argsCount < 3 then return end
                local player = GetPlayer(playerID)
                if not player or not player:IsValid() or player:IsFakeClient() then return end
                local questID = args[3]
                if not questID then return end
                QuestManager:SetActiveQuest(player, questID, 0)
                return MenuManager:ShowMainMenu(playerID)
            end,
            info = function(playerID, args, argsCount, silent)
                if argsCount < 2 then return end
                return MenuManager:ShowActiveQuestInfo(playerID)
            end
        }

        local option = args[2]

        if not handlers[option] then return end
        return handlers[option](playerID, args, argsCount, silent)

    end,
    --- @param playerID number
    --- @param args table
    --- @param argsCount number
    --- @param silent boolean
    deactive = function(playerID, args, argsCount, silent)

        if argsCount < 2 then
            return
        end

        local player = GetPlayer(playerID)
        if not player or not player:IsValid() or player:IsFakeClient() then
            return
        end

        local questID = args[2]
        QuestManager:SetDeactiveQuest(player,questID)
        return MenuManager:ShowMainMenu(playerID)
    end
}

--- @param playerID number
--- @param args table
--- @param argsCount number
--- @param silent boolean
--- @param prefix string
local function OnQuestCommand(playerID, args, argsCount, silent, prefix)
    if playerID < 0 then
        return
    end

    if argsCount < 1 then
        return commandsHandler.show(playerID, args, argsCount, silent)
    end

    local option = args[1]
    if not commandsHandler[option] then
        return commandsHandler.show(playerID, args, argsCount, silent)
    end

    return commandsHandler[option](playerID, args, argsCount, silent)
end

commands:Register("quest", OnQuestCommand)