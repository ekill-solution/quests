---
--- @param event Event
local function OnPluginStart(event)
    QuestManager:Initialize()
end

---@param event Event
local function OnPluginStop(event)

end

--- @param event Event
local function OnPlayerConnectFull(event)
    if not db:IsConnected() then return end
    QuestManager:LoadPlayer(event:GetInt("userid"))
end

--- @param event Event
local function OnPlayerDisconnect(event)
    QuestManager:SavePlayer(event:GetInt("userid"), true)
end

--- @param event Event
--- @return number|nil EventResult
local function OnBombPlanted(event)
    local playerID = event:GetInt("userid")
    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then
        return
    end

    local eventData = {
        progress = 1,
        site = event:GetInt("site")
    }

    QuestManager:OnQuestEvent(player, "planted_bombs", eventData)
end

--- @param event Event
--- @return number|nil EventResult
local function OnBombDefused(event)
    local playerID = event:GetInt("userid")
    local player = GetPlayer(playerID)
    if not player or not player:IsValid() or player:IsFakeClient() then
        return
    end

    local eventData = {
        progress = 1,
        site = event:GetInt("site")
    }
    QuestManager:OnQuestEvent(player, "defused_bombs", eventData)
end

--- @param event Event
--- @return number|nil EventResult
local function OnPlayerHurt(event)
    local victimID = event:GetInt("userid")
    local attackerID = event:GetInt("attacker")
    if victimID == attackerID then return end
    local attacker = GetPlayer(attackerID)
    if not attacker or not attacker:IsValid() or attacker:IsFakeClient() then
        return
    end

    local eventData = {
        progress = event:GetInt("dmg_health")
    }

    QuestManager:OnQuestEvent(attacker, "dealed_damages", eventData)
end

--- @param event Event
local function OnPlayerDeath(event)
    local victimID = event:GetInt("userid")
    local attackerID = event:GetInt("attacker")
    if victimID == attackerID then return end
    local attacker = GetPlayer(attackerID)
    if not attacker or not attacker:IsValid() or attacker:IsFakeClient() then
        return
    end

    local eventData = {
        progress = 1,
        assistedflash = event:GetBool("assistedflash"),
        headshot = event:GetBool("headshot"),
        noscope = event:GetBool("noscope"),
        thrusmoke = event:GetBool("thrusmoke"),
        attackerblind = event:GetBool("attackerblind"),
        distance = event:GetFloat("distance"),
        hitgroup = event:GetInt("hitgroup"),
        attackerinair = event:GetBool("attackerinair")
    }
    QuestManager:OnQuestEvent(attacker, "killed_enemies", eventData)

    local assister = GetPlayer(event:GetInt("assister"))
    if not assister or not assister:IsValid() or assister:IsFakeClient() then
        return
    end
    QuestManager:OnQuestEvent(assister, "assisted_killed_enemies", eventData)
end

--- @param event Event
local function OnRoundEnd(event)

    for playerID = 0, playermanager:GetPlayerCap() - 1 do
        local player = GetPlayer(playerID)

        if not player or not player:IsValid() or player:IsFakeClient() then
            goto continue
        end

        local playerTeam = player:CBaseEntity().TeamNum
        local winnerTeam = event:GetInt("winner")

        if winnerTeam == playerTeam then
            QuestManager:OnQuestEvent(player, "won_rounds", {progress = 1})
        end

        QuestManager:OnQuestEvent(player, "played_rounds", {progress = 1})

        ::continue::
    end

end
--- @param event Event
local function OnRoundMvp(event)
    local player = GetPlayer(event:GetInt("userid"))
    if not player or not player:IsValid() or player:IsFakeClient() then
        return
    end
    QuestManager:OnQuestEvent(player, "mvp_rounds", {progress = 1})
end


AddEventHandler("OnPluginStart", OnPluginStart)
AddEventHandler("OnPluginStop", OnPluginStop)
AddEventHandler("OnPlayerConnectFull", OnPlayerConnectFull)
AddEventHandler("OnPlayerDisconnect", OnPlayerDisconnect)

AddEventHandler("OnBombPlanted", OnBombPlanted)
AddEventHandler("OnBombDefused", OnBombDefused)
AddEventHandler("OnPlayerHurt", OnPlayerHurt)
AddEventHandler("OnPlayerDeath", OnPlayerDeath)
AddEventHandler("OnRoundEnd", OnRoundEnd)
AddEventHandler("OnRoundMvp", OnRoundMvp)
