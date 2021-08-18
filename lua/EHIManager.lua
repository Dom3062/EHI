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
    self._t = 0
    self._trackers = {}
    setmetatable(self._trackers, {__mode = "k"})
    self._stealth_trackers = { pagers = {}, lasers = {} }
    self._pager_trackers = {}
    self._laser_trackers = {}
    self._trackers_to_update = {}
    setmetatable(self._trackers_to_update, {__mode = "k"})
    self._trackers_pos = {}
    setmetatable(self._trackers_pos, {__mode = "k"})
    self._trade = {
        ai = false,
        normal = false
    }
    self._n_of_trackers = 0
    self._cache = { _deployables = {} }
    local x, y = managers.gui_data:safe_to_full(EHI:GetOption("x_offset"), EHI:GetOption("y_offset"))
    self._x = x
    self._y = y
    self._text_scale = EHI:GetOption("text_scale")
    self._level_started_from_beginning = true
    panel_size = panel_size * self._scale
    panel_offset = panel_offset * self._scale
end

function EHIManager:init_finalize()
    managers.network:add_event_listener("EHIDropIn", "on_set_dropin", callback(self, self, "DisableStartFromBeginning"))
    EHI:AddOnAlarmCallback(callback(self, self, "RemoveStealthTrackers"))
    EHI:AddOnAlarmCallback(callback(self, self, "DisableBodyBags"))
end

function EHIManager:ShowPanel()
    self._ws:show()
end

function EHIManager:HidePanel()
    self._ws:hide()
end

function EHIManager:LoadTime(t)
    self._t = t
end

function EHIManager:InteractionExists(tweak_data)
    local interactions = managers.interaction._interactive_units or {}
    for _, unit in pairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            return true
        end
    end
    return false
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
    return #self:GetUnits(path, slotmask)
end

function EHIManager:GetUnits(path, slotmask)
    local tbl = {}
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring then
            tbl[#tbl + 1] = unit
        end
    end
    return tbl
end

--[[
    Returns unit on provided (or first pos if not) position
]]
function EHIManager:GetUnit(path, slotmask, pos)
    return self:GetUnits(path, slotmask)[pos or 1]
end

function EHIManager:CountLootbagsAvailable(path, loot_type, slotmask)
    slotmask = slotmask or 14
    local count = 0
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring and unit:carry_data() and unit:carry_data():carry_id() == loot_type then
            count = count + 1
        end
    end
    return count
end

function EHIManager:save(data)
    if self._level_started_from_beginning or true then
        return
    end
    local state = {}
    for key, tracker in pairs(self._trackers) do
        -- Load all trackers not excluded from the sync
        if not tracker._exclude_from_sync then
            state[key] = {}
            state[key].time = tracker._time
            state[key].floors = tracker._floors
            state[key].money = tracker._money
            state[key].chance = tracker._chance
            state[key].max = tracker._max
            state[key].dont_flash = tracker._flash
            state[key].flash_times = tracker._flash_times
            state[key].remove_after_reaching_target = tracker._remove_after_reaching_counter_target
            state[key].status_is_overridable = tracker._status_is_overridable
            state[key].status = tracker._status
            state[key].icons = tracker._icons
            state[key].paused = tracker._paused
            state[key].class = tracker._class
        end
    end
    -- Custody Time is synced separately
    if self:TrackerExists("CustodyTime") then
        local tracker = self:GetTracker("CustodyTime")
        state.CustodyTime = { peers = {} }
        for peer_id, time in pairs(tracker._peer_custody_time) do
            state.CustodyTime.peers[peer_id] = {}
            state.CustodyTime.peers[peer_id].time = time
        end
        for peer_id, in_custody in pairs(tracker._peer_in_custody) do
            state.CustodyTime.peers[peer_id].in_custody = in_custody
        end
        state.CustodyTime.ai_trade = tracker._ai_trade
        state.CustodyTime.trade = tracker._trade
    end
    -- Vault tracker in Meltdown
    if self:TrackerExists("VaultTimeToOpen") then
        local tracker = self:GetTracker("VaultTimeToOpen")
        state.VaultTimeToOpen =
        {
            time = tracker._time,
            n_of_crowbars = tracker._n_of_crowbars
        }
    end
    data.EHIManager = state
end

function EHIManager:load(data)
    if data.EHIManager then
        local state = data.EHIManager
        if state.CustodyTime and EHI:GetOption("show_trade_delay") then
            self:AddCustodyTimeTracker()
            for peer_id, peer_info in pairs(state.CustodyTime.peers) do
                self:CallFunction("CustodyTime", "AddPeerCustodyTime", peer_id, peer_info.time)
                if peer_info.in_custody then
                    self:CallFunction("CustodyTime", "SetPeerInCustody", peer_id)
                end
            end
            local tick = managers.trade:GetTradeCounterTick()
            self:SetTrade("ai", state.CustodyTime.ai_trade, tick)
            self:SetTrade("normal", state.CustodyTime.trade, tick)
        end
        state.CustodyTime = nil
        if state.VaultTimeToOpen then
            self:AddTracker({
                id = "VaultTimeToOpen",
                class = "EHIVaultTemperatureTracker"
            })
            self:SetTrackerTime("VaultTimeToOpen", state.VaultTimeToOpen.time)
            if state.VaultTimeToOpen.n_of_crowbars > 0 then
                self:CallFunction("VaultTimeToOpen", "SetNumberOfCrowbars", state.VaultTimeToOpen.n_of_crowbars)
                self:AddTrackerToUpdate("VaultTimeToOpen", self:GetTracker("VaultTimeToOpen"))
            end
            state.VaultTimeToOpen = nil
        end
        for key, tracker_data in pairs(state) do
            self:AddTracker({
                id = key,
                time = tracker_data.time,
                floors = tracker_data.floors,
                money = tracker_data.money,
                chance = tracker_data.chance,
                max = tracker_data.max,
                dont_flash = tracker_data.dont_flash,
                flash_times = tracker_data.flash_times,
                remove_after_reaching_target = tracker_data.remove_after_reaching_target,
                status_is_overridable = tracker_data.status_is_overridable,
                status = tracker_data.status,
                icons = tracker_data.icons,
                paused = tracker_data.paused,
                class = tracker_data.class
            })
        end
        self.synced_from_host = true
    end
end

function EHIManager:LoadSync()
    if self._level_started_from_beginning or self.synced_from_host then
        return
    end
    local level_id = Global.game_settings.level_id
    local difficulty = Global.game_settings.difficulty
    local show_achievement = EHI:GetOption("show_achievement")
    if level_id == "pbr2" then -- Birth of Sky
        self:SetTrackerProgressRemaining("voff_4", self:CountInteractionAvailable("ring_band"))
        --[[if show_achievement and EHI:IsOVKOrAbove(difficulty) then
            self:AddTimedAchievementTracker("jerry_4", 83)
        end]]
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
    elseif level_id == "mus" then -- The Diamond
        if show_achievement then
            self:AddTimedAchievementTracker("bat_4", 600)
        end
    elseif level_id == "dark" then -- Murky Station
        if show_achievement then
            self:AddTimedAchievementTracker("dark_2", 420)
        end
    elseif level_id == "chew" then -- The Biker Heist Day 2
        if show_achievement then
            self:AddTimedAchievementTracker("born_5", 120)
        end
    elseif level_id == "big" then -- The Big Bank
        if show_achievement and EHI:DifficultyToIndex(difficulty) >= 1 then -- Hard or above
            self:AddTimedAchievementTracker("bigbank_4", 720)
        end
    elseif level_id == "red2" then -- First World Bank
        if show_achievement and managers.groupai:state():whisper_mode() then
            self:AddTimedAchievementTracker("green_3", 817)
        end
    elseif level_id == "fish" then -- The Yacht Heist
        if show_achievement and EHI:IsOVKOrAbove(difficulty) then
            self:AddTimedAchievementTracker("fish_4", 360)
        end
    elseif level_id == "kenaz" then -- Golden Grin Casino
        if show_achievement then
            self:AddTimedAchievementTracker("kenaz_4", 840)
        end
    elseif level_id == "cage" then -- Car Shop
        if show_achievement then
            self:AddTimedAchievementTracker("fort_4", 240)
        end
    elseif level_id == "ukrainian_job" then -- Ukrainian Job
        if show_achievement then
            self:AddTimedAchievementTracker("lets_do_this", 36)
        end
    elseif level_id == "chas" then -- Dragon Heist
        if show_achievement and EHI:IsOVKOrAbove(difficulty) then
            self:AddTimedAchievementTracker("chas_11", 360)
        end
    elseif level_id == "nmh" then -- No Mercy
        local units = self:GetUnits("units/pd2_dlc_nmh/props/nmh_prop_counter/nmh_prop_counter", 1)
        for _, unit in ipairs(units or {}) do
            local o = unit:digital_gui()
            if o and (o._timer_count_down or o._timer_paused) then
                self:AddTracker({
                    floors = o._timer - 4,
                    id = "EscapeElevator",
                    icons = { "pd2_door" },
                    class = "EHIElevatorTimerTracker"
                })
                if o._timer_paused then
                    self:CallFunction("EscapeElevator", "SetPause", true)
                end
                break
            end
        end
    elseif level_id == "man" then -- Undercover
        -- Achievement count used planks on windows, vents, ...
        -- There are total 49 positions and 10 planks
        self:SetTrackerProgressRemaining("man_4", 49 - self:CountInteractionAvailable("stash_planks"))
        if managers.groupai:state():whisper_mode() then
            self:AddAchievementNotificationTracker("man_3")
        end
    elseif level_id == "arm_for" then -- Transport: Train Heist
        if managers.groupai:state():whisper_mode() then
            self:AddAchievementNotificationTracker("armored_6")
        end
    end
end

function EHIManager:DisableStartFromBeginning()
    self._level_started_from_beginning = false
end

function EHIManager:update(t, dt)
    for _, tracker in pairs(self._trackers_to_update) do
        tracker:update(t, dt)
    end
    managers.hud:UpdateTrackerWaypoints(t, dt)
end

function EHIManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(self._t, dt)
end

function EHIManager:destroy()
    for _, tracker in pairs(self._trackers) do
        tracker:destroy(true)
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

function EHIManager:AddInvisibleTracker(params)
    params.panel_visible = false
    self:AddTracker(params)
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
                    tbl.tracker:SetTop(self:GetY(tbl.pos), self:GetY(final_pos))
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
    local class = params.class or "EHITracker"
    local tracker = _G[class]:new(self._hud_panel, params)
    tracker:SetPanelVisible()
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
    self._stealth_trackers.pagers[params.id] = true
    self:AddTracker(params)
end

function EHIManager:AddLaserTracker(params)
    for id, _ in pairs(self._stealth_trackers.lasers) do
        -- Don't add this tracker if the "next_cycle_t" is the same as time to prevent duplication
        local tracker = self:GetTracker(id)
        if tracker and tracker._next_cycle_t == params.time then
            return
        end
    end
    self._stealth_trackers.lasers[params.id] = true
    self:AddTracker(params)
end

function EHIManager:GetAchievementIcon(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and achievement.icon_id
end

function EHIManager:AddTimedAchievementTracker(id, time_max, icon)
    local t = time_max - self._t
    if EHI:IsAchievementUnlocked(id) or t <= 0 then
        return
    end
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        time = t,
        icons = { icon },
        class = "EHIAchievementTracker"
    })
end

function EHIManager:AddAchievementProgressTracker(id, max, exclude_from_sync, remove_after_reaching_target, icon)
    if EHI:IsAchievementUnlocked(id) then
        return
    end
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        max = max,
        icons = { icon },
        exclude_from_sync = exclude_from_sync,
        remove_after_reaching_target = remove_after_reaching_target,
        class = "EHIAchievementProgressTracker"
    })
end

function EHIManager:AddAchievementNotificationTracker(id, status, icon)
    if EHI:IsAchievementUnlocked(id) then
        return
    end
    icon = icon or self:GetAchievementIcon(id)
    self:AddTracker({
        id = id,
        status = status,
        icons = { icon },
        class = "EHIAchievementNotificationTracker"
    })
end

function EHIManager:RemovePager(id)
    self._stealth_trackers.pagers[id] = nil
end

function EHIManager:RemoveLaser(id)
    self._stealth_trackers.lasers[id] = nil
end

function EHIManager:RemoveStealthTrackers()
    for _, trackers in pairs(self._stealth_trackers) do
        for key, _ in pairs(trackers) do
            self:RemoveTracker(key)
        end
    end
end

function EHIManager:DisableBodyBags()
    self:CallFunction("Deployables", "AddToIgnore", "bodybags_bag")
    self._deployables_ignore = { bodybags_bag = true }
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
            value.tracker:SetTop(self:GetY(value.pos), self:GetY(final_pos))
            self._trackers_pos[id].pos = final_pos
        end
    end
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

function EHIManager:SetTimerDone(id)
    local tracker = self._trackers[id]
    if tracker and tracker.SetDone then
        tracker:SetDone()
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
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    self._cache._deployables[type][key] = { unit = unit, tracker_type = tracker_type }
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
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    if self._cache._deployables[type][key] then
        if self:TrackerDoesNotExist(type) then
            self:CreateDeployableTracker(type)
        end
        local deployable = self._cache._deployables[type][key]
        local unit = deployable.unit
        local tracker = self:GetTracker(type)
        if tracker then
            if deployable.tracker_type then
                tracker:UpdateAmount(deployable.tracker_type, unit, key, unit:base():GetRealAmount())
            else
                tracker:UpdateAmount(unit, key, unit:base():GetRealAmount())
            end
        end
        self._cache._deployables[type][key] = nil
    end
end

function EHIManager:RemoveFromDeployableCache(type, key)
    if not key then
        return
    end
    self._cache._deployables[type] = self._cache._deployables[type] or {}
    self._cache._deployables[type][key] = nil
end

function EHIManager:CreateDeployableTracker(type)
    if type == "Deployables" then
        self:AddAggregatedDeployablesTracker()
    elseif type == "Health" then
        self:AddAggregatedHealthTracker()
    elseif type == "DoctorBags" then
        self:AddTracker({
            id = "DoctorBags",
            icons = { "doctor_bag" },
            exclude_from_sync = true,
            class = "EHIEquipmentTracker"
        })
    elseif type == "AmmoBags" then
        self:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            exclude_from_sync = true,
            class = "EHIEquipmentTracker"
        })
    elseif type == "FirstAidKits" then
        self:AddTracker({
            id = "FirstAidKits",
            icons = { "first_aid_kit" },
            dont_show_placed = true,
            exclude_from_sync = true,
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

function EHIManager:IncreaseTrackerProgressMax(id)
    local tracker = self._trackers[id]
    if tracker and tracker.IncreaseProgressMax then
        tracker:IncreaseProgressMax()
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

function EHIManager:AddAggregatedDeployablesTracker()
    self:AddTracker({
        id = "Deployables",
        ids = { "doctor_bag", "ammo_bag", "grenade_crate", "first_aid_kit", "bodybags_bag" },
        icons = { "deployables" },
        dont_show_placed = { first_aid_kit = true },
        ignore = self._deployables_ignore or {},
        format = { ammo_bag = "percent" },
        exclude_from_sync = true,
        class = "EHIAggregatedEquipmentTracker"
    })
end

function EHIManager:AddAggregatedHealthTracker()
    self:AddTracker({
        id = "Health",
        ids = { "doctor_bag", "first_aid_kit" },
        icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } },
        dont_show_placed = { first_aid_kit = true },
        exclude_from_sync = true,
        class = "EHIAggregatedHealthEquipmentTracker"
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
        exclude_from_sync = true,
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