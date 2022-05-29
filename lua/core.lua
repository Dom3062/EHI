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
    DisableOnLoad = {},

    LootCounter =
    {
        CheckType =
        {
            AllLoot = 1, -- Currently unused
            BagsOnly = 2,
            ValueOfBags = 3,
            SmallLootOnly = 4, -- Currently unused
            ValueOfSmallLoot = 5,
            OneTypeOfLoot = 6
        }
    },

    _cache =
    {
        MissionUnits = {},
        InstanceUnits = {},
        IgnoreWaypoints = {},
        ElementWaypointFunction = {}
    },

    Callback = {},

    OnAlarmCallback = {},
    OnCustodyCallback = {},
    AchievementCounter = {},

    _base_delay = {},
    _element_delay = {},

    SyncMessages =
    {
        EHISyncAddTracker = "EHISyncAddTracker"
    },

    SpecialFunctions =
    {
        RemoveTracker = 2,
        PauseTracker = 3,
        UnpauseTracker = 4,
        UnpauseTrackerIfExists = 5,
        AddTrackerIfDoesNotExist = 7,
        SetAchievementComplete = 8,
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
        DecreaseChance = 34,
        GetElementTimerAccurate = 35,
        UnpauseOrSetTimeByPreplanning = 36,
        UnpauseTrackerIfExistsAccurate = 37,
        ShowAchievementCustom = 38,
        FinalizeAchievement = 39,
        RemoveTriggerAndShowAchievementFromStart = 40,
        IncreaseChanceFromElement = 42,
        DecreaseChanceFromElement = 43,
        SetChanceFromElement = 44,
        SetChanceFromElementWhenTrackerExists = 45,
        PauseTrackerWithTime = 46,
        RemoveTriggerAndShowAchievementCustom = 47,
        IncreaseProgressMax = 48,
        SetTimeIfLoudOrStealth = 49,
        ShowWaypoint = 51,
        ShowEHIWaypoint = 52,
        RemoveTriggerAndStartAchievementCountdown = 53,
        DecreaseProgress = 54,

        Debug = 100000,
        CustomCode = 100001,
        CustomCodeIfEnabled = 100002,

        -- Don't use it directly! Instead, call "EHI:GetFreeCustomSpecialFunctionID()" and "EHI:RegisterCustomSpecialFunction()" respectively
        CustomSF = 1000
    },

    SFF = {},

    ConditionFunctions =
    {
        IsLoud = function()
            return managers.groupai and not managers.groupai:state():whisper_mode()
        end,
        IsStealth = function()
            return managers.groupai and managers.groupai:state():whisper_mode()
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
        Keycard = "equipment_bank_manager_key",
        Power = "pd2_power",
        Drill = "pd2_drill",
        Alarm = "C_Bain_H_GOBank_IsEverythingOK",
        Water = "pd2_water_tap",
        Blimp = "blimp",

        EndlessAssault = { { icon = "padlock", color = Color(1, 0, 0) } },
        CarLootDrop = { "pd2_car", "pd2_lootdrop" },
        CarEscape = { "pd2_car", "pd2_escape", "pd2_lootdrop" },
        CarEscapeNoLoot = { "pd2_car", "pd2_escape" },
        CarWait = { "pd2_car", "pd2_escape", "pd2_lootdrop", "faster" },
        HeliEscape = { "heli", "pd2_escape", "pd2_lootdrop" },
        HeliEscapeNoLoot = { "heli", "pd2_escape" },
        HeliLootDrop = { "heli", "pd2_lootdrop" },
        HeliDropDrill = { "heli", "pd2_drill", "pd2_goto" },
        HeliDropBag = { "heli", "wp_bag", "pd2_goto" },
        HeliDropC4 = { "heli", "pd2_c4", "pd2_goto" },
        BoatEscape = { "boat", "pd2_escape", "pd2_lootdrop" }
    },

    Trackers =
    {
        MallcrasherMoney = "EHIMoneyCounterTracker",
        Warning = "EHIWarningTracker",
        Pausable = "EHIPausableTracker",
        Chance = "EHIChanceTracker",
        Progress = "EHIProgressTracker",
        Achievement = "EHIAchievementTracker",
        AchievementDone = "EHIAchievementDoneTracker",
        AchievementUnlock = "EHIAchievementUnlockTracker",
        AchievementProgress = "EHIAchievementProgressTracker",
        AchievementNotification = "EHIAchievementNotificationTracker",
        AchievementBagValueTracker = "EHIAchievementBagValueTracker",
        AchievementTimedProgressTracker = "EHIAchievementTimedProgressTracker",
        AchievementTimedMoneyCounterTracker = "EHIAchievementTimedMoneyCounterTracker",
        AssaultDelay = "EHIAssaultDelayTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
    },

    AchievementTrackers =
    {
        EHIAchievementTracker = true,
        EHIAchievementDoneTracker = true,
        EHIAchievementUnlockTracker = true,
        EHIAchievementProgressTracker = true,
        EHIAchievementObtainableTracker = true,
        EHIAchievementNotificationTracker = true,
        EHIAchievementBagValueTracker = true,
        EHIAchievementTimedProgressTracker = true,
        EHIAchievementTimedMoneyCounterTracker = true
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

    difficulty_remap = {
        very_hard = "overkill",
        overkill = "overkill_145",
        mayhem = "easy_wish",
        death_wish = "overkill_290",
        death_sentence = "sm_wish"
    },

    HostElement = "on_executed",
    ClientElement = "client_on_executed",

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

function EHI:IsDifficultyOrAbove(difficulty)
    return self:DifficultyToIndex(self:DifficultyName(difficulty)) <= self._cache.DifficultyIndex
end

function EHI:IsDifficultyOrBelow(difficulty)
    return self:DifficultyToIndex(self:DifficultyName(difficulty)) >= self._cache.DifficultyIndex
end

function EHI:DifficultyName(difficulty)
    return self.difficulty_remap[difficulty] or difficulty
end

function EHI:IsDifficulty(difficulty)
    return self._cache.Difficulty == self:DifficultyName(difficulty)
end

function EHI:IsBetweenDifficulties(diff_1, diff_2)
    local diff_1_index = self:DifficultyToIndex(self:DifficultyName(diff_1))
    local diff_2_index = self:DifficultyToIndex(self:DifficultyName(diff_2))
    if diff_1_index > diff_2_index then
        diff_1_index = diff_1_index - diff_2_index
        diff_2_index = diff_1_index + diff_2_index
        diff_1_index = diff_2_index - diff_1_index
    end
    return self._cache.DifficultyIndex >= diff_1_index and self._cache.DifficultyIndex <= diff_2_index
end

function EHI:Init()
    self._cache.Difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
    self._cache.DifficultyIndex = self:DifficultyToIndex(self._cache.Difficulty)
    self._cache.Host = Network:is_server()
    self._cache.Client = not self._cache.Host
end

function EHI:Log(s)
    log("[EHI] " .. (s or "nil"))
end

---Works the same way as EHI:Log(), but the string is not saved on HDD
---@param s any
function EHI:LogFast(s)
    io.stdout:write("[EHI] " .. (s or "nil") .. "\n")
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
        -- Menu Only
        show_preview_text = true,

        -- Common
        x_offset = 0,
        y_offset = 150,
        text_scale = 1,
        scale = 1,
        vr_scale = 2.5,
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal

        -- Visuals
        show_tracker_bg = true,
        show_one_icon = false,

        -- Trackers
        show_mission_trackers = true,
        show_achievement = true,
        hide_unlocked_achievements = true,
        show_achievement_failed_popup = true,
        show_gained_xp = true,
        xp_format = 3,
        xp_panel = 1,
        total_xp_show_difference = true,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_trade_delay_suppress_in_stealth = true,
        show_timers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        gage_tracker_panel = 1,
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
        show_minion_per_player = true,
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
        show_waypoints_pager = true,
        show_waypoints_cameras = true,
        show_waypoints_zipline = true,

        -- Buffs
        show_buffs = true,
        buffs_x_offset = 0,
        buffs_y_offset = 80,
        buffs_alignment = 2, -- 1 = Left; 2 = Center; 3 = Right
        buffs_scale = 1,
        buffs_shape = 1, -- 1 = Square; 2 = Circle
        buffs_show_progress = true,
        buffs_invert_progress = false
    }
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

function EHI:IsXPTrackerDisabled()
    if not self:GetOption("show_gained_xp") then
        return true
    end
    if Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree" then
        return true
    end
    return false
end

function EHI:AddCallback(id, f)
    self.Callback[id] = self.Callback[id] or {}
    self.Callback[id][#self.Callback[id] + 1] = f
end

function EHI:CallCallback(id)
    for _, callback in ipairs(self.Callback[id] or {}) do
        callback()
    end
end

function EHI:AddOnAlarmCallback(f)
    self.OnAlarmCallback[#self.OnAlarmCallback + 1] = f
end

---@param dropin boolean
function EHI:RunOnAlarmCallbacks(dropin)
    for _, callback in ipairs(self.OnAlarmCallback) do
        callback(dropin)
    end
    self.OnAlarmCallback = {}
end

function EHI:AddOnCustodyCallback(f)
    self.OnCustodyCallback[#self.OnCustodyCallback + 1] = f
end

function EHI:RunOnCustodyCallback(state)
    for _, callback in ipairs(self.OnCustodyCallback) do
        callback(state)
    end
end

---@param object table
---@param func string
---@param post_call function
function EHI:Hook(object, func, post_call)
    self:HookWithID(object, func, "EHI_" .. func, post_call)
end

---@param object table
---@param func string
---@param id string
---@param post_call function
function EHI:HookWithID(object, func, id, post_call)
    Hooks:PostHook(object, func, id, post_call)
end

---@param object table
---@param func string
---@param pre_call function
function EHI:PreHook(object, func, pre_call)
    self:PreHookWithID(object, func, "EHI_Pre_" .. func, pre_call)
end

---@param object table
---@param func string
---@param id string
---@param pre_call function
function EHI:PreHookWithID(object, func, id, pre_call)
    Hooks:PreHook(object, func, id, pre_call)
end

---@param object table
---@param func string
---@param id string
---@param post_call function
function EHI:HookElement(object, func, id, post_call)
    Hooks:PostHook(object, func, "EHI_Element_" .. id, post_call)
end

---@param id string
function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

---@param id string
function EHI:UnhookElement(id)
    Hooks:RemovePostHook("EHI_Element_" .. id)
end

---@return boolean
function EHI:ShowDramaTracker()
    return self:GetOption("show_drama_tracker") and self._cache.Host
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

---@param id number
---@param start_index number
---@param continent_index number
---@return number
function EHI:GetInstanceElementID(id, start_index, continent_index)
    return (continent_index or 100000) + math.mod(id, 100000) + 30000 + start_index
end

---@param id number
---@param start_index number
---@param continent_index number
---@return number
function EHI:GetInstanceUnitID(id, start_index, continent_index)
    return self:GetInstanceElementID(id, start_index, continent_index)
end

---@param final_index number
---@param start_index number
---@param continent_index number
---@return number
function EHI:GetBaseUnitID(final_index, start_index, continent_index)
    return (final_index - 30000 - start_index - continent_index) + 100000
end

local math_floor = math.floor
function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math_floor(n / bracket + sign * 0.5) * bracket
end

function EHI:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

--[[
    Instance Vector = Instance Position
    Element Vector = Position of the element in the instance
    Rotation = Instance Rotation
]]
function EHI:GetInstanceElementPosition(instance_vector, element_vector, rotation)
    return instance_vector + element_vector:rotate_with(rotation)
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

function EHI:DebugEquipment(tracker_id, unit, key, amount, peer_id)
    self:Log("Received garbage. Key is nil. Tracker ID: " .. tostring(tracker_id))
    self:Log("unit: " .. tostring(unit))
    if unit and alive(unit) then
        self:Log("unit:name(): " .. tostring(unit:name()))
        self:Log("unit:key(): " .. tostring(unit:key()))
    end
    self:Log("key: " .. tostring(key))
    self:Log("amount: " .. tostring(amount))
    if peer_id then
        self:Log("Peer ID: " .. tostring(peer_id))
    end
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

---@param level_id string
---@return boolean
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
            "firestarter_1",
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
            "escape_overpass_night",
            "escape_park",
            "escape_park_day",
            "escape_street"
        }, level_id)
end

---@param id string
---@return table
function EHI:GetAchievementIcon(id)
    local achievement = tweak_data.achievement.visual[id]
    if achievement then
        return { achievement.icon_id }
    end
end

---@param id string
---@return string
function EHI:GetAchievementIconString(id)
    local achievement = tweak_data.achievement.visual[id]
    if achievement then
        return achievement.icon_id
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

---@param id number
---@param trigger table
local function AddTracker(id, trigger)
    local trigger_table = trigger
    trigger_table.time = EHI:GetTime(id)
    managers.ehi:AddTracker(trigger_table)
end

---@param id number
---@return number
function EHI:GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.rand(triggers[id].random_time) or 0)
    return full_time
end

---@param id number
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

---@param id number
function EHI:AddTracker(id)
    local trigger = triggers[id]
    AddTracker(id, trigger)
    if trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param id number
---@param delay number
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

---@param id number
function EHI:CheckConditionFunction(id)
    if triggers[id].condition_function then
        if triggers[id].condition_function() then
            self:AddTracker(id)
        end
    else
        self:AddTracker(id)
    end
end

---@param id number
function EHI:CheckCondition(id)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            self:CheckConditionFunction(id)
        end
    else
        self:CheckConditionFunction(id)
    end
end

local function GetElementTimer(self, id)
    if self._cache.Host then
        local element = managers.mission:get_element_by_id(triggers[id].element)
        if element then
            local t = (element._timer or 0) + (triggers[id].additional_time or 0)
            triggers[id].time = t
            self:CheckCondition(id)
            managers.ehi:Sync(id, t)
        end
    else
        self:CheckCondition(id)
    end
end

---@param id number
function EHI:UnhookTrigger(id)
    self:UnhookElement(id)
    triggers[id] = nil
end

---@param id string
local function PauseTracker(id)
    managers.ehi:PauseTracker(id)
    managers.ehi_waypoint:PauseWaypoint(id)
end

---@param id string
local function UnpauseTracker(id)
    managers.ehi:UnpauseTracker(id)
    managers.ehi_waypoint:UnpauseWaypoint(id)
end

---@param id string
local function RemoveTracker(id)
    managers.ehi:RemoveTracker(id)
    managers.ehi_waypoint:RemoveWaypoint(id)
end

---@param id number
---@param element table
---@param enabled boolean
function EHI:Trigger(id, element, enabled)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.RemoveTracker then
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
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:SetAchievementComplete(triggers[id].id, true)
            elseif f == SF.ReplaceTrackerWithTracker then
                RemoveTracker(triggers[id].data.id)
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
                self:UnhookTrigger(id)
            elseif f == SF.Trigger then
                for _, trigger in pairs(triggers[id].data) do
                    self:Trigger(trigger, element, enabled)
                end
            elseif f == SF.RemoveTrigger then
                self:UnhookTrigger(id)
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
                self:UnhookTrigger(id)
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(triggers[id].data.id) then
                    triggers[id].time = triggers[id].data.yes
                else
                    triggers[id].time = triggers[id].data.no
                end
                self:CheckCondition(id)
            elseif f == SF.IncreaseProgress then
                managers.ehi:IncreaseTrackerProgress(triggers[id].id)
                --managers.hud:IncreaseTrackerWaypointProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTrackerClient then
                local value = managers.ehi:ReturnValue(triggers[id].id, "GetTrackerType")
                if value ~= "accurate" then
                    if managers.ehi:TrackerExists(triggers[id].id) then
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
                    self:UnhookTrigger(trigger_id)
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
                    if triggers[id].data.cache_id then
                        self._cache[triggers[id].data.cache_id] = true
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
                self:UnhookTrigger(id)
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
                self:UnhookTrigger(id)
            elseif f == SF.IncreaseProgressMax then
                managers.ehi:IncreaseTrackerProgressMax(triggers[id].id)
            elseif f == SF.SetTimeIfLoudOrStealth then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        triggers[id].time = triggers[id].data.no
                    else -- Loud
                        triggers[id].time = triggers[id].data.yes
                    end
                    self:CheckCondition(id)
                end
            elseif f == SF.ShowWaypoint then
                managers.hud:add_waypoint(triggers[id].id, triggers[id].data)
            elseif f == SF.RemoveTriggerAndStartAchievementCountdown then
                managers.ehi:StartTrackerCountdown(triggers[id].id)
                self:UnhookTrigger(id)
            elseif f == SF.DecreaseProgress then
                managers.ehi:DecreaseTrackerProgress(triggers[id].id)
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                triggers[id].f()
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    triggers[id].f()
                end

            elseif f >= SF.CustomSF then
                self.SFF[f](id, triggers[id], element, enabled)
            end
        else
            self:CheckCondition(id)
        end
    end
end

---@param id number
---@param f function
function EHI:RegisterCustomSpecialFunction(id, f)
    self.SFF[id] = f
end

function EHI:GetFreeCustomSpecialFunctionID()
    local id = self.SpecialFunctions.CustomSF
    self._cache.SFFUsed = self._cache.SFFUsed or {}
    while true do
        if self._cache.SFFUsed[id] then
            id = id + 1
        else
            self._cache.SFFUsed[id] = true
            break
        end
    end
    return id
end

function EHI:InitElements()
    self:HookElements(triggers)
    if self._cache.Host then
        local scripts = managers.mission._scripts or {}
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
                                    self:AddTrackerAndSync(params.id, delay)
                                    element_delay_triggers[e._id][params.id] = nil
                                elseif host_triggers[params.id].set_time_when_tracker_exists then
                                    if managers.ehi:TrackerExists(host_triggers[params.id].id) then
                                        managers.ehi:SetTrackerTimeNoAnim(host_triggers[params.id].id, delay)
                                        self:Sync(self.SyncMessages.EHISyncAddTracker, LuaNetworking:TableToString({ id = id, delay = delay or 0 }))
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

function EHI:HookElements(elements_to_hook)
    local function Client(element, ...)
        self:Trigger(element._id, element, true)
    end
    local function Host(element, ...)
        self:Trigger(element._id, element, element._values.enabled)
    end
    local client = self._cache.Client
    local func = client and self.ClientElement or self.HostElement
    local f = client and Client or Host
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(elements_to_hook) do
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
                    self.HookOnLoad[id] = true
                end
            end
        end
    end
end

function EHI:SyncLoad()
    self:HookElements(self.HookOnLoad)
    self.HookOnLoad = {}
    self:DisableWaypoints(self.DisableOnLoad)
    self:DisableWaypointsOnInit()
    self.DisableOnLoad = {}
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

function EHI:ParseTriggers(mission_triggers, trigger_id_all, trigger_icons_all)
    if not self:GetOption("show_mission_trackers") then
        return
    end
    local show_achievement = self:GetOption("show_achievement")
    for id, data in pairs(mission_triggers) do
        -- Mark every tracker, that has random time, as inaccurate
        if data.random_time then
            if not data.class then
                mission_triggers[id].class = self.Trackers.Inaccurate
            elseif data.class ~= self.Trackers.InaccuratePausable and data.class == self.Trackers.Warning then
                mission_triggers[id].class = self.Trackers.InaccurateWarning
            end
        end
        -- Fill the rest table properties for Achievement trackers
        if data.class and self.AchievementTrackers[data.class] then
            if not data.special_function then
                mission_triggers[id].special_function = SF.ShowAchievement
            end
            if data.condition == nil then
                mission_triggers[id].condition = show_achievement
            end
            if not data.icons then
                mission_triggers[id].icons = self:GetAchievementIcon(mission_triggers[id].id)
            end
        end
        -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
        if data.special_function == SF.ShowWaypoint then
            mission_triggers[id].data.distance = true
            mission_triggers[id].data.state = "sneak_present"
            mission_triggers[id].data.present_timer = 0
            mission_triggers[id].data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
        end
    end
    self:AddTriggers(mission_triggers, trigger_id_all or "Trigger", trigger_icons_all or {})
end

function EHI:ShouldDisableWaypoints()
    return self:GetOption("show_timers") and self:GetWaypointOption("show_waypoints_timers")
end

local function HostWaypoint(self, instigator, ...)
    if not self._values.enabled then
        return
    end
    if self._values.only_on_instigator and instigator ~= managers.player:player_unit() then
        ElementWaypoint.super.on_executed(self, instigator)
        return
    end
    if not self._values.only_in_civilian or managers.player:current_state() == "civilian" then
        local text = managers.localization:text(self._values.text_id)
        managers.hud:AddWaypointSoft(self._id, {
            distance = true,
            state = "sneak_present",
            present_timer = 0,
            text = text,
            icon = self._values.icon,
            position = self._values.position
        })
    elseif managers.hud:get_waypoint_data(self._id) then
        managers.hud:remove_waypoint(self._id)
    end
    ElementWaypoint.super.on_executed(self, instigator)
end
function EHI:DisableElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id)
    if not element or self._cache.ElementWaypointFunction[id] then
        return
    end
    if self._cache.Host then
        self._cache.ElementWaypointFunction[id] = element.on_executed
        element.on_executed = HostWaypoint
    else
        self._cache.ElementWaypointFunction[id] = element.client_on_executed
        element.client_on_executed = function(...) end
    end
end

function EHI:RestoreElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id)
    if not (element and self._cache.ElementWaypointFunction[id]) then
        return
    end
    if self._cache.Host then
        element.on_executed = self._cache.ElementWaypointFunction[id]
    else
        element.client_on_executed = self._cache.ElementWaypointFunction[id]
    end
    self._cache.ElementWaypointFunction[id] = nil
end

function EHI:DisableWaypoints(waypoints)
    if not self:ShouldDisableWaypoints() then
        return
    end
    self.DisableOnLoad = waypoints
    for id, _ in pairs(waypoints) do
        self._cache.IgnoreWaypoints[id] = true
    end
end

function EHI:DisableWaypointsOnInit()
    for id, _ in pairs(self.DisableOnLoad) do
        self:DisableElementWaypoint(id)
    end
end

function EHI:ShowLootCounter(max, additional_loot, check_type, loot_type)
    managers.ehi:ShowLootCounter(max, additional_loot)
    if not self._cache.LootCounter then
        local function Hook(self, ...)
            self:EHIReportProgress("LootCounter", check_type or EHI.LootCounter.CheckType.BagsOnly, loot_type)
        end
        self:HookWithID(LootManager, "sync_secure_loot", "EHI_LootCounter_sync_secure_loot", Hook)
        self:HookWithID(LootManager, "sync_load", "EHI_LootCounter_sync_load", Hook)
        self._cache.LootCounter = true
    end
end

local show_achievement = false
function EHI:ShowAchievementLootCounter(params)
    if self._cache.AchievementsAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
        if params.show_loot_counter then
            self:ShowLootCounter(params.max, params.additional_loot)
        end
        return
    end
    managers.ehi:AddAchievementProgressTracker(params.achievement, params.max, params.additional_loot, params.exclude_from_sync, params.remove_after_reaching_target, params.show_loot_counter)
    if params.no_counting then
        return
    end
    self:AddAchievementToCounter(params)
end

function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.AchievementsAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
        return
    end
    managers.ehi:AddAchievementBagValueCounter(params.achievement, params.value, params.exclude_from_sync, params.remove_after_reaching_target)
    self:AddAchievementToCounter(params)
end

function EHI:AddAchievementToCounter(params)
    self.AchievementCounter[#self.AchievementCounter + 1] =
    {
        id = params.achievement,
        check_type = params.counter and params.counter.check_type or self.LootCounter.CheckType.BagsOnly,
        loot_type = params.counter and params.counter.loot_type,
        sync_only = params.sync_only
    }
    self:HookAchievementCounter()
end

function EHI:HookAchievementCounter()
    if not self.AchievementCounterHook then
        local function Hook(self, sync_load)
            for _, achievement in pairs(EHI.AchievementCounter) do
                if not achievement.sync_only or (achievement.sync_only and sync_load) then
                    self:EHIReportProgress(achievement.id, achievement.check_type, achievement.loot_type)
                end
            end
        end
        self:HookWithID(LootManager, "sync_secure_loot", "EHI_AchievementCounter_sync_secure_loot", function(self, ...)
            Hook(self, false)
        end)
        self:HookWithID(LootManager, "sync_load", "EHI_AchievementCounter_sync_load", function(self, ...)
            Hook(self, true)
        end)
        self.AchievementCounterHook = true
    end
end

function EHI:AddLoadSyncFunction(f)
    if self._cache.Host then
        return
    end
    managers.ehi:AddLoadSyncFunction(f)
end

--[[
    This is bad, rethink the call flow with parameters
]]
function EHI:UpdateUnits(tbl)
    if not self:GetOption("show_timers") then
        return
    end
    self:FinalizeUnits(tbl)
    for id, data in pairs(tbl) do
        self._cache.MissionUnits[id] = data
    end
end

---@param tbl table
---@param instance_start_index number
---@param instance_continent_index? number
function EHI:UpdateInstanceUnits(tbl, instance_start_index, instance_continent_index)
    if not self:GetOption("show_timers") then
        return
    end
    local new_tbl = {}
    for id, data in pairs(tbl) do
        local computed_id = self:GetInstanceElementID(id, instance_start_index, instance_continent_index)
        new_tbl[computed_id] = self:DeepClone(data)
        if new_tbl[computed_id].remove_vanilla_waypoint then
            new_tbl[computed_id].waypoint_id = self:GetInstanceElementID(new_tbl[computed_id].waypoint_id, instance_start_index, instance_continent_index)
        end
        new_tbl[computed_id].base_index = id
    end
    self:FinalizeUnits(new_tbl)
    for id, data in pairs(new_tbl) do
        self._cache.InstanceUnits[id] = data
    end
end

EHI:Load()

-- Hack
show_achievement = EHI:GetOption("show_achievement")

if EHI:GetWaypointOption("show_waypoints_only") then
    function EHI:AddTracker(id)
        local trigger = triggers[id]
        if trigger.waypoint then
            managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
        else
            AddTracker(id, trigger)
        end
    end
end

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
    return not self:IsAchievementUnlocked(achievement) and not self._cache.AchievementsAreDisabled
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

    function EHI:DebugInstance(instance_name)
        if self._cache.Client then
            self:Log("Instance debugging is only available when you are the host")
            return
        end
        local scripts = managers.mission._scripts or {}
        local instances = managers.world_instance:instance_data()
        for _, instance in ipairs(instances) do
            if instance.name == instance_name then
                PrintTableDeep(instance or {}, 5000, true, "[EHI]")
                local start = self:GetInstanceElementID(100000, instance.start_index)
                local _end = start + instance.index_size - 1
                local f = function(e, ...)
                    managers.hud:DebugBaseElement(e._id, instance.start_index, nil, e:editor_name())
                end
                self:Log(string.format("Hooking elements in instance '%s'", instance_name))
                for _, script in pairs(scripts) do
                    for i = start, _end, 1 do
                        local element = script:element(i)
                        if element then
                            self:HookWithID(element, self.HostElement, "EHI_Debug_Element_" .. tostring(i), f)
                        end
                    end
                end
                self:Log("Hooking done")
            end
        end
    end
end

function EHI:PrintTable(tbl)
    if _G.PrintTableDeep then
        _G.PrintTableDeep(tbl, 5000, true, "[EHI]")
    else
        _G.PrintTable(tbl)
    end
end