---@alias EHITrackerManager.Tracker { tracker: EHITracker, pos: number, x: number, w: number }

local EHI = EHI
---@class EHITrackerManager
---@field IsLoading fun(self: self): boolean `VR only (EHITrackerManagerVR)`
---@field AddToLoadQueue fun(self: self, key: string, data: table, f: function, add: boolean?) `VR only (EHITrackerManagerVR)`
---@field SetPanel fun(self: self, panel: Panel) `VR only (EHITrackerManagerVR)`
local EHITrackerManager = {}
EHITrackerManager._trackers = setmetatable({}, { __mode = "k" }) ---@type table<string, EHITrackerManager.Tracker?>
EHITrackerManager._sync_tm_add_tracker = "EHI_TM_SyncAddTracker"
EHITrackerManager._sync_tm_update_tracker = "EHI_TM_SyncUpdateTracker"
EHITrackerManager._n_of_rc = EHI:GetOption("trackers_n_of_rc") --[[@as number]] -- Number of Rows/Columns
EHITrackerManager.Rounding =
{
    Standard = 1,
    Chance = 2
}
function EHITrackerManager:post_init()
    EHITracker._parent_class = self
    self:_create_workspace()
    self._t = 0
    self._stealth_trackers = { lasers = {} }
    self._trackers_to_update = setmetatable({}, { __mode = "k" }) ---@type table<string, EHITracker?>
    self._n_of_trackers = 0
    self._delay_popups = true
    self._panel_size = tweak_data.ehi.default.tracker.size_h * self._scale
    self._panel_offset = tweak_data.ehi.default.tracker.offset * self._scale
    self._base_tracker_class = EHI.Trackers.Base
    if self._rc_params then
        self._rc_params.next_panel_offset = self._rc_params.next_panel_offset * self._scale
        self._rc_params.gap_scaled = self._rc_params.gap_scaled * self._scale
        self._rc_params.horizontal_offset = self._panel_size + self._panel_size + self._panel_offset
    end
end

function EHITrackerManager:_create_workspace()
    self._x, self._y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._ws:hide()
    self._scale = EHI:GetOption("scale") --[[@as number]]
    self._panel = self._ws:panel():panel({ layer = -10 })
    EHI:AddCallback(EHI.CallbackMessage.HUDVisibilityChanged, function(visibility) ---@param visibility boolean
        if visibility then
            self._ws:show()
        else
            self._ws:hide()
        end
    end)
end

function EHITrackerManager:init_finalize()
    EHI:AddOnSpawnedCallback(function()
        self._delay_popups = false
        for _, tbl in pairs(self._trackers) do
            tbl.tracker:PlayerSpawned()
        end
    end)
    EHI:AddOnAlarmCallback(function(dropin)
        for _, def in pairs(self._trackers) do
            def.tracker:SwitchToLoudMode()
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
        for _, def in pairs(self._trackers) do
            def.tracker:MissionEnd()
        end
    end)
    if CustomNameColor and CustomNameColor.ModID and not Global.game_settings.single_player then
        managers.ehi_sync:AddReceiveHook(CustomNameColor.ModID, "EHI_EHITrackerManager", function(data, sender)
            if data and data ~= "" then
                local col = NetworkHelper:StringToColour(data)
                self:CallFunction("Converts", "UpdatePeerColor", sender, col)
            end
        end)
    end
end

---@param peer_id number?
function EHITrackerManager:GetPeerColorByPeerID(peer_id)
    return peer_id and tweak_data.chat_colors[peer_id] or Color.white
end

---@param dt number
function EHITrackerManager:update(t, dt)
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:update(dt)
    end
end

---@param t number
function EHITrackerManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(nil, dt)
end

function EHITrackerManager:destroy()
    for _, tbl in pairs(self._trackers) do
        tbl.tracker:destroy(true)
    end
    if self._ws and alive(self._ws) then
        managers.gui_data:destroy_workspace(self._ws)
        self._ws = nil
    end
end

---@param params ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTracker(params, pos)
    if self._trackers[params.id] then
        EHI:Log(string.format("Tracker with ID '%s' exists!", params.id))
        EHI:LogTraceback()
        self._trackers[params.id].tracker:ForceDelete()
    end
    params.delay_popup = self._delay_popups
    local tracker = (params.class_table or _G[params.class or self._base_tracker_class]):new(self._panel, params)
    local w = tracker:GetTrackerSize()
    pos = self:_move_trackers(pos, w)
    local x = self:_get_x(pos, w)
    local y = self:_get_y(pos)
    if tracker._needs_update then
        self._trackers_to_update[params.id] = tracker
    end
    tracker:PosAndSetVisible(x, y)
    self._trackers[params.id] = { tracker = tracker, pos = pos or self._n_of_trackers, x = x, w = w }
    self:_tracker_created(tracker, pos or self._n_of_trackers, w)
end

---@param params ElementTrigger
function EHITrackerManager:AddHiddenTracker(params)
    if self._trackers[params.id] then
        EHI:Log(string.format("Tracker with ID '%s' exists!", params.id))
        EHI:LogTraceback()
        self._trackers[params.id].tracker:ForceDelete()
    end
    local tracker = (params.class_table or _G[params.class or self._base_tracker_class]):new(self._panel, params)
    if tracker._needs_update then
        self._trackers_to_update[params.id] = tracker
    end
    self._trackers[params.id] = { tracker = tracker }
end

---@param params ElementTrigger
function EHITrackerManager:PreloadTracker(params)
    if self._trackers[params.id] then
        EHI:Log(string.format("Tracker with ID '%s' exists!", params.id))
        EHI:LogTraceback()
        self._trackers[params.id].tracker:ForceDelete()
    end
    local tracker = (params.class_table or _G[params.class or self._base_tracker_class]):new(self._panel, params)
    self._trackers[params.id] = { tracker = tracker }
end

---@param id string
---@param params ElementTrigger?
---@param pos number?
function EHITrackerManager:RunTracker(id, params, pos)
    local tbl = self._trackers[id]
    if not tbl then
        return
    end
    tbl.tracker:Run(params)
    if tbl.pos then
        return
    end
    local w = tbl.tracker:GetTrackerSize()
    pos = self:_move_trackers(pos, w)
    local x = self:_get_x(pos, w)
    local y = self:_get_y(pos)
    tbl.tracker:PosAndSetVisible(x, y)
    tbl.pos = pos or self._n_of_trackers
    tbl.x = x
    tbl.w = w
    if tbl.tracker._needs_update then
        self:_add_tracker_to_update(tbl.tracker)
    end
    self:_tracker_created(tbl.tracker, tbl.pos, w)
end

---@param params ElementTrigger
function EHITrackerManager:AddLaserTracker(params)
    local count = self._stealth_trackers.lasers[params.time] or 0
    if count > 0 then
        self._stealth_trackers.lasers[params.time] = count + 1
        return
    end
    self._stealth_trackers.lasers[params.time] = 1
    self:AddTracker(params)
end

---@param id string
---@param t number
function EHITrackerManager:RemoveLaserTracker(id, t)
    local count = self._stealth_trackers.lasers[t] or 0
    if count > 0 then
        if count - 1 <= 0 then
            self._stealth_trackers.lasers[t] = nil
        else
            self._stealth_trackers.lasers[t] = count - 1
        end
    end
    self:RemoveTracker(id)
end

---@param params ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTrackerIfDoesNotExist(params, pos)
    if self:DoesNotExist(params.id) then
        self:AddTracker(params, pos)
    end
end

---@param id string
---@param params ElementTrigger
---@param pos number?
function EHITrackerManager:RunTrackerIfDoesNotExist(id, params, pos)
    local tbl = id and self._trackers[id]
    if tbl and not tbl.pos then
        self:RunTracker(id, params, pos)
    end
end

if EHITrackerManager._n_of_rc > 0 then
    EHITrackerManager._rc_params =
    {
        last_line = 1,
        next_panel_offset = tweak_data.ehi.default.tracker.size_h + tweak_data.ehi.default.tracker.gap, --[[@as number]]
        gap_scaled = tweak_data.ehi.default.tracker.gap,
        horizontal_offset = 0
    }
    ---@param pos number?
    function EHITrackerManager:_get_rc_line_index(pos)
        return math.floor((pos or self._n_of_trackers) / self._n_of_rc)
    end

    ---@param pos number?
    ---@param pos_line number?
    function EHITrackerManager:_get_rc_line_and_pos_line_from_pos(pos, pos_line)
        pos_line = pos_line or (self:_get_rc_line_index(pos) + 1)
        return self._rc_line[pos_line], pos_line
    end

    ---@param pos_line number
    function EHITrackerManager:_get_start_end_pos_from_pos_line(pos_line)
        pos_line = math.max(0, pos_line - 1)
        return self._n_of_rc * pos_line, (self._n_of_rc * (pos_line + 1)) - 1
    end

    EHITrackerManager._rc_line = {} ---@type { max_size: number, id: string }[]
    EHITrackerManager._rc_line[1] = { max_size = 0 }
    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Vertical) then -- Vertical in VR or in non-VR
        blt.vm.loadfile(EHI.LuaPath .. "manager/tracker/rc_vertical.lua")(EHITrackerManager)
    else -- Horizontal
        blt.vm.loadfile(EHI.LuaPath .. "manager/tracker/rc_horizontal.lua")(EHITrackerManager)
    end
else
    blt.vm.loadfile(EHI.LuaPath .. "manager/tracker/default.lua")(EHITrackerManager)
end

function EHITrackerManager:_itemize_list_of_trackers()
    local list = {} ---@type EHITrackerManager.Tracker[]
    for _, tbl in pairs(self._trackers) do
        if tbl.pos then
            list[tbl.pos] = tbl
        end
    end
    return list
end

---@param tracker EHITracker
function EHITrackerManager:_add_tracker_to_update(tracker)
    self._trackers_to_update[tracker._id] = tracker
end

---@param id string
function EHITrackerManager:_remove_tracker_from_update(id)
    self._trackers_to_update[id] = nil
end

---@param id string
---@param new_id string
function EHITrackerManager:UpdateTrackerID(id, new_id)
    local tbl = self._trackers[id]
    if self:Exists(new_id) or not tbl then
        return
    end
    tbl.tracker._id = new_id
    self._trackers[new_id] = table.remove_key(self._trackers, id)
    self._trackers_to_update[new_id] = table.remove_key(self._trackers_to_update, id)
end

---@param id string
---@param hint string
function EHITrackerManager:UpdateHint(id, hint)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:UpdateHint(hint)
    end
end

---@param id string
---@return EHITracker?
function EHITrackerManager:GetTracker(id)
    local tbl = id and self._trackers[id]
    return tbl and tbl.tracker
end

---@param id string
function EHITrackerManager:RemoveTracker(id)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:delete()
    end
end

---@param id string
function EHITrackerManager:ForceRemoveTracker(id)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:ForceDelete()
    end
end

---@param id string
function EHITrackerManager:HideTracker(id)
    local tracker = self._trackers[id]
    self._trackers_to_update[id] = nil
    if tracker and tracker.pos then
        local pos, w = tracker.pos, tracker.w
        tracker.pos = nil
        self._n_of_trackers = self._n_of_trackers - 1
        self:_rearrange_trackers(pos, w)
        self:_tracker_destroyed(id, pos, w)
    end
end

---@param id string
function EHITrackerManager:_destroy_tracker(id)
    local tracker = table.remove_key(self._trackers, id)
    self._trackers_to_update[id] = nil
    if tracker and tracker.pos then
        local pos, w = tracker.pos, tracker.w
        self._n_of_trackers = self._n_of_trackers - 1
        self:_rearrange_trackers(pos, w)
        self:_tracker_destroyed(id, pos, w)
    end
end

---@param id string
function EHITrackerManager:Exists(id)
    return self._trackers[id] ~= nil
end

---@param id string
function EHITrackerManager:DoesNotExist(id)
    return not self:Exists(id)
end

---@param id string
---@param pause boolean
function EHITrackerManager:SetPaused(id, pause)
    local tracker = self:GetTracker(id) --[[@as EHIPausableTracker]]
    if tracker and tracker.SetPause then
        tracker:SetPause(pause)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTime(id, time)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetTime(time)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTimeNoAnim(id, time)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetTimeNoAnim(time)
    end
end

---@param id string
---@param icon string
function EHITrackerManager:SetIcon(id, icon)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetIcon(icon)
    end
end

---@param id string
---@param amount number
---@param rounding number?
---@param bracket integer?
function EHITrackerManager:IncreaseChance(id, amount, rounding, bracket)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.IncreaseChance then
        if rounding then
            if rounding == self.Rounding.Standard then
                amount = math.ehi_round(amount, bracket)
            else
                amount = math.ehi_round_chance(amount)
            end
        end
        tracker:IncreaseChance(amount)
    end
end

---@param id string
---@param amount number
---@param rounding number?
---@param bracket number?
function EHITrackerManager:DecreaseChance(id, amount, rounding, bracket)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.DecreaseChance then
        if rounding then
            if rounding == self.Rounding.Standard then
                amount = math.ehi_round(amount, bracket)
            else
                amount = math.ehi_round_chance(amount)
            end
        end
        tracker:DecreaseChance(amount)
    end
end

---@param id string
---@param amount number
---@param rounding number?
---@param bracket number?
function EHITrackerManager:SetChance(id, amount, rounding, bracket)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.SetChance then
        if rounding then
            if rounding == self.Rounding.Standard then
                amount = math.ehi_round(amount, bracket)
            else
                amount = math.ehi_round_chance(amount)
            end
        end
        tracker:SetChance(amount)
    end
end

---Rounds the number as percent before it is passed to a tracker
---@param id string
---@param amount number
function EHITrackerManager:SetChancePercent(id, amount)
    self:SetChance(id, math.ehi_round_chance(amount))
end

---@param id string
---@param progress number
function EHITrackerManager:SetProgress(id, progress)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgress then
        tracker:SetProgress(progress)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:IncreaseProgress(id, value)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress(value)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:DecreaseProgress(id, value)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.DecreaseProgress then
        tracker:DecreaseProgress(value)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:IncreaseProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.IncreaseProgressMax then
        tracker:IncreaseProgressMax(max)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:DecreaseProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.DecreaseProgressMax then
        tracker:DecreaseProgressMax(max)
    end
end

---@param id string
---@param max number
function EHITrackerManager:SetProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgressMax then
        tracker:SetProgressMax(max)
    end
end

---@param id string
---@param remaining number
function EHITrackerManager:SetProgressRemaining(id, remaining)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgressRemaining then
        tracker:SetProgressRemaining(remaining)
    end
end

---@param id string Tracker ID
---@param group_id string ID of the group
---@param value number?
function EHITrackerManager:IncreaseGroupProgress(id, group_id, value)
    local tracker = self:GetTracker(id) --[[@as EHIProgressGroupTracker]]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress(value, group_id)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetAccurate(id, time)
    local tracker = self:GetTracker(id) --[[@as EHIInaccurateTracker]]
    if tracker and tracker.SetAccurate then
        tracker:SetAccurate(time)
    end
end

---@param id string
---@param count number
function EHITrackerManager:SetCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.SetCount then
        tracker:SetCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:IncreaseCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.IncreaseCount then
        tracker:IncreaseCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:DecreaseCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.DecreaseCount then
        tracker:DecreaseCount(count)
    end
end

---Synces data to trackers from GameSetup:load()
---@param id string
function EHITrackerManager:SetSyncData(id, ...)
    self:CallFunction(id, "SyncData", ...)
end

---@param id string
---@param f string
function EHITrackerManager:CallFunction(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

---Returns `true` if the tracker does not exist
---@param id string
---@param f string
function EHITrackerManager:CallFunction2(id, f, ...)
    local tracker = self:GetTracker(id)
    if not tracker then
        return true
    elseif tracker[f] then
        tracker[f](tracker, ...)
    end
end

---@param id string
---@param f string
---@return ...
function EHITrackerManager:ReturnValue(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        return tracker[f](tracker, ...)
    end
end

do
    local path = EHI.LuaPath .. "trackers/"
    dofile(path .. "EHITracker.lua")
    dofile(path .. "EHIWarningTracker.lua")
    dofile(path .. "EHIPausableTracker.lua")
    dofile(path .. "EHIChanceTracker.lua")
    dofile(path .. "EHIProgressTracker.lua")
    dofile(path .. "EHICountTracker.lua")
    dofile(path .. "EHINeededValueTracker.lua")
    dofile(path .. "EHIInaccurateTrackers.lua")
    dofile(path .. "EHITimedTrackers.lua")
    dofile(path .. "EHIGroupTrackers.lua")
    dofile(path .. "EHIAchievementTrackers.lua")
    dofile(path .. "EHISideJobTrackers.lua")
    dofile(path .. "EHIEventMissionTrackers.lua")
end

if _G.IS_VR then
    return blt.vm.loadfile(EHI.LuaPath .. "vr/EHITrackerManagerVR.lua")(EHITrackerManager)
elseif VoidUI then
    dofile(EHI.LuaPath .. "hud/tracker/void_ui.lua")
end

return EHITrackerManager