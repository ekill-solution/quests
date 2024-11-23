Utils = {}
---comment
---@param errorText string
---@return boolean
function Utils.HandleError(errorText)
    if #errorText > 0 then
        logger:Write(LogType_t.Error, errorText)
        if QuestManager.debug then
            print("{darkred}[ERROR]{default}" .. errorText)
        end
    end
    return #errorText > 0
end
---@param debugText string
---@return boolean
function Utils.HandleDebug(debugText)
    if #debugText > 0 and QuestManager.debug then
        logger:Write(LogType_t.Debug, debugText)
        if QuestManager.debug then
            print("{gray}[DEBUG] " .. debugText)
        end
    end
    return #debugText > 0 and QuestManager.debug
end

function Utils.ReplyToCommand(playerID, text)
    return ReplyToCommand(playerID, QuestManager.prefix, text)
end