if _G.EHI then
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
            OneTypeOfLoot = 6,
            CustomCheck = 7,
            Debug = 8
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

    CallbackMessage =
    {
        Spawned = "PlayerSpawned"
    },

    OnAlarmCallback = {},
    OnCustodyCallback = {},
    AchievementCounter = {},
    KillCounter = {},

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
        IncreaseChanceFromElement = 42,
        DecreaseChanceFromElement = 43,
        SetChanceFromElement = 44,
        SetChanceFromElementWhenTrackerExists = 45,
        PauseTrackerWithTime = 46,
        RemoveTriggerAndShowAchievementCustom = 47,
        IncreaseProgressMax = 48,
        SetTimeIfLoudOrStealth = 49,
        AddTimeByPreplanning = 50,
        ShowWaypoint = 51,
        DecreaseProgressMax = 52,
        DecreaseProgress = 53,
        ShowTrophy = 54,

        Debug = 100000,
        CustomCode = 100001,
        CustomCodeIfEnabled = 100002,
        CustomCodeDelayed = 100003,

        -- Don't use it directly! Instead, call "EHI:GetFreeCustomSpecialFunctionID()" and "EHI:RegisterCustomSpecialFunction()" respectively
        CustomSF = 1000
    },

    SyncFunctions =
    {
        [35] = true, -- GetElementTimerAccurate
        [37] = true -- UnpauseTrackerIfExistsAccurate
    },

    TriggerFunction =
    {
        [13] = true, -- TriggerIfEnabled
        [17] = true -- Trigger
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
        Sentry = "wp_sentry",
        PCHack = "wp_hack",
        Glasscutter = "equipment_glasscutter",
        Loot = "pd2_loot",
        Goto = "pd2_goto",

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
        HeliWait = { "heli", "pd2_escape", "pd2_lootdrop", "faster" },
        BoatEscape = { "boat", "pd2_escape", "pd2_lootdrop" },
        BoatEscapeNoLoot = { "boat", "pd2_escape" }
    },

    Trackers =
    {
        MallcrasherMoney = "EHIMoneyCounterTracker",
        Warning = "EHIWarningTracker",
        Pausable = "EHIPausableTracker",
        Chance = "EHIChanceTracker",
        Counter = "EHICountTracker",
        Progress = "EHIProgressTracker",
        NeededValue = "EHINeededValueTracker",
        Achievement = "EHIAchievementTracker",
        AchievementDone = "EHIAchievementDoneTracker",
        AchievementUnlock = "EHIAchievementUnlockTracker",
        AchievementStatus = "EHIAchievementStatusTracker",
        AchievementProgress = "EHIAchievementProgressTracker",
        AchievementBagValue = "EHIAchievementBagValueTracker",
        AssaultDelay = "EHIAssaultDelayTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
        Trophy = "EHITrophyTracker",
        Daily = "EHIDailyTracker",
        DailyProgress = "EHIDailyProgressTracker"
    },

    AchievementTrackers =
    {
        EHIAchievementTracker = true,
        EHIAchievementDoneTracker = true,
        EHIAchievementUnlockTracker = true,
        EHIAchievementProgressTracker = true,
        EHIAchievementStatusTracker = true,
        EHIAchievementBagValueTracker = true
    },

    TrophyTrackers =
    {
        EHITrophyTracker = true
    },

    DailyTrackers =
    {
        EHIDailyTracker = true,
        EHIDailyProgressTracker = true
    },

    Difficulties =
    {
        Normal = 0,
        Hard = 1,
        VeryHard = 2,
        OVERKILL = 3,
        Mayhem = 4,
        DeathWish = 5,
        DeathSentence = 6
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
    local difficulties = {
        "easy", -- Leftover from PD:TH
        "normal",
        "hard",
        "overkill",
        "overkill_145",
        "easy_wish",
        "overkill_290",
        "sm_wish"
    }
    return table.index_of(difficulties, difficulty) - 2
end

function EHI:IsDifficultyOrAbove(difficulty)
    return difficulty <= self._cache.DifficultyIndex
end

function EHI:IsDifficultyOrBelow(difficulty)
    return difficulty >= self._cache.DifficultyIndex
end

function EHI:IsDifficulty(difficulty)
    return self._cache.DifficultyIndex == difficulty
end

function EHI:IsBetweenDifficulties(diff_1, diff_2)
    if diff_1 > diff_2 then
        diff_1 = diff_1 - diff_2
        diff_2 = diff_1 + diff_2
        diff_1 = diff_2 - diff_1
    end
    return self._cache.DifficultyIndex >= diff_1 and self._cache.DifficultyIndex <= diff_2
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
    local prefix = os.date("%I:%M:%S %p")
    io.stdout:write(prefix .. " Lua: [EHI] " .. (s or "nil") .. "\n")
end

function EHI:LogTraceback()
    log("[EHI] " .. debug.traceback())
end

function EHI:Load()
    self:LoadDefaultValues()
    local file = io.open(self.SettingsSaveFilePath, "r")
    if file then
        local table
        local success, _ = pcall(function()
            table = json.decode(file:read('*all'))
        end)
        file:close()
        if success then
            if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
                self:LoadValues(self.settings, table)
            else
                self.SaveDataNotCompatible = true
                self:Save()
            end
        else -- Save File got corrupted, use default values
            self._cache.SaveFileCorrupted = true
            self:Save() -- Resave the data
        end
    end
end

function EHI:Save()
    self.settings.SaveDataVer = self.SaveDataVer
    self.settings.ModVersion = self.ModVersion
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or "{}")
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
        vr_scale = 1,
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical, 2 = Horizontal

        -- Visuals
        show_tracker_bg = true,
        show_tracker_corners = true,
        show_one_icon = false,

        -- Trackers
        show_mission_trackers = true,
        show_unlockables = true,
        unlockables =
        {
            -- Achievements
            show_achievements = true,
            show_achievements_mission = true,
            hide_unlocked_achievements = true,
            show_achievements_weapon = true,
            show_achievements_melee = true,
            show_achievements_grenade = true,
            show_achievements_vehicle = true,
            show_achievements_other = true,
            show_achievement_failed_popup = true,
            show_achievement_started_popup = true,

            -- Trophies
            show_trophies = true,
            hide_unlocked_trophies = true,
            show_trophy_failed_popup = true,
            show_trophy_started_popup = true,

            -- Daily missions
            show_dailies = true,
            show_daily_failed_popup = true,
            show_daily_started_popup = true
        },
        show_gained_xp = true,
        xp_format = 3,
        xp_panel = 1,
        total_xp_show_difference = true,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_trade_delay_suppress_in_stealth = true,
        show_timers = true,
        show_camera_loop = true,
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
        show_minion_killed_message = true,
        show_minion_killed_message_type = 1, -- 1 = Popup; 2 = Hint
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_enemy_count_tracker = true,
        show_laser_tracker = false,
        show_assault_delay_tracker = true,
        show_loot_counter = true,
        show_all_loot_secured_popup = true,
        variable_random_loot_format = 3, -- 1 = Max-(Max+Random)?; 2 = MaxRandom?; 3 = Max+Random?
        show_bodybags_counter = false,
        show_escape_chance = true,

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
        buffs_invert_progress = false,
        buff_option =
        {
            -- Skills
            -- Mastermind
            inspire_basic = true,
            inspire_ace = true,
            uppers = true,
            uppers_range = true,
            uppers_range_refresh = 2, -- 1 / value
            quick_fix = true,
            painkillers = true,
            combat_medic = true,
            hostage_taker_muscle = true,
            forced_friendship = true,
            ammo_efficiency = true,
            aggressive_reload = true,
            -- Enforcer
            overkill = true,
            underdog = true,
            bullseye = true,
            bulletstorm = true,
            -- Ghost
            sixth_sense_initial = true,
            sixth_sense_marked = true,
            sixth_sense_refresh = true,
            second_wind = true,
            unseen_strike = true,
            -- Fugitive
            running_from_death_reload = true,
            running_from_death_movement = true,
            up_you_go = true,
            swan_song = true,
            bloodthirst = true,
            bloodthirst_reload = true,
            berserker = true,
            berserker_refresh = 4, -- 1 / value

            -- Perks
            infiltrator = true,
            gambler = true,
            grinder = true,
            maniac = true,
            anarchist = true, -- +Armorer
            biker = true,
            kingpin = true,
            sicario = true,
            stoic = true,
            tag_team = true,
            hacker = true,
            leech = true,

            -- Other
            interact = true,
            reload = true,
            melee_charge = true,
            shield_regen = true,
            dodge = true,
            dodge_refresh = 1, -- 1 / value
            dodge_persistent = false,
            crit = true,
            crit_refresh = 1, -- 1 / value
            crit_persistent = false,
            inspire_ai = true
        }
    }
end

function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

function EHI:ShowMissionAchievements()
    return self:GetUnlockableAndOption("show_achievements_mission") and self:GetUnlockableOption("show_achievements")
end

function EHI:GetUnlockableOption(option)
    if option then
        return self.settings.unlockables[option]
    end
end

function EHI:GetUnlockableAndOption(option)
    return self:GetOption("show_unlockables") and self:GetUnlockableOption(option)
end

function EHI:GetEquipmentOption(option)
    return self:GetOption("show_equipment_tracker") and self:GetOption(option)
end

function EHI:GetEquipmentColor(equipment)
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

function EHI:GetBuffOption(option)
    if option then
        return self.settings.buff_option[option]
    end
end

function EHI:MissionTrackersAndWaypointEnabled()
    return self:GetOption("show_mission_trackers") and self:GetOption("show_waypoints")
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

function EHI:AreGagePackagesSpawned()
    return self._cache.GagePackages and self._cache.GagePackages > 0
end

function EHI:AddCallback(id, f)
    self.Callback[id] = self.Callback[id] or {}
    self.Callback[id][#self.Callback[id] + 1] = f
end

function EHI:CallCallback(id, ...)
    for _, callback in ipairs(self.Callback[id] or {}) do
        callback(...)
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

function EHI:RunOnCustodyCallback(custody_state)
    for _, callback in ipairs(self.OnCustodyCallback) do
        callback(custody_state)
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

---@param id string|number
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
---@param continent_index number?
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

function EHI:GetInstanceElementPosition2(id)
    local element = managers.mission:get_element_by_id(id)
    if not element then
        return nil
    end
    return element:value("position")
end

function EHI:GetInstanceUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    if not unit then
        return nil
    end
    if not unit.position then
        return nil
    end
    return unit:position()
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
    return achievement and { achievement.icon_id }
end

---@param id string
---@return string
function EHI:GetAchievementIconString(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and achievement.icon_id
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

function EHI:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    local function FillRestOfProperties(key, value)
        if not value.id then
            triggers[key].id = trigger_id_all
        end
        if not value.icons then
            triggers[key].icons = trigger_icons_all
        end
    end
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            local t = triggers[key]
            if t.special_function and self.TriggerFunction[t.special_function] then
                -- TODO:
                -- This won't properly rearrange triggers when both of them are Trigger function
                -- It may lead to endless loop, stucking the game
                local new_key = (key * 10) + 1
                while triggers[new_key] do
                    new_key = new_key + 1
                end
                triggers[new_key] = value
                FillRestOfProperties(new_key, value)
                if t.data then
                    t.data[#t.data + 1] = new_key
                else
                    self:Log("key: " .. tostring(key) .. " does not have 'data' table, the trigger " .. tostring(new_key) .. " will not be called!")
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
                    self:Log("key: " .. tostring(key) .. " with ID: " .. tostring(value.id) .. " does not have 'data' table, the former trigger won't be moved and triggers assigned to this one will not be called!")
                end
            else
                --self:PrintTable(value, key, "new_triggers")
                --self:PrintTable(t, key, "triggers")
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

function EHI:AddWaypointToTrigger(id, waypoint)
    if not triggers[id] then
        return
    end
    triggers[id].waypoint = waypoint
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
    local trigger = triggers[id]
    managers.ehi:AddTracker({
        id = trigger.id,
        time = trigger.data[math.random(#trigger.data)],
        icons = trigger.icons,
        class = trigger.class
    })
    if trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
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
    local trigger = host_triggers[id]
    managers.ehi:AddTrackerAndSync({
        id = trigger.id,
        time = (trigger.time or 0) + (delay or 0),
        icons = trigger.icons,
        class = trigger.class
    }, id, delay)
    if trigger.waypoint then
        managers.ehi_waypoint:AddWaypoint(trigger.id, trigger.waypoint)
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
            local trigger = triggers[id]
            local f = trigger.special_function
            if f == SF.RemoveTracker then
                RemoveTracker(trigger.id)
            elseif f == SF.PauseTracker then
                PauseTracker(trigger.id)
            elseif f == SF.UnpauseTracker then
                UnpauseTracker(trigger.id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    UnpauseTracker(trigger.id)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(trigger.id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementComplete then
                managers.ehi:SetAchievementComplete(trigger.id, true)
            elseif f == SF.ReplaceTrackerWithTracker then
                RemoveTracker(trigger.data.id)
                self:CheckCondition(id)
            elseif f == SF.IncreaseChance then
                managers.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.TriggerIfEnabled then
                if enabled then
                    for _, t in pairs(trigger.data) do
                        self:Trigger(t, element, enabled)
                    end
                end
            elseif f == SF.CreateAnotherTrackerWithTracker then
                self:CheckCondition(id)
                self:Trigger(trigger.data.fake_id, element, enabled)
            elseif f == SF.SetChanceWhenTrackerExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, trigger.chance)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                self:CheckCondition(id)
                self:UnhookTrigger(id)
            elseif f == SF.Trigger then
                for _, t in pairs(trigger.data) do
                    self:Trigger(t, element, enabled)
                end
            elseif f == SF.RemoveTrigger then
                self:UnhookTrigger(id)
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetTrackerTime(trigger.id, trigger.time)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(trigger.data) do
                    RemoveTracker(tracker)
                end
            elseif f == SF.ShowAchievement then
                if self:IsAchievementLocked(trigger.id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggerAndShowAchievement then
                if self:IsAchievementLocked(trigger.id) then
                    self:CheckCondition(id)
                end
                self:UnhookTrigger(id)
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    trigger.time = trigger.data.yes
                else
                    trigger.time = trigger.data.no
                end
                self:CheckCondition(id)
            elseif f == SF.IncreaseProgress then
                managers.ehi:IncreaseTrackerProgress(trigger.id)
                --managers.hud:IncreaseTrackerWaypointProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTrackerClient then
                local value = managers.ehi:ReturnValue(trigger.id, "GetTrackerType")
                if value ~= "accurate" then
                    if managers.ehi:TrackerExists(trigger.id) then
                        managers.ehi:SetTrackerTimeNoAnim(trigger.id, self:GetTime(id))
                    else
                        self:CheckCondition(id)
                    end
                end
            elseif f == SF.SetTrackerAccurate then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetTrackerAccurate(trigger.id, trigger.time)
                else
                    self:CheckCondition(id)
                end
            elseif f == SF.RemoveTriggers then
                for _, trigger_id in pairs(trigger.data) do
                    self:UnhookTrigger(trigger_id)
                end
            elseif f == SF.SetAchievementStatus then
                managers.ehi:SetAchievementStatus(trigger.id, trigger.status or "ok")
            elseif f == SF.ShowAchievementFromStart then
                if self:IsAchievementLocked(trigger.id) and not managers.statistics:is_dropin() then
                    self:CheckCondition(id)
                end
            elseif f == SF.SetAchievementFailed then
                managers.ehi:SetAchievementFailed(trigger.id)
            elseif f == SF.SetRandomTime then
                if managers.ehi:TrackerDoesNotExist(trigger.id) then
                    self:AddTrackerWithRandomTime(id)
                end
            elseif f == SF.DecreaseChance then
                managers.ehi:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.GetElementTimerAccurate then
                GetElementTimer(self, id)
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:UnpauseTracker(trigger.id)
                else
                    if trigger.time then
                        self:CheckCondition(id)
                        return
                    end
                    if managers.preplanning:IsAssetBought(trigger.data.id) then
                        trigger.time = trigger.data.yes
                    else
                        trigger.time = trigger.data.no
                    end
                    self:CheckCondition(id)
                end
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if managers.ehi:TrackerExists(trigger.id) then
                    UnpauseTracker(trigger.id)
                else
                    GetElementTimer(self, id)
                end
            elseif f == SF.ShowAchievementCustom then
                if self:IsAchievementLocked(trigger.data) then
                    self:CheckCondition(id)
                end
            elseif f == SF.FinalizeAchievement then
                managers.ehi:CallFunction(trigger.id, "Finalize")
            elseif f == SF.IncreaseChanceFromElement then
                managers.ehi:IncreaseChance(trigger.id, element._values.chance)
            elseif f == SF.DecreaseChanceFromElement then
                managers.ehi:DecreaseChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElement then
                managers.ehi:SetChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElementWhenTrackerExists then
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.ehi:SetChance(trigger.id, element._values.chance)
                else
                    trigger.chance = element._values.chance
                    self:CheckCondition(id)
                end
            elseif f == SF.PauseTrackerWithTime then
                local t_id = trigger.id
                local t_time = trigger.time
                PauseTracker(t_id)
                managers.ehi:SetTrackerTimeNoAnim(t_id, t_time)
                managers.ehi_waypoint:SetWaypointTime(t_id, t_time)
            elseif f == SF.RemoveTriggerAndShowAchievementCustom then
                if self:IsAchievementLocked(trigger.data) then
                    self:CheckCondition(id)
                end
                self:UnhookTrigger(id)
            elseif f == SF.IncreaseProgressMax then
                managers.ehi:IncreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.SetTimeIfLoudOrStealth then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        trigger.time = trigger.data.no
                    else -- Loud
                        trigger.time = trigger.data.yes
                    end
                    self:CheckCondition(id)
                end
            elseif f == SF.AddTimeByPreplanning then
                local t = 0
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    t = trigger.data.yes
                else
                    t = trigger.data.no
                end
                trigger.time = trigger.time + t
                self:CheckCondition(id)
            elseif f == SF.ShowWaypoint then
                managers.hud:add_waypoint(trigger.id, trigger.data)
            elseif f == SF.DecreaseProgressMax then
                managers.ehi:DecreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.DecreaseProgress then
                managers.ehi:DecreaseTrackerProgress(trigger.id, trigger.progress)
            elseif f == SF.ShowTrophy then
                if self:IsTrophyLocked(trigger.id) then
                    self:CheckCondition(id)
                end
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.CustomCode then
                trigger.f(trigger.arg)
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    trigger.f(trigger.arg)
                end
            elseif f == SF.CustomCodeDelayed then
                self:DelayCall(tostring(id), trigger.t or 0, trigger.f)

            elseif f >= SF.CustomSF then
                self.SFF[f](id, trigger, element, enabled)
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
                    element._calc_base_delay = function(e, ...)
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
                    element._calc_element_delay = function(e, params, ...)
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
    for id, _ in pairs(self.HookOnLoad) do
        local trigger = triggers[id]
        if trigger then
            if trigger.special_function == SF.ShowWaypoint and trigger.data then
                if trigger.data.position_by_element then
                    self:AddPositionFromElement(trigger.data, trigger.id, true)
                elseif trigger.data.position_by_unit then
                    self:AddPositionFromUnit(trigger.data, trigger.id, true)
                end
            elseif trigger.waypoint then
                if trigger.waypoint.position_by_element then
                    self:AddPositionFromElement(trigger.data, trigger.id, true)
                elseif trigger.waypoint.position_by_unit then
                    self:AddPositionFromUnit(trigger.data, trigger.id, true)
                end
            end
        end
    end
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

function EHI:AddPositionFromElement(data, id, check)
    local vector = self:GetInstanceElementPosition2(data.position_by_element)
    if vector then
        data.position = vector
        data.position_by_element = nil
    elseif check then
        self:Log("Element with ID " .. tostring(data.position_by_element) .. " has not been found. Element ID to hook: " .. tostring(id))
    end
end

function EHI:AddPositionFromUnit(data, id, check)
    local vector = self:GetInstanceUnitPosition(data.position_by_unit)
    if vector then
        data.position = vector
        data.position_by_unit = nil
    elseif check then
        self:Log("Unit with ID " .. tostring(data.position_by_unit) .. " has not been found. Element ID to hook: " .. tostring(id))
    end
end

function EHI:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    new_triggers = new_triggers or {}
    local show_achievement = self:ShowMissionAchievements()
    local show_trophy = self:GetUnlockableAndOption("show_trophies")
    local function FillAchievementTrigger(data)
        if not data.special_function then
            data.special_function = SF.ShowAchievement
        end
        if data.difficulty_pass ~= nil then
            data.condition = data.difficulty_pass and show_achievement
            data.difficulty_pass = nil
        elseif data.condition == nil then
            data.condition = show_achievement
        end
        if not data.icons then
            data.icons = self:GetAchievementIcon(data.id)
        end
    end
    local function FillTrophyTrigger(data, sf, c)
        if not data.special_function then
            data.special_function = sf
        end
        if data.difficulty_pass ~= nil then
            data.condition = data.difficulty_pass and c
            data.difficulty_pass = nil
        elseif data.condition == nil then
            data.condition = c
        end
        if not data.icons then
            data.icons = { self.Icons.Trophy }
        end
    end
    self:AddTriggers(new_triggers.other or {}, trigger_icons_all or "Trigger", trigger_icons_all)
    local trophy = new_triggers.trophy
    if show_trophy and trophy then
        for _, data in pairs(trophy) do
            if data.class and self.TrophyTrackers[data.class] then
                FillTrophyTrigger(data, SF.ShowTrophy, show_trophy)
            end
        end
        self:AddTriggers2(trophy, nil, trigger_icons_all or "Trigger", trigger_icons_all)
    end
    -- Daily Side Jobs are checked before they are passed to this function
    -- See EHI:IsDailyAvailable()
    local daily = new_triggers.daily
    if daily then
        for _, data in pairs(daily) do
            if data.class and self.DailyTrackers[data.class] then
                FillTrophyTrigger(data, SF.ShowDaily, true)
            end
        end
        self:AddTriggers2(daily, nil, trigger_icons_all or "Trigger", trigger_icons_all)
    end
    --self:PrintTable(triggers, "Before achievements")
    local achievement_triggers = new_triggers.achievement
    if show_achievement and achievement_triggers then
        for _, data in pairs(achievement_triggers) do
            if data.class and self.AchievementTrackers[data.class] then
                FillAchievementTrigger(data)
            end
        end
        self:AddTriggers2(achievement_triggers, nil, trigger_icons_all or "Trigger", trigger_icons_all)
    end
    self:ParseMissionTriggers(new_triggers.mission, trigger_id_all, trigger_icons_all)
    --self:PrintTable(triggers, "After achievements:")
end

function EHI:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    if not self:GetOption("show_mission_trackers") then
        for id, data in pairs(new_triggers) do
            if data.special_function and self.SyncFunctions[data.special_function] then
                self:AddTriggers2({ [id] = data }, nil, trigger_id_all or "Trigger", trigger_icons_all)
            end
        end
        return
    end
    local host = self._cache.Host
    for _, data in pairs(new_triggers) do
        -- Mark every tracker, that has random time, as inaccurate
        if data.random_time then
            if not data.class then
                data.class = self.Trackers.Inaccurate
            elseif data.class ~= self.Trackers.InaccuratePausable and data.class == self.Trackers.Warning then
                data.class = self.Trackers.InaccurateWarning
            end
        end
        -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
        if data.special_function == SF.ShowWaypoint then
            data.data.distance = true
            data.data.state = "sneak_present"
            data.data.present_timer = 0
            data.data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
            if data.data.position_by_element then
                self:AddPositionFromElement(data.data, data.id, host)
            elseif data.data.position_by_unit then
                self:AddPositionFromUnit(data.data, data.id, host)
            end
            if not data.data.position then
                data.data.position = Vector3()
                self:Log("Waypoint in element with ID '" .. tostring(data.id) .. "' does not have valid waypoint position! Setting it to default vector to avoid crashing")
            end
        end
        -- Fill the rest table properties for EHI Waypoints
        if data.waypoint then
            data.waypoint.time = data.waypoint.time or data.time
            if not data.waypoint.icon then
                data.waypoint.icon = data.icons and data.icons[1] and data.icons[1].icon or data.icons[1]
            end
            if data.waypoint.position_by_element then
                self:AddPositionFromElement(data.waypoint, data.id, host)
            elseif data.waypoint.position_by_unit then
                self:AddPositionFromUnit(data.waypoint, data.id, host)
            end
            if not data.waypoint.position then
                data.waypoint.position = Vector3()
                self:Log("Waypoint in element with ID '" .. tostring(data.id) .. "' does not have valid waypoint position! Setting it to default vector to avoid crashing")
            end
        end
    end
    self:AddTriggers2(new_triggers, nil, trigger_id_all or "Trigger", trigger_icons_all)
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

-- Used on clients when offset is required
-- Do not call it directly!
function EHI:ShowLootCounterOffset(params, manager)
    local offset = managers.loot:GetSecuredBagsAmount()
    manager:ShowLootCounter(params.max, params.additional_loot, params.max_random, offset)
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, "LootCounter")
        if params.hook_triggers then
            self:HookElements(params.triggers)
        end
    end
    if params.sequence_triggers then
        local function IncreaseMax(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootSpawned")
        end
        local function DecreaseRandom(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootDeclined")
        end
        for unit_id, sequences in pairs(params.sequence_triggers) do
            for _, sequence in ipairs(sequences.loot) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
            end
            for _, sequence in ipairs(sequences.no_loot) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
            end
        end
    end
    if params.no_counting then
        return
    end
    self:HookLootCounter()
end

function EHI:ShowLootCounter(params)
    if not self:GetOption("show_loot_counter") then
        return
    end
    self:ShowLootCounterNoCheck(params)
end

function EHI:ShowLootCounterNoCheck(params)
    if Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree" then
        return
    end
    local n_offset = 0
    if params.offset then
        if self._cache.Host then
            n_offset = managers.loot:GetSecuredBagsAmount()
        else
            managers.ehi:AddFullSyncFunction(callback(self, self, "ShowLootCounterOffset", params))
            return
        end
    end
    managers.ehi:ShowLootCounter(params.max, params.additional_loot, params.max_random, n_offset)
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, "LootCounter")
    end
    if params.sequence_triggers then
        local function IncreaseMax(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootSpawned")
        end
        local function DecreaseRandom(...)
            managers.ehi:CallFunction("LootCounter", "RandomLootDeclined")
        end
        for unit_id, sequences in pairs(params.sequence_triggers) do
            for _, sequence in ipairs(sequences.loot) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
            end
            for _, sequence in ipairs(sequences.no_loot) do
                managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
            end
        end
    end
    if params.no_counting then
        return
    end
    self:HookLootCounter()
end

function EHI:HookLootCounter(check_type, loot_type)
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
    if self._cache.UnlockablesAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
        if params.show_loot_counter then
            self:ShowLootCounter({ max = params.max, additional_loot = params.additional_loot })
        end
        return
    end
    managers.ehi:AddAchievementProgressTracker(params.achievement, params.max, params.additional_loot, params.exclude_from_sync, params.remove_after_reaching_target, params.show_loot_counter)
    if params.triggers then
        self:AddTriggers(params.triggers, params.achievement)
        return
    elseif params.no_counting then
        return
    end
    self:AddAchievementToCounter(params)
end

function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.UnlockablesAreDisabled or not show_achievement or self:IsAchievementUnlocked(params.achievement) then
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
        sync_only = params.sync_only,
        f = params.counter and params.counter.f
    }
    self:HookAchievementCounter()
end

function EHI:HookAchievementCounter()
    if not self.AchievementCounterHook then
        local function Hook(self, sync_load)
            for _, achievement in ipairs(EHI.AchievementCounter) do
                if not achievement.sync_only or (achievement.sync_only and sync_load) then
                    self:EHIReportProgress(achievement.id, achievement.check_type, achievement.loot_type, achievement.f)
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

function EHI:ShowAchievementKillCounter(id, id_stat, achievement_option)
    if (achievement_option and not self:GetUnlockableOption(achievement_option)) or not show_achievement then
        return
    end
    if self._cache.UnlockablesAreDisabled or self:IsAchievementUnlocked2(id) then
        return
    end
    local progress = self:GetAchievementProgress(id_stat)
    local tweak_data = tweak_data.achievement.persistent_stat_unlocks[id_stat]
    if not tweak_data then
        self:Log("No statistics found for achievement " .. tostring(id) .. "; Stat: " .. tostring(id_stat))
        return
    end
    local max = tweak_data[1] and tweak_data[1].at or 0
    if progress >= max then
        return
    end
    managers.ehi:AddAchievementKillCounter(id, progress, max)
    self.KillCounter[id_stat] = id
    if not self.KillCounterHook then
        EHI:Hook(AchievmentManager, "award_progress", function(am, stat, value)
            local s = EHI.KillCounter[stat]
            if s then
                managers.ehi:IncreaseTrackerProgress(s, value)
            end
        end)
        self.KillCounterHook = true
    end
end

function EHI:AddLoadSyncFunction(f)
    if self._cache.Host then
        return
    end
    managers.ehi:AddLoadSyncFunction(f)
end

---@param tbl table
function EHI:UpdateUnits(tbl)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateUnitsNoCheck(tbl)
end

function EHI:UpdateUnitsNoCheck(tbl)
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
    self:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
end

function EHI:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
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

function EHI:SetMissionDoorPosAndIndex(pos, index)
    if TimerGui.SetMissionDoorPosAndIndex then
        TimerGui.SetMissionDoorPosAndIndex(pos, index)
    end
end

EHI:Load()

-- Hack
show_achievement = EHI:ShowMissionAchievements()

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

if not EHI:GetOption("show_mission_trackers") then
    function EHI:AddTrackerAndSync(id, delay)
        managers.ehi:Sync(id, delay)
    end

    GetElementTimer = function(self, id)
        if self._cache.Host then
            local element = managers.mission:get_element_by_id(triggers[id].element)
            if element then
                local t = (element._timer or 0) + (triggers[id].additional_time or 0)
                managers.ehi:Sync(id, t)
            end
        end
    end
end

if EHI:GetUnlockableOption("hide_unlocked_achievements") then
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

if EHI:GetUnlockableOption("hide_unlocked_trophies") then
    function EHI:IsTrophyUnlocked(trophy)
        return managers.custom_safehouse:is_trophy_unlocked(trophy)
    end
else
    function EHI:IsTrophyUnlocked(trophy)
        return false
    end
end

function EHI:IsDailyAvailable(daily, skip_unlockables_check)
    if not self:GetUnlockableAndOption("show_dailies") then
        return false
    end
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily then
        if current_daily.state == "completed" or current_daily.state == "rewarded" then
            return false
        end
        if skip_unlockables_check then
            return true
        end
        return not self._cache.UnlockablesAreDisabled
    end
    return false
end

function EHI:IsDailyMissionAvailable(daily, skip_unlockables_check)
    --[[local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily then
        if current_daily.state == "completed" or current_daily.state == "rewarded" then
            return false
        end
        if skip_unlockables_check then
            return true
        end
        return not self._cache.UnlockablesAreDisabled
    end]]
    return false
end

function EHI:IsTrophyLocked(trophy)
    return not self:IsTrophyUnlocked(trophy) and not self._cache.UnlockablesAreDisabled
end

function EHI:IsAchievementLocked(achievement)
    return not self:IsAchievementUnlocked(achievement) and not self._cache.UnlockablesAreDisabled
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

function EHI:IsAchievementUnlocked2(achievement)
    return not self:IsAchievementLocked2(achievement)
end

if EHI.debug then -- For testing purposes
    function EHI:IsAchievementLocked2(achievement)
        return true
    end

    function EHI:IsAchievementUnlocked2(achievement)
        return false
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
                self:PrintTable(instance or {})
                local start = self:GetInstanceElementID(100000, instance.start_index)
                local _end = start + instance.index_size - 1
                local f = function(e, ...)
                    managers.hud:DebugBaseElement2(e._id, instance.start_index, nil, e:editor_name(), instance_name)
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

function EHI:PrintTable(tbl, ...)
    local s = ""
    if ... then
        local _tbl = { ... }
        for _, _s in ipairs(_tbl) do
            s = s .. " " .. tostring(_s)
        end
    end
    if _G.PrintTableDeep then
        _G.PrintTableDeep(tbl, 5000, true, "[EHI]" .. s, {}, false)
    else
        if s ~= "" then
            self:Log(s)
        end
        _G.PrintTable(tbl)
    end
end