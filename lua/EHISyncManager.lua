---@class EHISyncManagerSyncData
---@field has_useful_bots boolean
---@field has_bots_enabled boolean
---@field has_hostages_extend_break_time boolean

local EHI = EHI

---@class EHISyncManager
local EHISyncManager = {}
function EHISyncManager:post_init()
    if EHI.IsClient then
        self._drop_in_listener = CallbackEventHandler:new()
        self._load_sync = CallbackEventHandler:new()
        self._full_sync = CallbackEventHandler:new()
        managers.network:add_event_listener("EHISyncDropIn", "on_set_dropin", function()
            self._is_dropin = true
            self._drop_in_listener:dispatch()
            self._drop_in_listener:clear()
            self._drop_in_listener = nil
            managers.network:remove_event_listener("EHISyncDropIn")
        end)
    end
end

---@param f function
function EHISyncManager:AddDropInListener(f)
    if self._drop_in_listener then
        self._drop_in_listener:add(f)
    end
end

function EHISyncManager:IsDropIn()
    return self._is_dropin
end

---@param f function
function EHISyncManager:AddLoadSyncFunction(f)
    if self._load_sync then
        self._load_sync:add(f)
    end
end

---@param f function
function EHISyncManager:AddFullSyncFunction(f)
    if self._full_sync then
        self._full_sync:add(f)
    end
end

function EHISyncManager:load_post()
    self.__syncing = true
    if self._is_dropin then
        self._load_sync:dispatch()
    else
        self._full_sync:dispatch()
    end
    self._full_sync:clear()
    self._full_sync = nil
    self._load_sync:clear()
    self._load_sync = nil
    self.__syncing = nil
end

function EHISyncManager:IsSyncing()
    return self.__syncing
end

---Syncing via SuperBLT
---@param message_id string A message to sync data to
---@param hook_id string
---@param f fun(data: string, sender: integer)
---@overload fun(self: self, message_id: string, f: fun(data: string, sender: integer))
function EHISyncManager:AddReceiveHook(message_id, hook_id, f)
    if f then
        NetworkHelper:AddReceiveHook(message_id, hook_id, f)
    else
        NetworkHelper:AddReceiveHook(message_id, message_id, hook_id --[[@as function]])
    end
end

---Syncing via SuperBLT
---@param message_id string A message to sync data to
---@param hook_id string?
function EHISyncManager:RemoveReceiveHook(message_id, hook_id)
    NetworkHelper:RemoveReceiveHook(hook_id or message_id, message_id)
end

if Global.game_settings and Global.game_settings.single_player then
    EHISyncManager.SyncData = function(...) end
    EHISyncManager.SyncTable = function(...) end
else
    ---Syncing via SuperBLT
    ---@param message string
    ---@param data string
    function EHISyncManager:SyncData(message, data)
        NetworkHelper:SendToPeersExcept(1, message, data)
    end

    ---Syncing via SuperBLT
    ---@param message string
    ---@param tbl table A table of data that will get encoded to json
    function EHISyncManager:SyncTable(message, tbl)
        NetworkHelper:SendToPeersExcept(1, message, json.encode(tbl))
    end
end

---@param data SyncData
function EHISyncManager:load_pre(data)
    local state = data.EHISyncManager
    if not state then
        return
    end
    if state.has_useful_bots then
        EHI._cache.HostHasUsefulBots = true
        EHI._cache.HostHasBots = state.has_bots_enabled
        local briefing = managers.menu_component and managers.menu_component._mission_briefing_gui
        if briefing and briefing.RefreshXPOverview then
            briefing:RefreshXPOverview()
        end
        if EHI:IsXPTrackerEnabled() then
            managers.ehi_experience:SetAIOnDeathListener()
            managers.ehi_experience:SetCriminalsListener(true)
        end
    end
    if state.has_hostages_extend_break_time and EHIAssaultTracker then
        EHIAssaultTracker._ANTICIPATION_DELAY_PER_HOSTAGE = 5
    end
end

---@param data SyncData
function EHISyncManager:save(data)
    local state = {}
    state.has_useful_bots = UsefulBots ~= nil
    state.has_bots_enabled = Global.game_settings.team_ai
    state.has_hostages_extend_break_time = EHI:IsModInstalled("Hostages Extend Break Time", "Pat")
    data.EHISyncManager = state
end

return EHISyncManager