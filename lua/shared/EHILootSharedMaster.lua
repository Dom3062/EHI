---@class EHILootSharedMaster
---@field new fun(self: self, params: EHITracker.params): self
EHILootSharedMaster = class()
EHILootSharedMaster._id = "LootCounter"
EHILootSharedMaster._SHOW_POPUP = EHI:GetOption("show_all_loot_secured_popup")
EHILootSharedMaster._SHOW_TRACKERS = EHI:GetOption("show_trackers") --[[@as boolean]]
EHILootSharedMaster._SHOW_WAYPOINTS = EHI:GetOption("show_waypoints") --[[@as boolean]]
---@param params EHITracker.params
function EHILootSharedMaster:init(params)
    self._manager = params.manager --[[@as EHIManager]]
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._mission_loot = 0
    self._offset = params.offset or 0
    self._max_random = params.max_random or 0
    self._stay_on_screen = self._max_random > 0
    self._max_xp_bags = params.max_xp_bags or 0
    self._unknown_random = params.unknown_random
    self._loot_id = {}
    self._loot_check_delay = {} ---@type table<number, { t: number, callback: function? }>
    self._loot_check_n = 0
end

if EHI:GetOption("variable_random_loot_format") == 1 then
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "-" .. max .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "-" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
elseif EHI:GetOption("variable_random_loot_format") == 2 then
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. max .. "?+?"
            else
                return self._progress .. "/" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
else
    function EHILootSharedMaster:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return self._progress .. "/" .. self._max
    end
end

---@param silent_update boolean?
function EHILootSharedMaster:DispatchUpdate(silent_update)
    self._manager:Call(self._id, "SetText", self:Format(), silent_update)
end

function EHILootSharedMaster:SetOnlyLootCounterMode()
    self._only_loot_counter = true
end

function EHILootSharedMaster:IsRunningInOnlyLootCounterMode()
    return self._only_loot_counter
end

---@param f fun(progress: number, max: number): boolean
function EHILootSharedMaster:AddWaypointFunctionCheck(f)
    self._waypoint_function_check = f
end

function EHILootSharedMaster:RunWaypointFunctionCheck()
    if self._waypoint_function_check then
        return self._waypoint_function_check(self._progress, self._max)
    end
    return true
end

---@param f fun(progress: number, max: number): boolean
function EHILootSharedMaster:AddWaypointRemoveFunctionCheck(f)
    self._waypoint_remove_function_check = f
end

function EHILootSharedMaster:RunWaypointRemoveFunctionCheck()
    if self._waypoint_remove_function_check then
        return self._waypoint_remove_function_check(self._progress, self._max)
    end
    return true
end

---@param dt number
function EHILootSharedMaster:update(dt)
    for id, data in pairs(self._loot_check_delay) do
        data.t = data.t - dt
        if data.t <= 0 then
            self._loot_check_delay[id] = nil
            self._loot_check_n = self._loot_check_n - 1
            if self._loot_check_n <= 0 then
                self:RemoveFromUpdate()
            end
            self:RandomLootDeclinedCheck(id)
            if data.callback then
                data.callback(id)
            end
        end
    end
end

---@param id number
---@param callback function?
function EHILootSharedMaster:AddDelayedLootDeclinedCheck(id, callback)
    self._loot_check_delay[id] = { t = 2, callback = callback }
    if self._loot_check_n == 0 then
        self:AddToUpdate()
    end
    self._loot_check_n = self._loot_check_n + 1
end

---@param progress number
---@param silent_update boolean?
function EHILootSharedMaster:SetProgress(progress, silent_update)
    local fixed_progress = progress + self._mission_loot - self._offset
    local original_max = self._max
    if self._max_xp_bags > 0 then
        self._max = math.min(self._max, self._max_xp_bags)
    end
    if self._progress ~= fixed_progress and not self._disable_counting then
        self._progress = fixed_progress
        self:DispatchUpdate(silent_update)
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
    self._max = original_max
end

function EHILootSharedMaster:SetCompleted()
    self._disable_counting = true
    if self._stay_on_screen then
        self._manager:Call(self._id, "SetCompleted", true)
        return
    elseif self._SHOW_POPUP and not self._popup_showed then
        self._popup_showed = true
        local xp_text = self._max_xp_bags > 0 and "ehi_popup_all_xp_loot_secured" or "ehi_popup_all_loot_secured"
        managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text(xp_text), "EHI_Loot")
    end
    self:delete_listener()
end

---@param max number
function EHILootSharedMaster:SetProgressMax(max)
    if self._max_xp_bags > 0 and self._max_xp_bags >= max then
        self._max_xp_bags = 0
        self._manager:Call(self._id, "MaxNoLongerLimited")
    end
    self._max = max
    self:DispatchUpdate()
    self._disable_counting = nil
    self:VerifyStatus()
end

---@param max number?
function EHILootSharedMaster:IncreaseProgressMax(max)
    self:SetProgressMax(self._max + (max or 1))
end

---@param max number?
function EHILootSharedMaster:DecreaseProgressMax(max)
    self:SetProgressMax(self._max - (max or 1))
end

function EHILootSharedMaster:VerifyStatus()
    self._stay_on_screen = self._max_random > 0 or self._unknown_random
    if self._progress == self._max then
        self:SetCompleted()
    end
end

---@param random number?
function EHILootSharedMaster:RandomLootSpawned(random)
    if self._max_random <= 0 then
        return
    elseif self._progress == self._max then
        self._manager:Call(self._id, "MaxNoLongerLimited")
    end
    local n = random or 1
    self._max_random = self._max_random - n
    self:IncreaseProgressMax(n)
end

---@param random number?
function EHILootSharedMaster:RandomLootDeclined(random)
    if self._max_random <= 0 then
        return
    end
    self._max_random = self._max_random - (random or 1)
    self:SetProgressMax(self._max)
end

---@param max number?
function EHILootSharedMaster:SetMaxRandom(max)
    self._max_random = max or 0
    self:SetProgressMax(self._max)
end

---@param progress number?
function EHILootSharedMaster:IncreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random + (progress or 1))
end

---@param progress number?
function EHILootSharedMaster:DecreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random - (progress or 1))
end

---@param id number
---@param force boolean? This is here to combat desync, use it if element does not have `fail` state
function EHILootSharedMaster:RandomLootSpawnedCheck(id, force)
    if self._loot_id[id] then
        if force then
            self:IncreaseProgressMax()
        end
        return
    end
    self._loot_id[id] = true
    self:RandomLootSpawned()
end

---@param id number
function EHILootSharedMaster:RandomLootDeclinedCheck(id)
    if self._loot_id[id] then
        return
    end
    self._loot_id[id] = true
    self:RandomLootDeclined()
end

---@param state boolean?
function EHILootSharedMaster:SetUnknownRandomLoot(state)
    if state == self._unknown_random then
        return
    end
    self._unknown_random = state
    self._manager._trackers:CallFunction(self._id, "UpdateUnknownLoot", state)
    self:DispatchUpdate()
end

function EHILootSharedMaster:SecuredMissionLoot()
    local progress = self._progress - self._mission_loot + self._offset
    self._mission_loot = self._mission_loot + 1
    self:SetProgress(progress)
end

---@param count number
function EHILootSharedMaster:SetCountOfArmoredTransports(count)
    self._n_of_loot_in_transports = count * 9
    self._n_of_loot_in_one_transport = 9
end

function EHILootSharedMaster:RandomLootSpawnedInTransport()
    if self._n_of_loot_in_transports <= 0 then
        return
    end
    self:RandomLootSpawned()
    self._n_of_loot_in_transports = self._n_of_loot_in_transports - 1
    self._n_of_loot_in_one_transport = self._n_of_loot_in_one_transport - 1
    if self._n_of_loot_in_one_transport == 0 and self._n_of_loot_in_transports > 0 then
        self._n_of_loot_in_one_transport = 9
    end
end

function EHILootSharedMaster:RandomLootDeclinedInTransport()
    if self._n_of_loot_in_transports <= 0 then
        return
    end
    self:RandomLootDeclined()
    self._n_of_loot_in_transports = self._n_of_loot_in_transports - 1
    self._n_of_loot_in_one_transport = self._n_of_loot_in_one_transport - 1
    if self._n_of_loot_in_one_transport == 0 and self._n_of_loot_in_transports > 0 then
        self._n_of_loot_in_one_transport = 9
    end
end

function EHILootSharedMaster:ExplosionInTransport()
    while self._n_of_loot_in_one_transport ~= 9 and self._n_of_loot_in_transports > 0 do
        self:RandomLootDeclinedInTransport()
    end
    if self._n_of_loot_in_transports <= 0 and self._n_of_loot_in_one_transport > 0 then
        self:RandomLootDeclined(self._n_of_loot_in_one_transport)
        self._n_of_loot_in_one_transport = 0
    end
end

---Called during GameSetup:load()
---@param progress number
---@param set_progress_remaining boolean?
function EHILootSharedMaster:SetSyncData(progress, set_progress_remaining)
    if set_progress_remaining then
        progress = self._max - progress
    end
    if progress >= self._max then
        self:delete_listener(true)
    else
        self:SetProgress(progress, true)
    end
end

---@param silent_removal boolean?
function EHILootSharedMaster:delete_listener(silent_removal)
    if silent_removal then
        self._manager:Remove(self._id)
        self._manager._loot._waypoint_element = nil
    else
        self._manager:Call(self._id, "SetCompleted")
    end
    self._manager._loot:RemoveListener(self._id)
end

function EHILootSharedMaster:AddToUpdate()
    if self._SHOW_TRACKERS then
        self._manager._trackers:_add_tracker_to_update(self) ---@diagnostic disable-line
    elseif self._SHOW_WAYPOINTS then
        self._manager._waypoints:_add_waypoint_to_update(self) ---@diagnostic disable-line
    end
end

function EHILootSharedMaster:RemoveFromUpdate()
    if self._SHOW_TRACKERS then
        self._manager._trackers:_remove_tracker_from_update(self._id)
    elseif self._SHOW_WAYPOINTS then
        self._manager._waypoints:_remove_waypoint_from_update(self._id)
    end
end