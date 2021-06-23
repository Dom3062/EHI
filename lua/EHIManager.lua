local EHI = EHI
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
    self._laser_trackers = {}
    self._trackers_to_update = {}
    self._trackers_pos = {}
    self._trade = {
        ai = false,
        normal = false,
        t = nil
    }
    self._n_of_trackers = 0
    self._cache = {}
    self._deployable_cache = {}
    self._sync_time = 0
    self._sync_real_time = Application:time()
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    self._text_scale = EHI:GetOption("text_scale")
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

function EHIManager:CountInteractionAvailable(tweak_data)
    local interactions = managers.interaction._interactive_units or {}
    local count = 0
    for _, unit in pairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            count = count + 1
        end
    end
    return count
end

function EHIManager:CountUnitAvailable(path, slotmask)
    local count = 0
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring then
            count = count + 1
        end
    end
    return count
end

function EHIManager:load()
    if Global.statistics_manager.playing_from_start then
        return
    end
    local level_id = Global.game_settings.level_id
    if level_id == "pbr2" then -- Birth of Sky
        self:SetTrackerProgressRemaining("voff_4", self:CountInteractionAvailable("ring_band"))
    elseif level_id == "pex" then -- Breakfast in Tijuana
        --[[
            There are total 12 places where medals can appears
            -- 11 places are on the first floor (6 randomly selected)
            -- last place is in the locker room (instance)
            Game sync all used places. When a medal is picked up, it is removed from the world
            and not synced to other drop-in players

            Can't use function "CountInteractionAvailable" because the medal in the locker room is not interactable first
            This is more accurate and reliable
        ]]
        self:SetTrackerProgressRemaining("pex_11", self:CountUnitAvailable("units/pd2_dlc_pex/props/pex_props_federali_chief_medal/pex_props_federali_chief_medal", 1) - 5)
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
    if pos and type(pos) == "number" and self._n_of_trackers ~= 0 then
        local move = false
        for _, tbl in pairs(self._trackers_pos) do
            if tbl.pos >= pos then
                move = true
                break
            end
        end
        if move then
            for id, tbl in pairs(self._trackers_pos) do
                if tbl.pos >= pos then
                    local final_pos = tbl.pos + 1
                    tbl.tracker:SetTop(self:GetY(final_pos))
                    self._trackers_pos[id].pos = final_pos
                end
            end
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
    params.text_scale = self._text_scale
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

function EHIManager:AddLaserTracker(params)
    for id, _ in pairs(self._laser_trackers) do
        -- Don't add this tracker if the "next_cycle_t" is the same as time to prevent duplication
        local tracker = self:GetTracker(id)
        if tracker and tracker._next_cycle_t == params.time then
            return
        end
    end
    self._laser_trackers[params.id] = true
    self:AddTracker(params)
end

function EHIManager:AddAchievementProgressTracker(id, max, icon)
    if EHI:IsAchievementUnlocked(id) then
        return
    end
    self:AddTracker({
        id = id,
        max = max,
        icons = { icon },
        class = "EHIAchievementProgressTracker"
    })
end

function EHIManager:RemovePager(id)
    self._pager_trackers[id] = nil
end

function EHIManager:RemoveLaser(id)
    self._laser_trackers[id] = nil
end

function EHIManager:RemovePagerTrackers()
    for key, _ in pairs(self._pager_trackers) do
        self:RemoveTracker(key)
    end
    self._pager_trackers = {}
end

function EHIManager:RemoveLaserTrackers()
    for key, _ in pairs(self._laser_trackers) do
        self:RemoveTracker(key)
    end
    self._laser_trackers = {}
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
    return id and self._trackers[id]
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

function EHIManager:SetTimerUpgrades(id, upgrades)
    local tracker = self._trackers[id]
    if tracker and tracker.SetUpgrades then
        tracker:SetUpgrades(upgrades)
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

function EHIManager:AddToDeployableCache(type, key, unit, tracker_type)
    if not key then
        return
    end
    self._deployable_cache[type] = self._deployable_cache[type] or {}
    self._deployable_cache[type][key] = { unit = unit, tracker_type = tracker_type }
    local tracker = self:GetTracker(type)
    if tracker then
        if tracker_type then
            tracker:UpdateAmount(tracker_type, unit, key, 0)
        else
            tracker:UpdateAmount(unit, key, 0)
        end
    end
end

function EHIManager:LoadFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployable_cache[type] = self._deployable_cache[type] or {}
    if self._deployable_cache[type][key] then
        if self:TrackerDoesNotExist(type) then
            self:CreateDeployableTracker(type)
        end
        local deployable = self._deployable_cache[type][key]
        local unit = deployable.unit
        local tracker = self:GetTracker(type)
        if tracker then
            if deployable.tracker_type then
                tracker:UpdateAmount(deployable.tracker_type, unit, key, unit:base():GetRealAmount())
            else
                tracker:UpdateAmount(unit, key, unit:base():GetRealAmount())
            end
        end
        self._deployable_cache[type][key] = nil
    end
end

function EHIManager:RemoveFromDeployableCache(type, key)
    if not key then
        return
    end
    self._deployable_cache[type] = self._deployable_cache[type] or {}
    self._deployable_cache[type][key] = nil
end

function EHIManager:CreateDeployableTracker(type)
    if type == "Health" then
        self:AddAggregatedHealthTracker()
    elseif type == "DoctorBags" then
        self:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        managers.ehi:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            class = "EHIEquipmentTracker"
        })
    end
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

function EHIManager:IncreaseTrackerProgress(id)
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

function EHIManager:SetTrackerProgressRemaining(id, remaining)
    local tracker = self._trackers[id]
    if tracker and tracker.SetProgressRemaining then
        tracker:SetProgressRemaining(remaining)
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

function EHIManager:SetAchievementComplete(id, force)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCompleted then
        tracker:SetCompleted(force)
    end
end

function EHIManager:SetFailedAchievement(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetFailed then
        tracker:SetFailed()
    end
end

function EHIManager:SetAchievementStatus(id, status)
    local tracker = self._trackers[id]
    if tracker and tracker.SetStatus then
        tracker:SetStatus(status)
    end
end

function EHIManager:SetTrackerCount(id, count)
    local tracker = self._trackers[id]
    if tracker and tracker.SetCount then
        tracker:SetCount(count)
    end
end

function EHIManager:AddCustodyTimeTracker()
    self:AddTracker({
        id = "CustodyTime",
        icons = { "mugshot_in_custody" },
        class = "EHICiviliansKilledTracker"
    })
end

function EHIManager:AddCustodyTimeTrackerAndAddPeerCustodyTime(peer_id, time)
    self:AddCustodyTimeTracker()
    self:CallFunction("CustodyTime", "AddPeerCustodyTime", peer_id, time)
    if self._trade.normal or self._trade.ai then
        local f = self._trade.normal and "SetTrade" or "SetAITrade"
        self:CallFunction("CustodyTime", f, true, managers.trade:GetTradeCounterTick(), true)
    end
end

function EHIManager:SetTrade(type, pause, t)
    self._trade[type] = pause
    local f = type == "normal" and "SetTrade" or "SetAITrade"
    self:CallFunction("CustodyTime", f, pause, t)
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