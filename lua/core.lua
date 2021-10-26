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

    OnAlarmCallback = {},

    _base_delay = {},
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
        TriggerIfEnabled = 13,
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
        SetTimeNoAnimOrCreateTrackerClient = 26,
        SetTrackerAccurate = 27,
        RemoveTriggers = 28,
        SetAchievementStatus = 29,
        ShowAchievementFromStart = 30,
        SetAchievementFailed = 31,
        SetRandomTime = 32,
        SetProgressMax = 33,
        DecreaseChance = 34,
        GetElementTimerAccurate = 35,
        UnpauseOrSetTimeByPreplanning = 36,
        UnpauseTrackerIfExistsAccurate = 37,
        ShowAchievementCustom = 38,
        FinalizeAchievement = 39,
        RemoveTriggerAndShowAchievementFromStart = 40,
        ExecuteAchievementIfInteractionExists = 41,
        IncreaseChanceFromElement = 42,
        DecreaseChanceFromElement = 43,
        SetChanceFromElement = 44,
        SetChanceFromElementWhenTrackerExists = 45,
        PauseTrackerWithTime = 46,
        RemoveTriggerAndShowAchievementCustom = 47,
        IncreaseProgressMax = 48,
        AddTrackerIfDoesNotExistElementHostCheckOnly = 49,
        IncreaseChanceFromElementSpecify = 50,
        ShowWaypoint = 51,
        ShowEHIWaypoint = 52,

        AddToGlobalAndExecute = 99998, -- REMOVE ME
        Debug = 100000,
        CustomCode = 100001,
        CustomCodeIfEnabled = 100002
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
        Trophy = "milestone_trophy",
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
        Lasers = "C_Dentist_H_BigBank_Entrapment",
        Money = "equipment_plates",
        Phone = "pd2_phone",
        Keycard = "equipment_bank_manager_key"
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
local EHI = _G.EHI
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

function EHI:Log(s)
    log("[EHI] " .. (s or "nil"))
end

function EHI:LogTraceback()
    log("[EHI] " .. debug.traceback())
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
        text_scale = 1,
        scale = 1,
        vr_scale = 2.5,
        time_format = 2,
        tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal

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
        show_trade_delay_suppress_in_stealth = true,
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
        show_equipment_ecmjammer = true,
        show_equipment_ecmfeedback = true,
        show_equipment_aggregate_health = true,
        show_equipment_aggregate_all = false,
        equipment_color =
        {
            doctor_bag =
            {
                r = 255,
                g = 0,
                b = 0
            },
            ammo_bag =
            {
                r = 255,
                g = 255,
                b = 0
            },
            grenade_crate =
            {
                r = 0,
                g = 255,
                b = 0
            },
            first_aid_kit =
            {
                r = 255,
                g = 102,
                b = 102
            },
            bodybags_bag =
            {
                r = 51,
                g = 204,
                b = 255
            }
        },
        show_minion_tracker = true,
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_enemy_count_tracker = true,
        show_laser_tracker = false,

        -- Waypoints
        show_waypoints = true,
        show_waypoints_only = false,
        show_waypoints_present_timer = 2,
        show_waypoints_enemy_turret = true,
        show_waypoints_timers = true,
        show_waypoints_pager = true
    }
    self:Log("Default values loaded")
end

function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:GetEquipmentOption(equipment)
    if equipment and self.settings.equipment_color[equipment] then
        return self:GetColor(self.settings.equipment_color[equipment])
    end
    return Color.white
end

function EHI:GetWaypointOption(waypoint)
    return self:GetOption("show_waypoints") and self:GetOption(waypoint)
end

function EHI:GetColor(color)
    if color and color.r and color.g and color.b then
        return Color(255, color.r, color.g, color.b) / 255
    end
    return Color.white
end

function EHI:AddOnAlarmCallback(f)
    self.OnAlarmCallback[#self.OnAlarmCallback + 1] = f
end

function EHI:RunOnAlarmCallbacks(dropin)
    for _, callback in pairs(self.OnAlarmCallback) do
        callback(dropin)
    end
    self.OnAlarmCallback = {}
end

function EHI:Hook(object, func, post_call)
    self:HookWithID(object, func, "EHI_" .. func, post_call)
end

function EHI:HookWithID(object, func, id, post_call)
    Hooks:PostHook(object, func, id, post_call)
end

function EHI:PreHook(object, func, pre_call)
    Hooks:PreHook(object, func, "EHI_Pre_" .. func, pre_call)
end

function EHI:HookElement(object, func, id, post_call)
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
    end
    return color
end

function EHI:GetInstanceElementID(id, start_index, continent_index)
    return (continent_index or 100000) + math.mod(id, 100000) + 30000 + start_index
end

function EHI:GetInstanceUnitID(id, start_index, continent_index)
    return self:GetInstanceElementID(id, start_index, continent_index)
end

function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math.floor(n / bracket + sign * 0.5) * bracket
end

function EHI:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(1, message, data or "")
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
                time = trigger.delay_only and delay or ((trigger.time or 0) + delay),
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
    self:Log(debug.traceback())
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

function EHI:IsOneXPElementHeist(level_id)
    return table.contains({
            "four_stores",
            "nightclub",
            "jewelry_store",
            "ukrainian_job",
            "election_day_1",
            "election_day_2",
            "election_day_3",
            "election_day_3_skip1",
            "election_day_3_skip2",
            "alex_1",
            "alex_2",
            "alex_3",
            "firestarter_2",
            "firestarter_3",
            "branchbank",
            "branchbank_gold",
            "branchbank_cash",
            "branchbank_deposit",
            "haunted",
            "safehouse",
            "short1_stage1",
			"short1_stage2",
            "short2_stage1",
			"short2_stage2b",
            "arm_cro",
            "arm_fac",
            "arm_hcm",
            "arm_par",
            "arm_und",
            "escape_cafe",
            "escape_cafe_day",
            "escape_garage",
            "escape_overpass",
            "escape_park",
            "escape_park_day",
            "escape_street"
        }, level_id)
end

function EHI:GetAchievementIcon(id)
    local achievement = tweak_data.achievement.visual[id]
    if achievement then
        return { achievement.icon_id }
    end
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
                self:Log("key: " .. tostring(key) .. " does not have element to hook!")
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
    if triggers[id].waypoint then
        managers.ehi_waypoint:AddWaypoint(triggers[id].id, triggers[id].waypoint)
    end
end

function EHI:AddTracker(id, sync)
    local trigger = triggers[id]
    managers.ehi:AddTracker({
        id = trigger.id,
        time = self:GetTime(id),
        chance = trigger.chance,
        max = trigger.max,
        dont_flash = trigger.dont_flash,
        dont_flash_max = trigger.dont_flash_max,
        flash_times = trigger.flash_times,
        remove_after_reaching_target = trigger.remove_after_reaching_target,
        status_is_overridable = trigger.status_is_overridable,
        status = trigger.status,
        to_secure = trigger.to_secure,
        icons = trigger.icons,
        class = trigger.class
    })
    if sync then
        managers.ehi:Sync(id, self:GetTime(id))
    end
    if trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.data)
    end
end

function EHI:AddTrackerAndSync(id, delay)
    managers.ehi:AddTrackerAndSync({
        id = host_triggers[id].id,
        time = (host_triggers[id].time or 0) + (delay or 0),
        icons = host_triggers[id].icons,
        class = host_triggers[id].class
    }, id, delay)
    if host_triggers[id].waypoint then
        managers.ehi_waypoint:AddWaypoint(host_triggers[id].id, host_triggers[id].data)
    end
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
            local t = (element._timer or 0) + (triggers[id].additional_time or 0)
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

local function PauseTracker(id)
    managers.ehi:PauseTracker(id)
    managers.ehi_waypoint:PauseWaypoint(id)
end

local function UnpauseTracker(id)
    managers.ehi:UnpauseTracker(id)
    managers.ehi_waypoint:UnpauseWaypoint(id)
end

local function RemoveTracker(id)
    managers.ehi:RemoveTracker(id)
    managers.ehi_waypoint:RemoveWaypoint(id)
end

function EHI:Trigger(id, element, enabled)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.ehi:AddMoneyToTracker(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    UnpauseTracker(triggers[id].id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:ResetTrackerTime(triggers[id].id)
                    UnpauseTracker(triggers[id].id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:SetAchievementComplete(triggers[id].id, true)
            elseif f == SF.AddToCache then
                self._cache[triggers[id].id] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = self._cache[triggers[id].id]
                self._cache[triggers[id].id] = nil
                triggers[id].icons[1] = data.icon
                self:CheckCondition(id)
            elseif f == SF.ReplaceTrackerWithTracker then
                RemoveTracker(triggers[id].data.id)
                if triggers[id].data.trigger then
                    UnhookTrigger(self, triggers[id].data.trigger) -- Removes trigger from the list, used in The White House
                end
                self:CheckCondition(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.TriggerIfEnabled then
                if enabled then
                    for _, trigger in pairs(triggers[id].data) do
                        self:Trigger(trigger)
                    end
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
                    managers.ehi:SetTrackerTime(triggers[id].id, triggers[id].time)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    RemoveTracker(tracker)
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
                managers.hud:IncreaseTrackerWaypointProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTrackerClient then
                local value = managers.ehi:ReturnValue(triggers[id].id, "GetTrackerType")
                if value ~= "accurate" then
                    if value then
                        managers.ehi:SetTrackerTimeNoAnim(triggers[id].id, self:GetTime(id))
                    else
                        self:CheckCondition(id)
                    end
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
            elseif f == SF.SetAchievementStatus then
                managers.ehi:SetAchievementStatus(triggers[id].id, triggers[id].status or "ok")
            elseif f == SF.ShowAchievementFromStart then
                if Global.statistics_manager.playing_from_start then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementFailed then
                managers.ehi:SetAchievementFailed(triggers[id].id)
            elseif f == SF.SetRandomTime then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:AddTrackerWithRandomTime(id)
                end
            elseif f == SF.SetProgressMax then
                managers.ehi:SetTrackerProgressMax(triggers[id].id, triggers[id].max)
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
                    UnpauseTracker(triggers[id].id)
                else
                    GetElementTimer(self, id)
                end
            elseif f == SF.ShowAchievementCustom then
                if self:IsAchievementLocked(triggers[id].data) then
                    self:CheckCondition(id)
                end
            elseif f == SF.FinalizeAchievement then
                managers.ehi:CallFunction(triggers[id].id, "Finalize")
            elseif f == SF.RemoveTriggerAndShowAchievementFromStart then
                if Global.statistics_manager.playing_from_start and self:IsAchievementLocked(triggers[id].id) then
                    self:CheckCondition(id)
                end
                UnhookTrigger(self, id)
            elseif f == SF.ExecuteAchievementIfInteractionExists then
                if self:IsAchievementLocked(triggers[id].id) and managers.ehi:InteractionExists(triggers[id].data) then
                    self:CheckCondition(id)
                end
            elseif f == SF.IncreaseChanceFromElement then
                managers.ehi:IncreaseChance(triggers[id].id, element._values.chance)
            elseif f == SF.DecreaseChanceFromElement then
                managers.ehi:DecreaseChance(triggers[id].id, element._values.chance)
            elseif f == SF.SetChanceFromElement then
                managers.ehi:SetChance(triggers[id].id, element._values.chance)
            elseif f == SF.SetChanceFromElementWhenTrackerExists then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, element._values.chance)
                else
                    trigger.chance = element._values.chance
                    self:CheckCondition(id)
                end
            elseif f == SF.PauseTrackerWithTime then
                PauseTracker(triggers[id].id)
                managers.ehi:SetTrackerTimeNoAnim(triggers[id].id, triggers[id].time)
                managers.ehi_waypoint:SetWaypointTime(triggers[id].id, triggers[id].time)
            elseif f == SF.RemoveTriggerAndShowAchievementCustom then
                if self:IsAchievementLocked(triggers[id].data) then
                    self:CheckCondition(id)
                end
                UnhookTrigger(self, id)
            elseif f == SF.IncreaseProgressMax then
                managers.ehi:IncreaseTrackerProgressMax(triggers[id].id)
            elseif f == SF.AddTrackerIfDoesNotExistElementHostCheckOnly then
                if Network:is_server() and element._values.counter_target == 0 then
                    if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                        self:CheckCondition(id)
                    end
                else
                    if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                        self:CheckCondition(id)
                    end
                end
            elseif f == SF.IncreaseChanceFromElementSpecify then
                local e = managers.mission:get_element_by_id(triggers[id].element)
                if e then
                    managers.ehi:IncreaseChance(triggers[id].id, e._values.chance)
                end
            elseif f == SF.ShowWaypoint then
                if triggers[id].delay then
                    EHI:DelayCall("EHI_" .. triggers[id].id, triggers[id].delay, function()
                        managers.hud:add_waypoint(triggers[id].id, triggers[id].data)
                    end)
                    return
                end
                managers.hud:add_waypoint(triggers[id].id, triggers[id].data)
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                triggers[id].f()
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    triggers[id].f()
                end

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
                managers.ehi:RemoveTracker(triggers[id].data.id)
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

            -- ElementCounterFilter
            elseif f == SF.HOX2_CheckOkValueHostCheckOnly then
                local continue = false
                if Network:is_server() then
                    if element:_values_ok() then
                        continue = true
                    end
                else
                    continue = true
                end
                if continue then
                    if managers.ehi:TrackerExists(triggers[id].id) then
                        managers.ehi:SetTrackerProgress(triggers[id].id, triggers[id].data.progress)
                    elseif not triggers[id].data.dont_create then
                        self:CheckCondition(id)
                        managers.ehi:SetTrackerProgress(triggers[id].id, triggers[id].data.progress)
                    end
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
                    self:CheckCondition(1011480)
                end
            elseif f == SF.KOSUGI_DisableTriggerAndExecute then
                UnhookTrigger(self, triggers[id].data.id)
                self:CheckCondition(id)
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
            elseif f == SF.SAND_ExecuteIfProgressMatch then
                local tracker = managers.ehi:GetTracker("sand_9_buttons")
                if tracker and tracker:GetProgress() == triggers[id].data then
                    managers.ehi:RemoveTracker("sand_9_buttons")
                    managers.ehi:SetAchievementFailed("sand_9")
                end
            end
        else
            self:CheckCondition(id)
        end
    end
end

function EHI:InitElements()
    local function Client(element, ...)
        self:Trigger(element._id, element, true)
    end
    local function Host(element, ...)
        self:Trigger(element._id, element, element._values.enabled)
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
                    self:HookElement(element, func, id, f)
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
                    self._base_delay[id] = element._calc_base_delay
                    element._calc_base_delay = function (e, ...)
                        local delay = self._base_delay[e._id](e, ...)
                        self:AddTrackerAndSync(e._id, delay)
                        return delay
                    end
                end
            end
        end
        for id, _ in pairs(element_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._element_delay[id] = element._calc_element_delay
                    element._calc_element_delay = function (e, params, ...)
                        local delay = self._element_delay[e._id](e, params, ...)
                        if element_delay_triggers[e._id][params.id] then
                            if host_triggers[params.id] then
                                if host_triggers[params.id].remove_trigger_when_executed then
                                    element_delay_triggers[e._id][params.id] = nil
                                elseif host_triggers[params.id].set_time_when_tracker_exists then
                                    if managers.ehi:TrackerExists(host_triggers[params.id].id) then
                                        managers.ehi:SetTrackerTimeNoAnim(host_triggers[params.id].id, delay)
                                        self:Sync(self.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
                                    else
                                        self:AddTrackerAndSync(params.id, delay)
                                    end
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

function EHI:SyncLoad()
    local function Client(element, ...)
        self:Trigger(element._id, element, true)
    end
    local scripts = managers.mission._scripts or {}
    for _, id in pairs(self.HookOnLoad) do
        for _, script in pairs(scripts) do
            local element = script:element(id)
            if element then
                self:HookElement(element, "client_on_executed", id, Client)
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

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_EHI", function(sender, id, data)
    if id == EHI.SyncMessages.EHISyncAddTracker then
        local tbl = LuaNetworking:StringToTable(data)
        EHI:AddTrackerSynced(tonumber(tbl.id), tonumber(tbl.delay))
    end
end)

EHI:Load()

if EHI:GetOption("hide_unlocked_achievements") then
    local G = Global
    function EHI:IsAchievementUnlocked(achievement)
        local a = G.achievment_manager.achievments[achievement]
        return a and a.awarded
    end
else -- Always show trackers for achievements
    function EHI:IsAchievementUnlocked(achievement)
        return false
    end
end

function EHI:IsAchievementLocked(achievement)
    return not self:IsAchievementUnlocked(achievement) and not self._cache.AreAchievementsDisabled
end

function EHI:GetAchievementProgress(achievement)
    return managers.achievment:get_stat(achievement) or 0
end

-- Used for achievements that has in the description "Kill X enemies in an heist" and etc... to show them only once
-- This is done to prevent tracker spam if the player decides to replay the same heist with a similar weapon or weapon category
-- Once the achievement has been awarded, the achievement will no longer show on the screen
function EHI:IsAchievementLocked2(achievement)
    local a = Global.achievment_manager.achievments[achievement]
    return a and not a.awarded
end

if EHI.debug then -- For testing purposes
    function EHI:IsAchievementLocked2(achievement)
        return true
    end
end