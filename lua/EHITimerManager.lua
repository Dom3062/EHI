---@class EHITimerManager
local EHITimerManager = {}
function EHITimerManager:post_init()
    self._groups = {} --[[@as table<string, { count: number, [number]: { count: number, [number]: { name: string, timer_count: number }}}> ]]
    self._units_in_active_group = {} --[[@as table<string, string?>]]
    if EHI:GetTrackerOption("show_timers") and EHI:GetWaypointOption("show_waypoints_timers") then
        self._shared = {} --[[@as table<string, EHITimerGuiSharedMaster|EHITimerGuiGroupSharedMaster?>]]
        self._FORCE_SHARED_MASTER = true
        dofile(EHI.LuaPath .. "shared/EHITimerSharedMaster.lua")
        EHITimerGuiSharedMaster._parent = self
        EHITimerGuiGroupSharedMaster._parent = self
    end
    local max_timers = EHI:GetOption("show_timers_max_in_group") --[[@as number]]
    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", { [3] = true, [4] = true }) then
        self._MAX_TIMERS = max_timers > 1 and math.huge or 1
    else
        self._MAX_TIMERS = max_timers
    end
    self._GROUPING_IS_ENABLED = self._MAX_TIMERS > 1
end

---@param id string Unit key
---@param t number
---@param group string
---@param subgroup number
---@param i_subgroup number
---@param upgrades table?
---@param timer_gui TimerGui
---@param visibility_data table
function EHITimerManager:_add_timer_subgroup(id, t, group, subgroup, i_subgroup, upgrades, timer_gui, visibility_data)
    local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
    local params = {
        id = tracker_id,
        icons = visibility_data.icons,
        key = id,
        time = t,
        timer_gui = timer_gui,
        upgrades = upgrades,
        group = group,
        subgroup = subgroup,
        i_subgroup = i_subgroup,
        hint = visibility_data.hint,
        theme = visibility_data.theme,
        class = "EHITimerGuiGroupTracker"
    }
    managers.ehi_tracker:AddTracker(params)
    local active_group = self._groups[group]
    active_group.count = active_group.count + 1
    active_group[subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }
    self._units_in_active_group[id] = tracker_id
    if self._FORCE_SHARED_MASTER then
        self._shared[tracker_id] = EHITimerGuiGroupSharedMaster:new(params)
    end
end

---@param id string Unit key
---@param t number
---@param group string
---@param subgroup number
---@param i_subgroup number
---@param upgrades table?
---@param timer_gui TimerGui
---@param visibility_data table
function EHITimerManager:_add_timer_isubgroup(id, t, group, subgroup, i_subgroup, upgrades, timer_gui, visibility_data)
    local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
    local params =
    {
        id = tracker_id,
        icons = visibility_data.icons,
        key = id,
        time = t,
        timer_gui = timer_gui,
        upgrades = upgrades,
        group = group,
        subgroup = subgroup,
        i_subgroup = i_subgroup,
        hint = visibility_data.hint,
        theme = visibility_data.theme,
        class = "EHITimerGuiGroupTracker"
    }
    managers.ehi_tracker:AddTracker(params)
    local active_group = self._groups[group]
    active_group.count = active_group.count + 1
    local active_subgroup = active_group[subgroup]
    active_subgroup.count = active_subgroup.count + 1
    active_subgroup[i_subgroup] = { name = tracker_id, timer_count = 1 }
    self._units_in_active_group[id] = tracker_id
    if self._FORCE_SHARED_MASTER then
        self._shared[tracker_id] = EHITimerGuiGroupSharedMaster:new(params)
    end
end

---@param group string
---@param subgroup number
---@param i_subgroup number
function EHITimerManager._get_tracker_id(group, subgroup, i_subgroup)
    return string.format("timergroup_%s%d%d", group, subgroup, i_subgroup)
end

---@param skills table?
function EHITimerManager._compute_subgroup(skills)
    local subgroup = 0
    if skills then
        --[[
            upgrade_table = {
                faster = (skills.speed_upgrade_level or 0),
                silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0),
                restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0)
            }
        ]]
        subgroup = skills.speed_upgrade_level or 0
        if skills.reduced_alert then
            subgroup = subgroup + 10
        end
        if skills.silent_drill then
            subgroup = subgroup + 20
        end
        if (skills.auto_repair_level_1 or 0) > 0 then
            subgroup = subgroup + 100
        end
        if (skills.auto_repair_level_2 or 0) > 0 then
            subgroup = subgroup + 200
        end
    end
    return subgroup
end

---@param params table
function EHITimerManager:StartTimer(params)
    if self._GROUPING_IS_ENABLED and not params.no_grouping then
        local group = params.group
        local subgroup = self._compute_subgroup(params.skills)
        local add_subgroup, add_i_subgroup, i_subgroup = false, false, 1
        if self._groups[group] then
            if self._groups[group][subgroup] then
                local group_i = 0
                for i, i_sub in ipairs(self._groups[group][subgroup]) do
                    group_i = i
                    if i_sub.timer_count < self._MAX_TIMERS then
                        i_sub.timer_count = i_sub.timer_count + 1
                        managers.ehi_tracker:CallFunction(i_sub.name, "AddTimer", params.time, params.id, params.warning, params.completion, params.timer_gui)
                        self._units_in_active_group[params.id] = i_sub.name
                        local master = self:_get_shared_master(i_sub.name) ---@cast master -EHITimerGuiSharedMaster
                        if master then
                            master:AddTimer(params.id, params.time, params.timer_gui)
                        end
                        return
                    end
                end
                i_subgroup = group_i + 1
                add_i_subgroup = true
            else
                add_subgroup = true
            end
        end
        local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
        self._units_in_active_group[params.id] = tracker_id
        params.id = tracker_id
        params.class = (self._FORCE_SHARED_MASTER and self._GROUPING_IS_ENABLED and params.timer_gui) and "EHITimerGroupTracker" or params.timer_gui and "EHITimerGuiGroupTracker" or "EHITimerGroupTracker"
        params.subgroup = subgroup
        params.i_subgroup = i_subgroup
        if add_i_subgroup then
            local active_subgroup = self._groups[group][subgroup]
            active_subgroup.count = active_subgroup.count + 1
            active_subgroup[i_subgroup] = { name = tracker_id, timer_count = 1 }
        elseif add_subgroup then
            local active_group = self._groups[group]
            active_group.count = active_group.count + 1
            active_group[subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }
        else -- add group
            self._groups[group] = { [subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }, count = 1 }
        end
    elseif self._FORCE_SHARED_MASTER and params.timer_gui then
        params.class = "EHITimerTracker"
    end
    managers.ehi_tracker:AddTracker(params)
    if self._FORCE_SHARED_MASTER and params.timer_gui then -- Enabled for now for TimerGui units
        self._shared[params.id] = (self._GROUPING_IS_ENABLED and params.timer_gui) and EHITimerGuiGroupSharedMaster:new(params) or EHITimerGuiSharedMaster:new(params)
    end
end

---@param id string Unit Key
function EHITimerManager:RemoveTimer(id)
    local active_group = table.remove_key(self._units_in_active_group, id)
    if active_group then
        local group, subgroup, i_subgroup = managers.ehi_tracker:ReturnValue(active_group, "GetGroupData")
        self:_remove_timer_from_group(id, group, subgroup, i_subgroup)
    else
        managers.ehi_tracker:RemoveTracker(id)
        local master = self:_remove_shared_master(id)
        if master then
            master:RemoveFromUpdate()
        end
    end
    managers.ehi_waypoint:RemoveWaypoint(id)
end

---@param id string Unit Key
---@param group string
---@param subgroup number
---@param i_subgroup number
function EHITimerManager:_remove_timer_from_group(id, group, subgroup, i_subgroup)
    local g = self._groups[group]
    local s = g and g[subgroup]
    local i = s and s[i_subgroup]
    if i then
        i.timer_count = i.timer_count - 1
        if i.timer_count <= 0 then -- Remove the i_subgroup
            self._groups[group][subgroup][i_subgroup] = nil
            managers.ehi_tracker:ForceRemoveTracker(i.name)
            local master = self:_remove_shared_master(i.name)
            if master then
                master:RemoveFromUpdate()
            end
            s.count = s.count - 1
            if s.count <= 0 then
                self._groups[group][subgroup] = nil
                g.count = g.count - 1
                if g.count <= 0 then
                    self._groups[group] = nil
                end
            end
        else
            managers.ehi_tracker:CallFunction(i.name, "StopTimer", id)
            local master = self:_get_shared_master(i.name) ---@cast master -EHITimerGuiSharedMaster
            if master then
                master:RemoveTimer(id)
            end
        end
    end
end

---@param id string Unit Key
---@param t number
function EHITimerManager:SetTimerTime(id, t)
    managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetTimeNoAnim", t, id) -- To keep compatibility with `EHITimerTracker`
end

if EHI:GetTrackerOption("show_timers") and EHI:GetWaypointOption("show_waypoints_timers") then
    if EHI:GetOption("time_format") == 1 then
        EHITimerManager.FormatTimer = tweak_data.ehi.functions.ReturnSecondsOnly
    else
        EHITimerManager.FormatTimer = tweak_data.ehi.functions.ReturnMinutesAndSeconds
    end
    ---@param id string Unit Key
    ---@param t number
    function EHITimerManager:UpdateTimer(id, t)
        local t_string = self:FormatTimer(t)
        managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetTimeNoFormat", t, t_string, id) -- To keep compatibility with `EHITimerTracker`
        managers.ehi_waypoint:CallFunction(id, "SetTimeNoFormat", t, t_string)
    end
end

---@param id string Unit Key
---@param jammed boolean
function EHITimerManager:SetJammed(id, jammed)
    local master = self:_get_shared_master(self._units_in_active_group[id] or id)
    if master then
        master:SetJammed(jammed, id) ---@diagnostic disable-line
    end
    managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetJammed", jammed, id) -- To keep compatibility with `EHITimerTracker`
    managers.ehi_waypoint:CallFunction(id, "SetJammed", jammed)
end

---@param id string Unit Key
---@param powered boolean
function EHITimerManager:SetPowered(id, powered)
    local master = self:_get_shared_master(self._units_in_active_group[id] or id)
    if master then
        master:SetPowered(powered, id) ---@diagnostic disable-line
    end
    managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetPowered", powered, id) -- To keep compatibility with `EHITimerTracker`
    managers.ehi_waypoint:CallFunction(id, "SetPowered", powered)
end

---@param id string Unit Key
---@param state boolean
function EHITimerManager:SetAutorepair(id, state)
    managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetAutorepair", state, id) -- To keep compatibility with `EHITimerTracker`
    managers.ehi_waypoint:CallFunction(id, "SetAutorepair", state)
end

---@param id string Unit Key
function EHITimerManager:SetRunning(id)
    local master = self:_get_shared_master(self._units_in_active_group[id] or id)
    if master then
        master:SetRunning(id) ---@diagnostic disable-line
    end
    managers.ehi_tracker:CallFunction(self._units_in_active_group[id] or id, "SetRunning", id) -- To keep compatibility with `EHITimerTracker`
    managers.ehi_waypoint:CallFunction(id, "SetRunning")
end

---@param id string Unit Key
function EHITimerManager:IsTimerMergeRunning(id)
    return managers.ehi_tracker:ReturnValue(self._units_in_active_group[id] or id, "IsTimerMergeRunning", id) or managers.ehi_waypoint:WaypointExists(id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
function EHITimerManager:TimerExists(id)
    return managers.ehi_tracker:Exists(self._units_in_active_group[id] or id) or managers.ehi_waypoint:WaypointExists(id)
end

---@param timer_gui TimerGui
function EHITimerManager:SetTimerUpgrades(timer_gui)
    local id = timer_gui._ehi_key
    local upgrades, skills = timer_gui:GetUpgrades()
    if self._GROUPING_IS_ENABLED then
        local unit_group = self._units_in_active_group[id]
        if unit_group then
            local group, subgroup, i_subgroup = managers.ehi_tracker:ReturnValue(unit_group, "GetGroupData")
            local new_subgroup = self._compute_subgroup(skills)
            if subgroup ~= new_subgroup then
                if self._groups[group] then
                    local visibility_data = timer_gui:GetVisibilityData()
                    local g_i_subgroup = self._groups[group][new_subgroup]
                    local t = timer_gui._time_left or timer_gui._current_timer or 0
                    if g_i_subgroup then -- New subgroup exists, check to what tracker we can add it
                        local new_i_group = 0
                        for i, sub in ipairs(g_i_subgroup) do
                            new_i_group = i
                            if sub.timer_count < self._MAX_TIMERS then
                                sub.timer_count = sub.timer_count + 1
                                managers.ehi_tracker:CallFunction(sub.name, "AddTimer", t, id, false, false, timer_gui)
                                self:_remove_timer_from_group(id, group, subgroup, i_subgroup)
                                self._units_in_active_group[id] = sub.name
                                local master = self:_get_shared_master(sub.name) ---@cast master -EHITimerGuiSharedMaster
                                if master then
                                    master:AddTimer(id, t, timer_gui)
                                end
                                return
                            end
                        end -- Unfortunately all active subgroups are full, create a new i_subgroup
                        self:_add_timer_isubgroup(id, t, group, subgroup, new_i_group + 1, upgrades, timer_gui, visibility_data)
                    else -- New subgroup does not exist, needs to be created
                        self:_add_timer_subgroup(id, t, group, new_subgroup, 1, upgrades, timer_gui, visibility_data)
                    end
                    self:_remove_timer_from_group(id, group, subgroup, i_subgroup)
                end
            end
        end
    else
        managers.ehi_tracker:CallFunction(id, "SetUpgrades", upgrades)
    end
end

---@param id string
function EHITimerManager:_get_shared_master(id)
    return self._shared and self._shared[id]
end

---@param id string
function EHITimerManager:_remove_shared_master(id)
    if self._shared then
        return table.remove_key(self._shared, id)
    end
end

function EHITimerManager:SharedMasterIsEnabled()
    return self._FORCE_SHARED_MASTER
end

EHI:AddCallback(EHI.CallbackMessage.InitManagers, function(managers)
    EHITimerManager:post_init()
end)

return EHITimerManager