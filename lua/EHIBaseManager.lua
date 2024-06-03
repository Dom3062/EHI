---@class EHIBaseManager
EHIBaseManager = class()

---@param n number
---@param bracket number? Number in `*10` or `/10`
---@return number
function EHIBaseManager:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

---@param n number
function EHIBaseManager:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

---@param message_id string A message to sync data to
---@param hook_id string
---@param f fun(data: string, sender: integer)
---@overload fun(self: self, message_id: string, f: fun(data: string, sender: integer))
function EHIBaseManager:AddReceiveHook(message_id, hook_id, f)
    if f then
        NetworkHelper:AddReceiveHook(message_id, hook_id, f)
    else
        NetworkHelper:AddReceiveHook(message_id, message_id, hook_id --[[@as function]])
    end
end

---@param message string
---@param data any
function EHIBaseManager:Sync(message, data)
    NetworkHelper:SendToPeersExcept(1, message, data)
end

---@param message string
---@param tbl table
function EHIBaseManager:SyncTable(message, tbl)
    NetworkHelper:SendToPeersExcept(1, message, json.encode(tbl))
end

if Global.game_settings and Global.game_settings.single_player then
    EHIBaseManager.Sync = function(...) end
    EHIBaseManager.SyncTable = function(...) end
end