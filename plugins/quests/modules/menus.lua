MenuManager = {}
MenuManager.__index = {}

---comment
---@param playerID number
function MenuManager:ShowMainMenu(playerID)

    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then return end

    local menuID = "quests_mainmenu_".. os.clock()

    local options = {}
    local activeCommand = "sw_quest active list"
    if not QuestManager.playersQuest[playerID] or not QuestManager.playersQuest[playerID].active.questID then
        table.insert(options, {FetchTranslation("quests.menu.active.title", playerID) .. ": [----]", activeCommand})
    else
        activeCommand = "sw_quest active info"
        local activeQuestID = QuestManager.playersQuest[playerID].active.questID
        local activeQuestProgress =QuestManager.playersQuest[playerID].active.progress or 0
        local questGoal = QuestManager.quests[activeQuestID].goal
        local activeQuestTitle = FetchTranslation(QuestManager.quests[activeQuestID].title, playerID)
        table.insert(options, { FetchTranslation("quests.menu.active.title", playerID) .. ": [".. activeQuestTitle .."]", activeCommand })
        table.insert(options, { FetchTranslation("quests.menu.progress.title", playerID) .. ": [".. activeQuestProgress .."/".. questGoal .."]", activeCommand})
    end

    local historyCount = QuestManager:GetPlayerHistoryCount(playerID)
    local questsCount = QuestManager.questsCount
    local historyCommand = "sw_quest history list"
    if historyCount == 0 then
        historyCommand = ""
    end

    table.insert(options, {FetchTranslation("quests.menu.history.title", playerID) .. ": [" .. historyCount .."/".. questsCount .."]", historyCommand})

    if #options == 0 then
        return
    end

    menus:RegisterTemporary(menuID, FetchTranslation("quests.menu.title", playerID), QuestManager.menu.color or "21FF00", options)
    player:HideMenu()
    player:ShowMenu(menuID)
end
---comment
---@param playerID number
function MenuManager:ShowActiveQuestsList(playerID)
    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then return end

    local playerQuest = QuestManager.playersQuest[playerID]
    if not playerQuest or not playerQuest.active or not playerQuest.history then
        playerQuest = {active = {}, history = {}}
    end

    local menuID = "quests_showactivequestlist_".. os.clock()
    local options = {}

    local command = "sw_quest active set"

    for questID, quest in next, QuestManager.quests do
        if playerQuest.active.questID == questID or playerQuest.history[questID] then
            goto continue
        end
        table.insert(options, {FetchTranslation(quest.title, playerID), command.." "..questID})
        ::continue::
    end

    if #options == 0 then
        return
    end

    table.sort(options, function (a, b)
        return a[1] < b[1]
    end)

    menus:RegisterTemporary(menuID, FetchTranslation("quests.menu.title", playerID), QuestManager.menu.color or "21FF00", options)
    player:HideMenu()
    player:ShowMenu(menuID)
end

---comment
---@param playerID number
function MenuManager:ShowActiveQuestInfo(playerID)
    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then return end

    local playerActiveQuest = QuestManager.playersQuest[playerID].active

    if not playerActiveQuest or not playerActiveQuest.questID then
        return
    end

    local quest = QuestManager.quests[playerActiveQuest.questID]
    if not quest then
        return
    end
    local menuID = "quests_showactivequestinfo".. os.clock()
    local options = {
        { FetchTranslation("quests.menu.progress.title", playerID) .. ": [".. playerActiveQuest.progress .."/".. quest.goal .."]", ""},
        { FetchTranslation("quests.menu.deactive.title", playerID), "sw_quest deactive ".. playerActiveQuest.questID},
    }

    if #options == 0 then
        return
    end

    menus:RegisterTemporary(menuID, "[:. ".. FetchTranslation(quest.title, playerID) .." .:]", QuestManager.menu.color or "21FF00", options)
    player:HideMenu()
    player:ShowMenu(menuID)

end