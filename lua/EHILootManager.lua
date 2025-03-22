local EHI = EHI

---@class EHILootManager : EHIBaseManager
---@field super EHIBaseManager
---@field new fun(self: self): self
---@field AddListener fun(self: self, id: string, f: fun(loot: LootManager))
---@field _loot_counter_sync_data LootCounterTable
EHILootManager = class(EHIBaseManager)
EHILootManager._sync_lm_add_loot_counter = "EHI_LM_AddLootCounter"
EHILootManager._sync_lm_update_loot_counter = "EHI_LM_SyncUpdateLootCounter"
function EHILootManager:init()
    self._show_tracker, self._show_waypoint = EHI:GetShowTrackerAndWaypoint("show_loot_counter", "show_waypoints_loot_counter")
    self._delay_popups = true
    self:CreateListener()
    if EHI.IsClient then
        self._sync_listener = CallbackEventHandler:new()
    end
end

---@param manager EHIManager
function EHILootManager:init_manager(manager)
    self._manager = manager
    self._trackers = manager._trackers
    self._waypoints = manager._waypoints
end

function EHILootManager:init_finalize()
    if EHI.IsClient and (self._show_tracker or self._show_waypoint) then
        self:AddReceiveHook(self._sync_lm_add_loot_counter, function(data, sender)
            local params = json.decode(data)
            self:ShowLootCounter(params.max, params.max_random, 0, params.offset)
            self:AddLootListener(true)
        end)
        self:AddReceiveHook(self._sync_lm_update_loot_counter, function(data, sender)
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
end

function EHILootManager:Spawned()
    self._delay_popups = nil
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param max_xp_bags number?
---@param offset number?
---@param unknown_random boolean?
---@param no_max boolean?
---@param max_bags_for_level table?
function EHILootManager:ShowLootCounter(max, max_random, max_xp_bags, offset, unknown_random, no_max, max_bags_for_level)
    if max_bags_for_level then
        if self._show_tracker then
            self._trackers:AddTracker({
                id = "LootCounter",
                xp_params = max_bags_for_level,
                loot_parent = self,
                class = "EHILootMaxTracker"
            })
        end
    else
        if no_max then
            if self._show_tracker then
                self._trackers:AddTracker({
                    id = "LootCounter",
                    max = max or 0,
                    max_random = max_random or 0,
                    max_xp_bags = max_xp_bags or 0,
                    offset = offset or 0,
                    loot_parent = self,
                    class = "EHILootCountTracker"
                })
            end
        else
            dofile(EHI.LuaPath .. "shared/EHILootSharedMaster.lua")
            self._master = EHILootSharedMaster:new({
                max = max or 0,
                max_random = max_random or 0,
                max_xp_bags = max_xp_bags or 0,
                offset = offset or 0,
                unknown_random = unknown_random,
                manager = self._manager
            })
            self:_adjust_master()
            if self._show_tracker then
                self._trackers:AddTracker({
                    id = "LootCounter",
                    max = max or 0,
                    max_random = max_random or 0,
                    max_xp_bags = max_xp_bags or 0,
                    class = "EHILootTrackerNew"
                })
            end
            if self._show_waypoint then
                self._waypoints:AddWaypointlessWaypoint("LootCounter", {
                    max = max or 0,
                    max_random = max_random or 0,
                    max_xp_bags = max_xp_bags or 0,
                    class = "EHILootWaypoint"
                })
                self:_adjust_waypoint()
            end
            self._master:SetOnlyLootCounterMode()
            self._master:DispatchUpdate(true)
        end
    end
end

---@param max number
function EHILootManager:_create_waypoint_tracker(max)
    if self._show_waypoint then
        dofile(EHI.LuaPath .. "shared/EHILootSharedMaster.lua")
        self._master = EHILootSharedMaster:new({
            max = max,
            manager = self._manager
        })
        self:_adjust_master()
        self._waypoints:AddWaypointlessWaypoint("LootCounter", {
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
    if self.__loot_counter_present_timer then
        self._waypoints:CallFunction("LootCounter", "SetPresentTimerForWaypoints", self.__loot_counter_present_timer)
        self.__loot_counter_present_timer = nil
    end
    if self.__loot_counter_disable_waypoint_removal then
        self._waypoints:CallFunction("LootCounter", "DisableWaypointRemoval")
        self.__loot_counter_disable_waypoint_removal = nil
    end
end

---@param present_timer number|table<number, number?>
function EHILootManager:SetPresentTimerForWaypoints(present_timer)
    if self._waypoints:CallFunction2("LootCounter", "SetPresentTimerForWaypoints", present_timer) then
        self.__loot_counter_present_timer = present_timer
    end
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
    return self._master ~= nil and (self._listener._listeners and self._listener._listeners.LootCounter)
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
    self._waypoints:CallFunction("LootCounter", "CreateWaypoint", element._id, element._values.icon, element._values.position)
end

---@param id number
function EHILootManager:RemoveWaypoint(id)
    if self._waypoint_overriden and self._waypoint_overriden[id] then
        self._waypoint_overriden[id] = nil
        self._waypoints:CallFunction("LootCounter", "RemoveWaypoint", id)
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
    self._waypoints:CallFunction("LootCounter", "ReplaceWaypoint", id)
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

function EHILootManager:DisableWaypointRemoval()
    if self._waypoints:CallFunction2("LootCounter", "DisableWaypointRemoval") then
        self.__loot_counter_disable_waypoint_removal = true
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
    if not self._delay_popups then
        self:SyncTable(self._sync_lm_add_loot_counter, self._loot_counter_sync_data)
    end
end

---@param no_sync_load boolean?
---@param endless_counter boolean?
function EHILootManager:AddLootListener(no_sync_load, endless_counter)
    if not (self._listener._listeners and self._listener._listeners.LootCounter) then
        local BagsOnly = EHI.Const.LootCounter.CheckType.BagsOnly
        if endless_counter then
            self:AddListener("LootCounter", function(loot)
                self._trackers:SetTrackerProgress("LootCounter", loot:EHIReportProgress(BagsOnly))
            end)
        else
            self:AddListener("LootCounter", function(loot)
                if self._master then
                    self._master:SetProgress(loot:EHIReportProgress(BagsOnly))
                end
            end)
        end
        -- If sync load is disabled, the counter needs to be updated via `EHIManager:AddLoadSyncFunction()` to properly show number of secured loot
        -- Usually done in heists which have additional loot that spawns depending on random chance; example: Red Diamond in Diamond Heist (Classic)
        if EHI.IsClient and not no_sync_load then
            if endless_counter then
                self:AddSyncListener(function(loot)
                    self._trackers:SetTrackerSyncData("LootCounter", loot:EHIReportProgress(BagsOnly))
                end)
            else
                self:AddSyncListener(function(loot)
                    if self._master then
                        self._master:SetSyncData(loot:EHIReportProgress(BagsOnly))
                    end
                end)
            end
        end
    end
end

---@param params AchievementLootCounterTable|AchievementBagValueCounterTable
---@param endless_counter boolean?
function EHILootManager:AddAchievementListener(params, endless_counter)
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
                self._trackers:SetTrackerProgress(params.achievement, secured)
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
                self._trackers:SetTrackerProgress(params.achievement, progress)
                if self._master and not self._master:IsRunningInOnlyLootCounterMode() then
                    self._master:SetProgress(progress)
                end
                if progress >= (params.max or params.value) then
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
                self._trackers:SetTrackerSyncData(params.achievement, secured)
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
    self._trackers:SetTrackerSyncData(tracker_id or "LootCounter", secured)
    self._waypoints:CallFunction("LootCounter", "SetSyncData", secured)
end

---@param id number
---@param callback function?
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
    self:SyncTable(self._sync_lm_add_loot_counter, data)
end

---@param random number?
function EHILootManager:SyncRandomLootSpawned(random)
    self:RandomLootSpawned(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max = sync_data.max + n
        sync_data.max_random = sync_data.max_random - n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootSpawned", random = n })
    end
end

---@param random number?
function EHILootManager:SyncRandomLootDeclined(random)
    self:RandomLootDeclined(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random - n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "RandomLootDeclined", random = n })
    end
end


---@param random number?
function EHILootManager:SyncIncreaseLootCounterMaxRandom(random)
    self:IncreaseLootCounterMaxRandom(random)
    local sync_data = self._loot_counter_sync_data
    if sync_data then
        local n = random or 1
        sync_data.max_random = sync_data.max_random + n
        self:SyncTable(self._sync_lm_update_loot_counter, { type = "IncreaseMaxRandom", random = n })
    end
end

---@param sequence_triggers table<number, LootCounterTable.SequenceTriggersTable>?
function EHILootManager:AddSequenceTriggers(sequence_triggers)
    if not (sequence_triggers and next(sequence_triggers)) then
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