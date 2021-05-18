local panel_size = 32
local panel_offset = 6
EHIManager = EHIManager or class()
function EHIManager:init()
    if _G.IS_VR then
        self._ws = Overlay:gui():create_screen_workspace()
        self._ws:set_pinned_screen(true)
        self._scale = EHI:GetOption("vr_scale")
    else
        self._ws = managers.gui_data:create_fullscreen_workspace()
        self._scale = EHI:GetOption("scale")
    end
    self._ws:hide()
    self._hud_panel = self._ws:panel():panel({
        name = "ehi_panel",
        layer = -10
    })
    self._trackers = {}
    self._pager_trackers = {}
    self._trackers_to_update = {}
    self._trackers_pos = {}
    self._n_of_trackers = 0
    self._civilian_killed_tracker = {}
    self._cache = {}
    self._sync_time = 0
    self._sync_real_time = Application:time()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    panel_size = panel_size * self._scale
    panel_offset = panel_offset * self._scale
end

function EHIManager:ShowPanel()
    self._ws:show()
end

function EHIManager:HidePanel()
    self._ws:hide()
end

function EHIManager:LoadTime(sync_time)
    --EHI:Log("Loaded synced Heist time")
    --EHI:Log(tostring(sync_time))
    self._sync_time = sync_time
    self._sync_real_time = Application:time()
end

function EHIManager:CountPickupAvailable(tweak_data)
    local interactions = managers.interaction._interactive_units or {}
    local count = 0
    for _, unit in pairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            count = count + 1
        end
    end
    return count
end

function EHIManager:load()
    local level_id = Global.game_settings.level_id
    if level_id == "pbr2" then -- Birth of Sky
        self:SetTrackerProgress("voff_4", 9 - self:CountPickupAvailable("ring_band"))
    --[[elseif level_id == "pex" then -- Breakfast in Tijuana
        self:SetTrackerProgress("pex_11", 7 - self:CountPickupAvailable("pex_medal"))]]
    end
end

function EHIManager:update(t, dt)
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:update(t, dt)
    end
end

function EHIManager:destroy()
    for _, tracker in pairs(self._trackers) do
        tracker:destroy()
    end
    if alive(self._ws) then
        if _G.IS_VR then
            Overlay:gui():destroy_workspace(self._ws)
        else
            managers.gui_data:destroy_workspace(self._ws)
        end
        self._ws = nil
    end
end

function EHIManager:SyncTime(time)
    --EHI:Log("Synced Heist time: " .. tostring(time))
    self._sync_time = time
    self._sync_real_time = Application:time()
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:Sync(time)
    end
end

function EHIManager:AddTracker(params, pos)
    if self._trackers[params.id] then
        EHI:Log("Tracker with ID '" .. tostring(params.id) .. "' exists! Traceback:")
        EHI:Log(debug.traceback())
        self._trackers[params.id]:delete()
    end
    if pos and self._n_of_trackers ~= 0 then
        local move = false
        local trackers_to_move = {}
        for key, tbl in pairs(self._trackers_pos) do
            if tbl.pos >= pos then
                move = true
                trackers_to_move[key] = tbl
            end
        end
        if move then
        else
            -- No tracker found on the provided pos
            -- Scrap this and create the tracker on the first available position
            pos = nil
        end
    else
        -- Received crap or no tracker exists
        pos = nil
    end
    params.parent_class = self
    params.x = self._x
    params.y = self:GetY(pos)
    params.scale = self._scale
    params.sync_time = self._sync_time
    params.sync_real_time = self._sync_real_time
    local class = self:GetClass(params.class)
    local tracker = class:new(self._hud_panel, params)
    if tracker._update then
        self._trackers_to_update[params.id] = tracker
    end
    self._trackers[params.id] = tracker
    self._trackers_pos[params.id] = { tracker = tracker, pos = pos or self._n_of_trackers }
    self._n_of_trackers = self._n_of_trackers + 1
end

-- Called by host only. Clients with EHI call EHIManager:AddTracker() when synced
function EHIManager:AddTrackerAndSync(params, id, delay)
    self:AddTracker(params)
    self:Sync(id, delay)
end

function EHIManager:Sync(id, delay)
    EHI:Sync(EHI.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
end

function EHIManager:AddPagerTracker(params)
    self._pager_trackers[params.id] = true
    self:AddTracker(params)
end

function EHIManager:RemovePager(id)
    self._pager_trackers[id] = nil
end

function EHIManager:RemovePagerTrackers()
    for key, _ in pairs(self._pager_trackers) do
        self:RemoveTracker(key)
    end
    self._pager_trackers = {}
end

function EHIManager:GetClass(class)
    class = class or "EHITracker"
    return _G[class]
end

function EHIManager:GetY(pos)
    pos = pos or self._n_of_trackers
    return self._y + (pos * (panel_size + panel_offset))
end

function EHIManager:AddTrackerToUpdate(id, tracker)
    self._trackers_to_update[id] = tracker
end

function EHIManager:RemoveTrackerFromUpdate(id)
    self._trackers_to_update[id] = nil
end

function EHIManager:GetTracker(id)
    if id then
        return self._trackers[id]
    end
    return nil
end

function EHIManager:RemoveTracker(id, remove_ref_only)
    if not remove_ref_only then
        local tracker = self._trackers[id]
        if tracker then
            tracker:delete()
        end
        return
    end
    self._trackers[id] = nil
    self._trackers_to_update[id] = nil
    local pos = self._trackers_pos[id].pos
    self._trackers_pos[id] = nil
    self._n_of_trackers = self._n_of_trackers - 1
    self:RearrangeTrackers(pos)
end

function EHIManager:RearrangeTrackers(pos)
    if not pos then
        return
    end
    for id, value in pairs(self._trackers_pos) do
        if value.pos > pos then
            local final_pos = value.pos - 1
            value.tracker:SetTop(self:GetY(final_pos))
            self._trackers_pos[id].pos = final_pos
        end
    end
end

function EHIManager:AddTrackerToUpdate(id, tracker)
    self._trackers_to_update[id] = tracker
end

function EHIManager:TrackerExists(id)
    return self._trackers[id] ~= nil
end

function EHIManager:TrackerDoesNotExist(id)
    return not self:TrackerExists(id)
end

function EHIManager:SetTrackerPaused(id, pause)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPause then
        tracker:SetPause(pause)
    end
end

function EHIManager:PauseTracker(id)
    self:SetTrackerPaused(id, true)
end

function EHIManager:UnpauseTracker(id)
    self:SetTrackerPaused(id, false)
end

function EHIManager:AddMoneyToTracker(id, money)
    local tracker = self._trackers[id]
    if tracker and tracker.AddMoney then
        tracker:AddMoney(money)
    end
end

function EHIManager:RemoveMoneyFromTracker(id, money)
    local tracker = self._trackers[id]
    if tracker and tracker.RemoveMoney then
        tracker:RemoveMoney(money)
    end
end

function EHIManager:AddXPToTracker(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.AddXP then
        tracker:AddXP(amount)
    end
end

function EHIManager:SetTrackerUpgradeable(id, upgradeable)
    local tracker = self._trackers[id]
    if tracker and tracker.SetUpgradeable then
        tracker:SetUpgradeable(upgradeable)
    end
end

function EHIManager:SetTrackerUpgrades(id, upgrades)
    local tracker = self._trackers[id]
    if tracker and tracker.SetUpgrades then
        tracker:SetUpgrades(upgrades)
    end
end

function EHIManager:SetTrackerTime(id, time)
    local tracker = self._trackers[id]
    if tracker and tracker.SetTime then
        tracker:SetTime(time)
    end
end

function EHIManager:SetTrackerTimeNoAnim(id, time)
    local tracker = self._trackers[id]
    if tracker and tracker.SetTimeNoAnim then
        tracker:SetTimeNoAnim(time)
    end
end

function EHIManager:SetTimerJammed(id, jammed)
    local tracker = self._trackers[id]
    if tracker and tracker.SetJammed then
        tracker:SetJammed(jammed)
    end
end

function EHIManager:SetTimerPowered(id, powered)
    local tracker = self._trackers[id]
    if tracker and tracker.SetPowered then
        tracker:SetPowered(powered)
    end
end

function EHIManager:ResetTrackerTime(id)
    local tracker = self._trackers[id]
    if tracker then
        tracker:ResetTime()
    end
end

function EHIManager:AddDelayToTracker(id, delay)
    local tracker = self._trackers[id]
    if tracker then
        tracker:AddDelay(delay)
    end
end

function EHIManager:AddToCache(id, data)
    self._cache[id] = data
end

function EHIManager:GetAndRemoveFromCache(id)
    local data = self._cache[id]
    self._cache[id] = nil
    return data
end

function EHIManager:IncreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseChance then
        tracker:IncreaseChance(amount)
    end
end

function EHIManager:DecreaseChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.DecreaseChance then
        tracker:DecreaseChance(amount)
    end
end

function EHIManager:SetChance(id, amount)
    local tracker = self._trackers[id]
    if tracker and tracker.SetChance then
        tracker:SetChance(amount)
    end
end

function EHIManager:SetTrackerProgress(id, progress)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgress then
        tracker:SetProgress(progress)
    end
end

function EHIManager:SetTrackerIncreaseProgress(id)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgress then
        tracker:IncreaseProgress()
    end
end

function EHIManager:SetTrackerProgressMax(id, max)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressMax then
        tracker:SetProgressMax(max)
    end
end

function EHIManager:SetTrackerTextColor(id, color)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTextColor(color)
    end
end

function EHIManager:SetTrackerAccurate(id, time)
    local tracker = self._trackers[id]
    if tracker then
        tracker:SetTrackerAccurate(time)
    end
end

function EHIManager:AddAggregatedHealthTracker()
    self:AddTracker({
        id = "Health",
        ids = { "doctor_bag", "first_aid_kit" },
        icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } },
        dont_show_placed = { first_aid_kit = true },
        class = "EHIAggregatedEquipmentTracker"
    })
end

function EHIManager:SetFailedAchievement(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetFailed then
        tracker:SetFailed()
    end
end

function EHIManager:CallFunction(id, f, ...)
    local tracker = self._trackers[id]
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHI", function(sender, id, data)
    if id == EHI.SyncMessages.EHISyncAddTracker then
        local tbl = LuaNetworking:StringToTable(data)
        EHI:AddTrackerSynced(tonumber(tbl.id), tonumber(tbl.delay))
    end
end)