local EHI = EHI
---@class EHITrackerManager
---@field IsLoading fun(self: self): boolean VR only (EHITrackerManagerVR)
---@field AddToLoadQueue fun(self: self, key: string, data: table, f: function, add: boolean?) VR only (EHITrackerManagerVR)
---@field SetPanel fun(self: self, panel: Panel) VR only (EHITrackerManagerVR)
EHITrackerManager = {}
EHITrackerManager.GetAchievementIcon = EHI.GetAchievementIcon
function EHITrackerManager:new()
    self:CreateWorkspace()
    self._t = 0
    self._trackers = setmetatable({}, {__mode = "k"}) ---@type table<string, { tracker: EHITracker, pos: number, x: number, w: number }?>
    self._stealth_trackers = { pagers = {}, lasers = {} }
    self._trackers_to_update = setmetatable({}, {__mode = "k"}) ---@type table<string, EHITracker?>
    self._n_of_trackers = 0
    self._delay_popups = true
    self._panel_size = 32 * self._scale
    self._panel_offset = 6 * self._scale
    self._base_tracker_class = EHI.Trackers.Base
    return self
end

function EHITrackerManager:CreateWorkspace()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._ws:hide()
    self._scale = EHI:GetOption("scale") --[[@as number]]
    self._hud_panel = self._ws:panel():panel({
        name = "ehi_panel",
        layer = -10
    })
end

function EHITrackerManager:init_finalize()
    EHI:AddOnAlarmCallback(callback(self, self, "SwitchToLoudMode"))
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "Spawned"))
    if EHI:IsClient() then
        Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHITracker", function(sender_id, id, data)
            if id == EHI.SyncMessages.TrackerManager.SyncAddTracker then
                local params = LuaNetworking:StringToTable(data)
                if params._id == "LootCounter" and EHI:GetOption("show_loot_counter") then
                    self:ShowLootCounter(tonumber(params.max), tonumber(params.max_random), tonumber(params.offset))
                    EHI:HookLootCounter(true)
                end
            elseif id == EHI.SyncMessages.TrackerManager.SyncUpdateTracker then
                local params = LuaNetworking:StringToTable(data)
                if params._id == "LootCounter" then
                    if params.type == "IncreaseMaxRandom" then
                        self:IncreaseLootCounterMaxRandom(tonumber(params.random))
                    elseif params.type == "RandomLootSpawned" then
                        self:RandomLootSpawned(tonumber(params.random))
                    elseif params.type == "RandomLootDeclined" then
                        self:RandomLootDeclined(tonumber(params.random))
                    end
                end
            end
        end)
    end
end

function EHITrackerManager:Spawned()
    self._delay_popups = false
    for _, tbl in pairs(self._trackers) do
        tbl.tracker:PlayerSpawned()
    end
end

function EHITrackerManager:ShowPanel()
    self._ws:show()
end

function EHITrackerManager:HidePanel()
    self._ws:hide()
end

---@param t number
function EHITrackerManager:LoadTime(t)
    self._t = t
end

function EHITrackerManager:LoadSync()
    EHI:DelayCall("EHI_Converts_UpdatePeerColors", 2, function()
        self:CallFunction("Converts", "UpdatePeerColors")
    end)
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

function EHITrackerManager:load(data)
    local load_data = data.EHITrackerManager
    if load_data then
        if load_data.LootCounter and EHI:GetOption("show_loot_counter") then
            local params = deep_clone(load_data.LootCounter) --[[@as LootCounterTable]]
            params.client_from_start = true
            params.no_sync_load = true
            EHI:ShowLootCounterNoCheck(params)
            self:SyncSecuredLoot()
        end
    end
end

function EHITrackerManager:save(data)
    if self._trackers_to_sync then
        local sync_data = {}
        for key, value in pairs(self._trackers_to_sync) do
            sync_data[key] = value
        end
        data.EHITrackerManager = sync_data
    end
end

---@param params AddTrackerTable|ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTracker(params, pos)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id].tracker:ForceDelete()
    end
    params.delay_popup = self._delay_popups
    local class = params.class or self._base_tracker_class
    local tracker_class = _G[class] --[[@as EHITracker]]
    local tracker = tracker_class:new(self._hud_panel, params, self)
    local w = tracker:GetPanelW()
    pos = self:MoveTracker(pos, w)
    local x = self:GetX(pos, w)
    local y = self:GetY(pos)
    if tracker._update then
        self._trackers_to_update[params.id] = tracker
    end
    tracker:PosAndSetVisible(x, y)
    self._trackers[params.id] = { tracker = tracker, pos = pos or self._n_of_trackers, x = x, w = w }
    self._n_of_trackers = self._n_of_trackers + 1
end

---@param params AddTrackerTable|ElementTrigger
function EHITrackerManager:PreloadTracker(params)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists!")
        EHI:LogTraceback()
        self._trackers[params.id].tracker:ForceDelete()
    end
    local class = params.class or self._base_tracker_class
    local tracker = _G[class]:new(self._hud_panel, params, self) --[[@as EHITracker]]
    self._trackers[params.id] = { tracker = tracker }
end

---@param id string
---@param params AddTrackerTable|ElementTrigger
function EHITrackerManager:RunTracker(id, params)
    local tbl = self._trackers[id]
    if not tbl then
        return
    end
    tbl.tracker:Run(params)
    if tbl.pos then
        return
    end
    local w = tbl.tracker:GetPanelW()
    local x = self:GetX(nil, w)
    local y = self:GetY()
    tbl.tracker:PosAndSetVisible(x, y)
    tbl.pos = self._n_of_trackers
    tbl.x = x
    tbl.w = w
    if tbl.tracker._update then
        self:AddTrackerToUpdate(tbl.tracker)
    end
    self._n_of_trackers = self._n_of_trackers + 1
end

---Called by host only. Clients with EHI call EHITrackerManager:AddTracker() when synced
---@param params AddTrackerTable
---@param id integer
---@param delay number
function EHITrackerManager:AddTrackerAndSync(params, id, delay)
    self:AddTracker(params)
    self:Sync(id, delay)
end

---@param id integer
---@param delay number
function EHITrackerManager:Sync(id, delay)
    EHI:SyncTable(EHI.SyncMessages.EHISyncAddTracker, { id = id, delay = delay or 0 })
end

if Global.game_settings.single_player then
    EHITrackerManager.Sync = function(...) end
end

---@param id string
function EHITrackerManager:AddPagerTracker(id)
    self._stealth_trackers.pagers[id] = true
    local params =
    {
        id = id,
        hint = "pager",
        class = "EHIPagerTracker"
    }
    self:AddTracker(params)
end

---@param params table
function EHITrackerManager:AddLaserTracker(params)
    for id, _ in pairs(self._stealth_trackers.lasers) do
        -- Don't add this tracker if the "next_cycle_t" is the same as time to prevent duplication
        local tracker = self:GetTracker(id) --[[@as EHILaserTracker?]]
        if tracker and tracker._next_cycle_t == params.time then
            return
        end
    end
    self._stealth_trackers.lasers[params.id] = true
    self:AddTracker(params)
end

---@param id string
---@param time_max number
function EHITrackerManager:AddTimedAchievementTracker(id, time_max)
    local t = time_max - math.max(managers.ehi_manager._t, self._t)
    if t <= 0 then
        return
    end
    self:AddTracker({
        id = id,
        time = t,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Base
    })
end

---@param id string
---@param max number
---@param progress number?
---@param show_finish_after_reaching_target boolean?
---@param class string?
function EHITrackerManager:AddAchievementProgressTracker(id, max, progress, show_finish_after_reaching_target, class)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = class or EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param status string?
function EHITrackerManager:AddAchievementStatusTracker(id, status)
    self:AddTracker({
        id = id,
        status = status,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Status
    })
end

---@param id string
---@param max number
---@param loot_counter_on_fail boolean?
---@param start_silent boolean?
function EHITrackerManager:AddAchievementLootCounter(id, max, loot_counter_on_fail, start_silent)
    self:AddTracker({
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        loot_counter_on_fail = loot_counter_on_fail,
        start_silent = start_silent,
        class = EHI.Trackers.Achievement.LootCounter
    })
end

---@param id string
---@param max number
---@param show_finish_after_reaching_target boolean?
function EHITrackerManager:AddAchievementBagValueCounter(id, max, show_finish_after_reaching_target)
    self:AddTracker({
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = EHI.Trackers.Achievement.BagValue
    })
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param offset number?
function EHITrackerManager:ShowLootCounter(max, max_random, offset)
    self:AddTracker({
        id = "LootCounter",
        max = max or 0,
        max_random = max_random or 0,
        offset = offset or 0,
        class = "EHILootTracker"
    })
end

---@param tracker_id string? Defaults to `LootCounter` if not provided
function EHITrackerManager:SyncSecuredLoot(tracker_id)
    self:SetTrackerProgress(tracker_id or "LootCounter", managers.loot:GetSecuredBagsAmount())
end

---@param id string
---@param progress number
---@param max number
function EHITrackerManager:AddAchievementKillCounter(id, progress, max)
    self:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Progress
    })
end

---@param params AddTrackerTable|ElementTrigger
---@param pos integer?
function EHITrackerManager:AddTrackerIfDoesNotExist(params, pos)
    if self:TrackerDoesNotExist(params.id) then
        self:AddTracker(params, pos)
    end
end

---@param id string
---@param params AddTrackerTable|ElementTrigger
function EHITrackerManager:RunTrackerIfDoesNotExist(id, params)
    local tbl = id and self._trackers[id]
    if tbl and not tbl.pos then
        self:RunTracker(id, params)
    end
end

---@param id string
---@param stealth_id string
function EHITrackerManager:RemoveStealthTracker(id, stealth_id)
    self._stealth_trackers[stealth_id][id] = nil
    self:RemoveTracker(id)
end

---@param id string
function EHITrackerManager:RemoveLaserTracker(id)
    self:RemoveStealthTracker(id, "lasers")
end

function EHITrackerManager:SwitchToLoudMode()
    for _, trackers in pairs(self._stealth_trackers) do
        for key, _ in pairs(trackers) do
            self:RemoveTracker(key)
        end
    end
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", { [1] = true, [2] = true }) then -- Vertical in VR or in non-VR
    ---@param pos number?
    ---@param w number
    ---@return number
    function EHITrackerManager:GetX(pos, w)
        return self._x
    end

    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", 1) then -- Top to Bottom
        ---@param pos number?
        ---@return number
        function EHITrackerManager:GetY(pos)
            pos = pos or self._n_of_trackers
            return self._y + (pos * (self._panel_size + self._panel_offset))
        end
    else -- Bottom to Top
        ---@param pos number?
        ---@return number
        function EHITrackerManager:GetY(pos)
            pos = pos or self._n_of_trackers
            return self._y - (pos * (self._panel_size + self._panel_offset))
        end
    end

    ---@param pos number?
    ---@param w number
    ---@return number?
    function EHITrackerManager:MoveTracker(pos, w)
        if type(pos) == "number" and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
            for _, tbl in pairs(self._trackers) do
                if tbl.pos and tbl.pos >= pos then
                    local final_pos = tbl.pos + 1
                    local y = self:GetY(final_pos)
                    tbl.tracker:AnimateTop(y)
                    tbl.tracker:AnimateHintTop(y)
                    tbl.pos = final_pos
                end
            end
            return pos
        end
        return nil -- Received crap or no tracker exists; create tracker on the first available position
    end

    ---@param pos number
    ---@param w number
    ---@param pos_move number?
    ---@param panel_offset_move number?
    function EHITrackerManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
        if not pos then
            return
        end
        for _, value in pairs(self._trackers) do
            if value.pos and value.pos > pos then
                local final_pos = value.pos - 1
                local y = self:GetY(final_pos)
                value.tracker:AnimateTop(y)
                value.tracker:AnimateHintTop(y)
                value.pos = final_pos
            end
        end
    end

    ---Call this function only from trackers themselves
    ---@param id string
    ---@param new_w number
    ---@param move_the_tracker boolean?
    function EHITrackerManager:ChangeTrackerWidth(id, new_w, move_the_tracker)
    end
else -- Horizontal
    ---@param pos number?
    ---@return number
    function EHITrackerManager:GetY(pos)
        return self._y
    end

    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", 3) then -- Left to Right
        ---@param pos number?
        ---@param w number
        ---@return number
        function EHITrackerManager:GetX(pos, w)
            if self._n_of_trackers == 0 or pos and pos <= 0 then
                return self._x
            end
            local x = 0
            local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
            for _, value in pairs(self._trackers) do
                if value.pos and value.pos == pos_create then
                    x = value.x + value.w + self._panel_offset
                    break
                end
            end
            return x
        end

        ---@param pos number?
        ---@param w number
        ---@return number?
        function EHITrackerManager:MoveTracker(pos, w)
            if type(pos) == "number" and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
                for _, tbl in pairs(self._trackers) do
                    if tbl.pos and tbl.pos >= pos then
                        local final_x = tbl.x + w + self._panel_offset
                        tbl.tracker:AnimateLeft(final_x)
                        tbl.tracker:AnimateHintLeft(final_x)
                        tbl.x = final_x
                        tbl.pos = tbl.pos + 1
                    end
                end
                return pos
            end
            return nil -- Received crap or no tracker exists; create tracker on the first available position
        end

        ---@param pos number
        ---@param w number
        ---@param pos_move number?
        ---@param panel_offset_move number?
        function EHITrackerManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
            if not pos then
                return
            end
            pos_move = pos_move or 1
            panel_offset_move = panel_offset_move or self._panel_offset
            for _, value in pairs(self._trackers) do
                if value.pos and value.pos > pos then
                    local final_x = value.x - w - panel_offset_move
                    value.tracker:AnimateLeft(final_x)
                    value.tracker:AnimateHintLeft(final_x)
                    value.x = final_x
                    value.pos = value.pos - pos_move
                end
            end
        end

        ---Call this function only from trackers themselves
        ---@param id string
        ---@param new_w number
        ---@param move_the_tracker boolean?
        function EHITrackerManager:ChangeTrackerWidth(id, new_w, move_the_tracker)
            local tracker = self._trackers[id]
            if not tracker then
                return
            end
            local w = tracker.w
            local w_diff = -(new_w - w)
            if w_diff == 0 then
                return
            end
            tracker.w = new_w
            self:RearrangeTrackers(tracker.pos, w_diff, 0, 0)
        end
    else -- Right to Left
        ---@param pos number?
        ---@param w number
        ---@return number
        function EHITrackerManager:GetX(pos, w)
            if self._n_of_trackers == 0 or pos and pos <= 0 then
                return self._x
            end
            local x = 0
            local pos_create = pos and (pos - 1) or (self._n_of_trackers - 1)
            for _, value in pairs(self._trackers) do
                if value.pos and value.pos == pos_create then
                    x = value.x - w - self._panel_offset
                    break
                end
            end
            return x
        end

        ---@param pos number?
        ---@param w number
        ---@return number?
        function EHITrackerManager:MoveTracker(pos, w)
            if type(pos) == "number" and pos >= 0 and self._n_of_trackers > 0 and pos <= self._n_of_trackers then
                local list = {} ---@type table<number, { tracker: EHITracker, pos: number, x: number, w: number }>
                for _, value in pairs(self._trackers) do
                    if value.pos then
                        list[value.pos] = value
                    end
                end
                local start_pos = 0
                local previous_x = self._x
                if pos > 0 then
                    local on_pos = list[pos]
                    if on_pos then
                        previous_x = on_pos.x - w - self._panel_offset
                        on_pos.tracker:AnimateLeft(previous_x)
                        on_pos.tracker:AnimateHintLeft(previous_x)
                        on_pos.x = previous_x
                        on_pos.pos = on_pos.pos + 1
                        start_pos = pos + 1
                    else
                        EHI:Log("[EHITrackerManager:MoveTracker()] Something happened during getting the tracker on the position! Nil was returned")
                        EHI:Log("This shouldn't happen, returning nil value to create the tracker on the last available position")
                        return nil
                    end
                end
                for i = start_pos, self._n_of_trackers - 1, 1 do
                    local t_pos = list[i]
                    local final_x = previous_x - t_pos.w - self._panel_offset
                    previous_x = final_x
                    t_pos.tracker:AnimateLeft(final_x)
                    t_pos.tracker:AnimateHintLeft(final_x)
                    t_pos.x = final_x
                    t_pos.pos = t_pos.pos + 1
                end
                return pos
            end
            return nil -- Received crap or no tracker exists; create tracker on the first available position
        end

        ---@param pos number
        ---@param w number
        ---@param pos_move number?
        ---@param panel_offset_move number?
        function EHITrackerManager:RearrangeTrackers(pos, w, pos_move, panel_offset_move)
            if not pos then
                return
            end
            pos_move = pos_move or 1
            panel_offset_move = panel_offset_move or self._panel_offset
            for _, value in pairs(self._trackers) do
                if value.pos and value.pos > pos then
                    local final_x = value.x + w + panel_offset_move
                    value.tracker:AnimateLeft(final_x)
                    value.tracker:AnimateHintLeft(final_x)
                    value.x = final_x
                    value.pos = value.pos - pos_move
                end
            end
        end

        ---Call this function only from trackers themselves
        ---@param id string
        ---@param new_w number
        ---@param move_the_tracker boolean?
        function EHITrackerManager:ChangeTrackerWidth(id, new_w, move_the_tracker)
            local tracker = self._trackers[id]
            if not tracker then
                return
            end
            local w = tracker.w
            local w_diff = -(new_w - w)
            if w_diff == 0 then
                return
            end
            tracker.w = new_w
            local pos = tracker.pos
            if move_the_tracker then
                pos = pos - 1
            else
                tracker.x = tracker.x + w_diff
            end
            self:RearrangeTrackers(pos, w_diff, 0, 0)
        end
    end
end

---@param tracker EHITracker
function EHITrackerManager:AddTrackerToUpdate(tracker)
    self._trackers_to_update[tracker._id] = tracker
end

---@param id string
function EHITrackerManager:RemoveTrackerFromUpdate(id)
    self._trackers_to_update[id] = nil
end

---@param id string
---@param new_id string
function EHITrackerManager:UpdateTrackerID(id, new_id)
    if self:TrackerExists(new_id) or self:TrackerDoesNotExist(id) then
        return
    end
    local tbl = self._trackers[id] ---@cast tbl -?
    tbl.tracker:UpdateID(new_id)
    self._trackers[id] = nil
    self._trackers[new_id] = tbl
    if self._trackers_to_update[id] then
        local update = self._trackers_to_update[id]
        self._trackers_to_update[id] = nil
        self._trackers_to_update[new_id] = update
    end
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
    local tbl = self._trackers[id]
    if tbl then
        tbl.tracker:delete()
    end
end

---@param id string
function EHITrackerManager:ForceRemoveTracker(id)
    local tbl = self._trackers[id]
    if tbl then
        tbl.tracker:ForceDelete()
    end
end

---@param id string
function EHITrackerManager:HideTracker(id)
    local tracker = self._trackers[id]
    self._trackers_to_update[id] = nil
    if tracker and tracker.pos then
        local pos = tracker.pos
        local w = tracker.w
        tracker.pos = nil
        self._n_of_trackers = self._n_of_trackers - 1
        self:RearrangeTrackers(pos, w)
    end
end

---@param id string
function EHITrackerManager:DestroyTracker(id)
    local tracker = self._trackers[id]
    self._trackers[id] = nil
    self._trackers_to_update[id] = nil
    if tracker and tracker.pos then
        local pos = tracker.pos
        local w = tracker.w
        self._n_of_trackers = self._n_of_trackers - 1
        self:RearrangeTrackers(pos, w)
    end
end

---@param id string
function EHITrackerManager:TrackerExists(id)
    return self._trackers[id] ~= nil
end

---@param id string
function EHITrackerManager:TrackerDoesNotExist(id)
    return not self:TrackerExists(id)
end

---@param id string
---@param pause boolean
function EHITrackerManager:SetTrackerPaused(id, pause)
    local tracker = self:GetTracker(id) --[[@as EHIPausableTracker]]
    if tracker and tracker.SetPause then
        tracker:SetPause(pause)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:AddXPToTracker(id, amount)
    local tracker = self:GetTracker(id) --[[@as EHIXPTracker]]
    if tracker and tracker.AddXP then
        tracker:AddXP(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:SetXPInTracker(id, amount)
    local tracker = self:GetTracker(id) --[[@as EHITotalXPTracker]]
    if tracker and tracker.SetXP then
        tracker:SetXP(amount)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerTime(id, time)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetTime(time)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerTimeNoAnim(id, time)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetTimeNoAnim(time)
    end
end

---@param id string
---@param jammed boolean
function EHITrackerManager:SetTimerJammed(id, jammed)
    local tracker = self:GetTracker(id) --[[@as EHITimerTracker]]
    if tracker and tracker.SetJammed then
        tracker:SetJammed(jammed)
    end
end

---@param id string
---@param powered boolean
function EHITrackerManager:SetTimerPowered(id, powered)
    local tracker = self:GetTracker(id) --[[@as EHITimerTracker]]
    if tracker and tracker.SetPowered then
        tracker:SetPowered(powered)
    end
end

---@param id string
function EHITrackerManager:SetTimerRunning(id)
    local tracker = self:GetTracker(id) --[[@as EHITimerTracker]]
    if tracker and tracker.SetRunning then
        tracker:SetRunning()
    end
end

---@param id string
---@param icon string
function EHITrackerManager:SetTrackerIcon(id, icon)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetIcon(icon)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:IncreaseChance(id, amount)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.IncreaseChance then
        tracker:IncreaseChance(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:DecreaseChance(id, amount)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.DecreaseChance then
        tracker:DecreaseChance(amount)
    end
end

---@param id string
---@param amount number
function EHITrackerManager:SetChance(id, amount)
    local tracker = self:GetTracker(id) --[[@as EHIChanceTracker]]
    if tracker and tracker.SetChance then
        tracker:SetChance(amount)
    end
end

---@param id string
---@param progress number
function EHITrackerManager:SetTrackerProgress(id, progress)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgress then
        tracker:SetProgress(progress)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:IncreaseTrackerProgress(id, value)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress(value)
    end
end

---@param id string
---@param value number?
function EHITrackerManager:DecreaseTrackerProgress(id, value)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.DecreaseProgress then
        tracker:DecreaseProgress(value)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:IncreaseTrackerProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.IncreaseProgressMax then
        tracker:IncreaseProgressMax(max)
    end
end

---@param id string
---@param max number?
function EHITrackerManager:DecreaseTrackerProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.DecreaseProgressMax then
        tracker:DecreaseProgressMax(max)
    end
end

---@param id string
---@param max number
function EHITrackerManager:SetTrackerProgressMax(id, max)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgressMax then
        tracker:SetProgressMax(max)
    end
end

---@param id string
---@param remaining number
function EHITrackerManager:SetTrackerProgressRemaining(id, remaining)
    local tracker = self:GetTracker(id) --[[@as EHIProgressTracker]]
    if tracker and tracker.SetProgressRemaining then
        tracker:SetProgressRemaining(remaining)
    end
end

---@param id string
---@param time number
function EHITrackerManager:SetTrackerAccurate(id, time)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:SetTrackerAccurate(time)
    end
end

---@param id string
function EHITrackerManager:StartTrackerCountdown(id)
    local tracker = self:GetTracker(id)
    if tracker then
        self:AddTrackerToUpdate(tracker)
    end
end

---@param id string
---@param force boolean?
function EHITrackerManager:SetAchievementComplete(id, force)
    local tracker = self:GetTracker(id) --[[@as EHIAchievementProgressTracker]]
    if tracker and tracker.SetCompleted then
        tracker:SetCompleted(force)
    end
end

---@param id string
function EHITrackerManager:SetAchievementFailed(id)
    local tracker = self:GetTracker(id) --[[@as EHIAchievementProgressTracker]]
    if tracker and tracker.SetFailed then
        tracker:SetFailed()
    end
end

---@param id string
---@param status string
function EHITrackerManager:SetAchievementStatus(id, status)
    local tracker = self:GetTracker(id) --[[@as EHIAchievementStatusTracker]]
    if tracker and tracker.SetStatus then
        tracker:SetStatus(status)
    end
end

---@param id string
---@param count number
function EHITrackerManager:SetTrackerCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.SetCount then
        tracker:SetCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:IncreaseTrackerCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.IncreaseCount then
        tracker:IncreaseCount(count)
    end
end

---@param id string
---@param count number?
function EHITrackerManager:DecreaseTrackerCount(id, count)
    local tracker = self:GetTracker(id) --[[@as EHICountTracker]]
    if tracker and tracker.DecreaseCount then
        tracker:DecreaseCount(count)
    end
end

function EHITrackerManager:SecuredMissionLoot()
    self:CallFunction("LootCounter", "SecuredMissionLoot")
end

---@param max number?
function EHITrackerManager:IncreaseLootCounterProgressMax(max)
    self:IncreaseTrackerProgressMax("LootCounter", max)
end

---@param max number?
function EHITrackerManager:DecreaseLootCounterProgressMax(max)
    self:DecreaseTrackerProgressMax("LootCounter", max)
end

---@param max_random number?
function EHITrackerManager:SetLootCounterMaxRandom(max_random)
    self:CallFunction("LootCounter", "SetMaxRandom", max_random)
end

---@param progress number?
function EHITrackerManager:IncreaseLootCounterMaxRandom(progress)
    self:CallFunction("LootCounter", "IncreaseMaxRandom", progress)
end

---@param progress number?
function EHITrackerManager:DecreaseLootCounterMaxRandom(progress)
    self:CallFunction("LootCounter", "DecreaseMaxRandom", progress)
end

---@param random number?
function EHITrackerManager:RandomLootSpawned(random)
    self:CallFunction("LootCounter", "RandomLootSpawned", random)
end

---@param random number?
function EHITrackerManager:RandomLootDeclined(random)
    self:CallFunction("LootCounter", "RandomLootDeclined", random)
end

---@param id string|number Element ID
---@param force boolean? Force loot spawn event if the element does not have "fail" state (desync workaround)
function EHITrackerManager:RandomLootSpawnedCheck(id, force)
    self:CallFunction("LootCounter", "RandomLootSpawnedCheck", id, force)
end

---@param id number
---@param t number? Defaults to `2` if not provided
function EHITrackerManager:AddDelayedLootDeclinedCheck(id, t)
    self:CallFunction("LootCounter", "AddDelayedLootDeclinedCheck", id, t)
end

---@param id string|number Element ID
function EHITrackerManager:RandomLootDeclinedCheck(id)
    self:CallFunction("LootCounter", "RandomLootDeclinedCheck", id)
end

---@param id string
---@param data table
function EHITrackerManager:SetTrackerToSync(id, data)
    self._trackers_to_sync = self._trackers_to_sync or {}
    data._id = id
    self._trackers_to_sync[id] = data
end

---@param id string
---@param data table
function EHITrackerManager:SetTrackerToSync2(id, data)
    self:SetTrackerToSync(id, data)
    EHI:SyncTable(EHI.SyncMessages.TrackerManager.SyncAddTracker, self._trackers_to_sync[id])
end

---Shows Loot Counter, needs to be hooked to count correctly
---@param max number?
---@param max_random number?
---@param offset number?
function EHITrackerManager:SyncShowLootCounter(max, max_random, offset)
    self:ShowLootCounter(max, max_random, offset)
    self._trackers_to_sync = self._trackers_to_sync or {}
    self._trackers_to_sync.LootCounter =
    {
        _id = "LootCounter",
        max = max or 0,
        max_random = max_random or 0,
        offset = offset or 0
    }
    if not self._delay_popups then
        EHI:SyncTable(EHI.SyncMessages.TrackerManager.SyncAddTracker, self._trackers_to_sync.LootCounter)
    end
end

---@param random number?
function EHITrackerManager:SyncIncreaseLootCounterMaxRandom(random)
    self:IncreaseLootCounterMaxRandom(random)
    local sync_data = self._trackers_to_sync and self._trackers_to_sync.LootCounter
    if sync_data then
        sync_data.max_random = sync_data.max_random + (random or 1)
        EHI:SyncTable(EHI.SyncMessages.TrackerManager.SyncUpdateTracker, { _id = "LootCounter", type = "IncreaseMaxRandom", random = random })
    end
end

---@param random number?
function EHITrackerManager:SyncRandomLootSpawned(random)
    self:RandomLootSpawned(random)
    local sync_data = self._trackers_to_sync and self._trackers_to_sync.LootCounter
    if sync_data then
        local n = random or 1
        sync_data.max = sync_data.max + n
        sync_data.max_random = sync_data.max_random - n
        EHI:SyncTable(EHI.SyncMessages.TrackerManager.SyncUpdateTracker, { _id = "LootCounter", type = "RandomLootSpawned", random = random })
    end
end

---@param random number?
function EHITrackerManager:SyncRandomLootDeclined(random)
    self:RandomLootDeclined(random)
    local sync_data = self._trackers_to_sync and self._trackers_to_sync.LootCounter
    if sync_data then
        sync_data.max_random = sync_data.max_random - (random or 1)
        EHI:SyncTable(EHI.SyncMessages.TrackerManager.SyncUpdateTracker, { _id = "LootCounter", type = "RandomLootDeclined", random = random })
    end
end

---@param id string
---@param f string
---@param ... any
function EHITrackerManager:CallFunction(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

---@param id string
---@param f string
---@param ... any
---@return ...
function EHITrackerManager:ReturnValue(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        return tracker[f](tracker, ...)
    end
end

---@generic T
---@param id string
---@param f string
---@param default T
---@param ... any
---@return ...|T
function EHITrackerManager:ReturnValueOrDefault(id, f, default, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        return tracker[f](tracker, ...)
    end
    return default
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
    dofile(path .. "EHIColoredCodesTracker.lua")
    dofile(path .. "EHITimedTrackers.lua")
    dofile(path .. "EHIAchievementTrackers.lua")
    dofile(path .. "EHITrophyTrackers.lua")
    dofile(path .. "EHIDailyTrackers.lua")
    if EHI:GetOption("xp_panel") <= 2 and EHI:IsXPTrackerVisible() then
        dofile(path .. "EHIXPTracker.lua")
    end
    if EHI:GetOption("show_equipment_tracker") or (EHI:GetOption("show_minion_tracker") and EHI:GetOption("show_minion_option") == 2) then
        dofile(path .. "EHIEquipmentTracker.lua")
    end
    if EHI:GetOption("show_equipment_tracker") then
        dofile(path .. "EHIAggregatedEquipmentTracker.lua")
        dofile(path .. "EHIAggregatedHealthEquipmentTracker.lua")
        dofile(path .. "EHIECMTracker.lua")
    end
    if EHI:GetOption("show_loot_counter") then
        dofile(path .. "EHILootTracker.lua")
    end
    if EHI:CombineAssaultDelayAndAssaultTime() then
        dofile(path .. "EHIAssaultTracker.lua")
    else
        if EHI:AssaultDelayTrackerIsEnabled() then
            dofile(path .. "EHIAssaultDelayTracker.lua")
        end
        if EHI:GetOption("show_assault_time_tracker") then
            dofile(path .. "EHIAssaultTimeTracker.lua")
        end
    end
end

if VoidUI then
    dofile(EHI.LuaPath .. "hud/tracker/void_ui.lua")
end