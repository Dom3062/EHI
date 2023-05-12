local EHI = EHI
EHIManager = {}
EHIManager.GetAchievementIcon = EHI.GetAchievementIcon
EHIManager.Trackers = EHI.Trackers
EHIManager.Waypoints = EHI.Waypoints
EHIManager.SyncFunctions = EHI.SyncFunctions
EHIManager.TriggerFunction = EHI.TriggerFunction
EHIManager.SFF = {}
function EHIManager:new(ehi_tracker, ehi_waypoints)
    self._trackers = ehi_tracker
    self._waypoints = ehi_waypoints
    self._level_started_from_beginning = true
    self._t = 0
    return self
end

function EHIManager:init_finalize()
    managers.network:add_event_listener("EHIManagerDropIn", "on_set_dropin", callback(self, self, "DisableStartFromBeginning"))
end

function EHIManager:load()
    self:LoadSync()
    self:SyncLoad()
end

function EHIManager:LoadTime(t)
    self._t = t
    self._trackers:LoadTime(t)
    self._waypoints:LoadTime(t)
end

function EHIManager:AddLoadSyncFunction(f)
    if EHI:IsHost() then
        return
    end
    self._load_sync = self._load_sync or {}
    self._load_sync[#self._load_sync + 1] = f
end

function EHIManager:AddFullSyncFunction(f)
    if EHI:IsHost() then
        return
    end
    self._full_sync = self._full_sync or {}
    self._full_sync[#self._full_sync + 1] = f
end

function EHIManager:LoadSync()
    if self._level_started_from_beginning then
        for _, f in ipairs(self._full_sync or {}) do
            f(self)
        end
    else
        for _, f in ipairs(self._load_sync or {}) do
            f(self)
        end
        self._trackers:LoadSync()
    end
    -- Clear used memory
    self._full_sync = nil
    self._load_sync = nil
end

function EHIManager:DisableStartFromBeginning()
    self._level_started_from_beginning = false
end

function EHIManager:GetStartedFromBeginning()
    return self._level_started_from_beginning
end

function EHIManager:GetDropin()
    return not self:GetStartedFromBeginning()
end

function EHIManager:update(t, dt)
    self._trackers:update(t, dt)
    self._waypoints:update(t, dt)
end

function EHIManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(t, dt)
end

function EHIManager:Exists(id)
    return self._trackers:TrackerExists(id) or self._waypoints:WaypointExists(id)
end

function EHIManager:DoesNotExist(id)
    return not self:Exists(id)
end

function EHIManager:Remove(id)
    self._trackers:ForceRemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

function EHIManager:SetPaused(id, pause)
    self._trackers:SetTrackerPaused(id, pause)
    self._waypoints:SetWaypointPause(id, pause)
end

function EHIManager:Pause(id)
    self:SetPaused(id, true)
end

function EHIManager:Unpause(id)
    self:SetPaused(id, false)
end

function EHIManager:RemovePager(id)
    self._trackers:RemoveStealthTracker(id, "pagers")
    self._waypoints:RemovePagerWaypoint(id)
end

function EHIManager:SetAccurate(id, t)
    self._trackers:SetTrackerAccurate(id, t)
    self._waypoints:SetWaypointAccurate(id, t)
end

function EHIManager:SetIcon(id, icon)
    self._trackers:SetTrackerIcon(id, icon)
    self._waypoints:SetWaypointIcon(id, icon)
end

function EHIManager:SetTimerJammed(id, jammed)
    self._trackers:SetTimerJammed(id, jammed)
    self._waypoints:SetTimerWaypointJammed(id, jammed)
end

function EHIManager:SetTimerPowered(id, powered)
    self._trackers:SetTimerPowered(id, powered)
    self._waypoints:SetTimerWaypointPowered(id, powered)
end

function EHIManager:Call(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
    self._waypoints:CallFunction(id, f, ...)
end

function EHIManager:destroy()
    self._trackers:destroy()
    self._waypoints:destroy()
end

---------------------------------
local SF = EHI.SpecialFunctions
local triggers = {}
local host_triggers = {}
local base_delay_triggers = {}
local element_delay_triggers = {}
---Adds trigger to mission element when they run
---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in triggers!")
        else
            triggers[key] = value
            if not value.id then
                triggers[key].id = trigger_id_all
            end
            if not value.icons and not value.run then
                triggers[key].icons = trigger_icons_all
            end
        end
    end
end

---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table
---@param params table?
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    local function FillRestOfProperties(key, value)
        if not value.id then
            triggers[key].id = trigger_id_all
        end
        if not value.icons and not value.run then
            triggers[key].icons = trigger_icons_all
        end
    end
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            local t = triggers[key]
            if t.special_function and self.TriggerFunction[t.special_function] then
                if value.special_function and self.TriggerFunction[value.special_function] then
                    if t.data then
                        local data = value.data or {}
                        for i = 1, #data, 1 do
                            t.data[#t.data + 1] = data[i]
                        end
                    else
                        EHI:Log("key: " .. tostring(key) .. " does not have 'data' table, new triggers won't be added!")
                    end
                elseif t.data then
                    local new_key = (key * 10) + 1
                    while triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = value
                    FillRestOfProperties(new_key, value)
                    t.data[#t.data + 1] = new_key
                else
                    EHI:Log("key: " .. tostring(key) .. " does not have 'data' table, the trigger " .. tostring(new_key) .. " will not be called!")
                end
            elseif value.special_function and self.TriggerFunction[value.special_function] then
                if value.data then
                    local new_key = (key * 10) + 1
                    while table.contains(value.data, new_key) or new_triggers[new_key] or triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = t
                    triggers[key] = value
                    FillRestOfProperties(key, value)
                    value.data[#value.data + 1] = new_key
                else
                    EHI:Log("key: " .. tostring(key) .. " with ID: " .. tostring(value.id) .. " does not have 'data' table, the former trigger won't be moved and triggers assigned to this one will not be called!")
                end
            else
                local new_key = (key * 10) + 1
                local key2 = new_key + 1
                triggers[key] = { special_function = params and params.SF or SF.Trigger, data = { new_key, key2 } }
                triggers[new_key] = t
                triggers[key2] = value
                FillRestOfProperties(key2, value)
            end
        else
            triggers[key] = value
            FillRestOfProperties(key, value)
        end
    end
end

function EHIManager:AddHostTriggers(new_triggers, trigger_id_all, trigger_icons_all, type)
    for key, value in pairs(new_triggers) do
        if host_triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in host triggers!")
        else
            host_triggers[key] = value
            if not value.id then
                host_triggers[key].id = trigger_id_all
            end
            if not value.icons then
                host_triggers[key].icons = trigger_icons_all
            end
        end
        if type == "base" then
            if base_delay_triggers[key] then
                EHI:Log("key: " .. tostring(key) .. " already exists in host base delay triggers!")
            else
                base_delay_triggers[key] = true
            end
        else
            if value.hook_element or value.hook_elements then
                if value.hook_element then
                    element_delay_triggers[value.hook_element] = element_delay_triggers[value.hook_element] or {}
                    element_delay_triggers[value.hook_element][key] = true
                else
                    for _, element in pairs(value.hook_elements) do
                        element_delay_triggers[element] = element_delay_triggers[element] or {}
                        element_delay_triggers[element][key] = true
                    end
                end
            else
                EHI:Log("key: " .. tostring(key) .. " does not have element to hook!")
            end
        end
    end
end

function EHIManager:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    new_triggers = new_triggers or {}
    self:PreloadTrackers(new_triggers.preload or {}, trigger_id_all or "Trigger", trigger_icons_all or {})
    local function ParseParams(data, id)
        if type(data.alarm_callback) == "function" then
            EHI:AddOnAlarmCallback(data.alarm_callback)
        end
        if type(data.load_sync) == "function" then
            self:AddLoadSyncFunction(data.load_sync)
        end
        if data.failed_on_alarm then
            EHI:AddOnAlarmCallback(function()
                self._trackers:SetAchievementFailed(id)
            end)
        end
        if data.mission_end_callback then
            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                if success then
                    self._trackers:SetAchievementComplete(id, true)
                else
                    self._trackers:SetAchievementFailed(id)
                end
            end)
        end
    end
    self:ParseOtherTriggers(new_triggers.other or {}, trigger_id_all or "Trigger", trigger_icons_all)
    local trophy = new_triggers.trophy
    if EHI:GetUnlockableAndOption("show_trophies") and trophy and next(trophy) then
        for id, data in pairs(trophy) do
            if data.difficulty_pass ~= false and EHI:IsTrophyLocked(id) then
                for _, element in pairs(data.elements or {}) do
                    if element.class and EHI.TrophyTrackers[element.class] and not data.icons then
                        data.icons = { EHI.Icons.Trophy }
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
        end
    end
    local daily = new_triggers.daily
    if EHI:GetUnlockableAndOption("show_dailies") and daily and next(daily) then
        for id, data in pairs(daily) do
            if data.difficulty_pass ~= false and EHI:IsDailyAvailable(id) then
                for _, element in pairs(data.elements or {}) do
                    if element.class and EHI.DailyTrackers[element.class] and not data.icons then
                        data.icons = { EHI.Icons.Trophy }
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
        end
    end
    local achievement_triggers = new_triggers.achievement
    if EHI:ShowMissionAchievements() and achievement_triggers and next(achievement_triggers) then
        local function Parser(data, id)
            if data.achievement_counter then
                local params = data.achievement_counter
                params.achievement = id
                EHI:ShowAchievementLootCounterNoCheck(params)
            else
                for _, element in pairs(data.elements or {}) do
                    if element.class and EHI.AchievementTrackers[element.class] then
                        element.beardlib = data.beardlib
                        if not element.icons then
                            if data.beardlib then
                                element.icons = { "ehi_" .. id }
                            else
                                element.icons = self:GetAchievementIcon(id)
                            end
                        end
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
        end
        local function IsAchievementLocked(data, id)
            if data.beardlib then
                return not EHI:IsBeardLibAchievementUnlocked(data.package, id)
            else
                return EHI:IsAchievementLocked(id)
            end
        end
        for id, data in pairs(achievement_triggers) do
            if data.difficulty_pass ~= false and IsAchievementLocked(data, id) then
                Parser(data, id)
            elseif type(data.cleanup_callback) == "function" then
                data.cleanup_callback()
            end
        end
    end
    self:ParseMissionTriggers(new_triggers.mission or {}, trigger_id_all, trigger_icons_all)
    --EHI:PrintTable(triggers)
end

function EHIManager:ParseOtherTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        if data.condition == false then
            new_triggers[id] = nil
        end
    end
    self:AddTriggers(new_triggers, trigger_id_all or "Trigger", trigger_icons_all)
end

function EHIManager:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    if not EHI:GetOption("show_mission_trackers") then
        for id, data in pairs(new_triggers) do
            if data.special_function and self.SyncFunctions[data.special_function] then
                self:AddTriggers2({ [id] = data }, nil, trigger_id_all or "Trigger", trigger_icons_all)
            end
        end
        return
    end
    local host = EHI:IsHost()
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        if data.condition == false then
            new_triggers[id] = nil
        else
            data.condition = nil
            -- Mark every tracker, that has random time, as inaccurate
            if data.random_time then
                if not data.class then
                    data.class = self.Trackers.Inaccurate
                    if data.waypoint then
                        data.waypoint.class = self.Waypoints.Inaccurate
                    end
                elseif data.class ~= self.Trackers.InaccuratePausable and data.class == self.Trackers.Warning then
                    data.class = self.Trackers.InaccurateWarning
                    if data.waypoint then
                        data.class = self.Waypoints.InaccurateWarning
                    end
                end
            end
            -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
            if data.special_function == SF.ShowWaypoint then
                data.data.distance = true
                data.data.state = "sneak_present"
                data.data.present_timer = 0
                data.data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
                if data.data.position_by_element then
                    data.id = data.id or data.data.position_by_element
                    EHI:AddPositionFromElement(data.data, data.id, host)
                elseif data.data.position_by_unit then
                    EHI:AddPositionFromUnit(data.data, data.id, host)
                end
                if data.data.icon then
                    local redirect = EHI.WaypointIconRedirect[data.data.icon]
                    if redirect then
                        data.data.icon = redirect
                        data.data.icon_redirect = true
                    end
                end
            end
            -- Fill the rest table properties for EHI Waypoints
            if data.waypoint then
                data.waypoint.time = data.waypoint.time or data.time
                if not data.waypoint.icon then
                    local icon
                    if data.icons then
                        icon = data.icons[1] and data.icons[1].icon or data.icons[1]
                    elseif trigger_icons_all then
                        icon = trigger_icons_all[1] and trigger_icons_all[1].icon or trigger_icons_all[1]
                    end
                    if icon then
                        data.waypoint.icon = EHI.WaypointIconRedirect[icon] or icon
                    end
                end
                if data.waypoint.position_by_element then
                    EHI:AddPositionFromElement(data.waypoint, data.id, host)
                elseif data.waypoint.position_by_unit then
                    EHI:AddPositionFromUnit(data.waypoint, data.id, host)
                end
            end
        end
    end
    self:AddTriggers2(new_triggers, nil, trigger_id_all or "Trigger", trigger_icons_all)
end

---@param preload table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:PreloadTrackers(preload, trigger_id_all, trigger_icons_all)
    for _, params in ipairs(preload) do
        params.id = params.id or trigger_id_all
        params.icons = params.icons or trigger_icons_all
        self._trackers:PreloadTracker(params)
    end
end

function EHIManager:InitElements()
    self:HookElements(triggers)
    if EHI:IsClient() then
        return
    end
    local scripts = managers.mission._scripts or {}
    if next(base_delay_triggers) then
        self._base_delay = {}
        for id, _ in pairs(base_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._base_delay[id] = element._calc_base_delay
                    element._calc_base_delay = function(e, ...)
                        local delay = self._base_delay[e._id](e, ...)
                        self:AddTrackerAndSync(e._id, delay)
                        return delay
                    end
                end
            end
        end
    end
    if next(element_delay_triggers) then
        self._element_delay = {}
        for id, _ in pairs(element_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._element_delay[id] = element._calc_element_delay
                    element._calc_element_delay = function(e, params, ...)
                        local delay = self._element_delay[e._id](e, params, ...)
                        if element_delay_triggers[e._id][params.id] then
                            if host_triggers[params.id] then
                                local trigger = host_triggers[params.id]
                                if trigger.remove_trigger_when_executed then
                                    self:AddTrackerAndSync(params.id, delay)
                                    element_delay_triggers[e._id][params.id] = nil
                                elseif trigger.set_time_when_tracker_exists then
                                    if self._trackers:TrackerExists(trigger.id) then
                                        self._trackers:SetTrackerTimeNoAnim(trigger.id, delay)
                                        EHI:Sync(EHI.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
                                    else
                                        self:AddTrackerAndSync(params.id, delay)
                                    end
                                else
                                    self:AddTrackerAndSync(params.id, delay)
                                end
                            else
                                self:AddTrackerAndSync(params.id, delay)
                            end
                        end
                        return delay
                    end
                end
            end
        end
    end
end

function EHIManager:HookElements(elements_to_hook)
    local function Client(element, ...)
        self:Trigger(element._id, element, true)
    end
    local function Host(element, ...)
        self:Trigger(element._id, element, element._values.enabled)
    end
    local client = EHI:IsClient()
    local func = client and EHI.ClientElement or EHI.HostElement
    local f = client and Client or Host
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(elements_to_hook) do
        if id >= 100000 and id <= 999999 then
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    EHI:HookElement(element, func, id, f)
                elseif client then
                    --[[
                        On client, the element was not found
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHIManager:SyncLoad())
                    ]]
                    EHI.HookOnLoad[id] = true
                end
            end
        end
    end
end

function EHIManager:SyncLoad()
    for _, trigger in pairs(triggers) do
        if trigger.special_function == SF.ShowWaypoint and trigger.data and not trigger.data.position then
            if trigger.data.position_by_element then
                EHI:AddPositionFromElement(trigger.data, trigger.id, true)
            elseif trigger.data.position_by_unit then
                EHI:AddPositionFromUnit(trigger.data, trigger.id, true)
            end
        elseif trigger.waypoint and not trigger.waypoint.position then
            if trigger.waypoint.position_by_element then
                EHI:AddPositionFromElement(trigger.waypoint, trigger.id, true)
            elseif trigger.waypoint.position_by_unit then
                EHI:AddPositionFromUnit(trigger.waypoint, trigger.id, true)
            end
        end
    end
    for id, _ in pairs(EHI.HookOnLoad) do
        local trigger = triggers[id]
        if trigger then
            if trigger.special_function == SF.ShowWaypoint and trigger.data then
                if trigger.data.position_by_element then
                    trigger.id = trigger.id or trigger.data.position_by_element
                    EHI:AddPositionFromElement(trigger.data, trigger.id, true)
                elseif trigger.data.position_by_unit then
                    EHI:AddPositionFromUnit(trigger.data, trigger.id, true)
                end
            elseif trigger.waypoint then
                if trigger.waypoint.position_by_element then
                    EHI:AddPositionFromElement(trigger.waypoint, trigger.id, true)
                elseif trigger.waypoint.position_by_unit then
                    EHI:AddPositionFromUnit(trigger.waypoint, trigger.id, true)
                end
            end
        end
    end
    self:HookElements(EHI.HookOnLoad)
    EHI.HookOnLoad = nil
    EHI:DisableWaypoints(EHI.DisableOnLoad)
    EHI:DisableWaypointsOnInit()
    EHI.DisableOnLoad = nil
end

---@param trigger table
local function AddTracker(self, trigger)
    if trigger.random_time then
        trigger.time = self:GetRandomTime(trigger)
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
    end
    self._trackers:AddTracker(trigger)
end

---@param trigger table
---@return number
function EHIManager:GetRandomTime(trigger)
    local full_time = trigger.additional_time or 0
    full_time = full_time + math.rand(trigger.random_time)
    return full_time
end

---@param trigger table
function EHIManager:AddTrackerWithRandomTime(trigger)
    trigger.time = trigger.data[math.random(#trigger.data)]
    self._trackers:AddTracker(trigger)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param trigger table
function EHIManager:AddTracker(trigger)
    if trigger.run then
        self._trackers:RunTracker(trigger.id, trigger.run)
    else
        AddTracker(self, trigger)
    end
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param id number
---@param delay number
function EHIManager:AddTrackerAndSync(id, delay)
    local trigger = host_triggers[id]
    self._trackers:AddTrackerAndSync({
        id = trigger.id,
        time = (trigger.time or 0) + (delay or 0),
        icons = trigger.icons,
        class = trigger.class
    }, id, delay)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(trigger)
    elseif trigger.waypoint then
        self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param trigger table
function EHIManager:CheckCondition(trigger)
    if trigger.condition_function then
        if trigger.condition_function() then
            self:AddTracker(trigger)
        end
    else
        self:AddTracker(trigger)
    end
end

local function GetElementTimer(self, trigger, id)
    if EHI:IsHost() then
        local element = managers.mission:get_element_by_id(trigger.element)
        if element then
            local t = (element._timer or 0) + (trigger.additional_time or 0)
            trigger.time = t
            self:CheckCondition(trigger)
            self._trackers:Sync(id, t)
        end
    else
        self:CheckCondition(trigger)
    end
end

---@param id number
function EHIManager:UnhookElement(id)
    Hooks:RemovePostHook("EHI_Element_" .. id)
end

---@param id number
function EHIManager:UnhookTrigger(id)
    self:UnhookElement(id)
    triggers[id] = nil
end

---@param id number
---@param element table
---@param enabled boolean
---@overload fun(self, id: number)
---@overload fun(self, id: number, element: table)
function EHIManager:Trigger(id, element, enabled)
    local trigger = triggers[id]
    if trigger then
        if trigger.special_function then
            local f = trigger.special_function
            if f == SF.RemoveTracker then
                if trigger.data then
                    for _, tracker in ipairs(trigger.data) do
                        self:Remove(tracker)
                    end
                else
                    self:Remove(trigger.id)
                end
            elseif f == SF.PauseTracker then
                self:Pause(trigger.id)
            elseif f == SF.UnpauseTracker then
                self:Unpause(trigger.id)
            elseif f == SF.UnpauseTrackerIfExists then
                if self:Exists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if self._trackers:TrackerDoesNotExist(trigger.id) then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.ReplaceTrackerWithTracker then
                self:Remove(trigger.data.id)
                self:CheckCondition(trigger)
            elseif f == SF.ShowAchievementFromStart then -- Achievement unlock is checked during level load
                if not managers.statistics:is_dropin() then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetAchievementComplete then
                self._trackers:SetAchievementComplete(trigger.id, true)
            elseif f == SF.SetAchievementStatus then
                self._trackers:SetAchievementStatus(trigger.id, trigger.status or "ok")
            elseif f == SF.SetAchievementFailed then
                self._trackers:SetAchievementFailed(trigger.id)
            elseif f == SF.AddAchievementToCounter then
                local data = trigger.data or {}
                data.achievement = data.achievement or trigger.id
                EHI:AddAchievementToCounter(data)
                self:CheckCondition(trigger)
            elseif f == SF.IncreaseChance then
                self._trackers:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.TriggerIfEnabled then
                if enabled then
                    if trigger.data then
                        for _, t in ipairs(trigger.data) do
                            self:Trigger(t, element, enabled)
                        end
                    else
                        self:Trigger(trigger.id, element, enabled)
                    end
                end
            elseif f == SF.CreateAnotherTrackerWithTracker then
                self:CheckCondition(trigger)
                self:Trigger(trigger.data.fake_id, element, enabled)
            elseif f == SF.SetChanceWhenTrackerExists then
                if self._trackers:TrackerExists(trigger.id) then
                    self._trackers:SetChance(trigger.id, trigger.chance)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.Trigger then
                if trigger.data then
                    for _, t in ipairs(trigger.data) do
                        self:Trigger(t, element, enabled)
                    end
                else
                    self:Trigger(trigger.id, element, enabled)
                end
            elseif f == SF.RemoveTrigger then
                if trigger.data then
                    for _, trigger_id in ipairs(trigger.data) do
                        self:UnhookTrigger(trigger_id)
                    end
                else
                    self:UnhookTrigger(trigger.id)
                end
            elseif f == SF.SetTimeOrCreateTracker then
                local key = trigger.id
                if self:Exists(key) then
                    local time = trigger.run and trigger.run.time or trigger.time or 0
                    self._trackers:SetTrackerTime(key, time)
                    self._waypoints:SetWaypointTime(key, time)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    trigger.time = trigger.data.yes
                else
                    trigger.time = trigger.data.no
                end
                if trigger.waypoint then
                    trigger.waypoint.time = trigger.time
                end
                self:CheckCondition(trigger)
            elseif f == SF.IncreaseProgress then
                self._trackers:IncreaseTrackerProgress(trigger.id)
            elseif f == SF.SetTrackerAccurate then
                if self:Exists(trigger.id) then
                    self:SetAccurate(trigger.id, trigger.time)
                else
                    self:CheckCondition(trigger)
                end
            elseif f == SF.SetRandomTime then
                if self._trackers:TrackerDoesNotExist(trigger.id) then
                    self:AddTrackerWithRandomTime(trigger)
                end
            elseif f == SF.DecreaseChance then
                self._trackers:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.GetElementTimerAccurate then
                GetElementTimer(self, trigger, id)
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if self._trackers:TrackerExists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    if trigger.time then
                        self:CheckCondition(trigger)
                        return
                    end
                    if managers.preplanning:IsAssetBought(trigger.data.id) then
                        trigger.time = trigger.data.yes
                    else
                        trigger.time = trigger.data.no
                    end
                    self:CheckCondition(trigger)
                end
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if self._trackers:TrackerExists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    GetElementTimer(self, trigger, id)
                end
            elseif f == SF.FinalizeAchievement then
                self._trackers:CallFunction(trigger.id, "Finalize")
            elseif f == SF.IncreaseChanceFromElement then
                self._trackers:IncreaseChance(trigger.id, element._values.chance)
            elseif f == SF.DecreaseChanceFromElement then
                self._trackers:DecreaseChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElement then
                self._trackers:SetChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElementWhenTrackerExists then
                if self._trackers:TrackerExists(trigger.id) then
                    self._trackers:SetChance(trigger.id, element._values.chance)
                else
                    trigger.chance = element._values.chance
                    self:CheckCondition(trigger)
                end
            elseif f == SF.PauseTrackerWithTime then
                local t_id = trigger.id
                local t_time = trigger.time
                self:Pause(t_id)
                self._trackers:SetTrackerTimeNoAnim(t_id, t_time)
                self._waypoints:SetWaypointTime(t_id, t_time)
            elseif f == SF.IncreaseProgressMax then
                self._trackers:IncreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.IncreaseProgressMax2 then
                if self._trackers:TrackerExists(trigger.id) then
                    self._trackers:IncreaseTrackerProgressMax(trigger.id, trigger.max)
                else
                    local new_trigger =
                    {
                        id = trigger.id,
                        max = trigger.max or 1,
                        class = trigger.class or "EHILootTracker"
                    }
                    self:CheckCondition(new_trigger)
                end
            elseif f == SF.SetTimeIfLoudOrStealth then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        trigger.time = trigger.data.no
                    else -- Loud
                        trigger.time = trigger.data.yes
                    end
                    self:CheckCondition(trigger)
                end
            elseif f == SF.AddTimeByPreplanning then
                local t = 0
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    t = trigger.data.yes
                else
                    t = trigger.data.no
                end
                trigger.time = trigger.time + t
                self:CheckCondition(trigger)
            elseif f == SF.ShowWaypoint then
                managers.hud:AddWaypointFromTrigger(trigger.id, trigger.data)
            elseif f == SF.ShowEHIWaypoint then
                self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
            elseif f == SF.DecreaseProgressMax then
                self._trackers:DecreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.DecreaseProgress then
                self._trackers:DecreaseTrackerProgress(trigger.id, trigger.progress)
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                trigger.f(trigger.arg)
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    trigger.f(trigger.arg)
                end
            elseif f == SF.CustomCodeDelayed then
                EHI:DelayCall(tostring(id), trigger.t or 0, trigger.f)
            elseif f >= SF.CustomSF then
                self.SFF[f](self, trigger, element, enabled)
            end
        else
            self:CheckCondition(trigger)
        end
        if trigger.trigger_times and trigger.trigger_times > 0 then
            trigger.trigger_times = trigger.trigger_times - 1
            if trigger.trigger_times == 0 then
                self:UnhookTrigger(id)
            end
        end
    end
end

---@param sync_triggers table
function EHIManager:SetSyncTriggers(sync_triggers)
    if self._sync_triggers then
        for key, value in pairs(sync_triggers) do
            if self._sync_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in sync!")
            else
                self._sync_triggers[key] = deep_clone(value)
            end
        end
    else
        self._sync_triggers = deep_clone(sync_triggers)
    end
end

function EHIManager:AddSyncTrigger(id, trigger)
    self._sync_triggers = self._sync_triggers or {}
    self._sync_triggers[id] = deep_clone(trigger)
end

function EHIManager:AddTrackerSynced(id, delay)
    if self._sync_triggers[id] then
        local trigger = self._sync_triggers[id]
        local trigger_id = trigger.id
        if self._trackers:TrackerExists(trigger_id) then
            if trigger.delay_only then
                self._trackers:SetTrackerAccurate(trigger_id, delay)
            else
                self._trackers:SetTrackerAccurate(trigger_id, (trigger.time or trigger.additional_time or 0) + delay)
            end
        else
            self._trackers:AddTracker({
                id = trigger_id,
                time = trigger.delay_only and delay or ((trigger.time or trigger.additional_time or 0) + delay),
                icons = trigger.icons,
                class = trigger.synced and trigger.synced.class or trigger.class
            })
        end
        if trigger.client_on_executed then
            -- Right now there is only SF.RemoveTriggerWhenExecuted
            self._sync_triggers[id] = nil
        end
    end
end

function EHIManager:AddWaypointToTrigger(id, waypoint)
    local t = triggers[id]
    if not t then
        return
    end
    local w = deep_clone(waypoint)
    if not w.time then
        w.time = t.time
    end
    if not w.icon then
        local icon = t.icons
        if icon and icon[1] then
            if type(icon[1]) == "table" then
                w.icon = icon[1].icon
            elseif type(icon[1]) == "string" then
                w.icon = icon[1]
            end
        end
    end
    t.waypoint = w
end

function EHIManager:RegisterCustomSpecialFunction(id, f)
    self.SFF[id] = f
end

function EHIManager:UnregisterCustomSpecialFunction(id)
    self.SFF[id] = nil
end

if EHI:GetWaypointOption("show_waypoints_only") then
    ---@param trigger table
    function EHIManager:AddTracker(trigger)
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            if not trigger.run then
                if trigger.random_time then
                    trigger.time = self:GetRandomTime(trigger)
                end
            end
            trigger.waypoint_f(trigger)
        elseif trigger.waypoint then
            if trigger.random_time then
                trigger.waypoint.time = self:GetRandomTime(trigger)
            end
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        else
            AddTracker(self, trigger)
        end
    end
end

if not EHI:GetOption("show_mission_trackers") then
    function EHIManager:AddTrackerAndSync(id, delay)
        self._trackers:Sync(id, delay)
    end

    GetElementTimer = function(self, trigger, id)
        if EHI:IsHost() then
            local element = managers.mission:get_element_by_id(trigger.element)
            if element then
                local t = (element._timer or 0) + (trigger.additional_time or 0)
                self._trackers:Sync(id, t)
            end
        end
    end
end

if EHI:IsClient() then
    Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHI", function(sender, id, data)
        if id == EHI.SyncMessages.EHISyncAddTracker then
            local tbl = LuaNetworking:StringToTable(data)
            EHIManager:AddTrackerSynced(tonumber(tbl.id), tonumber(tbl.delay))
        end
    end)
end