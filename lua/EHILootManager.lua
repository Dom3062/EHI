local EHI = EHI

---@class EHILootManager
---@field _loot_counter_sync_data LootCounterTable
EHILootManager = {}
EHILootManager._id = "LootCounter"
EHILootManager._sync_lm_add_loot_counter = "EHI_LM_AddLootCounter"
EHILootManager._sync_lm_update_loot_counter = "EHI_LM_SyncUpdateLootCounter"
---@param trackers EHITrackerManager
---@param waypoints EHIWaypointManager
function EHILootManager:new(trackers, waypoints)
    self._trackers = trackers
    self._waypoints = waypoints
    self._show_tracker, self._show_waypoint = EHI:GetShowTrackerAndWaypoint("show_loot_counter", "show_waypoints_loot_counter")
    self._delay_sync = true
    self._listener = ListenerHolder:new()
    if EHI.IsClient then
        self._sync_listener = CallbackEventHandler:new()
    end
    return self
end

function EHILootManager:init_finalize()
    EHI:AddOnSpawnedCallback(function()
        self._delay_sync = nil
    end)
    if EHI.IsClient and (self._show_tracker or self._show_waypoint) then
        managers.ehi_sync:AddReceiveHook(self._sync_lm_add_loot_counter, function(data, sender)
            local params = json.decode(data)
            self:ShowLootCounter(params.max, params.max_random, 0, params.offset)
            self:AddLootListener(true)
        end)
        managers.ehi_sync:AddReceiveHook(self._sync_lm_update_loot_counter, function(data, sender)
            local params = json.decode(data)
            if params.type == "IncreaseMaxRandom" then
                self:IncreaseLootCounterMaxRandom(params.random)
            elseif params.type == "RandomLootSpawned" then
                self:RandomLootSpawned(params.random)
            elseif params.type == "RandomLootDeclined" then
                self:RandomLootDeclined(params.random)
            end
        end)
    end
    if self._show_tracker then
        EHI:LoadTracker("EHILootTracker")
    end
    if self._show_waypoint then
        EHI:LoadWaypoint("EHILootWaypoint")
    end
end

---@param id string
---@param f fun(loot: LootManager)
function EHILootManager:AddListener(id, f)
    self._listener:add(id, f)
end

function EHILootManager:Call(...)
    self._listener:call(...)
end

---@param id string
function EHILootManager:RemoveListener(id)
    self._listener:remove(id)
end

---@param id string
function EHILootManager:RemoveLootMaster(id)
    self:RemoveListener(id)
    self._master = nil
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param max_xp_bags number?
---@param offset number?
---@param unknown_random boolean?
---@param no_max boolean?
---@param max_bags_for_level table?
---@param waypoint_class string?
function EHILootManager:ShowLootCounter(max, max_random, max_xp_bags, offset, unknown_random, no_max, max_bags_for_level, waypoint_class)
    EHI:LoadMaster("EHILootSharedMaster")
    if max_bags_for_level then
        self._master = EHILootMaxSharedMaster:new({
            xp_params = max_bags_for_level,
            loot = self,
            tracking = managers.ehi_tracking
        })
    elseif no_max then
        self._master = EHILootCountSharedMaster:new({
            max = math.huge,
            max_random = max_random or 0,
            max_xp_bags = max_xp_bags or 0,
            offset = offset or 0,
            loot = self,
            tracking = managers.ehi_tracking
        })
    else
        self._master = EHILootSharedMaster:new({
            max = max or 0,
            max_random = max_random or 0,
            max_xp_bags = max_xp_bags or 0,
            offset = offset or 0,
            unknown_random = unknown_random,
            loot = self,
            tracking = managers.ehi_tracking
        })
    end
    if self._show_tracker then
        self._trackers:AddTracker({
            id = self._id,
            max = no_max and math.huge or max or 0,
            max_random = max_random or 0,
            max_xp_bags = max_xp_bags or 0,
            unknown_random = unknown_random,
            class = "EHILootTracker"
        })
    end
    if self._show_waypoint then
        self._waypoints:AddWaypointlessWaypoint(self._id, {
            max = no_max and math.huge or max or 0,
            max_random = max_random or 0,
            max_xp_bags = max_xp_bags or 0,
            class = waypoint_class or EHI.Waypoints.LootCounter.Base
        })
        self:_adjust_waypoint()
    end
    self:_adjust_master()
    self._master:SetOnlyLootCounterMode()
    self._master:DispatchUpdate(true)
end

---@param id string Achievement ID
---@param max number
function EHILootManager:_create_waypoint_tracker(id, max)
    if self._show_waypoint then
        EHI:LoadMaster("EHILootSharedMaster")
        self._master = EHILootSharedMaster:new({
            achievement_id = id,
            max = max,
            loot = self,
            tracking = managers.ehi_tracking
        })
        self:_adjust_master()
        self._waypoints:AddWaypointlessWaypoint(self._id, {
            max = max,
            max_random = 0,
            max_xp_bags = 0,
            class = "EHILootWaypoint"
        })
        self:_adjust_waypoint()
        self._master:DispatchUpdate()
    end
end

function EHILootManager:_adjust_master()
    if self.__master_waypoint_function_check then
        self:WaypointFunctionCheck(self.__master_waypoint_function_check)
        self.__master_waypoint_function_check = nil
    end
    if self.__master_waypoint_remove_function_check then
        self:WaypointRemoveFunctionCheck(self.__master_waypoint_remove_function_check)
        self.__master_waypoint_remove_function_check = nil
    end
end

function EHILootManager:_adjust_waypoint()
    for f, data in pairs(self.__loot_counter_adjust_data or {}) do
        self._waypoints:CallFunction(self._id, f, data)
    end
    self.__loot_counter_adjust_data = nil
end

---@param present_timer number|table<number, number?>
function EHILootManager:SetPresentTimerForWaypoints(present_timer)
    if self._waypoints:CallFunction2(self._id, "SetPresentTimerForWaypoints", present_timer) then
        self:_add_waypoint_adjust_function("SetPresentTimerForWaypoints", present_timer)
    end
end

---@param f string
---@param data any
function EHILootManager:_add_waypoint_adjust_function(f, data)
    self.__loot_counter_adjust_data = self.__loot_counter_adjust_data or {}
    self.__loot_counter_adjust_data[f] = data
end

---@param f (fun(progress: number, max: number): boolean)?
function EHILootManager:WaypointFunctionCheck(f)
    if self._master then
        self._master:AddWaypointFunctionCheck(f)
    else
        self.__master_waypoint_function_check = f
    end
end

function EHILootManager:IsMasterActive()
    if self._master then
        local listener_id = self._master:GetListenerID()
        return self._listener._listeners and self._listener._listeners[listener_id] ~= nil
    end
    return false
end

function EHILootManager:IsMasterWaypointCheckValid()
    if self._master then
        return self._master:RunWaypointFunctionCheck()
    end
    return false
end

---@param id number
function EHILootManager:IsWaypointOverriden(id)
    if self._waypoint_overriden then
        return self._waypoint_overriden[id]
    end
    return false
end

---@param element ElementWaypoint
function EHILootManager:OverrideWaypoint(element)
    self._waypoint_overriden = self._waypoint_overriden or {} ---@type table<number, boolean>
    self._waypoint_overriden[element._id] = true
    self._waypoints:CallFunction(self._id, "CreateWaypoint", element._id, element._values.icon, element._values.position)
end

---@param id number
function EHILootManager:RemoveWaypoint(id)
    if self._waypoint_overriden and self._waypoint_overriden[id] then
        self._waypoint_overriden[id] = nil
        self._waypoints:CallFunction(self._id, "RemoveWaypoint", id)
        managers.hud:RestoreWaypoint(id, true)
    end
end

---@param id number
function EHILootManager:_restore_waypoint(id)
    if self._waypoint_overriden and self._waypoint_overriden[id] then
        self._waypoint_overriden[id] = nil
        managers.hud:RestoreWaypoint(id)
    end
end

---Replaces EHI Loot Waypoint with another EHI Waypoint  
---The Loot Waypoint needs to be removed from the Loot Waypoint class otherwise it will crash as soon players secure another loot bag
---@param id number
---@param manual_removal boolean? By default, this function will also move the current waypoint to the cache if exists. Pass `true` to do it manually or for the first time if Loot Waypoint does not exists
function EHILootManager:ReplaceWaypoint(id, manual_removal)
    self._waypoints:CallFunction(self._id, "ReplaceWaypoint", id)
    if self._waypoint_overriden then
        self._waypoint_overriden[id] = nil
        if not manual_removal then
            managers.hud:SoftRemoveWaypoint2(id)
        end
    end
end

---@param f fun(progress: number, max: number): boolean
function EHILootManager:WaypointRemoveFunctionCheck(f)
    if self._master then
        self._master:AddWaypointRemoveFunctionCheck(f)
    else
        self.__master_waypoint_remove_function_check = f
    end
end

function EHILootManager:CanRemoveWaypointCheck()
    if self._master then
        return self._master:RunWaypointRemoveFunctionCheck()
    end
    return true
end

---@param amount number
function EHILootManager:ObjectiveXPAwarded(amount)
    if self._master and self._master.ObjectiveXPAwarded then
        self._master:ObjectiveXPAwarded(amount) ---@diagnostic disable-line
    end
end

function EHILootManager:DisableWaypointRemoval()
    if self._waypoints:CallFunction2(self._id, "DisableWaypointRemoval") then
        self:_add_waypoint_adjust_function("DisableWaypointRemoval", true)
    end
end

---@param id number
function EHILootManager:AddWaypointElement(id)
    self._waypoint_element = self._waypoint_element or {}
    self._waypoint_element[id] = true
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param offset number?
function EHILootManager:SyncShowLootCounter(max, max_random, offset)
    self:ShowLootCounter(max, max_random, 0, offset)
    self:SetSyncData({
        max = max or 0,
        max_random = max_random or 0,
        offset = offset or 0
    })
    if not self._delay_sync then
        managers.ehi_sync:SyncTable(self._sync_lm_add_loot_counter, self._loot_counter_sync_data)
    end
end

---@param no_sync_load boolean?
function EHILootManager:AddLootListener(no_sync_load)
    if not (self._listener._listeners and self._listener._listeners.LootCounter) then
        local BagsOnly = EHI.Const.LootCounter.CheckType.BagsOnly
        self:AddListener(self._id, function(loot)
            if self._master then -- Just in case
                self._master:SetProgress(loot:EHIReportProgress(BagsOnly))
            end
        end)
        -- If sync load is disabled, the counter needs to be updated via `EHIManager:AddLoadSyncFunction()` to properly show number of secured loot
        -- Usually done in heists which have additional loot that spawns depending on random chance; example: Red Diamond in Diamond Heist (Classic)
        if EHI.IsClient and not no_sync_load then
            self:AddSyncListener(function(loot)
                if self._master then -- Just in case
                    self._master:SetSyncData(loot:EHIReportProgress(BagsOnly))
                end
            end)
        end
    end
end

---@param params AchievementLootCounterTable|AchievementBagValueCounterTable
---@param max number
---@param endless_counter boolean?
function EHILootManager:AddAchievementListener(params, max, endless_counter)
    local check_type, loot_type, f = EHI.Const.LootCounter.CheckType.BagsOnly, nil, nil
    if params.counter then
        check_type = params.counter.check_type or EHI.Const.LootCounter.CheckType.BagsOnly
        loot_type = params.counter.loot_type
        f = params.counter.f
    end
    if endless_counter then
        self:AddListener(params.achievement, function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                local secured = loot:EHIReportProgress(check_type, loot_type)
                self._trackers:SetProgress(params.achievement, secured)
                if self._master and not self._master:IsRunningInOnlyLootCounterMode() then
                    self._master:SetProgress(secured)
                end
            end
        end)
    else
        self:AddListener(params.achievement, function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                local progress = loot:EHIReportProgress(check_type, loot_type)
                self._trackers:SetProgress(params.achievement, progress)
                if self._master and not self._master:IsRunningInOnlyLootCounterMode() then
                    self._master:SetProgress(progress)
                end
                if progress >= max then
                    self:RemoveListener(params.achievement)
                end
            end
        end)
    end
    if EHI.IsClient and not (params.load_sync or params.no_sync) then
        self:AddSyncListener(function(loot)
            if f then
                loot:EHIReportProgress(check_type, loot_type, f)
            else
                local secured = loot:EHIReportProgress(check_type, loot_type)
                self._trackers:SetSyncData(params.achievement, secured)
                if self._master and not self._master:IsRunningInOnlyLootCounterMode() then
                    self._master:SetSyncData(secured)
                end
            end
        end)
    end
end

---@param f fun(loot: LootManager)
function EHILootManager:AddSyncListener(f)
    if self._sync_listener then
        self._sync_listener:add(f)
    end
end

---@param loot LootManager
function EHILootManager:CallSyncListeners(loot)
    if self._sync_listener then
        self._sync_listener:dispatch(loot)
        self._sync_listener:clear()
        self._sync_listener = nil
    end
end

function EHILootManager:SecuredMissionLoot()
    if self._master then
        self._master:SecuredMissionLoot()
    end
end

---@param tracker_id string? Defaults to `LootCounter` if not provided
function EHILootManager:SyncSecuredLoot(tracker_id)
    local secured = managers.loot:GetSecuredBagsAmount()
    self._trackers:SetSyncData(tracker_id or self._id, secured)
    self._waypoints:CallFunction(self._id, "SetSyncData", secured)
end

---@param id number
---@param callback fun(id: number)?
function EHILootManager:AddDelayedLootDeclinedCheck(id, callback)
    if self._master then
        self._master:AddDelayedLootDeclinedCheck(id, callback)
    end
end

---@param max number?
function EHILootManager:IncreaseLootCounterProgressMax(max)
    if self._master then
        self._master:IncreaseProgressMax(max)
    end
end

---@param max number?
function EHILootManager:DecreaseLootCounterProgressMax(max)
    if self._master then
        self._master:DecreaseProgressMax(max)
    end
end

---@param progress number?
function EHILootManager:IncreaseLootCounterMaxRandom(progress)
    if self._master then
        self._master:IncreaseMaxRandom(progress)
    end
end

---@param progress number?
function EHILootManager:DecreaseLootCounterMaxRandom(progress)
    if self._master then
        self._master:DecreaseMaxRandom(progress)
    end
end

---@param max_random number?
function EHILootManager:SetLootCounterMaxRandom(max_random)
    if self._master then
        self._master:SetMaxRandom(max_random)
    end
end

---@param id number Element ID
---@param force boolean? Force loot spawn event if the element does not have `fail` state (desync workaround)
function EHILootManager:RandomLootSpawnedCheck(id, force)
    if self._master then
        self._master:RandomLootSpawnedCheck(id, force)
    end
end

---@param id number Element ID
function EHILootManager:RandomLootDeclinedCheck(id)
    if self._master then
        self._master:RandomLootDeclinedCheck(id)
    end
end

---@param random number?
function EHILootManager:RandomLootSpawned(random)
    if self._master then
        self._master:RandomLootSpawned(random)
    end
end

---@param random number?
function EHILootManager:RandomLootDeclined(random)
    if self._master then
        self._master:RandomLootDeclined(random)
    end
end

---@param random_spawned number
---@param random_total number
function EHILootManager:RandomLootSpawnedAndDeclined(random_spawned, random_total)
    if self._master then
        self._master:RandomLootSpawnedAndDeclined(random_spawned, random_total)
    end
end

---@param state boolean?
function EHILootManager:SetUnknownRandomLoot(state)
    if self._master then
        self._master:SetUnknownRandomLoot(state)
    end
end

---@param count number
function EHILootManager:SetCountOfArmoredTransports(count)
    if self._master then
        self._master:SetCountOfArmoredTransports(count)
    end
end

function EHILootManager:RandomLootSpawnedInTransport()
    if self._master then
        self._master:RandomLootSpawnedInTransport()
    end
end

function EHILootManager:RandomLootDeclinedInTransport()
    if self._master then
        self._master:RandomLootDeclinedInTransport()
    end
end

function EHILootManager:ExplosionInTransport()
    if self._master then
        self._master:ExplosionInTransport()
    end
end

---@param data table
function EHILootManager:SetSyncData(data)
    self._loot_counter_sync_data = data
end

---@param data table
function EHILootManager:SetSyncDataAndSync(data)
    self:SetSyncData(data)
    managers.ehi_sync:SyncTable(self._sync_lm_add_loot_counter, data)
end

---@param random number?
function EHILootManager:SyncRandomLootSpawned(random)
    self:RandomLootSpawned(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max = sync_data.max + n
        sync_data.max_random = sync_data.max_random - n
        managers.ehi_sync:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootSpawned", random = n })
    end
end

---@param random number?
function EHILootManager:SyncRandomLootDeclined(random)
    self:RandomLootDeclined(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random - n
        managers.ehi_sync:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootDeclined", random = n })
    end
end


---@param random number?
function EHILootManager:SyncIncreaseLootCounterMaxRandom(random)
    self:IncreaseLootCounterMaxRandom(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random + n
        managers.ehi_sync:SyncTable(self._sync_lm_update_loot_counter, { type = "IncreaseMaxRandom", random = n })
    end
end

---@param sequence_triggers table<number, LootCounterTable.SequenceTriggersTable>?
function EHILootManager:AddSequenceTriggers(sequence_triggers)
    if not ehi_next(sequence_triggers) then ---@cast sequence_triggers -?
        return
    end
    local function IncreaseMax(...)
        self:SyncRandomLootSpawned()
    end
    local function DecreaseRandom(...)
        self:SyncRandomLootDeclined()
    end
    for unit_id, sequences in pairs(sequence_triggers) do
        for _, sequence in ipairs(sequences.loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
        end
        for _, sequence in ipairs(sequences.no_loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
        end
    end
end

---@param state table<number, WaypointInitData>
function EHILootManager:pre_load(state)
    if not self._waypoint_element then
        return
    end
    self.__loaded_waypoints = {}
    for id, _ in pairs(state) do
        if self._waypoint_element[id] then
            self.__loaded_waypoints[id] = true
            state[id] = nil
        end
    end
end

---@param data SyncData
function EHILootManager:load(data)
    local load_data = data.EHILootManager
    if load_data and EHI:IsLootCounterVisible() then
        load_data.client_from_start = true
        load_data.no_sync_load = true
        EHI:ShowLootCounterNoChecks(load_data)
        self:SyncSecuredLoot()
    end
    if self.__loaded_waypoints then
        for id, _ in pairs(self.__loaded_waypoints) do
            local element = managers.mission:get_element_by_id(id)
            if element then
                element:on_executed()
            end
        end
        self.__loaded_waypoints = nil
    end
end

---@param data SyncData
function EHILootManager:save(data)
    if self._loot_counter_sync_data then
        data.EHILootManager = self._loot_counter_sync_data
    end
end