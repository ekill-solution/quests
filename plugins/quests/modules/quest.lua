QuestManager = {
    debug = false,
    tableName = "sw_quests",
    prefix = "{olive}[Quest System]{default}",
    menu = {
        color = "00FF22"
    },
    quests = {},
    questsCount = 0,
    playersQuest = {},
    rewardHandlers = {
        shop_points = function(playerID, reward)
            Utils.HandleDebug("Awarding shop points: " .. tostring(reward.value) .. " to playerID: " .. tostring(playerID))
            exports["shop-core"]:GiveCredits(playerID, reward.value)
        end,
        shop_item = function(playerID, reward)
            Utils.HandleDebug("Awarding shop item: " .. tostring(reward.value) .. " to playerID: " .. tostring(playerID))
            exports["shop-core"]:GiveItem(playerID, reward.value, false)
        end        
    }
}
QuestManager.__index = QuestManager

---@function QuestManager:Initialize()
function QuestManager:Initialize()

    config:Reload("quests")
    self.debug = config:Fetch("quests.debug") or false
    self.tableName = tostring(config:Fetch("quests.database.tablename") or "sw_quests")
    self.prefix = tostring(config:Fetch("quests.prefix") or "{olive}[Quest System]{default}")
    self.menu.color = tostring(config:Fetch("quests.menu.color") or "00FF22")
    Utils.HandleDebug("Initializing QuestManager...")

    local fetchedQuests = config:Fetch("quests.list")

    if not fetchedQuests or type(fetchedQuests) ~= "table" then
        Utils.HandleDebug("No quests found in configuration.")
        self.quests = {}
        self.questsCount = 0
    else
        self.quests = {}
        self.questsCount = 0
        for _, quest in next, fetchedQuests do
            self.quests[quest.id] = quest
            self.questsCount = self.questsCount + 1
            Utils.HandleDebug("Loaded quest: " .. tostring(quest.id))
        end
    end

    Utils.HandleDebug("Total quests loaded: " .. tostring(self.questsCount))

    db = Database(tostring(config:Fetch("quests.database.connection")))
    if not db:IsConnected() then
        Utils.HandleError("Cannot connect to database.")
        return
    end

    db:QueryBuilder():Table(self.tableName):Create({
        steamID = "string|max:17|primary",
        active = "json",
        history ="json"
    }):Execute(function(err, result)
        if Utils.HandleError(err) then return end
        Utils.HandleDebug("Table " .. self.tableName .. " ensured.")
    end)
    Utils.HandleDebug("QuestManager initialization complete.")
end

---@function QuestManager:LoadPlayer(playerID)
---@param playerID number
function QuestManager:LoadPlayer(playerID)
    Utils.HandleDebug("Loading quests for playerID: " .. tostring(playerID))

    if not db:IsConnected() then
        Utils.HandleDebug("Database is not connected. Cannot load player quests.")
        return
    end

    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object for playerID: " .. tostring(playerID))
        return
    end

    local qb = db:QueryBuilder():Table(self.tableName):Select({'active','history'}):Where('steamID','=',tostring(player:GetSteamID()))
    qb:Execute(function(err, result)
        if Utils.HandleError(err) then return end

        self.playersQuest[playerID] = { active = {}, history = {} }

        if #result == 0 then
            Utils.HandleDebug("No data found for playerID: " .. tostring(playerID))
            return
        end

        local playerData = result[#result]
        local playerActive = json.decode(playerData.active) or {}
        local playerHistory = json.decode(playerData.history) or {}
        Utils.HandleDebug("Loaded player active quests: " .. tostring(playerData.active))
        Utils.HandleDebug("Loaded player quest history: " .. tostring(playerData.history))

        if playerActive and playerActive.questID then
            self:SetActiveQuest(player, playerActive.questID, playerActive.progress)
        end

        self.playersQuest[playerID].history = playerHistory or {}
    end)
end

---@function QuestManager:SavePlayer(playerID)
---@param playerID number
---@param reset boolean
function QuestManager:SavePlayer(playerID, reset)
    Utils.HandleDebug("Saving quests for playerID: " .. tostring(playerID))

    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object for playerID: " .. tostring(playerID))
        return
    end

    if not self.playersQuest[playerID] then
        Utils.HandleDebug("No quest data found for playerID: " .. tostring(playerID))
        return
    end

    local activeQuest = self.playersQuest[playerID].active or {}
    local historyQuest = self.playersQuest[playerID].history or {}

    local qb = db:QueryBuilder():Table(self.tableName):Insert({tostring(player:GetSteamID()), activeQuest, historyQuest }):OnDuplicate({
        active = activeQuest,
        history = historyQuest
    })

    qb:Execute(function(err, result)
        if Utils.HandleError(err) then return end
        Utils.HandleDebug("Quests saved for playerID: " .. tostring(playerID))

        if reset then
            self.playersQuest[playerID] = nil
            Utils.HandleDebug("Quest data reset for playerID: " .. tostring(playerID))
        end
    end)
end

---@function QuestManager:GetPlayerHistoryCount(playerID)
---@param playerID number
function QuestManager:GetPlayerHistoryCount(playerID)
    Utils.HandleDebug("Getting history count for playerID: " .. tostring(playerID))

    -- Check if the player has any history data
    local playerHistory = self.playersQuest[playerID] and self.playersQuest[playerID].history
    if not playerHistory then
        Utils.HandleDebug("No history data found for playerID: " .. tostring(playerID))
        return 0 -- No completed quests
    end

    -- Count the number of completed quests (entries in history)
    local completedQuestsCount = 0
    for _, completed in next, playerHistory do
        if completed then
            completedQuestsCount = completedQuestsCount + 1
        end
    end

    Utils.HandleDebug("Player " .. tostring(playerID) .. " has completed " .. tostring(completedQuestsCount) .. " quests.")
    return completedQuestsCount
end

---@function QuestManager:SetActiveQuest(player, questID, progress)
---@param player Player
---@param questID string
---@param progress number|nil
function QuestManager:SetActiveQuest(player, questID, progress)
    Utils.HandleDebug("Attempting to set active quest for player: " .. tostring(player) .. ", questID: " .. tostring(questID))

    if not progress then
        progress = 0
    end

    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object. Aborting quest activation.")
        return
    end

    local playerID = player:GetSlot()
    Utils.HandleDebug("Player ID resolved: " .. tostring(playerID))

    local quest = self.quests[questID]
    if not quest then
        Utils.HandleDebug("Quest not found: " .. tostring(questID))
        return
    end

    if not self.playersQuest[playerID] then
        Utils.HandleDebug("No quest data found for playerID: " .. tostring(playerID) .. ". Initializing quest data.")
        self.playersQuest[playerID] = { active = {}, history = {} }
    end

    self.playersQuest[playerID].active = { questID = questID, progress = progress }
    Utils.HandleDebug("Quest set successfully for playerID: " .. tostring(playerID) .. ", Quest: " .. tostring(questID) .. ", Progress: " .. tostring(progress))
    
    local message = FetchTranslation("quests.activated", playerID)
    :gsub("{QUEST_TITLE}", FetchTranslation(quest.title, playerID))
    :gsub("{PROGRESS}", progress)
    :gsub("{QUEST_GOAL}", quest.goal)

    local messageDescription = FetchTranslation(quest.description, playerID)
    :gsub("{QUEST_GOAL}", quest.goal)

    Utils.ReplyToCommand(playerID, message)
    Utils.ReplyToCommand(playerID, messageDescription)
end

---@function QuestManager:SetActiveQuest(player, questID, progress)
---@param player Player
---@param questID string
function QuestManager:SetDeactiveQuest(player, questID)
    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object. Aborting quest activation.")
        return
    end
    local playerID = player:GetSlot()

    local quest = self.quests[questID]
    if not quest then
        Utils.HandleDebug("Quest not found: " .. tostring(questID))
        return
    end
    if not self.playersQuest[playerID].active or not self.playersQuest[playerID].active.questID == questID then
        return
    end

    self.playersQuest[playerID].active = {}

    local message = FetchTranslation("quests.deactivated", playerID)
    :gsub("{QUEST_TITLE}", FetchTranslation(quest.title, playerID))
    Utils.ReplyToCommand(playerID, message)

end

---@function QuestManager:OnQuestEvent(player, eventProgressKey, eventData)
---@param player Player
---@param eventProgressKey string
---@param eventData table|nil
function QuestManager:OnQuestEvent(player, eventProgressKey, eventData)
    Utils.HandleDebug("OnQuestEvent triggered for player: " .. tostring(player) .. ", eventProgressKey: " .. tostring(eventProgressKey))

    if not eventData then
        eventData = {}
    end

    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object. Aborting quest event handling.")
        return
    end

    local playerID = player:GetSlot()
    Utils.HandleDebug("Player ID resolved: " .. tostring(playerID))

    if not self.playersQuest[playerID] then
        Utils.HandleDebug("No active quest data found for playerID: " .. tostring(playerID))
        return
    end

    local activeQuest = self.playersQuest[playerID].active

    if not activeQuest or not activeQuest.questID then
        Utils.HandleDebug("No active quest or questID found for playerID: " .. tostring(playerID))
        return
    end

    local quest = self.quests[activeQuest.questID]
    if not quest then
        Utils.HandleDebug("Quest not found for questID: " .. tostring(activeQuest.questID))
        return
    end

    Utils.HandleDebug("Active quest found: " .. tostring(activeQuest.questID) .. ", progress: " .. tostring(activeQuest.progress))

    if quest.progress_key ~= eventProgressKey then
        Utils.HandleDebug("Event progress key mismatch. Expected: " .. tostring(quest.progress_key) .. ", Got: " .. tostring(eventProgressKey))
        return
    end

    if not self:CheckQuestRequirements(player, activeQuest.questID, eventData) then
        Utils.HandleDebug("Quest requirements not met for questID: " .. tostring(activeQuest.questID))
        return
    end

    local increment = eventData.progress or 1
    activeQuest.progress = activeQuest.progress + increment
    Utils.HandleDebug("Progress updated for questID: " .. tostring(activeQuest.questID) .. ". New progress: " .. tostring(activeQuest.progress))

    if activeQuest.progress >= quest.goal then
        Utils.HandleDebug("Quest goal reached for questID: " .. tostring(activeQuest.questID))
        self:MarkAsComplete(player, activeQuest.questID)
        return
    end

    local message = FetchTranslation("quests.progress", playerID)
        :gsub("{QUEST_TITLE}", FetchTranslation(quest.title, playerID))
        :gsub("{PROGRESS}", tostring(activeQuest.progress))
        :gsub("{QUEST_GOAL}", tostring(quest.goal))

    Utils.HandleDebug("Sending progress update message to playerID: " .. tostring(playerID))
    Utils.ReplyToCommand(playerID, message)
end

---@function QuestManager:CheckQuestRequirements(player, questID, eventData)
---@param player Player
---@param questID string
---@param eventData table
function QuestManager:CheckQuestRequirements(player, questID, eventData)
    Utils.HandleDebug("Starting CheckQuestRequirements for questID: " .. json.encode(questID))

    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Player is invalid or is a fake client.")
        return false
    end

    local quest = self.quests[questID]
    if not quest then
        Utils.HandleDebug("Quest with ID " .. tostring(questID) .. " not found.")
        return false
    end

    local require = quest.require or {}
    Utils.HandleDebug("Quest requirements: " .. tostring(require))

    if require.map then
        local type = type(require.map)
        local map = server:GetMap()
        Utils.HandleDebug("Checking map requirement. Type: " .. type)

        if type == "string" then
            if require.map ~= map then
                Utils.HandleDebug("Map mismatch. Required: " .. require.map .. ", Current: " .. tostring(map))
                return false
            end
        elseif type == "table" then
            local mapFound = false
            for _, value in next, require.map do
                Utils.HandleDebug("Checking map: " .. value .. ", Current" .. tostring(map))
                if value == map then
                    mapFound = true
                    break
                end
            end
            if not mapFound then
                Utils.HandleDebug("No matching map found in required maps.")
                return false
            end
        end
    end

    if require.weapon then
        local type = type(require.weapon)
        Utils.HandleDebug("Checking weapon requirement. Type: " .. type)
        local weaponService = player:CBasePlayerPawn().WeaponServices
        if not weaponService or not weaponService:IsValid() then
            Utils.HandleDebug("Weapon service is invalid or not found.")
            return false
        end
        local activeWeapon = weaponService.ActiveWeapon
        if not activeWeapon or not activeWeapon:IsValid() then
            Utils.HandleDebug("Active weapon is invalid or not found.")
            return false
        end
        local weaponName = CBaseEntity(activeWeapon:ToPtr()).Parent.Entity.DesignerName
        Utils.HandleDebug("Active weapon name: " .. weaponName)

        if type == "string" then
            if require.weapon ~= weaponName then
                Utils.HandleDebug("Weapon mismatch. Required: " .. require.weapon .. ", Current: " .. weaponName)
                return false
            end
        elseif type == "table" then
            local weaponFound = false
            for _, value in next, require.weapon do
                Utils.HandleDebug("Checking weapon: " .. value)
                if value == weaponName then
                    weaponFound = true
                    break
                end
            end
            if not weaponFound then
                Utils.HandleDebug("No matching weapon found in required weapons.")
                return false
            end
        end
    end

    if require.team then
        Utils.HandleDebug("Checking team requirement. Required: " .. tostring(require.team) .. ", Player's team: " .. tostring(player:CBaseEntity().TeamNum))
        if player:CBaseEntity().TeamNum ~= require.team then
            Utils.HandleDebug("Player's team does not match the required team.")
            return false
        end
    end

    if require.site then  
        if require.site ~= eventData.site then
            Utils.HandleDebug("Checking site requirement. Required: " .. tostring(require.site) .. ", got site " .. tostring(eventData.site))
            return false
        end
    end

    if require.assistedflash then
        if require.assistedflash ~= eventData.assistedflash then
            Utils.HandleDebug("Checking assistedflash requirement. Required: " .. tostring(require.assistedflash) .. ", got site " .. tostring(eventData.assistedflash))
            return false
        end
    end

    if require.headshot then
        if require.headshot ~= eventData.headshot then
            Utils.HandleDebug("Checking headshot requirement. Required: " .. tostring(require.headshot) .. ", got site " .. tostring(eventData.headshot))
            return false
        end
    end

    if require.noscope then
        if require.noscope ~= eventData.noscope then
            Utils.HandleDebug("Checking noscope requirement. Required: " .. tostring(require.noscope) .. ", got site " .. tostring(eventData.noscope))
            return false
        end
    end

    if require.thrusmoke then
        if require.thrusmoke ~= eventData.thrusmoke then
            Utils.HandleDebug("Checking thrusmoke requirement. Required: " .. tostring(require.thrusmoke) .. ", got site " .. tostring(eventData.thrusmoke))
            return false
        end
    end

    if require.attackerblind then
        if require.attackerblind ~= eventData.attackerblind then
            Utils.HandleDebug("Checking thrusmoke requirement. Required: " .. tostring(require.attackerblind) .. ", got site " .. tostring(eventData.attackerblind))
            return false
        end
    end

    if require.distance then
        if require.distance > eventData.distance then
            Utils.HandleDebug("Checking distance requirement. Required: " .. tostring(require.distance) .. ", got site " .. tostring(eventData.distance))
            return false            
        end
    end

    if require.hitgroup then
        if require.hitgroup ~= eventData.hitgroup then
            Utils.HandleDebug("Checking distance requirement. Required: " .. tostring(require.hitgroup) .. ", got site " .. tostring(eventData.hitgroup))
            return false            
        end
    end

    if require.attackerinair then
        if require.attackerinair ~= eventData.attackerinair then
            Utils.HandleDebug("Checking distance requirement. Required: " .. tostring(require.attackerinair) .. ", got site " .. tostring(eventData.attackerinair))
            return false            
        end        
    end

    Utils.HandleDebug("All requirements met for questID: " .. tostring(questID))
    return true
end

---@function QuestManager:MarkAsComplete(player, questID)
---@param player Player
---@param questID string
function QuestManager:MarkAsComplete(player, questID)
    Utils.HandleDebug("MarkAsComplete triggered for player questID: " .. tostring(questID))

    if not player or not player:IsValid() or player:IsFakeClient() then
        Utils.HandleDebug("Invalid player object. Aborting quest completion.")
        return
    end

    local playerID = player:GetSlot()
    Utils.HandleDebug("Player ID resolved: " .. tostring(playerID))

    local quest = self.quests[questID]
    if not quest then
        Utils.HandleDebug("Quest not found for questID: " .. tostring(questID))
        return
    end

    Utils.HandleDebug("Marking quest as complete for playerID: " .. tostring(playerID) .. ", questID: " .. tostring(questID))
    self.playersQuest[playerID].history[questID] = true
    Utils.HandleDebug("Quest added to history for playerID: " .. tostring(playerID))

    self.playersQuest[playerID].active = {}
    Utils.HandleDebug("Active quest cleared for playerID: " .. tostring(playerID))

    Utils.HandleDebug("Rewarding player for completing questID: " .. tostring(questID))
    self:RewardPlayer(player, questID)

    Utils.HandleDebug("Saving player data for playerID: " .. tostring(playerID))
    self:SavePlayer(playerID, false)

    Utils.HandleDebug("Quest completion process finished for playerID: " .. tostring(playerID) .. ", questID: " .. tostring(questID))
end

---@function QuestManager:RewardPlayer(player, questID)
---@param player Player
---@param questID string
function QuestManager:RewardPlayer(player, questID)
    Utils.HandleDebug("RewardPlayer triggered for player: " .. tostring(player) .. ", questID: " .. tostring(questID))

    local quest = self.quests[questID]
    if not quest or not quest.reward then
        Utils.HandleDebug("No quest or reward found for questID: " .. tostring(questID))
        return
    end

    local handler = self.rewardHandlers[quest.reward.type]
    if not handler then
        Utils.HandleDebug("No reward handler found for reward type: " .. tostring(quest.reward.type))
        return
    end
    local playerID = player:GetSlot()

    Utils.HandleDebug("Reward handler found for type: " .. tostring(quest.reward.type) .. ". Executing handler...")
    handler(playerID, quest.reward)
    Utils.HandleDebug("Reward handler executed successfully for player: " .. tostring(player))

    local message = FetchTranslation("quests.reward", playerID)
        :gsub("{REWARD_DESCRIPTION}", string.format("%s: %d", quest.reward.type, quest.reward.value))
        :gsub("{QUEST_TITLE}", FetchTranslation(quest.title, playerID))

    Utils.HandleDebug("Sending reward message to playerID: " .. tostring(playerID))
    Utils.ReplyToCommand(playerID, message)

    Utils.HandleDebug("RewardPlayer process completed for playerID: " .. tostring(playerID) .. ", questID: " .. tostring(questID))
end



