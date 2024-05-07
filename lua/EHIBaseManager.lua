---@class EHIBaseManager
EHIBaseManager = class()
---@param message string
---@param data any
function EHIBaseManager:Sync(message, data)
    LuaNetworking:SendToPeersExcept(1, message, data or "")
end

---@param message string
---@param tbl table?
function EHIBaseManager:SyncTable(message, tbl)
    LuaNetworking:SendToPeersExcept(1, message, json.encode(tbl or {}))
end

if Global.game_settings and Global.game_settings.single_player then
    EHIBaseManager.Sync = function(...) end
    EHIBaseManager.SyncTable = function(...) end
end