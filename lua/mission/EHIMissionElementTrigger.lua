---@class EHIManagerSyncData
---@field SyncedSFF { [string]: any }

---@class Visibility
local Visibility =
{
    _SHOW_MISSION_TRACKERS = EHI:GetTrackerOption("show_mission_trackers"),
    _SHOW_MISSION_WAYPOINTS = EHI:GetWaypointOption("show_waypoints_mission")
}
Visibility._SHOW_MISSION_TRIGGERS = Visibility._SHOW_MISSION_TRACKERS or Visibility._SHOW_MISSION_WAYPOINTS
Visibility._SHOW_MISSION_TRACKERS_TYPE =
{
    cheaty = Visibility._SHOW_MISSION_TRACKERS and EHI:GetOption("show_mission_trackers_cheaty")
}
Visibility._SHOW_MISSION_WAYPOINTS_TYPE =
{
    cheaty = Visibility._SHOW_MISSION_WAYPOINTS and EHI:GetOption("show_waypoints_mission_cheaty")
}
Visibility._SHOW_MISSION_TRIGGERS_TYPE =
{
    cheaty = Visibility._SHOW_MISSION_TRACKERS_TYPE.cheaty or Visibility._SHOW_MISSION_WAYPOINTS_TYPE.cheaty
}

---@class EHIMissionElementTrigger
---@field new fun(self: self, id: number, params: ElementTrigger): self
---@field _trackers EHITrackerManager
---@field _waypoints EHIWaypointManager
---@field _hook EHIHookManager
---@field _unlockable EHIUnlockableManager
---@field _loot EHILootManager
---@field _assault EHIAssaultManager
---@field _tracking EHITrackingManager
---@field _utils EHIMissionUtils
---@field _mission EHIMissionHolder
EHIMissionElementTrigger = class()
EHIMissionElementTrigger._all_triggers = {} ---@type table<number, EHIMissionElementTrigger?> Global cache table of all hooked Mission Element Triggers
EHIMissionElementTrigger._cache = {} -- Global cache table that is shared between all created Mission Element Triggers
EHIMissionElementTrigger._SFF = {} ---@type table<number, fun(self: EHIMissionElementTrigger, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)>
EHIMissionElementTrigger._SyncedSFF = {} -- Global cache table of sync data (any data that happens in a heist) that is shared between all created Mission Element Triggers; gets synced (if playing as a host) to other players when they join
EHIMissionElementTrigger.SF = EHI.SpecialFunctions
EHIMissionElementTrigger.IsHost = EHI.IsHost
EHIMissionElementTrigger.Trackers = EHI.Trackers
EHIMissionElementTrigger.Waypoints = EHI.Waypoints
EHIMissionElementTrigger.ConditionFunctions = EHI.ConditionFunctions
EHIMissionElementTrigger._event_listener = EventListenerHolder:new()
if EHI.IsClient then
    EHIMissionElementTrigger.IsClient = true
    EHIMissionElementTrigger._HookOnLoad = {} ---@type table<number, EHIMissionElementTrigger?>
    EHIMissionElementTrigger.LoadSyncHandler = CallbackEventHandler:new()
end
---@param id number
---@param params ElementTrigger
function EHIMissionElementTrigger:init(id, params)
    self._id = id
    self._params = params
    if params.special_function and params.special_function >= self.SF.CustomSF then
        self._f = self._SFF[params.special_function --[[@as number]] ]
    end
    if params.special_function == self.SF.ShowWaypoint and params.data then
        self._params.id = params.data.position_from_element or id
        self:_parse_vanilla_waypoint_trigger(params)
    end
end

---@param id number
function EHIMissionElementTrigger:re_init(id)
    self._id = id
    return self
end

---@param id string
---@param event string|string[]
---@param f function
function EHIMissionElementTrigger:AddEventListener(id, event, f)
    self._event_listener:add(id, event, f)
end

---@param event string
function EHIMissionElementTrigger:CallEvent(event, ...)
    self._event_listener:call(event, ...)
end

---@param id string
function EHIMissionElementTrigger:RemoveEventListener(id)
    self._event_listener:remove(id)
end

function EHIMissionElementTrigger:GetSpecialFunction()
    return self._params.special_function or 0
end

function EHIMissionElementTrigger:TriggerHasData()
    return self._params.data ~= nil
end

---@param id number
function EHIMissionElementTrigger:AddTrigger(id)
    if self._params.data then
        table.insert(self._params.data, id)
    end
end

function EHIMissionElementTrigger:AddTriggers(value)
    if self._params.data then
        for _, data_value in ipairs(value.data or {}) do
            table.insert(self._params.data, data_value)
        end
    else
        EHI:Log("key: " .. tostring(self._id) .. " does not have 'data' table, new triggers won't be added!")
    end
end

---@overload fun(self: EHIMissionElementTrigger)
---@param element MissionScriptElement
---@param enabled boolean
function EHIMissionElementTrigger:Trigger(element, enabled)
    local trigger = self._params
    local f = trigger.special_function
    if f then
        if f == self.SF.RemoveTracker then
            if trigger.data then
                for _, tracker in ipairs(trigger.data) do
                    self._tracking:ForceRemove(tracker)
                end
            else
                self._tracking:ForceRemove(trigger.id)
            end
        elseif f == self.SF.PauseTracker then
            self._tracking:Pause(trigger.id)
        elseif f == self.SF.UnpauseTracker then
            self._tracking:Unpause(trigger.id)
        elseif f == self.SF.UnpauseTrackerIfExists then
            if self._tracking:Exists(trigger.id) then
                self._tracking:Unpause(trigger.id)
            else
                self:CreateTracker()
            end
        elseif f == self.SF.AddTrackerIfDoesNotExist then
            if self._tracking:DoesNotExist(trigger.id) then
                self:CreateTracker()
            end
        elseif f == self.SF.ReplaceTrackerWithTracker then
            self._tracking:ForceRemove(trigger.data.id)
            self:CreateTracker()
        elseif f == self.SF.SetAchievementComplete then
            self._unlockable:SetAchievementComplete(trigger.id, true)
        elseif f == self.SF.SetAchievementStatus then
            self._unlockable:SetAchievementStatus(trigger.id, trigger.status or "ok")
        elseif f == self.SF.SetAchievementFailed then
            self._unlockable:SetAchievementFailed(trigger.id)
        elseif f == self.SF.AddAchievementToCounter then
            local data = trigger.data or {} ---@cast data AchievementLootCounterTable
            data.achievement = data.achievement or trigger.id
            data.no_sync = true
            self._loot:AddAchievementListener(data, data.max or trigger.max or 0)
            self:CreateTracker()
        elseif f == self.SF.IncreaseChance then
            self._tracking:IncreaseChance(trigger.id, trigger.amount)
        elseif f == self.SF.TriggerIfEnabled then
            if enabled then
                if trigger.data then
                    for _, t in ipairs(trigger.data) do
                        self:RunTrigger(t, element, enabled)
                    end
                else
                    self:RunTrigger(trigger.id --[[@as number]], element, enabled)
                end
            end
        elseif f == self.SF.CreateAnotherTrackerWithTracker then
            self:CreateTracker()
            self:RunTrigger(trigger.data.fake_id, element, enabled)
        elseif f == self.SF.SetChanceWhenTrackerExists then
            if self._trackers:Exists(trigger.id) then
                self._trackers:SetChance(trigger.id, trigger.chance)
                if trigger.tracker_merge then
                    self._trackers:SetTime(trigger.id, trigger.time)
                end
            else
                self:CreateTracker()
            end
        elseif f == self.SF.Trigger then
            if trigger.data then
                for _, t in ipairs(trigger.data) do
                    self:RunTrigger(t, element, enabled)
                end
            else
                self:RunTrigger(trigger.id --[[@as number]], element, enabled)
            end
        elseif f == self.SF.RemoveTrigger then
            if trigger.data then
                for _, trigger_id in ipairs(trigger.data) do
                    self:UnhookTrigger(trigger_id)
                end
            else
                self:UnhookTrigger(trigger.id --[[@as number]])
            end
        elseif f == self.SF.SetTimeOrCreateTracker then
            local key = trigger.id
            if trigger.tracker_merge then
                if self._trackers:Exists(key) then
                    self._trackers:SetTime(key, trigger.time)
                else
                    self:_AddTracker(trigger)
                end
                if trigger.waypoint_f then
                    trigger.waypoint_f(self, trigger)
                elseif trigger.waypoint then
                    if self._waypoints:WaypointExists(key) then
                        self._waypoints:SetTime(key, trigger.time)
                    else
                        self._waypoints:AddWaypoint(key, trigger.waypoint)
                    end
                end
            elseif self._tracking:Exists(key) then
                local time = trigger.run and trigger.run.time or trigger.time or 0
                self._tracking:SetTime(key, time)
            else
                self:CreateTracker()
            end
        elseif f == self.SF.SetTimeOrCreateTrackerIfEnabled then
            if enabled then
                if self._tracking:Exists(trigger.id) then
                    self._tracking:SetTime(trigger.id, trigger.time)
                else
                    self:CreateTracker()
                end
            end
        elseif f == self.SF.ExecuteIfElementIsEnabled then
            if enabled then
                self:CreateTracker()
            end
        elseif f == self.SF.SetTimeByPreplanning then
            if managers.preplanning:IsAssetBought(trigger.data.id) then
                trigger.time = trigger.data.yes
            else
                trigger.time = trigger.data.no
            end
            if trigger.waypoint then
                trigger.waypoint.time = trigger.time
            end
            self:CreateTracker()
        elseif f == self.SF.IncreaseProgress then
            self._tracking:IncreaseProgress(trigger.id)
        elseif f == self.SF.SetTrackerAccurate then
            if self._tracking:Exists(trigger.id) then
                self._tracking:SetAccurate(trigger.id, trigger.time)
            else
                self:CreateTracker()
            end
        elseif f == self.SF.SetRandomTime then
            if self._trackers:DoesNotExist(trigger.id) then
                trigger.time = table.random(trigger.data)
                self:CreateTracker()
            end
        elseif f == self.SF.DecreaseChance then
            self._trackers:DecreaseChance(trigger.id, trigger.amount)
        elseif f == self.SF.GetElementTimerAccurate then
            self:GetElementTimerAccurate()
        elseif f == self.SF.UnpauseTrackerIfExistsAccurate then
            if self._tracking:Exists(trigger.id) then
                self._tracking:Unpause(trigger.id)
            else
                self:GetElementTimerAccurate()
            end
        elseif f == self.SF.UnpauseOrSetTimeByPreplanning then
            if self._tracking:Exists(trigger.id) then
                self._tracking:Unpause(trigger.id)
            else
                if trigger.time then
                    self:CreateTracker()
                    return
                end
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    trigger.time = trigger.data.yes
                else
                    trigger.time = trigger.data.no
                end
                self:CreateTracker()
            end
        elseif f == self.SF.FinalizeAchievement then
            self._trackers:CallFunction(trigger.id, "Finalize")
        elseif f == self.SF.IncreaseChanceFromElement then ---@cast element ElementLogicChanceOperator
            self._tracking:IncreaseChance(trigger.id, element._values.chance)
        elseif f == self.SF.DecreaseChanceFromElement then ---@cast element ElementLogicChanceOperator
            self._trackers:DecreaseChance(trigger.id, element._values.chance)
        elseif f == self.SF.SetChanceFromElement then ---@cast element ElementLogicChanceOperator
            self._trackers:SetChance(trigger.id, element._values.chance)
        elseif f == self.SF.PauseTrackerWithTime then
            local t_id = trigger.id
            self._tracking:Pause(t_id)
            self._tracking:SetTimeNoAnim(t_id, trigger.time)
        elseif f == self.SF.IncreaseProgressMax then
            self._tracking:IncreaseProgressMax(trigger.id, trigger.max)
        elseif f == self.SF.IncreaseProgressMax2 then
            if self._trackers:Exists(trigger.id) then
                self._tracking:IncreaseProgressMax(trigger.id, trigger.max)
            else
                local new_trigger =
                {
                    id = trigger.id,
                    max = trigger.max or 1,
                    class = trigger.class or "EHILootTracker"
                }
                self:CreateTracker(new_trigger)
            end
        elseif f == self.SF.SetTimeIfLoudOrStealth then
            if managers.groupai:state():whisper_mode() then
                trigger.time = trigger.data.stealth
            else
                trigger.time = trigger.data.loud
            end
            if trigger.waypoint then
                trigger.waypoint.time = trigger.time
            end
            self:CreateTracker()
        elseif f == self.SF.AddTimeByPreplanning then
            local t = managers.preplanning:IsAssetBought(trigger.data.id) and trigger.data.yes or trigger.data.no
            trigger.time = trigger.time + t
            if trigger.waypoint then
                trigger.waypoint.time = trigger.time
            end
            self:CreateTracker()
        elseif f == self.SF.ShowWaypoint then
            if trigger.data.skip_if_waypoint_exists and self._waypoints:WaypointExists(trigger.data.skip_if_waypoint_exists) then
                return
            end
            managers.hud:AddWaypointFromTrigger(trigger.id, trigger.data)
        elseif f == self.SF.DecreaseProgressMax then
            self._tracking:DecreaseProgressMax(trigger.id, trigger.max)
        elseif f == self.SF.DecreaseProgress then
            self._trackers:DecreaseProgress(trigger.id, trigger.progress)
        elseif f == self.SF.IncreaseCounter then
            self._trackers:IncreaseCount(trigger.id, trigger.count)
        elseif f == self.SF.DecreaseCounter then
            self._trackers:DecreaseCount(trigger.id)
        elseif f == self.SF.SetCounter then
            self._trackers:SetCount(trigger.id, trigger.count)
        elseif f == self.SF.CallCustomFunction then
            if trigger.arg then
                self._tracking:Call(trigger.id, trigger.f --[[@as string]], unpack(trigger.arg))
            else
                self._tracking:Call(trigger.id, trigger.f --[[@as string]])
            end
        elseif f == self.SF.CallTrackerManagerFunction then
            local _tf = self._trackers[trigger.f --[[@as string]]] ---@type fun(self: EHITrackerManager, ...)?
            if _tf then
                if trigger.arg then
                    _tf(self._trackers, unpack(trigger.arg))
                else
                    _tf(self._trackers)
                end
            end
        elseif f == self.SF.CallWaypointManagerFunction then
            local _tf = self._waypoints[trigger.f --[[@as string]]] ---@type fun(self: EHIWaypointManager, ...)?
            if _tf then
                if trigger.arg then
                    _tf(self._waypoints, unpack(trigger.arg))
                else
                    _tf(self._waypoints)
                end
            end
        elseif f == self.SF.DebugElement then
            managers.chat:_receive_message(1, "[EHI]", string.format("ID: %d; Editor Name: %s; Enabled: %s", self._id, element:editor_name(), tostring(enabled)), Color.white)
        elseif f == self.SF.CustomCode then
            trigger.f(trigger.arg)
        elseif f == self.SF.CustomCode2 then
            trigger.f(self, trigger.arg)
        elseif f == self.SF.CustomCodeIfEnabled then
            if enabled then
                trigger.f(trigger.arg)
            end
        elseif f == self.SF.CustomCodeDelayed then
            DelayedCalls:Add(tostring(self._id), trigger.t or 0, trigger.f --[[@as function]])
        elseif f >= self.SF.CustomSF then
            self._f(self, self._params, element, enabled)
        end
    else
        self:CreateTracker()
    end
    if trigger.trigger_once then
        self:UnhookTrigger()
    end
end

---@param waypoint ElementWaypointTrigger
function EHIMissionElementTrigger:AddWaypoint(waypoint)
    local w = deep_clone(waypoint)
    w.time = w.time or self._params.time
    if not w.icon then
        local icon = self._params.icons
        if icon and icon[1] then
            if type(icon[1]) == "table" then
                w.icon = icon[1].icon
            elseif type(icon[1]) == "string" then
                w.icon = icon[1]
            end
        end
    end
    if self._params.class then
        w.class = self._mission._TrackerToWaypoint[self._params.class]
        for key, _ in pairs(self._mission._WaypointDataCopy[w.class or ""] or self._mission._WaypointDataCopy.Base) do
            w[key] = w[key] or self._params[key]
        end
    end
    self._params.waypoint = w
    if w.unit then
        if w.unit:unit_data() and w.unit:unit_data().add_destroy_listener then
            w.unit:unit_data():add_destroy_listener(string.format("EHIDestroy_%s_%d", tostring(self._params.id), self._id), function()
                self._waypoints:RemoveWaypoint(self._params.id)
            end)
        elseif w.unit:base() and w.unit:base().add_destroy_listener then
            w.unit:base():add_destroy_listener(string.format("EHIDestroy_%s_%d", tostring(self._params.id), self._id), function() ---@diagnostic disable-line
                self._waypoints:RemoveWaypoint(self._params.id)
            end)
        else
            EHI:Log(string.format("Unit %s with editor id %d does not have destroy listener. This will cause a crash when waypoint is running and game is restarted!", tostring(w.unit), w.unit.editor_id and w.unit:editor_id() or 0))
        end
    end
end

---@param icon string
function EHIMissionElementTrigger:UpdateWaypointIcon(icon)
    if self._params.waypoint then
        self._params.waypoint.icon = icon
        self._waypoints:SetWaypointIcon(self._params.id, icon)
    end
end

---@param trigger ElementTrigger
function EHIMissionElementTrigger:_AddTracker(trigger)
    if trigger.random_time then
        trigger.time = self:GetRandomTime(trigger)
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
    end
    self._trackers:AddTracker(trigger, trigger.pos)
end

---@param trigger ElementTrigger
function EHIMissionElementTrigger:GetRandomTime(trigger)
    return (trigger.additional_time or 0) + math.rand(trigger.random_time)
end

if Visibility._SHOW_MISSION_WAYPOINTS and not Visibility._SHOW_MISSION_TRACKERS then
    ---@param trigger ElementTrigger?
    function EHIMissionElementTrigger:CreateTracker(trigger)
        trigger = trigger or self._params
        if trigger.condition_function and not trigger.condition_function() then
            return
        elseif trigger.waypoint_f then
            if not trigger.run then
                if trigger.random_time then
                    trigger.time = self:GetRandomTime(trigger)
                end
            end
            trigger.waypoint_f(self, trigger)
        elseif trigger.waypoint then
            if trigger.random_time then
                trigger.waypoint.time = self:GetRandomTime(trigger)
            end
            if trigger.waypoint.waypointless then
                self._waypoints:AddWaypointlessWaypoint(trigger.waypoint.id or trigger.id, trigger.waypoint)
            else
                self._waypoints:AddWaypoint(trigger.waypoint.id or trigger.id, trigger.waypoint)
            end
        elseif trigger.run then
            self._trackers:RunTracker(trigger.id, trigger.run)
        elseif trigger.tracker_merge and self._trackers:Exists(trigger.tracker_merge.id or trigger.id) then
            local key = trigger.tracker_merge.id or trigger.id
            if trigger.tracker_merge.start_timer then
                self._trackers:CallFunction(key, "StartTimer", trigger.time)
            else
                self._trackers:SetTime(key, trigger.time)
            end
        elseif trigger.tracker_group and self._trackers:Exists(trigger.id) then
            self._trackers:CallFunction(trigger.id, "AddFromTrigger", trigger)
        else
            self:_AddTracker(trigger)
        end
    end
else
    ---@param trigger ElementTrigger?
    function EHIMissionElementTrigger:CreateTracker(trigger)
        trigger = trigger or self._params
        if trigger.condition_function and not trigger.condition_function() then
            return
        elseif trigger.run then
            self._trackers:RunTracker(trigger.id, trigger.run)
        elseif trigger.tracker_merge and self._trackers:Exists(trigger.tracker_merge.id or trigger.id) then
            local key = trigger.tracker_merge.id or trigger.id
            local t = trigger.time ---@cast t -?
            if trigger.tracker_merge.start_timer then
                self._trackers:CallFunction(key, "StartTimer", t)
            else
                self._trackers:SetTime(key, t)
            end
        elseif trigger.tracker_group and self._trackers:Exists(trigger.id) then
            self._trackers:CallFunction(trigger.id, "AddFromTrigger", trigger)
        else
            self:_AddTracker(trigger)
        end
        if trigger.waypoint_f then
            trigger.waypoint_f(self, trigger)
        elseif trigger.waypoint then
            if trigger.waypoint.waypointless then
                self._waypoints:AddWaypointlessWaypoint(trigger.waypoint.id or trigger.id, trigger.waypoint)
            else
                self._waypoints:AddWaypoint(trigger.waypoint.id or trigger.id, trigger.waypoint)
            end
        end
    end
end

if Visibility._SHOW_MISSION_TRIGGERS then
    function EHIMissionElementTrigger:GetElementTimerAccurate()
        if self.IsHost then
            local element = managers.mission:get_element_by_id(self._params.element) --[[@as ElementTimer?]]
            if element then
                local t = (element._timer or 0) + (self._params.additional_time or 0)
                self._params.time = t
                if self._params.waypoint then
                    self._params.waypoint.time = t
                end
                self:CreateTracker()
                self:SendMessage(t)
            end
        else
            self:CreateTracker()
        end
    end
else
    function EHIMissionElementTrigger:GetElementTimerAccurate()
        if self.IsHost then
            local element = managers.mission:get_element_by_id(self._params.element) --[[@as ElementTimer?]]
            if element then
                local t = (element._timer or 0) + (self._params.additional_time or 0)
                self:SendMessage(t)
            end
        end
    end
end

---@param delay number
---@param id number?
function EHIMissionElementTrigger:SendMessage(delay, id)
    NetworkHelper:SendToPeersExcept(1, "EHISyncAddTracker", json.encode({ id = id or self._id, delay = delay or 0 }))
end

function EHIMissionElementTrigger:sync_load()
    local trigger = self._params
    if trigger.special_function == self.SF.ShowWaypoint and trigger.data and not trigger.data.position then
        if trigger.data.position_from_element then
            self._mission:_add_position_from_element(trigger.data, trigger.id, true)
        elseif trigger.data.position_from_unit then
            self._mission:_add_position_from_unit(trigger.data, trigger.id, true)
        end
    elseif trigger.waypoint and not trigger.waypoint.position then
        if trigger.waypoint.data_from_element then
            self._mission:_add_data_from_element(trigger.waypoint, trigger.id, true)
        elseif trigger.waypoint.position_from_element then
            self._mission:_add_position_from_element(trigger.waypoint, trigger.id, true)
        elseif trigger.waypoint.position_from_unit then
            self._mission:_add_position_from_unit(trigger.waypoint, trigger.id, true)
        end
        trigger.waypoint.skip_if_not_found = nil
    end
end

function EHIMissionElementTrigger:LoadSync()
    if self._params.load_sync then
        self._params.load_sync(self)
        self._params.load_sync = nil
    end
end

function EHIMissionElementTrigger:RemoveLoadSync()
    self._params.load_sync = nil
end

---@param data ElementTrigger
function EHIMissionElementTrigger:_parse_vanilla_waypoint_trigger(data)
    data.data.distance = true
    data.data.state = "sneak_present"
    data.data.present_timer = 0
    data.data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
    if data.data.position_from_element then
        data.id = data.id or data.data.position_from_element
        self._mission:_add_position_from_element(data.data, data.id, true)
    elseif data.data.position_from_unit then
        self._mission:_add_position_from_unit(data.data, data.id, true)
    end
    if data.data.icon then
        local redirect = self._mission._WaypointIconRedirect[data.data.icon]
        if redirect then
            data.data.icon = redirect
            data.data.icon_redirect = true
        end
    end
    if not data.data.position then
        EHI:Log(string.format("Parsed Vanilla waypoint trigger with ID '%s' does not have a valid position. Position vector set to default value to avoid crashing.", tostring(data.id)))
        data.data.position = Vector3()
    end
end

---@overload fun(self: EHIMissionElementTrigger, id: number)
---@param id number
---@param element MissionScriptElement
---@param enabled boolean
function EHIMissionElementTrigger:RunTrigger(id, element, enabled)
    local trigger = self._all_triggers[id]
    if trigger then
        trigger:Trigger(element, enabled)
    end
end

---@param id number
---@param waypoint ElementWaypointTrigger
function EHIMissionElementTrigger:AddWaypointToTrigger(id, waypoint)
    local trigger = self._all_triggers[id]
    if trigger then
        trigger:AddWaypoint(waypoint)
    end
end

---@param id number
---@param params ElementTrigger
function EHIMissionElementTrigger:UpdateTriggerParams(id, params)
    local trigger = self._all_triggers[id]
    if trigger then
        trigger._params = params
    end
end

---@param id number
---@param icon string
function EHIMissionElementTrigger:UpdateWaypointTriggerIcon(id, icon)
    local trigger = self._all_triggers[id]
    if trigger and trigger._params.waypoint then
        trigger._params.waypoint.icon = icon
        self._waypoints:SetWaypointIcon(trigger._params.id, icon)
    end
end

---@param id number? ID of the element, if not provided `self._id` is used
function EHIMissionElementTrigger:UnhookTrigger(id)
    id = id or self._id
    if table.remove_key(self._all_triggers, id) then
        self._hook:UnhookElement(id)
    end
end

---@param f fun(self: EHIMissionElementTrigger, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return number
function EHIMissionElementTrigger:RegisterCustomSF(f)
    local f_id = (self._SFFUsed or self.SF.CustomSF) + 1
    self._SFF[f_id] = f
    self._SFFUsed = f_id
    return f_id
end

---@param id number
function EHIMissionElementTrigger:UnregisterCustomSF(id)
    self._SFF[id] = nil
end

---@param f fun(self: EHIMissionElementTrigger, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return number
function EHIMissionElementTrigger:RegisterCustomSyncedSF(f)
    local f_id = (self._SyncedSFFUsed or self.SF.CustomSyncedSF) + 1
    self._SFF[f_id] = f
    if self.IsHost then -- Syncing happens in `EHIManager:load()` and `EHIManager:save()`
        self._mission.SyncFunctions[f_id] = true
    end
    self._SyncedSFFUsed = f_id
    return f_id
end

---@param f fun(self: EHIMissionElementTrigger)
function EHIMissionElementTrigger:AddLoadSyncFunction(f)
    if self.LoadSyncHandler then
        self.LoadSyncHandler:add(f)
    end
end

---@param elements_to_hook table<number, EHIMissionElementTrigger?>?
function EHIMissionElementTrigger:__HookElements(elements_to_hook)
    local client = self.IsClient
    self.__hook_f = self.__hook_f or client and function(element, ...) ---@param element MissionScriptElement
        self:RunTrigger(element._id, element, true)
    end or function(element, ...) ---@param element MissionScriptElement
        self:RunTrigger(element._id, element, element._values.enabled)
    end
    local scripts = managers.mission._scripts or {}
    for id, trigger in pairs(elements_to_hook or self._all_triggers) do
        if math.within(id, 100000, 999999) then
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._hook:HookElement(element, self.__hook_f)
                elseif client then
                    --[[
                        On client, the element was not found
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHIManager:SyncLoad())
                    ]]
                    self._HookOnLoad[id] = trigger
                end
            end
        end
    end
end

---@param elements_to_hook table<number, _>
function EHIMissionElementTrigger:__FindAndHookElements(elements_to_hook)
    for id, _ in pairs(elements_to_hook) do
        elements_to_hook[id] = self._all_triggers[id]
    end
    self:__HookElements(elements_to_hook)
end

---@param triggers table<number, ElementTrigger>
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHIMissionElementTrigger:__AddTriggersAndHookElements(triggers, trigger_id_all, trigger_icons_all)
    self:__AddTriggers(triggers, trigger_id_all, trigger_icons_all)
    self:__FindAndHookElements(triggers)
end

---@param value ElementTrigger
---@param trigger_id_all string?
---@param trigger_icons_all table?
local function FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
    value.id = value.id or trigger_id_all
    if not value.icons and not value.run then
        value.icons = trigger_icons_all
    end
end
---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table<number, ElementTrigger>
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHIMissionElementTrigger:__AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        local t = self._all_triggers[key]
        if t then
            if self._mission.TriggerFunction[t:GetSpecialFunction()] then
                if self._mission.TriggerFunction[value.special_function or 0] then
                    t:AddTriggers(value)
                elseif t:TriggerHasData() then
                    local new_key = (key * 10) + 1
                    while self._all_triggers[new_key] do
                        new_key = new_key + 1
                    end
                    FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
                    self._all_triggers[new_key] = EHIMissionElementTrigger:new(new_key, value)
                    t:AddTrigger(new_key)
                else
                    EHI:Log("key: " .. tostring(key) .. " does not have 'data' table, the trigger " .. tostring(new_key) .. " will not be called!")
                end
            elseif self._mission.TriggerFunction[value.special_function or 0] then
                if value.data then
                    local new_key = (key * 10) + 1
                    while table.get_vector_index(value.data, new_key) or new_triggers[new_key] or self._all_triggers[new_key] do
                        new_key = new_key + 1
                    end
                    self._all_triggers[new_key] = t:re_init(new_key)
                    FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
                    table.insert(value.data, new_key)
                    self._all_triggers[key] = EHIMissionElementTrigger:new(key, value)
                else
                    EHI:Log("key: " .. tostring(key) .. " with ID: " .. tostring(value.id) .. " does not have 'data' table, the former trigger won't be moved and triggers assigned to this one will not be called!")
                end
            else
                local new_key = (key * 10) + 1
                local key2 = new_key + 1
                self._all_triggers[key] = EHIMissionElementTrigger:new(key, { special_function = self.SF.Trigger, data = { new_key, key2 } })
                self._all_triggers[new_key] = t:re_init(new_key)
                FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
                self._all_triggers[key2] = EHIMissionElementTrigger:new(key2, value)
            end
        else
            FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
            self._all_triggers[key] = EHIMissionElementTrigger:new(key, value)
        end
    end
end

function EHIMissionElementTrigger:__post_init()
    if self.IsClient then
        managers.ehi_sync:AddLoadSyncFunction(callback(self, self, "__load_sync"))
        managers.ehi_sync:AddFullSyncFunction(callback(self, self, "__full_sync"))
    end
    return self
end

function EHIMissionElementTrigger:__add_missing_position_to_waypoints()
    for _, element in pairs(self._all_triggers) do
        element:sync_load()
    end
end

function EHIMissionElementTrigger:__load_sync()
    for _, element in pairs(self._all_triggers) do
        element:sync_load()
        element:LoadSync()
    end
    self.LoadSyncHandler:dispatch(self)
    self.LoadSyncHandler:clear()
    self.LoadSyncHandler = nil
end

function EHIMissionElementTrigger:__full_sync()
    for _, element in pairs(self._all_triggers) do
        element:sync_load()
        element:RemoveLoadSync()
    end
end

---@param data SyncData
function EHIMissionElementTrigger:load(data)
    local state = data.EHIMissionElementTrigger or data.EHIManager -- Backwards compatibility
    if state and state.SyncedSFF then
        for key, value in pairs(state.SyncedSFF) do
            self._SyncedSFF[key] = value
        end
    end
end

---@param data SyncData
function EHIMissionElementTrigger:save(data)
    if ehi_next(self._SyncedSFF) then
        local state = {}
        state.SyncedSFF = {}
        for key, value in pairs(self._SyncedSFF) do
            state.SyncedSFF[key] = value
        end
        data.EHIMissionElementTrigger = state
        data.EHIManager = state -- Backwards compatibility
    end
end

---@class EHIHostMissionElementTrigger : EHIMissionElementTrigger
---@field super EHIMissionElementTrigger
---@field new fun(self: self, id: number, params: ElementTrigger): self
EHIHostMissionElementTrigger = class(EHIMissionElementTrigger)
EHIHostMissionElementTrigger._all_triggers = {} ---@type table<number, EHIHostMissionElementTrigger?> Global cache table of all hooked Mission Element Triggers that sync info to EHI clients
if Visibility._SHOW_MISSION_WAYPOINTS and not Visibility._SHOW_MISSION_TRACKERS then
    ---@param delay number
    ---@param id number
    function EHIHostMissionElementTrigger:CreateTrackerAndSync(delay, id)
        local previous_delay = self._params.time or 0
        self._params.time = previous_delay + (delay or 0)
        if self._params.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            self._params.waypoint_f(self, self._params)
        elseif self._params.waypoint then
            self._waypoints:AddWaypoint(self._params.id, self._params.waypoint)
        else
            self._trackers:AddTracker(self._params)
        end
        self:SendMessage(delay, id)
        self._params.time = previous_delay
    end
elseif Visibility._SHOW_MISSION_TRACKERS then
    ---@param delay number
    ---@param id number
    function EHIHostMissionElementTrigger:CreateTrackerAndSync(delay, id)
        local previous_delay = self._params.time or 0
        self._params.time = previous_delay + (delay or 0)
        self._trackers:AddTracker(self._params)
        if self._params.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            self._params.waypoint_f(self, self._params)
        elseif self._params.waypoint then
            self._waypoints:AddWaypoint(self._params.id, self._params.waypoint)
        end
        self:SendMessage(delay, id)
        self._params.time = previous_delay
    end
else
    EHIHostMissionElementTrigger.CreateTrackerAndSync = EHIHostMissionElementTrigger.SendMessage
end

---@class EHIHostBaseDelayMissionElementTrigger : EHIHostMissionElementTrigger
---@field super EHIHostMissionElementTrigger
---@field new fun(self: self, id: number, params: ElementTrigger): self
EHIHostBaseDelayMissionElementTrigger = class(EHIHostMissionElementTrigger)
---@param element MissionScriptElement
function EHIHostBaseDelayMissionElementTrigger:HookBaseDelay(element)
    self.__original = element._calc_base_delay
    element._calc_base_delay = function(e)
        local delay = self.__original(e)
        self:CreateTrackerAndSync(delay, e._id)
        return delay
    end
end

---@class EHIHostElementDelayMissionElementTrigger : EHIHostMissionElementTrigger
---@field super EHIHostMissionElementTrigger
---@field new fun(self: self, id: number): self
EHIHostElementDelayMissionElementTrigger = class(EHIHostMissionElementTrigger)
---@param id number
function EHIHostElementDelayMissionElementTrigger:init(id)
    self._id = id
    self.__elements = {} ---@type table<number, ElementTrigger>
end

---@param id number
---@param params ElementTrigger
function EHIHostElementDelayMissionElementTrigger:AddElementDelay(id, params)
    if self.__elements[id] then
        EHI:Log(string.format("key: %d already exists in host element delay triggers table! ID: %d", id, self._id))
        return
    end
    self.__elements[id] = params
end

---@param element MissionScriptElement
function EHIHostElementDelayMissionElementTrigger:HookElementDelay(element)
    self.__original = element._calc_element_delay
    element._calc_element_delay = function(e, params)
        local delay = self.__original(e, params)
        local trigger = self.__elements[params.id]
        if trigger then
            self._params = trigger
            if trigger.remove_trigger_when_executed then
                self:CreateTrackerAndSync(delay, params.id)
                self.__elements[params.id] = nil
            elseif trigger.set_time_when_tracker_exists and self._trackers:Exists(trigger.id) then
                self._trackers:SetTimeNoAnim(trigger.id, delay)
                self:SendMessage(delay, params.id)
            else
                self:CreateTrackerAndSync(delay, params.id)
            end
        end
        return delay
    end
end

function EHIHostElementDelayMissionElementTrigger:sync_load()
    for _, trigger in pairs(self.__elements) do
        self._params = trigger
        EHIHostElementDelayMissionElementTrigger.super.sync_load(self)
    end
end

---@class EHIClientMissionElementTrigger : EHIMissionElementTrigger
---@field super EHIMissionElementTrigger
---@field new fun(self: self, id: number, params: ElementTrigger): self
EHIClientMissionElementTrigger = class(EHIMissionElementTrigger)
EHIClientMissionElementTrigger._all_triggers = {} ---@type table<number, EHIClientMissionElementTrigger?> Global cache table of all hooked Mission Element Triggers that sync info from EHI host
function EHIClientMissionElementTrigger:init(id, params)
    local sync_trigger = deep_clone(params)
    if sync_trigger.synced then
        sync_trigger.class = sync_trigger.synced.class
        sync_trigger.synced = nil
    end
    if sync_trigger.waypoint and sync_trigger.waypoint.synced then
        sync_trigger.waypoint.class = sync_trigger.waypoint.synced.class
        sync_trigger.waypoint.synced = nil
    end
    if sync_trigger.delay_only then
        sync_trigger.random_time = nil
        sync_trigger.additional_time = nil
    end
    EHIClientMissionElementTrigger.super.init(self, id, sync_trigger)
end

---@param delay number
function EHIClientMissionElementTrigger:AddTrackerSynced(delay)
    local trigger = self._params
    local trigger_id = trigger.id
    if self._tracking:Exists(trigger_id) then
        if trigger.delay_only then
            self._tracking:SetAccurate(trigger_id, delay)
        else
            self._tracking:SetAccurate(trigger_id, (trigger.time or trigger.additional_time or 0) + delay)
        end
    else
        self:CreateSyncedTracker(trigger, delay)
    end
end

if Visibility._SHOW_MISSION_WAYPOINTS and not Visibility._SHOW_MISSION_TRACKERS then
    ---@param trigger ElementTrigger
    ---@param delay number
    function EHIClientMissionElementTrigger:CreateSyncedTracker(trigger, delay)
        local t = trigger.delay_only and delay or ((trigger.time or trigger.additional_time or 0) + delay)
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            trigger.time = t
            trigger.waypoint_f(self, trigger)
            trigger.time = nil
        elseif trigger.waypoint then
            trigger.waypoint.time = t
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        else
            self._trackers:AddTracker({
                id = trigger.id,
                time = t,
                icons = trigger.icons,
                hint = trigger.hint,
                class = trigger.class
            }, trigger.pos)
        end
    end
else
    ---@param trigger ElementTrigger
    ---@param delay number
    function EHIClientMissionElementTrigger:CreateSyncedTracker(trigger, delay)
        local t = trigger.delay_only and delay or ((trigger.time or trigger.additional_time or 0) + delay)
        self._trackers:AddTracker({
            id = trigger.id,
            time = t,
            icons = trigger.icons,
            hint = trigger.hint,
            class = trigger.class
        }, trigger.pos)
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            trigger.time = t
            trigger.waypoint_f(self, trigger)
            trigger.time = nil
        elseif trigger.waypoint then
            trigger.waypoint.time = t
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        end
    end
end

---@class EHIMissionUtils
local EHIMissionUtils = {}
---@param tweak_data string
function EHIMissionUtils:InteractionExists(tweak_data)
    local interactions = managers.interaction._interactive_units
    for _, unit in ipairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            return true
        end
    end
    return false
end

---@param id number
function EHIMissionUtils:IsMissionElementEnabled(id)
    local element = managers.mission:get_element_by_id(id)
    return element and element:enabled()
end

---@param id number
function EHIMissionUtils:IsMissionElementDisabled(id)
    return not self:IsMissionElementEnabled(id)
end

---@param tweak_data string
function EHIMissionUtils:CountInteractionAvailable(tweak_data)
    local count = 0
    local interactions = managers.interaction._interactive_units
    for _, unit in ipairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            count = count + 1
        end
    end
    return count
end

---@param offset integer?
function EHIMissionUtils:CountLootbagsOnTheGround(offset)
    local lootbags = {}
    local excluded = { value_multiplier = true, dye = true, types = true, small_loot = true }
    for key, data in pairs(tweak_data.carry) do
        if not (excluded[key] or data.is_unique_loot or data.skip_exit_secure) then
            lootbags[key] = true
        end
    end
    local count = 0 - (offset or 0)
    local interactions = managers.interaction._interactive_units ---@cast interactions UnitCarry[]
    for _, unit in ipairs(interactions) do
        if unit:carry_data() and lootbags[unit:carry_data():carry_id()] then
            count = count + 1
        end
    end
    return count
end

---@param path string
---@param slotmask integer
function EHIMissionUtils:CountUnitsAvailable(path, slotmask)
    local _, n = self:GetUnits(path, slotmask)
    return n - 1
end

---@param path string
---@param slotmask integer
function EHIMissionUtils:GetUnits(path, slotmask)
    local tbl = {}
    local tbl_i = 1
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in ipairs(units) do
        if unit and unit:name() == idstring then
            tbl[tbl_i] = unit
            tbl_i = tbl_i + 1
        end
    end
    return tbl, tbl_i
end

local EHI = EHI
---@class EHIMissionHolder : Visibility
local EHIMissionHolder = deep_clone(Visibility)
EHIMissionHolder._utils = EHIMissionUtils
EHIMissionHolder._triggers = EHIMissionElementTrigger
EHIMissionHolder._host_triggers = EHIHostMissionElementTrigger._all_triggers
EHIMissionHolder._client_triggers = EHIClientMissionElementTrigger._all_triggers
EHIMissionHolder.Trackers = EHI.Trackers
EHIMissionHolder.Waypoints = EHI.Waypoints
EHIMissionHolder.FilterTracker =
{
    show_timers =
    {
        waypoint = "show_waypoints_timers",
        table_name = "Timer"
    }
}
function EHIMissionHolder:new()
    self._TrackerToWaypoint =
    {
        [self.Trackers.Pausable] = self.Waypoints.Pausable,
        [self.Trackers.Progress] = self.Waypoints.Progress,
        [self.Trackers.Warning] = self.Waypoints.Warning,
        [self.Trackers.Chance] = self.Waypoints.Chance,
        [self.Trackers.Inaccurate] = self.Waypoints.Inaccurate,
        [self.Trackers.InaccuratePausable] = self.Waypoints.InaccuratePausable,
        [self.Trackers.InaccurateWarning] = self.Waypoints.InaccurateWarning,
        [self.Trackers.Group.Warning] = self.Waypoints.Warning,
        [self.Trackers.Code] = self.Waypoints.Code,
        [self.Trackers.ColoredCodes] = self.Waypoints.ColoredCodes,
        [self.Trackers.TimePreSync] = self.Waypoints.TimePreSync
    }
    self._TrackerToInaccurate =
    {
        [self.Trackers.Base] = self.Trackers.Inaccurate,
        [self.Trackers.Pausable] = self.Trackers.InaccuratePausable,
        [self.Trackers.Warning] = self.Trackers.InaccurateWarning
    }
    self._WaypointToInaccurate =
    {
        [self.Waypoints.Base] = self.Waypoints.Inaccurate,
        [self.Waypoints.Pausable] = self.Waypoints.InaccuratePausable,
        [self.Waypoints.Warning] = self.Waypoints.InaccurateWarning
    }
    self._WaypointIconRedirect =
    {
        [EHI.Icons.Heli] = "EHI_Heli"
    }
    local SF = EHI.SpecialFunctions
    self.TriggerFunction =
    {
        [SF.TriggerIfEnabled] = true,
        [SF.Trigger] = true
    }
    self.SyncFunctions =
    {
        [SF.GetElementTimerAccurate] = true,
        [SF.UnpauseTrackerIfExistsAccurate] = true
    }
    self._GroupingTrackers =
    {
        [self.Trackers.Group.Base] = true,
        [self.Trackers.Group.Warning] = true
    }
    self._WaypointDataCopy =
    {
        Base =
        {
            time = true
        },
        [self.Waypoints.Progress] =
        {
            progress = true,
            max = true
        },
        [self.Waypoints.Chance] =
        {
            chance = true,
            chances = true
        }
    }
    self._WaypointDataCopy[self.Waypoints.Less.Chance] = self._WaypointDataCopy[self.Waypoints.Chance]
    self._ConditionalLoad =
    {
        [self.Trackers.Code] = { tracker = "EHICodesTracker", waypoint = "EHICodesWaypoint", also_remove = self.Trackers.ColoredCodes },
        [self.Trackers.ColoredCodes] = { tracker = "EHICodesTracker", waypoint = "EHICodesWaypoint", also_remove = self.Trackers.Code },
        [self.Trackers.TimePreSync] = { tracker = self.Trackers.TimePreSync, waypoint = self.Waypoints.TimePreSync }
    }
    if EHI.IsClient then
        self.ClientSyncFunctions = deep_clone(self.SyncFunctions)
        self._HookOnLoad = self._triggers._HookOnLoad
    end
    return self
end

function EHIMissionHolder:init_finalize()
    local managers = managers
    self._triggers._trackers = managers.ehi_tracker
    self._triggers._waypoints = managers.ehi_waypoint
    self._triggers._hook = managers.ehi_hook
    self._triggers._unlockable = managers.ehi_unlockable
    self._triggers._loot = managers.ehi_loot
    self._triggers._assault = managers.ehi_assault
    self._triggers._tracking = managers.ehi_tracking
    self._triggers._utils = self._utils
    self._triggers._mission = self
    if EHI.IsClient then
        managers.ehi_sync:AddReceiveHook("EHISyncAddTracker", function(data, sender)
            local tbl = json.decode(data)
            if tbl and tbl.id and tbl.delay and self._client_triggers then
                local trigger = self._client_triggers[tbl.id]
                if trigger then
                    trigger:AddTrackerSynced(tbl.delay)
                    if trigger._params.client_on_executed then
                        -- Right now there is only SF.RemoveTriggerWhenExecuted
                        self._client_triggers[tbl.id] = nil
                    end
                end
            end
        end)
    end
end

---@param new_triggers ParseTriggersTable
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIMissionHolder:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    new_triggers = new_triggers or {}
    new_triggers.mission = new_triggers.mission or {}
    if new_triggers.tracker_merge then
        for key, value in pairs(new_triggers.tracker_merge) do
            local merge = { id = key, start_timer = value.start_timer }
            for id, trigger in pairs(value.elements or {}) do
                if trigger.id then
                    trigger.tracker_merge = merge
                else
                    trigger.id = key
                end
                new_triggers.mission[id] = trigger
            end
        end
    end
    if new_triggers.pre_parse and new_triggers.pre_parse.filter_out_not_loaded_trackers then
        local filter = new_triggers.pre_parse.filter_out_not_loaded_trackers
        if type(filter) == "string" then
            self:_filter_out_not_loaded_trackers(new_triggers.mission, filter)
        else
            for _, option in ipairs(filter) do
                self:_filter_out_not_loaded_trackers(new_triggers.mission, option)
            end
        end
    end
    if new_triggers.sync_triggers then
        local host = EHI.IsHost
        for key, tbl in pairs(new_triggers.sync_triggers) do
            if host then
                self:_add_host_triggers(key, tbl)
            else
                self:_set_sync_triggers(tbl)
            end
        end
    end
    if new_triggers.loot_removal_triggers and EHI:IsLootCounterVisible() then
        if EHI.IsHost then
            local function f(e, instigator, ...)
                if not e._values.enabled or not alive(instigator) then
                    return
                elseif e._values.type_filter and e._values.type_filter ~= "none" then
                    local carry_ext = instigator:carry_data()
                    if not carry_ext then
                        return
                    end
                    local carry_id = carry_ext:carry_id()
                    if carry_id ~= e._values.type_filter then
                        return
                    end
                end
                managers.ehi_loot:DecreaseLootCounterProgressMax()
            end
            for _, index in ipairs(new_triggers.loot_removal_triggers) do
                local element = managers.mission:get_element_by_id(index)
                if element then
                    managers.ehi_hook:PrehookElement(element, f)
                end
            end
        else
            local loot_trigger = { special_function = self._triggers:RegisterCustomSF(function(s, ...)
                s._loot:DecreaseLootCounterProgressMax()
            end) }
            new_triggers.other = new_triggers.other or {}
            for _, element in ipairs(new_triggers.loot_removal_triggers) do
                new_triggers.other[element] = loot_trigger
            end
        end
    end
    managers.ehi_assault:Parse(new_triggers.assault)
    self:PreloadTrackers(new_triggers.preload or {}, trigger_id_all or "Trigger", trigger_icons_all or {})
    ---@param data ParseAchievementDefinitionTable
    ---@param id string
    local function ParseParams(data, id)
        if data.alarm_callback then
            EHI:AddOnAlarmCallback(data.alarm_callback)
        end
        if data.load_sync then
            self._triggers:AddLoadSyncFunction(data.load_sync)
        end
        if data.failed_on_alarm then
            EHI:AddOnAlarmCallback(function()
                managers.ehi_unlockable:SetAchievementFailed(id)
            end)
        end
        if data.mission_end_callback then
            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                if success then
                    managers.ehi_unlockable:SetAchievementComplete(id, true)
                else
                    managers.ehi_unlockable:SetAchievementFailed(id)
                end
            end)
        end
        if data.parsed_callback then
            data.parsed_callback()
            data.parsed_callback = nil
        end
    end
    ---@param data ParseAchievementDefinitionTable
    local function PreparseParams(data)
        if data.preparse_callback then
            data.preparse_callback(data)
            data.preparse_callback = nil
        end
    end
    ---@param data ParseAchievementDefinitionTable
    local function Cleanup(data)
        for _, element in pairs(data.elements or {}) do
            if element.special_function and element.special_function > self._triggers.SF.CustomSF then
                self._triggers:UnregisterCustomSF(element.special_function)
            end
        end
        if data.cleanup_callback then
            data.cleanup_callback()
        end
        if data.cleanup_class then
            _G[data.cleanup_class] = nil
        end
    end
    self._triggers:__AddTriggers(new_triggers.other or {}, trigger_id_all or "Trigger", trigger_icons_all)
    if ehi_next(new_triggers.achievement) then
        if EHI:ShowMissionAchievements() then
            ---@param data ParseAchievementDefinitionTable
            ---@param id string
            local function Parser(data, id)
                PreparseParams(data)
                for _, element in pairs(data.elements or {}) do
                    if element.class or element.class_table then
                        element.beardlib = data.beardlib
                        if not element.icons then
                            if data.beardlib then
                                element.icons = { "ehi_" .. id }
                            else
                                element.icons = EHI:GetAchievementIcon(id)
                            end
                        end
                    end
                end
                self._triggers:__AddTriggers(data.elements or {}, id)
                ParseParams(data, id)
            end
            local function IsAchievementLocked(data, id)
                if data.beardlib then
                    return not EHI:IsBeardLibAchievementUnlocked(data.package, id)
                else
                    return EHI:IsAchievementLocked(id)
                end
            end
            for id, data in pairs(new_triggers.achievement) do
                if data.difficulty_pass ~= false and IsAchievementLocked(data, id) then
                    Parser(data, id)
                else
                    Cleanup(data)
                end
            end
        else
            for _, data in pairs(new_triggers.achievement) do
                Cleanup(data)
            end
        end
    end
    if ehi_next(new_triggers.trophy) then
        if EHI:GetUnlockableAndOption("show_trophies") then
            EHI:OptionAndLoadTracker("show_trophies")
            for id, data in pairs(new_triggers.trophy) do
                if data.difficulty_pass ~= false and EHI:IsTrophyLocked(id) then
                    PreparseParams(data)
                    for _, element in pairs(data.elements or {}) do
                        if (element.class or element.class_table) and not element.icons then
                            element.icons = { EHI.Icons.Trophy }
                        end
                    end
                    self._triggers:__AddTriggers(data.elements or {}, id)
                    ParseParams(data, id)
                end
            end
        else
            for _, data in pairs(new_triggers.trophy) do
                Cleanup(data)
            end
        end
    end
    if ehi_next(new_triggers.sidejob) then
        if EHI:GetUnlockableAndOption("show_dailies") then
            for id, data in pairs(new_triggers.sidejob) do
                if data.difficulty_pass ~= false and EHI:IsSHSideJobAvailable(id) then
                    PreparseParams(data)
                    for _, element in pairs(data.elements or {}) do
                        if (element.class or element.class_table) and not element.icons then
                            element.icons = { EHI.Icons.Trophy }
                        end
                    end
                    self._triggers:__AddTriggers(data.elements or {}, id)
                    ParseParams(data, id)
                else
                    Cleanup(data)
                end
            end
        else
            for _, data in pairs(new_triggers.sidejob) do
                Cleanup(data)
            end
        end
    end
    self:ParseMissionTriggers(new_triggers.mission, trigger_id_all, trigger_icons_all)
end

---@param mission_triggers table<number, ElementTrigger>
---@param trigger_id_all string?
---@param trigger_icons_all table?
---@param no_host_override boolean?
function EHIMissionHolder:ParseMissionTriggers(mission_triggers, trigger_id_all, trigger_icons_all, no_host_override)
    if not self._SHOW_MISSION_TRIGGERS then
        local triggers = {}
        for id, data in pairs(mission_triggers) do
            if data.special_function then
                if self.SyncFunctions[data.special_function] then
                    triggers[id] = data
                elseif data.special_function > self._triggers.SF.CustomSF then
                    self._triggers:UnregisterCustomSF(data.special_function)
                end
            end
        end
        self._triggers:__AddTriggers(triggers, trigger_id_all or "Trigger", trigger_icons_all)
        return
    end
    local host = EHI.IsHost
    if no_host_override then
        host = false
    end
    for id, data in pairs(mission_triggers) do
        -- Mark every tracker, that has random time, as inaccurate
        if data.random_time then
            data.class = self._TrackerToInaccurate[data.class or self.Trackers.Base]
            if not data.class then
                EHI:Log(string.format("Trigger %d with random time is using unknown tracker! Tracker class has been set to %s", id, self.Trackers.Inaccurate))
                data.class = self.Trackers.Inaccurate
            end
        end
        if data.special_function == self._triggers.SF.SetRandomTime then
            data.class = self.Trackers.Inaccurate
        end
        -- Fill the rest table properties for EHI Waypoints
        if self._SHOW_MISSION_WAYPOINTS then
            if data.waypoint then
                data.waypoint.remove_on_alarm = data.remove_on_alarm
                if not data.waypoint.class_table then
                    data.waypoint.class = data.waypoint.class or self._TrackerToWaypoint[data.class or ""]
                end
                for key, _ in pairs(self._WaypointDataCopy[data.waypoint.class or ""] or self._WaypointDataCopy.Base) do
                    data.waypoint[key] = data.waypoint[key] or data[key]
                end
                if data.waypoint.data_from_element then
                    self:_add_data_from_element(data.waypoint, data.id, host)
                elseif data.waypoint.data_from_element_and_remove_vanilla_waypoint then
                    local wp_id = data.waypoint.data_from_element_and_remove_vanilla_waypoint
                    data.waypoint.data_from_element = wp_id
                    data.waypoint.remove_vanilla_waypoint = wp_id
                    data.waypoint.data_from_element_and_remove_vanilla_waypoint = nil
                    self:_add_data_from_element(data.waypoint, data.id, host)
                else
                    if not data.waypoint.icon then
                        local icon
                        if data.icons then
                            icon = data.icons[1] and data.icons[1].icon or data.icons[1]
                        elseif trigger_icons_all then
                            icon = trigger_icons_all[1] and trigger_icons_all[1].icon or trigger_icons_all[1]
                        end
                        if icon then
                            data.waypoint.icon = self._WaypointIconRedirect[icon] or icon
                        end
                    end
                    if data.waypoint.position_from_element_and_remove_vanilla_waypoint then
                        local wp_id = data.waypoint.position_from_element_and_remove_vanilla_waypoint
                        data.waypoint.position_from_element = wp_id
                        data.waypoint.remove_vanilla_waypoint = wp_id
                        data.waypoint.position_from_element_and_remove_vanilla_waypoint = nil
                    end
                    if data.waypoint.position_from_element then
                        self:_add_position_from_element(data.waypoint, data.id, host)
                    elseif data.waypoint.position_from_unit then
                        self:_add_position_from_unit(data.waypoint, data.id, host)
                    end
                end
            end
        else
            data.waypoint = nil
            data.waypoint_f = nil
        end
        if data.class then
            if self._GroupingTrackers[data.class] then
                data.tracker_group = true
            end
            if self._ConditionalLoad[data.class] then
                local load = self._ConditionalLoad[data.class]
                EHI:LoadTracker(load.tracker)
                EHI:LoadWaypoint(load.waypoint)
                self._ConditionalLoad[data.class] = nil
                if load.also_remove then
                    self._ConditionalLoad[load.also_remove] = nil
                end
            end
        end
        if data.client and self.ClientSyncFunctions[data.special_function or 0] then
            data.additional_time = (data.additional_time or 0) + data.client.time
            data.random_time = data.client.random_time
            data.delay_only = true
            if data.class then
                data.synced = { class = data.class }
            end
            data.class = self._TrackerToInaccurate[data.class or self.Trackers.Base]
            if data.waypoint then
                if data.waypoint.class then
                    data.waypoint.synced = { class = data.waypoint.class }
                end
                data.waypoint.class = self._WaypointToInaccurate[data.waypoint.class or data.class or self.Waypoints.Base]
            end
            data.special_function = data.client.special_function or self._triggers.SF.AddTrackerIfDoesNotExist
            data.icons = data.icons or trigger_icons_all
            data.client = nil
            self:AddSyncTrigger(id, data)
            data.synced = nil
            if data.waypoint then
                data.waypoint.synced = nil
            end
            data.delay_only = nil
        end
    end
    self._triggers:__AddTriggers(mission_triggers, trigger_id_all or "Trigger", trigger_icons_all)
end

---@param preload ElementTrigger[]
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIMissionHolder:PreloadTrackers(preload, trigger_id_all, trigger_icons_all)
    for _, params in ipairs(preload) do
        params.id = params.id or trigger_id_all
        params.icons = params.icons or trigger_icons_all
        managers.ehi_tracker:PreloadTracker(params)
    end
end

---@param type
---|"base" # Random delay is defined in the BASE DELAY
---|"element" # Random delay is defined when calling the elements
---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIMissionHolder:_add_host_triggers(type, new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        if self._host_triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in host triggers!")
        else
            FillRestOfProperties(value, trigger_id_all, trigger_icons_all)
            local trigger = self._host_triggers[key]
            if type == "base" then
                trigger = EHIHostBaseDelayMissionElementTrigger:new(key, value)
                self._host_base_triggers = self._host_base_triggers or {} ---@type table<number, EHIHostBaseDelayMissionElementTrigger?>
                if self._host_base_triggers[key] then
                    EHI:Log("key: " .. tostring(key) .. " already exists in host base delay triggers!")
                else
                    self._host_base_triggers[key] = trigger
                end
            elseif value.hook_element then
                self._host_element_triggers = self._host_element_triggers or {} ---@type table<number, EHIHostElementDelayMissionElementTrigger?>
                trigger = self._host_element_triggers[value.hook_element] or EHIHostElementDelayMissionElementTrigger:new(value.hook_element)
                trigger:AddElementDelay(key, value)
                self._host_element_triggers[value.hook_element] = trigger
            else
                EHI:Log("key: " .. tostring(key) .. " does not have element to hook!")
            end
            self._host_triggers[key] = trigger
        end
    end
end

---@param id number
---@param trigger ElementTrigger
function EHIMissionHolder:AddSyncTrigger(id, trigger)
    if self._client_triggers[id] then
        EHI:Log("key: " .. tostring(id) .. " already exists in sync!")
        return
    end
    self._client_triggers[id] = EHIClientMissionElementTrigger:new(id, trigger)
end

---@param sync_triggers table
function EHIMissionHolder:_set_sync_triggers(sync_triggers)
    for key, value in pairs(sync_triggers) do
        if self._client_triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in sync!")
        else
            self._client_triggers[key] = EHIClientMissionElementTrigger:new(key, value)
        end
    end
end

---@param type "base"|"element"
---@param sync_triggers table
function EHIMissionHolder:AddMissionSyncTriggers(type, sync_triggers)
    if EHI.IsHost then
        self:_add_host_triggers(type, sync_triggers)
    else
        self:_set_sync_triggers(sync_triggers)
    end
end

---@param trigger_table table<number, ElementTrigger>
---@param option string
---| "show_timers" Filters out not loaded trackers with option show_timers
function EHIMissionHolder:_filter_out_not_loaded_trackers(trigger_table, option)
    local config = option and self.FilterTracker[option]
    if not config then
        return
    end
    local show_tracker
    if config.waypoint then
        show_tracker = EHI:GetShowTrackerAndWaypoint(option, config.waypoint)
    else
        show_tracker = EHI:GetTrackerOption(option)
    end
    if show_tracker then
        return
    end
    local not_loaded_tt = self.Trackers[config.table_name]
    if type(not_loaded_tt) ~= "table" then
        EHI:Log(string.format("Provided table name '%s' is not a table in EHI.Trackers! Nothing will be changed and the game may crash unexpectly!", config.table_name))
        return
    end
    for _, trigger in pairs(trigger_table) do
        if trigger.class then
            local key = table.get_key(not_loaded_tt, trigger.class)
            if key then
                trigger.class = self.Trackers[key] --[[@as string]]
            end
        end
    end
end

function EHIMissionHolder:InitElements()
    if self.__init_done then
        return
    end
    self.__init_done = true
    self._triggers:__HookElements()
    if EHI.IsClient then
        return
    end
    self._triggers:__add_missing_position_to_waypoints()
    local scripts = managers.mission._scripts or {}
    if ehi_next(self._host_base_triggers) then
        for id, trigger in pairs(self._host_base_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    trigger:HookBaseDelay(element)
                    trigger:sync_load()
                end
            end
        end
        self._host_base_triggers = nil
    end
    if ehi_next(self._host_element_triggers) then
        for id, trigger in pairs(self._host_element_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    trigger:HookElementDelay(element)
                    trigger:sync_load()
                end
            end
        end
        self._host_element_triggers = nil
    end
end

---@param id number Element ID
---@return Vector3?
function EHIMissionHolder:GetElementPosition(id)
    local element = managers.mission:get_element_by_id(id)
    return element and element:value("position")
end

---@param id number Element ID
function EHIMissionHolder:GetElementPositionOrDefault(id)
    return self:GetElementPosition(id) or Vector3()
end

---@param id number Unit ID
---@return Vector3?
function EHIMissionHolder:GetUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    return unit and unit.position and unit:position()
end

---@param id number Unit ID
function EHIMissionHolder:GetUnitPositionOrDefault(id)
    return self:GetUnitPosition(id) or Vector3()
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHIMissionHolder:_add_position_from_element(data, id, check)
    local vector = self:GetElementPosition(data.position_from_element)
    if vector then
        data.position = vector
        data.position_from_element = nil
    elseif check and not data.skip_if_not_found then
        data.position = Vector3()
        EHI:Log(string.format("Element with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_from_element, tostring(id)))
    end
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHIMissionHolder:_add_position_from_unit(data, id, check)
    local vector = self:GetUnitPosition(data.position_from_unit)
    if vector then
        data.position = vector
        data.position_from_unit = nil
    elseif check and not data.skip_if_not_found then
        data.position = Vector3()
        EHI:Log(string.format("Unit with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_from_unit, tostring(id)))
    end
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHIMissionHolder:_add_data_from_element(data, id, check)
    local element = managers.mission:get_element_by_id(data.data_from_element)
    if element then
        data.icon = element:value("icon")
        data.position = element:value("position") or Vector3()
        data.data_from_element = nil
    elseif check and not data.skip_if_not_found then
        data.position = Vector3()
        EHI:Log(string.format("Element with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.data_from_element, tostring(id)))
    end
end

function EHIMissionHolder:load()
    self._triggers:__add_missing_position_to_waypoints()
    for _, sync_trigger in pairs(self._client_triggers) do
        sync_trigger:sync_load()
    end
    for _, trigger in pairs(self._HookOnLoad) do
        trigger:sync_load()
    end
    self._triggers:__HookElements(self._HookOnLoad)
    self._HookOnLoad = nil
end

return EHIMissionHolder:new()