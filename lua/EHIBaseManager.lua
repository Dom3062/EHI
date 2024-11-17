---@class EHIBaseManager
EHIBaseManager = class()
---@param n number
---@param bracket number?
EHIBaseManager.RoundNumber = function(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

---@param n number
function EHIBaseManager:RoundHealthNumber(n)
    return self.RoundNumber(n * 10, 0.1)
end

---@param n number
function EHIBaseManager:RoundChanceNumber(n)
    return self.RoundNumber(n, 0.01) * 100
end

function EHIBaseManager:CreateEventListener()
    self._event_listener = EventListenerHolder:new()
end

---@param id string
---@param event string|string[]
---@param f function
function EHIBaseManager:AddEventListener(id, event, f)
    self._event_listener:add(id, event, f)
end

---@param event string
function EHIBaseManager:CallEvent(event, ...)
    self._event_listener:call(event, ...)
end

---@param id string
function EHIBaseManager:HasEventListener(id)
    return self._event_listener:has_listeners_for_event(id) ~= nil
end

---@param id string
function EHIBaseManager:RemoveEventListener(id)
    self._event_listener:remove(id)
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

---@param message_id string A message to sync data to
---@param hook_id string?
function EHIBaseManager:RemoveReceiveHook(message_id, hook_id)
    NetworkHelper:RemoveReceiveHook(hook_id or message_id, message_id)
end

---@param message string
---@param data string
function EHIBaseManager:SyncData(message, data)
    NetworkHelper:SendToPeersExcept(1, message, data)
end

---@param message string
---@param tbl table A table of data that will get encoded to json
function EHIBaseManager:SyncTable(message, tbl)
    NetworkHelper:SendToPeersExcept(1, message, json.encode(tbl))
end

if Global.game_settings and Global.game_settings.single_player then
    EHIBaseManager.Sync = function(...) end
    EHIBaseManager.SyncTable = function(...) end
end