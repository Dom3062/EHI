if _G.EHI then
    _G.EHI = _G.EHI or {}
    return
end

_G.EHI =
{
    debug = false,
    settings = {},

    _hooks = {},

    _sync_triggers = {},

    HookOnLoad = {},

    _cache =
    {
    },

    _element_delay = {},

    SyncMessages =
    {
        EHISyncAddTracker = "EHISyncAddTracker"
    },

    SpecialFunctions =
    {
        AddMoney = 1,
        RemoveTracker = 2,
        PauseTracker = 3,
        UnpauseTracker = 4,
        UnpauseTrackerIfExists = 5,
        ResetTrackerTimeWhenUnpaused = 6,
        AddTrackerIfDoesNotExist = 7,
        SetAchievementComplete = 8,
        AddToCache = 9,
        GetFromCache = 10,
        ReplaceTrackerWithTracker = 11,
        IncreaseChance = 12,
        ExecuteIfTrackerExists = 13,
        CreateAnotherTrackerWithTracker = 14,
        SetChanceWhenTrackerExists = 15,
        RemoveTriggerWhenExecuted = 16,
        Trigger = 17,
        RemoveTrigger = 18,
        SetTimeOrCreateTracker = 19,
        ExecuteIfElementIsEnabled = 20,
        RemoveTrackers = 21,
        ShowAchievement = 22,
        RemoveTriggerAndShowAchievement = 23,
        SetTimeByPreplanning = 24,
        IncreaseProgress = 25,
        SetTimeNoAnimOrCreateTracker = 26,
        SetTrackerAccurate = 27,
        RemoveTriggers = 28,
        AddToGlobalCache = 29,
        GetFromGlobalCache = 30,
        SetAchievementFailed = 31,
        SetRandomTime = 32,
        SetProgressMax = 33,
        DecreaseChance = 34,
        GetElementTimerAccurate = 35,
        UnpauseOrSetTimeByPreplanning = 36,
        UnpauseTrackerIfExistsAccurate = 37,

        ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists = 99997, -- REMOVE ME
        AddToGlobalAndExecute = 99998, -- REMOVE ME
        UnpauseAndSetTime = 99999, -- REMOVE ME
        Debug = 100000,
        CustomCode = 100001
    },

    ConditionFunctions =
    {
        IsLoud = function()
            if managers.groupai and not managers.groupai:state():whisper_mode() then
                return true
            end
            return false
        end,
        IsStealth = function()
            if managers.groupai and managers.groupai:state():whisper_mode() then
                return true
            end
            return false
        end
    },

    Icons =
    {
        Trophy = "trophy",
        Fire = "pd2_fire",
        Escape = "pd2_escape",
        LootDrop = "pd2_lootdrop",
        Fix = "pd2_fix",
        Bag = "wp_bag",
        Defend = "pd2_defend",
        C4 = "pd2_c4",
        Interact = "pd2_generic_interact",
        Winch = "equipment_winch_hook",
        Teargas = "teargas",
        Hostage = "hostage",
        Methlab = "pd2_methlab",
        Loop = "restarter",
        Wait = "faster",
        Vault = "C_Elephant_H_ElectionDay_Murphy",
        Car = "pd2_car",
        Heli = "heli",
        Boat = "boat",
        Lasers = "C_Dentist_H_BigBank_Entrapment"
    },

    difficulties = {
        "easy", -- Leftover from PD:TH
        "normal",
        "hard",
        "overkill",
        "overkill_145",
        "easy_wish",
        "overkill_290",
        "sm_wish"
    },

    ModVersion = ModInstance and tonumber(ModInstance:GetVersion()) or "N/A",
    ModPath = ModPath,
    LocPath = ModPath .. "loc/",
    LuaPath = ModPath .. "lua/",
    MenuPath = ModPath .. "menu/",
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}

local SF = EHI.SpecialFunctions

function EHI:DifficultyToIndex(difficulty)
    return table.index_of(self.difficulties, difficulty) - 2
end

function EHI:IsOVKOrAbove(difficulty)
    return self:DifficultyToIndex(difficulty) >= 3
end

function EHI:GetIcons()
    return self.Icons
end

function EHI:GetConditionFunctions()
    return self.ConditionFunctions
end

function EHI:Log(s)
    log("[EHI] " .. (s or "nil"))
end

function EHI:Load()
    self:LoadDefaultValues()
    local file = io.open(self.SettingsSaveFilePath, "r")
    if file then
        local table = json.decode(file:read('*all')) or {}
        file:close()
        if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
            self:LoadValues(self.settings, table)
            self:Log("Loaded user settings")
        else
            self.SaveDataNotCompatible = true
            self:Save()
        end
    end
end

function EHI:Save()
    self.settings.SaveDataVer = self.SaveDataVer
    self.settings.ModVersion = self.ModVersion
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or {})
        file:close()
    end
end

function EHI:LoadValues(ehi_table, file_table)
    for k, v in pairs(file_table) do -- Load subtables in table and calls the same method to load subtables or values in that subtable
        if type(file_table[k]) == "table" and ehi_table[k] then
            self:LoadValues(ehi_table[k], v)
        end
    end
    for k, v in pairs(file_table) do
        if type(file_table[k]) ~= "table" then
            if ehi_table and ehi_table[k] ~= nil then -- Load values to the table
                ehi_table[k] = v
            end
        end
    end
end

function EHI:DelayCall(name, t, func)
    DelayedCalls:Add(name, t, func)
end

function EHI:LoadDefaultValues()
    self.settings =
    {
        -- Common
        x_offset = 0,
        y_offset = 150,
        scale = 1,
        vr_scale = 2.5,
        time_format = 2,

        -- Visuals
        show_tracker_bg = true,
        show_one_icon = false,

        -- Trackers
        show_achievement = true,
        hide_unlocked_achievements = true,
        show_gained_xp = true,
        xp_format = 3,
        xp_panel = 1,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_timers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        show_captain_damage_reduction = true,
        show_equipment_tracker = true,
        equipment_format = 1,
        show_equipment_doctorbag = true,
        show_equipment_ammobag = true,
        show_equipment_grenadecases = true,
        show_equipment_bodybags = true,
        show_equipment_firstaidkit = true,
        show_equipment_aggregate_health = true,
        show_minion_tracker = true,
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_enemy_count_tracker = true,
        show_laser_tracker = false
    }
    self:Log("Default values loaded")
end

function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:Hook(object, func, post_call)
    Hooks:PostHook(object, func, "EHI_" .. func, post_call)
end

function EHI:PreHook(object, func, pre_call)
    Hooks:PreHook(object, func, "EHI_Pre_" .. func, pre_call)
end

function EHI:ElementHook(object, func, id, post_call)
    Hooks:PostHook(object, func, "EHI_Element_" .. id, post_call)
end

function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

function EHI:UnhookElement(id)
    Hooks:RemovePostHook("EHI_Element_" .. id)
end

function EHI:ShowDramaTracker()
    return self:GetOption("show_drama_tracker") and Network:is_server()
end

function EHI:GetPeerColor(unit)
    local color = Color.white
    if unit then
        color = managers.criminals:character_color_id_by_unit(unit)
        color = tweak_data.chat_colors[color] or Color.white
    else
        self:Log("unit is nil, returned color set to white")
    end
    return color
end

function EHI:GetPeerColorByPeerID(peer_id)
    local color = Color.white
    if peer_id then
        color = tweak_data.chat_colors[peer_id] or Color.white
    else
        self:Log("peer_id is nil, returned color set to white")
    end
    return color
end

function EHI:GetInstanceElementID(id, start_index)
    return 100000 + math.mod(id, 100000) + 30000 + start_index
end

function EHI:GetInstanceUnitID(id, start_index)
    return self:GetInstanceElementID(id, start_index)
end

function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(LuaNetworking:LocalPeerID(), message, data or "")
end

function EHI:SetSyncTriggers(triggers)
    if self._sync_triggers then
        for key, value in pairs(triggers) do
            if self._sync_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in sync!")
            else
                self._sync_triggers[key] = self:DeepClone(value)
            end
        end
    else
        self._sync_triggers = self:DeepClone(triggers)
    end
end

function EHI:AddSyncTrigger(id, trigger)
    self:SetSyncTriggers({ [id] = trigger })
end

function EHI:GetTimeSynced(id, delay)
    if self._sync_triggers[id].delay_only then
        return delay
    else
        return (self._sync_triggers[id].time or 0) + delay
    end
end

function EHI:AddTrackerSynced(id, delay)
    if self._sync_triggers[id] and managers.ehi then
        local trigger = self._sync_triggers[id]
        local trigger_id = trigger.id
        if managers.ehi:TrackerExists(trigger_id) then
            if trigger.delay_only then
                managers.ehi:SetTrackerAccurate(trigger_id, delay)
            else
                managers.ehi:SetTrackerAccurate(trigger_id, (trigger.time or 0) + delay)
            end
        else
            managers.ehi:AddTracker({
                id = trigger_id,
                time = self:GetTimeSynced(id, delay),
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

function EHI:DebugEquipment(tracker_id, unit, key, amount)
    self:Log("Received garbage. Key is nil. Tracker ID: " .. tostring(tracker_id))
    self:Log("unit: " .. tostring(unit))
    if unit and alive(unit) then
        self:Log("unit:name(): " .. tostring(unit:name()))
        self:Log("unit:key(): " .. tostring(unit:key()))
    end
    self:Log("key: " .. tostring(key))
    self:Log("amount: " .. tostring(amount))
    self:Log("traceback: " .. debug.traceback())
end

function EHI:DeepClone(o) -- Copy of OVK's function deep_clone
    if type(o) == "userdata" then
		return o
	end

	local res = {}

	setmetatable(res, getmetatable(o))

	for k, v in pairs(o) do
		if type(v) == "table" then
			res[k] = self:DeepClone(v)
		else
			res[k] = v
		end
	end

	return res
end

local triggers = {}
local host_triggers = {}
local base_delay_triggers = {}
local element_delay_triggers = {}
function EHI:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            self:Log("key: " .. tostring(key) .. " already exists in triggers!")
        else
            triggers[key] = value
            if not value.id then
                triggers[key].id = trigger_id_all
            end
            if not value.icons then
                triggers[key].icons = trigger_icons_all
            end
        end
    end
end

function EHI:AddHostTriggers(new_triggers, trigger_id_all, trigger_icons_all, type)
    for key, value in pairs(new_triggers) do
        if host_triggers[key] then
            self:Log("key: " .. tostring(key) .. " already exists in host triggers!")
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
                self:Log("key: " .. tostring(key) .. " already exists in host base delay triggers!")
            else
                base_delay_triggers[key] = true
            end
        else
            if element_delay_triggers[key] then
                self:Log("key: " .. tostring(key) .. " already exists in host element delay triggers!")
            else
                element_delay_triggers[key] = true
            end
        end
    end
end

function EHI:GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.rand(triggers[id].random_time) or 0)
    return full_time
end

function EHI:AddTrackerWithRandomTime(id)
    managers.ehi:AddTracker({
        id = triggers[id].id,
        time = triggers[id].data[math.random(#triggers[id].data)],
        icons = triggers[id].icons,
        class = triggers[id].class
    })
end

function EHI:AddTracker(id, sync)
    local trigger = triggers[id]
    managers.ehi:AddTracker({
        id = trigger.id,
        time = self:GetTime(id),
        chance = trigger.chance,
        max = trigger.max,
        dont_flash = trigger.dont_flash,
        flash_times = trigger.flash_times,
        remove_after_reaching_target = trigger.remove_after_reaching_target,
        status_is_overridable = trigger.status_is_overridable,
        icons = trigger.icons,
        class = trigger.class
    })
    if sync then
        managers.ehi:Sync(id, self:GetTime(id))
    end
end

function EHI:AddTrackerAndSync(id, delay)
    managers.ehi:AddTrackerAndSync({
        id = host_triggers[id].id,
        time = (host_triggers[id].time or 0) + (delay or 0),
        icons = host_triggers[id].icons,
        class = host_triggers[id].class
    }, id, delay)
end

function EHI:CheckConditionFunction(id, sync)
    if triggers[id].condition_function then
        if triggers[id].condition_function() then
            self:AddTracker(id, sync)
        end
    else
        self:AddTracker(id, sync)
    end
end

function EHI:CheckCondition(id, sync)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            self:CheckConditionFunction(id, sync)
        end
    else
        self:CheckConditionFunction(id, sync)
    end
end

local function GetElementTimer(self, id)
    if Network:is_server() then
        local element = managers.mission:get_element_by_id(triggers[id].element)
        if element then
            local t = element._timer or 0
            triggers[id].time = t
            self:CheckCondition(id, true)
        end
    else
        self:CheckCondition(id)
    end
end

local function UnhookTrigger(self, id)
    self:UnhookElement(id)
    triggers[id] = nil
end

function EHI:Trigger(id, enabled)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.ehi:AddMoneyToTracker(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.ehi:RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                managers.ehi:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.ehi:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:ResetTrackerTime(triggers[id].id)
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:CallFunction(triggers[id].id, "SetCompleted", true)
            elseif f == SF.AddToCache then
                self._cache[triggers[id].id] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = self._cache[triggers[id].id]
                self._cache[triggers[id].id] = nil
                triggers[id].icons[1] = data.icon
                self:CheckCondition(id)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.ehi:RemoveTracker(triggers[id].data.id)
                if triggers[id].data.trigger then
                    UnhookTrigger(self, triggers[id].data.trigger) -- Removes trigger from the list, used in The White House
                end
                self:CheckCondition(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.ehi:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.ehi:RemoveTracker(data.id)
                end
            elseif f == SF.CreateAnotherTrackerWithTracker then
                self:CheckCondition(id)
                self:Trigger(triggers[id].data.fake_id)
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, trigger.chance)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                self:CheckCondition(id)
                UnhookTrigger(self, id)
            elseif f == SF.Trigger then
                for _, trigger in pairs(triggers[id].data) do
                    self:Trigger(trigger)
                end
            elseif f == SF.RemoveTrigger then
                UnhookTrigger(self, id)
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.ehi:RemoveTracker(tracker)
                end
            elseif f == SF.ShowAchievement then
                if self:IsAchievementLocked(triggers[id].id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggerAndShowAchievement then
                if self:IsAchievementLocked(triggers[id].id) then
                    self:CheckCondition(id)
                end
                UnhookTrigger(self, id)
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(triggers[id].data.id) then
                    triggers[id].time = triggers[id].data.yes
                else
                    triggers[id].time = triggers[id].data.no
                end
                self:CheckCondition(id)
            elseif f == SF.IncreaseProgress then
                managers.ehi:IncreaseTrackerProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:SetTimeNoAnim(triggers[id].id, self:GetTime(id))
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.SetTrackerAccurate then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:SetTrackerAccurate(triggers[id].id, triggers[id].time)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggers then
                for _, trigger_id in pairs(triggers[id].data) do
                    UnhookTrigger(self, trigger_id)
                end
            elseif f == SF.UnpauseAndSetTime then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.AddToGlobalAndExecute then
                -- REMOVE ME
                --self._cache.VanReturn = true
                --self:CheckCondition(id)
            elseif f == SF.SetAchievementFailed then
                managers.ehi:CallFunction(triggers[id].id, "SetFailed")
            elseif f == SF.SetRandomTime then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:AddTrackerWithRandomTime(id)
                end
            elseif f == SF.SetProgressMax then
                managers.ehi:SetTrackerProgressMax(triggers[id].id, triggers[id].max)
            elseif f == SF.ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists then
                -- REMOVE ME
                --[[managers.ehi:RemoveTracker(triggers[id].data.id)
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:CheckCondition(id)
                end]]
            elseif f == SF.DecreaseChance then
                local trigger = triggers[id]
                managers.ehi:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.GetElementTimerAccurate then
                GetElementTimer(self, id)
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    if triggers[id].data.cache_id and self._cache[triggers[id].data.cache_id] then
                        self:CheckCondition(id)
                        return
                    end
                    if managers.preplanning:IsAssetBought(triggers[id].data.id) then
                        triggers[id].time = triggers[id].data.yes
                    else
                        triggers[id].time = triggers[id].data.no
                    end
                    self:CheckCondition(id)
                end
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    GetElementTimer(self, id)
                end
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                triggers[id].f()

            -- MissionScriptElement
            elseif f == SF.NMH_LowerFloor then
                if enabled then
                    managers.ehi:CallFunction(triggers[id].id, "LowerFloor")
                end
            elseif f == SF.ED3_SetWhiteColorWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:SetTrackerTextColor(triggers[id].id, Color.white)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ED3_SetPausedColor then
                managers.ehi:SetTrackerTextColor(triggers[id].id, Color.red)
            elseif f == SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists then
                managers.hud:RemoveTracker(triggers[id].data.id)
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.WD2_SetTrackerAccurate then -- Used in Watchdogs D2
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:SetTrackerAccurate(triggers[id].id, triggers[id].time)
                elseif not (managers.ehi:TrackerExists(triggers[id].id2) or managers.ehi:TrackerExists(triggers[id].id3)) then
                    self:CheckCondition(id)
                end
            elseif f == SF.FRIEND_ExecuteIfElementIsEnabledAndRemoveTrigger then
                if enabled then
                    self:CheckCondition(id)
                    UnhookTrigger(self, id)
                end

            -- ElementTimerOperator
            elseif f == SF.WATCHDOGS_2_AddToCache then
                self._cache[triggers[id].id] = triggers[id].time
            elseif f == SF.WATCHDOGS_2_GetFromCache then
                local data = self._cache[triggers[id].id]
                self._cache[triggers[id].id] = nil
                if data then
                    triggers[id].time = data
                    self:CheckCondition(id)
                    triggers[id].time = nil
                else
                    self:Log("No time saved in cache for id " .. tostring(id) .. "! This happens when client connected after the time was saved.")
                    self:Log("Inaccurate timer created to represent the missing tracker.")
                    self:CheckCondition(1011480)
                end
            elseif f == SF.KOSUGI_DisableTriggerAndExecute then
                UnhookTrigger(self, triggers[id].data.id)
                self:CheckCondition(id)
            elseif f == SF.CROJOB3_PauseTrackerAndAddNewTracker then
                managers.ehi:PauseTracker(triggers[id].id)
                self:Trigger(triggers[id].data.fake_id)
            elseif f == SF.CROJOB3_SetTimeByElement then
                if triggers[id].data.cache_id and self._cache[triggers[id].data.cache_id] then
                    self:CheckCondition(id)
                    return
                end
                local element = managers.mission:get_element_by_id(triggers[id].data.id)
                if element then
                    if element:enabled() then
                        triggers[id].time = triggers[id].data.yes
                    else
                        triggers[id].time = triggers[id].data.no
                    end
                    if triggers[id].data.cache_id then
                        self._cache[triggers[id].data.cache_id] = true
                    end
                    self:CheckCondition(id)
                end
            elseif f == SF.MEX_CheckIfLoud then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        triggers[id].time = triggers[id].data.no
                    else -- Loud
                        triggers[id].time = triggers[id].data.yes
                    end
                    self:CheckCondition(id)
                end

            -- ElementInstanceOutputEvent
            elseif f == SF.MeltdownAddCrowbar then
                managers.ehi:CallFunction(triggers[id].id, "AddCrowbar")

            -- ElementAreaTrigger
            elseif f == SF.ALEX_1_SetTimeIfMoreThanOrCreateTracker then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    local tracker = managers.ehi:GetTracker(triggers[id].id)
                    if tracker then
                        if tracker._time >= triggers[id].time then
                            managers.ehi:SetTrackerTime(triggers[id].id, triggers[id].time)
                        end
                    else
                        self:CheckCondition(id)
                    end
                else
                    self:CheckCondition(id)
                end
                UnhookTrigger(self, id)
            end
        else
            self:CheckCondition(id)
        end
    end
end

function EHI:InitElements()
    local function Client(element, ...)
        self:Trigger(element._id, true)
    end
    local function Host(element, ...)
        self:Trigger(element._id, element._values.enabled)
    end
    local client = Network:is_client()
    local func = client and "client_on_executed" or "on_executed"
    local f = client and Client or Host
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(triggers) do
        if id >= 100000 and id <= 999999 then
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self:ElementHook(element, func, id, f)
                elseif client then
                    --[[
                        On client, the element was not found
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHI:SyncLoad())
                    ]]
                    self.HookOnLoad[#self.HookOnLoad + 1] = id
                end
            end
        end
    end
    if not client then
        for id, _ in pairs(base_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._element_delay[id] = element._calc_base_delay
                    element._calc_base_delay = function(e)
                        local delay = self._element_delay[e._id](e)
                        self:AddTrackerAndSync(e._id, delay)
                        return delay
                    end
                end
            end
        end
    end
end

function EHI:SyncLoad()
    local function Client(element, ...)
        self:Trigger(element._id, true)
    end
    local scripts = managers.mission._scripts or {}
    for _, id in pairs(self.HookOnLoad) do
        for _, script in pairs(scripts) do
            local element = script:element(id)
            if element then
                self:ElementHook(element, "client_on_executed", id, Client)
            end
        end
    end
    self.HookOnLoad = {}
end

Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHI", function(peer, peer_id, reason)
    if managers.ehi then
        managers.ehi:CallFunction("CustodyTime", "RemovePeerFromCustody", peer_id)
    end
end)

EHI:Load()

if EHI:GetOption("hide_unlocked_achievements") then
    function EHI:IsAchievementUnlocked(achievement)
        local a = managers.achievment.achievments[achievement]
        return a and a.awarded
    end
    function EHI:IsAchievementLocked(achievement)
        return not self:IsAchievementUnlocked(achievement)
    end
else -- Always show trackers for achievements
    function EHI:IsAchievementUnlocked(achievement)
        return false
    end
    function EHI:IsAchievementLocked(achievement)
        return true
    end
end