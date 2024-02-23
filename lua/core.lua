if _G.EHI then
    return
end

_G.EHI =
{
    debug =
    {
        achievements = false,
        mission_door = false,
        loot_manager_escape = false,
        all_instances = false,
        gained_experience = { enabled = false, log = true },
        instance = false
    },
    settings = {},

    FilterTracker =
    {
        show_timers =
        {
            waypoint = "show_waypoints_timers",
            table_name = "Timer"
        }
    },

    OptionTracker =
    {
        show_timers =
        {
            file = "EHITimerTracker",
            count = 1
        },
        show_sniper_tracker =
        {
            file = "EHISniperTrackers",
            count = 1
        },
        show_captain_damage_reduction =
        {
            file = "EHIPhalanxDamageReductionTracker",
            count = 1
        }
    },

    _hooks = {},

    NoCivilianCounter =
    {
        alex_1 = true,
        haunted = true,
        man = true,
        bph = true
    },

    LootCounter =
    {
        CheckType =
        {
            BagsOnly = 1,
            ValueOfBags = 2,
            SmallLootOnly = 3, -- Currently unused
            ValueOfSmallLoot = 4,
            CheckTypeOfLoot = 5,
            CustomCheck = 6,
            Debug = 7
        }
    },

    _cache =
    {
        DisableAchievements = false,
        MissionUnits = {}, ---@type table<number, UnitUpdateDefinition>
        InstanceUnits = {}, ---@type table<number, UnitUpdateDefinition>
        InstanceMissionUnits = {}, ---@type table<number, UnitUpdateDefinition>
        IgnoreWaypoints = {}, ---@type table<number, boolean>
        ElementWaypoint = {}, ---@type table<number, boolean>
        XPElement = 0
    },

    Callback = {}, ---@type table<string|number, function[]>
    CallbackMessage =
    {
        Spawned = "Spawned",
        -- Provides `loc` (a LocalizationManager class) and `lang_name` (string)
        LocLoaded = "LocLoaded",
        -- Provides `success` (a boolean value)
        MissionEnd = "MissionEnd",
        GameRestart = "GameRestart",
        -- Provides `self` (a LootManager class)
        LootSecured = "LootSecured",
        -- Provides `managers` (a global table with all managers)
        InitManagers = "InitManagers",
        InitFinalize = "InitFinalize",
        -- Provides `self` (a LootManager class)
        LootLoadSync = "LootLoadSync",
        -- Provides `key` (a unit key; a string value), `local_peer` (a boolean value) and `peer_id` (a number value)
        OnMinionAdded = "OnMinionAdded",
        -- Provides `key` (a unit key; a string value), `local_peer` (a boolean value) and `peer_id` (a number value)
        OnMinionKilled = "OnMinionKilled",
        -- Provides `boost` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAISkillBoostChange = "TeamAISkillBoostChanged",
        -- Provides `boost` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAIAbilityBoostChange = "TeamAIAbilityBoostChanged",
        -- Provides `mode` (a string value -> `normal`, `phalanx`)
        AssaultModeChanged = "AssaultModeChanged",
        -- Provides `mode` (a string value -> `normal`, `endless`)
        AssaultWaveModeChanged = "AssaultWaveModeChanged",
        -- Provides `visibility` (a boolean value)
        HUDVisibilityChanged = "HUDVisibilityChanged",
        -- Provides `picked_up` (a number value), `max_units` (a number value) and `client_sync_load` (a boolean value)
        SyncGagePackagesCount = "SyncGagePackagesCount"
    },

    SyncMessages =
    {
        EHISyncAddBuff = "EHISyncAddBuff",
        EHISyncAddTracker = "EHISyncAddTracker",

        TrackerManager =
        {
            SyncAddTracker = "EHI_TM_SyncAddTracker",
            SyncUpdateTracker = "EHI_TM_SyncUpdateTracker"
        }
    },

    SpecialFunctions =
    {
        -- Requires `id` or `data (table of strings)`
        RemoveTracker = 1,
        -- Requires `id`
        PauseTracker = 2,
        -- Requires `id`
        UnpauseTracker = 3,
        -- Requires `id`
        UnpauseTrackerIfExists = 4,
        -- Requires `id`
        AddTrackerIfDoesNotExist = 5,
        -- Requires `id` and `data.id (string)`
        ReplaceTrackerWithTracker = 6,
        ShowAchievementFromStart = 7,
        -- Requires `id`
        SetAchievementComplete = 8,
        -- Requires `id`  
        -- Optional `status`
        SetAchievementStatus = 9,
        -- Requires `id`
        SetAchievementFailed = 10,
        -- Optional `data`  
        ---@see AchievementBagValueCounterTable  
        ---@see AchievementLootCounterTable
        AddAchievementToCounter = 11,
        -- Requires `id` and `amount`
        IncreaseChance = 12,
        -- Requires `id (number)` or `data (table of numbers)`
        TriggerIfEnabled = 13,
        -- Requires `id` and `data.fake_id (number)`
        CreateAnotherTrackerWithTracker = 14,
        -- Requires `id` and `chance`
        SetChanceWhenTrackerExists = 15,
        -- Requires `id (number)` or `data (table of numbers)`
        Trigger = 17,
        -- Requires `id (number)` or `data (table of numbers)`
        RemoveTrigger = 18,
        -- Requires `id` and `time`
        SetTimeOrCreateTracker = 19,
        -- Requires `id` and `time`
        SetTimeOrCreateTrackerIfEnabled = 20,
        ExecuteIfElementIsEnabled = 21,
        -- Requires `id` and `data.id (preplanning id)`  
        -- See: `ElementPreplanning` in Mission Script
        SetTimeByPreplanning = 24,
        -- Requires `id`
        IncreaseProgress = 25,
        -- Requires `id` and `time`
        SetTrackerAccurate = 27,
        -- Autosets tracker class to `EHIInaccurateTracker`  
        -- Requires `data (table of numbers)`  
        ---@see EHIManager.ParseMissionTriggers
        SetRandomTime = 32,
        -- Requires `id` and `amount`
        DecreaseChance = 34,
        -- Requires `element`  
        -- Optional `additional_time`  
        GetElementTimerAccurate = 35,
        -- Requires `id` and `element`  
        -- Optional `additional_time` 
        UnpauseTrackerIfExistsAccurate = 36,
        -- Requires `id` and `data.id (preplanning id)`  
        -- See: `ElementPreplanning` in Mission Script
        UnpauseOrSetTimeByPreplanning = 37,
        -- Requires `id`
        FinalizeAchievement = 39,
        -- Requires `id` and must be hooked to `ElementLogicChanceOperator`
        IncreaseChanceFromElement = 42,
        -- Requires `id` and must be hooked to `ElementLogicChanceOperator`
        DecreaseChanceFromElement = 43,
        -- Requires `id` and must be hooked to `ElementLogicChanceOperator`
        SetChanceFromElement = 44,
        -- Requires `id` and `time`
        PauseTrackerWithTime = 46,
        -- Requires `id` and `max`
        IncreaseProgressMax = 47,
        -- Requires `id` and `max`  
        -- Optional `class`
        IncreaseProgressMax2 = 48,
        -- Requires `data.stealth` and `data.loud`
        SetTimeIfLoudOrStealth = 49,
        -- Requires `id`, `data.id (preplanning id)`, `data.yes (if preplanning asset bought)` and `data.no (if preplanning asset not bought)`  
        -- See: `ElementPreplanning` in Mission Script
        AddTimeByPreplanning = 50,
        -- Autosets Vanilla settings for Waypoints  
        ---@see EHIManager.ParseMissionTriggers
        ShowWaypoint = 51,
        --- Requires `id` and `waypoint (table)`
        ShowEHIWaypoint = 52,
        -- Requires `id` and `max`
        DecreaseProgressMax = 53,
        -- Requires `id` and `progress`
        DecreaseProgress = 54,
        -- Requires `id`
        -- Optional `count`
        IncreaseCounter = 55,
        -- Requires `id`
        DecreaseCounter = 56,
        -- Requires `id` and `count`
        SetCounter = 57,

        -- Requires `id` and `f (function name as string)`  
        -- Optional `arg (table of arguments to pass to the function)`
        CallCustomFunction = 100,
        -- Requires `f (function name as string in EHITrackerManager)`  
        -- Optional `arg (table of arguments to pass to the function)`  
        ---@see EHITrackerManager
        CallTrackerManagerFunction = 101,
        -- Requires `f (function name as string in EHIWaypointManager)`  
        -- Optional `arg (table of arguments to pass to the function)`  
        ---@see EHIWaypointManager
        CallWaypointManagerFunction = 102,

        Debug = 1000,
        DebugElement = 1001,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)`
        CustomCode = 1002,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)`
        CustomCodeIfEnabled = 1003,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)` and `t`
        CustomCodeDelayed = 1004,

        -- Don't use it directly! Instead, call `EHI:GetFreeCustomSFID()` and `EHI:RegisterCustomSF()` respectively; or provide a function to `EHI:RegisterCustomSF()` as a first argument
        CustomSF = 100000,
        CustomSyncedSF = 200000
    },

    ConditionFunctions =
    {
        ---Checks if loud is active
        ---@return boolean
        IsLoud = function()
            return managers.groupai and not managers.groupai:state():whisper_mode()
        end,
        ---Checks if stealth is active
        ---@return boolean
        IsStealth = function()
            return managers.groupai and managers.groupai:state():whisper_mode()
        end
    },

    Hints =
    {
        -- Generic hints
        Question = "question",
        EndlessAssault = "endless_assault",
        Fire = "fire",
        FireRecharge = "fire_recharge",
        Escape = "escape",
        LootEscape = "loot_escape",
        Loot = "loot",
        LootTimed = "loot_timed",
        CookingChance = "cooking_chance",
        ScriptedBulldozer = "scripted_bulldozer",
        EnemySnipers = "enemy_snipers",
        EnemySnipersHeli = "enemy_snipers_heli",
        EnemySnipersLoop = "enemy_snipers_loop",
        Cutter = "cutter",
        Wait = "wait",
        Teargas = "teargas",
        Hack = "hack",
        DrillDelivery = "drill_delivery",
        DrillPartsDelivery = "drill_parts_delivery",
        Thermite = "thermite",
        Explosion = "explosion",
        PickUpPhone = "pick_up_phone",
        Kills = "kills",
        Winch = "winch",
        C4Delivery = "c4_delivery",
        ColorCodes = "color_codes",
        KeypadReset = "keypad_reset",
        FuelTransfer = "fuel_transfer",
        Charging = "charging",
        Alarm = "alarm",
        Process = "process",
        Chance = "chance",
        Defend = "defend",
        Restarting = "restarting",

        -- Heist specific hints
        big_Piggy = "big_piggy",
        brb_WinchDelivery = "brb_winch_delivery",
        cane_Safe = "cane_safe",
        crojob3_Water = "crojob3_water",
        crojob3_WaterEnRoute = "crojob3_water_enroute",
        crojob3_WaterRefill = "crojob3_water_refill",
        des_Crane = "des_crane",
        des_ChemSet = "des_chem_set",
        des_ChemSetRestart = "des_chem_set_restart",
        des_ChemSetInterrupt = "des_chem_set_interrupt",
        des_ChemSetCooking = "des_chem_set_cooking",
        election_day_3_CrashChance = "election_day_3_crash_chance",
        election_day_3_CrashChanceTime = "election_day_3_crash_chance_time",
        friend_Heli = "friend_heli",
        friend_HeliRandom = "friend_heli_random",
        friend_HeliCaddilac = "friend_heli_caddilac",
        friend_HeliDropCar = "friend_heli_drop_car",
        hox_1_VehicleMove = "hox_1_vehicle_move",
        hox_1_Car = "hox_1_car",
        hox_2_Request = "hox_2_request",
        hox_2_Evidence = "hox_2_evidence",
        kosugi_Heli = "kosugi_heli",
        kosugi_Loot = "kosugi_loot",
        kosugi_Guards = "kosugi_guards",
        kosugi_Keycard = "kosugi_keycard",
        mad_Bomb = "mad_bomb",
        mad_Scan = "mad_scan",
        mad_EMP = "mad_emp",
        mallcrasher_Destruction = "mallcrasher_destruction",
        man_Code = "man_code",
        mia_1_MethDone = "mia_1_meth_done",
        mia_1_NextMethIngredient = "mia_1_next_meth_ingredient",
        mia_2_Loot = "mia_2_loot",
        nail_ChemicalsEnRoute = "nail_chemicals_en_route",
        nmh_IncomingPolicePatrol = "nmh_incoming_police_patrol",
        nmh_IncomingCivilian = "nmh_incoming_civilian",
        nmh_PatientFileChance = "nmh_patient_file_chance",
        nmh_VialFail = "nmh_vial_fail",
        nmh_VialSuccess = "nmh_vial_success",
        pal_Money = "pal_money",
        pent_Chance = "pent_chance",
        peta2_LootZoneDelivery = "peta2_loot_zone_delivery",
        pines_Chance = "pines_chance",
        pines_ChanceReduction = "pines_chance_reduction",
        pines_Santa = "pines_santa",
        ranc_Chance = "ranc_chance",
        red2_Thermite = "red2_thermite",
        roberts_GenSec = "roberts_gensec",
        roberts_GenSecWarning = "roberts_gensec_warning",
        roberts_NextPhoneCall = "roberts_next_phone_call",
        run_FinalZone = "run_final_zone",
        run_Gas = "run_gas",
        run_GasFinal = "run_gas_final",
        rvd_Pink = "rvd_pink",
        rvd2_LiquidNitrogen = "rvd2_liquid_nitrogen",
        sand_Revive = "sand_revive",
        sand_HeliTurretTimer = "sand_heli_turret_timer",
        trai_Crane = "trai_crane",
        trai_LocoStart = "trat_loco_start",
        vit_Teargas = "vit_teargas"
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
        Turret = "turret",
        PCHack = "wp_hack",
        Glasscutter = "equipment_glasscutter",
        Loot = "pd2_loot",
        Goto = "pd2_goto",
        Pager = "pagers_used",
        Train = "C_Bain_H_TransportVarious_ButWait",
        LiquidNitrogen = "equipment_liquid_nitrogen_canister",
        Kill = "pd2_kill",
        Oil = "oil",
        Door = "pd2_door",
        USB = "equipment_usb_no_data",
        Destruction = "C_Vlad_H_Mallcrasher_Shoot",
        Tablet = "tablet",

        EndlessAssault = { { icon = "padlock", color = Color.red } },
        CarEscape = { "pd2_car", "pd2_escape", "pd2_lootdrop" },
        CarEscapeNoLoot = { "pd2_car", "pd2_escape" },
        CarWait = { "pd2_car", "pd2_escape", "pd2_lootdrop", "faster" },
        CarLootDrop = { "pd2_car", "pd2_lootdrop" },
        HeliEscape = { "heli", "pd2_escape", "pd2_lootdrop" },
        HeliEscapeNoLoot = { "heli", "pd2_escape" },
        HeliLootDrop = { "heli", "pd2_lootdrop" },
        HeliDropDrill = { "heli", "pd2_drill", "pd2_goto" },
        HeliDropBag = { "heli", "wp_bag", "pd2_goto" },
        HeliDropC4 = { "heli", "pd2_c4", "pd2_goto" },
        HeliDropWinch = { "heli", "equipment_winch_hook", "pd2_goto" },
        HeliWait = { "heli", "pd2_escape", "pd2_lootdrop", "faster" },
        HeliLootDropWait = { "heli", "pd2_lootdrop", "faster" },
        BoatEscape = { "boat", "pd2_escape", "pd2_lootdrop" },
        BoatEscapeNoLoot = { "boat", "pd2_escape" },
        BoatLootDrop = { "boat", "pd2_lootdrop" }
    },

    Trackers =
    {
        Base = "EHITracker",
        Warning = "EHIWarningTracker",
        -- Optional `paused`
        Pausable = "EHIPausableTracker",
        -- Optional `chance`
        Chance = "EHIChanceTracker",
        -- Optional `count`
        Counter = "EHICountTracker",
        -- Optional `max` and `progress`
        Progress = "EHIProgressTracker",
        NeededValue = "EHINeededValueTracker",
        Timed =
        {
            -- Optional `chance`
            Chance = "EHITimedChanceTracker",
            -- Optional `max` and `progress`
            Progress = "EHITimedProgressTracker",
            -- Optional `chance`
            WarningChance = "EHITimedWarningChanceTracker"
        },
        Timer =
        {
            Base = "EHITimerTracker",
            Progress = "EHIProgressTimerTracker",
            Chance = "EHIChanceTimerTracker"
        },
        Sniper =
        {
            -- Optional `single_sniper`
            Warning = "EHISniperWarningTracker",
            -- Optional `count`
            Count = "EHISniperCountTracker",
            -- Requires `chance`  
            -- Optional `chance_success` and `sniper_count`
            Chance = "EHISniperChanceTracker",
            -- Requires `time` and `refresh_t`
            Timed = "EHISniperTimedTracker",
            -- Requires `time`  
            -- Optional `count_on_refresh`
            TimedCount = "EHISniperTimedCountTracker",
            -- Requires `chance`, `time` and `recheck_t`
            TimedChance = "EHISniperTimedChanceTracker",
            -- Requires `chance`, `time` and `recheck_t`  
            -- Optional `single_sniper` and `heli_sniper`
            TimedChanceOnce = "EHISniperTimedChanceOnceTracker",
            -- Requires `chance`, `time`, `on_fail_refresh_t` and `on_success_refresh_t`  
            -- Optional `single_sniper` and `sniper_count`
            Loop = "EHISniperLoopTracker",
            -- Requires `chance`, `time`, `on_fail_refresh_t` and `on_success_refresh_t`  
            -- Optional `initial_spawn`, `initial_spawn_chance_set` (defaults to 0 if not provided), `reset_t`, `chance_success`, `single_sniper` and `sniper_count`
            LoopRestart = "EHISniperLoopRestartTracker",
            -- Requires `time` and `refresh_t`
            Heli = "EHISniperHeliTracker",
            -- Requires `chance`, `time` and `recheck_t`
            HeliTimedChance = "EHISniperHeliTimedChanceTracker"
        },
        Achievement =
        {
            Base = "EHIAchievementTracker",
            Unlock = "EHIAchievementUnlockTracker",
            -- Optional `status`
            Status = "EHIAchievementStatusTracker",
            Progress = "EHIAchievementProgressTracker",
            BagValue = "EHIAchievementBagValueTracker",
            LootCounter = "EHIAchievementLootCounterTracker"
        },
        Assault =
        {
            Time = "EHIAssaultTimeTracker",
            Delay = "EHIAssaultDelayTracker",
            Assault = "EHIAssaultTracker"
        },
        ColoredCodes = "EHIColoredCodesTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
        Trophy = "EHITrophyTracker",
        Daily =
        {
            Base = "EHIDailyTracker",
            Progress = "EHIDailyProgressTracker"
        }
    },

    Waypoints =
    {
        Base = "EHIWaypoint",
        Warning = "EHIWarningWaypoint",
        Progress = "EHIProgressWaypoint",
        Pausable = "EHIPausableWaypoint",
        Inaccurate = "EHIInaccurateWaypoint",
        InaccuratePausable = "EHIInaccuratePausableWaypoint",
        InaccurateWarning = "EHIInaccurateWarningWaypoint"
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
    -- PAYDAY 2/mods/Extra Heist Info/
    ModPath = ModPath,
    -- PAYDAY 2/mods/Extra Heist Info/loc/
    LocPath = ModPath .. "loc/",
    -- PAYDAY 2/mods/Extra Heist Info/lua/
    LuaPath = ModPath .. "lua/",
    -- PAYDAY 2/mods/Extra Heist Info/menu/
    MenuPath = ModPath .. "menu/",
    -- PAYDAY 2/mods/saves/ehi.json
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}
local SF = EHI.SpecialFunctions
EHI.SyncFunctions =
{
    [SF.GetElementTimerAccurate] = true,
    [SF.UnpauseTrackerIfExistsAccurate] = true
}
EHI.ClientSyncFunctions =
{
    [SF.GetElementTimerAccurate] = true,
    [SF.UnpauseTrackerIfExistsAccurate] = true
}
EHI.TriggerFunction =
{
    [SF.TriggerIfEnabled] = true,
    [SF.Trigger] = true
}
EHI.WaypointIconRedirect =
{
    [EHI.Icons.Heli] = "EHI_Heli"
}

---@param self table
local function LoadDefaultValues(self)
    self.settings =
    {
        mod_language = 1, -- Auto (default)

        -- Menu Only
        show_preview_text = true,

        -- Common
        x_offset = 0,
        y_offset = 150,
        text_scale = 1,
        scale = 1,
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical; Top to Bottom, 2 = Vertical; Bottom to Top, 3 = Horizontal; Left to Right, 4 = Horizontal; Right to Left
        vr_x_offset = 0,
        vr_y_offset = 150,
        vr_scale = 1,
        vr_tracker_alignment = 1, -- 1 = Vertical; Top to Bottom, 2 = Vertical; Bottom to Top, 3 = Horizontal; Left to Right, 4 = Horizontal; Right to Left

        colors =
        {
            tracker_waypoint =
            {
                inaccurate =
                {
                    r = 255,
                    g = 165,
                    b = 0
                },
                pause =
                {
                    r = 255,
                    g = 0,
                    b = 0
                },
                drill_autorepair =
                {
                    r = 137,
                    g = 209,
                    b = 254
                },
                warning =
                {
                    r = 255,
                    g = 0,
                    b = 0
                },
                completion =
                {
                    r = 0,
                    g = 255,
                    b = 0
                }
            },
            mission_briefing =
            {
                loot_secured =
                {
                    r = 255,
                    g = 188,
                    b = 0
                },
                total_xp =
                {
                    r = 0,
                    g = 255,
                    b = 0
                },
                optional =
                {
                    r = 137,
                    g = 209,
                    b = 254
                }
            }
        },

        -- Visuals
        show_tracker_bg = true,
        show_tracker_corners = true,
        show_one_icon = false,
        show_tracker_hint = true,
        show_tracker_hint_t = 15,

        -- Trackers
        show_mission_trackers = true,
        show_unlockables = true,
        unlockables =
        {
            -- Achievements
            show_achievements = true,
            show_achievement_description = false,
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
            show_trophy_description = false,
            hide_unlocked_trophies = true,
            show_trophy_failed_popup = true,
            show_trophy_started_popup = true,

            -- Daily missions
            show_dailies = true,
            show_daily_description = false,
            show_daily_failed_popup = true,
            show_daily_started_popup = true
        },
        show_gained_xp = true,
        show_xp_in_mission_briefing_only = false,
        xp_format = 3,
        xp_panel = 2,
        total_xp_difference = 2,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_trade_delay_suppress_in_stealth = true,
        show_trade_delay_amount_of_killed_civilians = false,
        show_timers = true,
        show_camera_loop = true,
        show_enemy_turret_trackers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        gage_tracker_panel = 1,
        show_captain_damage_reduction = true,
        show_equipment_tracker = true,
        equipment_format = 1,
        show_equipment_doctorbag = true,
        show_equipment_ammobag = true,
        show_equipment_grenadecases = true,
        grenadecases_block_on_abilities_or_no_throwable = false,
        show_equipment_bodybags = true,
        show_equipment_firstaidkit = true,
        show_equipment_ecmjammer = true,
        ecmjammer_block_ecm_without_pager_delay = false,
        show_equipment_ecmfeedback = true,
        show_ecmfeedback_refresh = true,
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
        show_minion_option = 3, -- 1 = You only; 2 = Total number of minions in one number; 3 = Number of minions per player
        show_minion_per_player = true,
        show_minion_killed_message = true,
        show_minion_killed_message_type = 1, -- 1 = Popup; 2 = Hint
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_enemy_count_tracker = true,
        show_enemy_count_show_pagers = true,
        show_civilian_count_tracker = true,
        civilian_count_tracker_format = 2, -- 1 = No format; one number only; 2 = Tied|Untied; 3 = Untied|Tied
        show_laser_tracker = false,
        show_assault_delay_tracker = true,
        show_assault_time_tracker = true,
        aggregate_assault_delay_and_assault_time = true,
        show_endless_assault = true,
        show_loot_counter = true,
        show_all_loot_secured_popup = true,
        variable_random_loot_format = 3, -- 1 = Max-(Max+Random)?; 2 = MaxRandom?; 3 = Max+Random?
        show_bodybags_counter = true,
        show_escape_chance = true,
        show_sniper_tracker = true,
        show_sniper_spawned_popup = true,

        -- Waypoints
        show_waypoints = true,
        show_waypoints_only = false,
        show_waypoints_present_timer = 2,
        show_waypoints_mission = true,
        show_waypoints_enemy_turret = true,
        show_waypoints_timers = true,
        show_waypoints_pager = true,
        show_waypoints_cameras = true,
        show_waypoints_zipline = true,
        show_waypoints_ecmjammer = true,

        -- Buffs
        show_buffs = true,
        buffs_x_offset = 0,
        buffs_y_offset = 80,
        buffs_vr_x_offset = 0,
        buffs_vr_y_offset = 80,
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
            dire_need = true,
            second_wind = true,
            unseen_strike = true,
            unseen_strike_initial = true,
            -- Fugitive
            trigger_happy = true,
            desperado = true,
            running_from_death_reload = true,
            running_from_death_movement = true,
            up_you_go = true,
            swan_song = true,
            bloodthirst = true,
            bloodthirst_reload = true,
            bloodthirst_ratio = 34, -- value / 100
            berserker = true,
            berserker_refresh = 4, -- 1 / value
            berserker_format = 1, -- 1 = Multiplier; 2 = Percent

            -- Perks
            infiltrator =
            {
                melee_cooldown = true
            },
            gambler =
            {
                regain_health_cooldown = true,
                ammo_give_out_cooldown = true
            },
            grinder =
            {
                regen_duration = true,
                stack_cooldown = true
            },
            maniac =
            {
                stack = true,
                stack_persistent = true,
                stack_refresh = 1,
                stack_update_rate = true,
                stack_decay = true
            },
            anarchist =
            {
                continuous_armor_regen = true,
                immunity = true,
                immunity_cooldown = true,
                kill_armor_regen_cooldown = true
            }, -- +Armorer
            expresident =
            {
                stored_health = true
            },
            biker =
            {
                kill_counter = true,
                kill_counter_persistent = true
            },
            kingpin =
            {
                injector = true,
                injector_cooldown = true
            },
            sicario =
            {
                smoke_bomb = true,
                smoke_bomb_cooldown = true,
                twitch = true,
                twitch_cooldown = true
            },
            stoic =
            {
                dot = true,
                cooldown = true
            },
            tag_team =
            {
                cooldown = true,
                effect = true,
                tagged = true
            },
            hacker =
            {
                pecm_cooldown = true,
                pecm_dodge = true,
                pecm_jammer = true,
                pecm_feedback = true
            },
            leech =
            {
                ampule = true,
                ampule_cooldown = true
            },
            copycat =
            {
                head_games_cooldown = true,
                grace_period = true,
                grace_period_cooldown = true
            },

            -- Other
            interact = true,
            reload = true,
            melee_charge = true,
            shield_regen = true,
            stamina = true,
            dodge = true,
            dodge_refresh = 1, -- 1 / value
            dodge_persistent = false,
            crit = true,
            crit_refresh = 1, -- 1 / value
            crit_persistent = false,
            inspire_ai = true,
            regen_throwable_ai = true,
            health = false,
            armor = false
        },

        -- Inventory
        show_inventory_detailed_description = false,
        hide_original_desc = true,

        -- Other
        show_remaining_xp = true,
        show_remaining_xp_to_100 = false,
        show_mission_xp_overview = true,
        show_floating_health_bar = true
    }
end

local function Load()
    local self = EHI
    if self._cache.__loaded then
        return
    end
    LoadDefaultValues(self)
    local file = io.open(self.SettingsSaveFilePath, "r")
    if file then
        local table
        local success, _ = pcall(function()
            table = json.decode(file:read("*all"))
        end)
        file:close()
        if success then
            if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
                local function LoadValues(settings_table, file_table)
                    if settings_table == nil then
                        return
                    end
                    for k, v in pairs(file_table) do
                        if settings_table[k] ~= nil then
                            if type(v) == "table" then -- Load subtables in table and calls itself to load subtables or values in that subtable
                                LoadValues(settings_table[k], v)
                            elseif type(settings_table[k]) == type(v) then -- Load values to the table if the type is the same
                                settings_table[k] = v
                            end
                        end
                    end
                end
                LoadValues(self.settings, table)
            else
                self._cache.SaveDataNotCompatible = true
                self:Save()
            end
        else -- Save File got corrupted, use default values
            self._cache.SaveFileCorrupted = true
            self:Save() -- Resave the data
        end
    end
    self._cache.__loaded = true
    self._cache.DisableAchievements = not self:ShowMissionAchievements()
end

---@param difficulty string
---@return integer
local function DifficultyToIndex(difficulty)
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

function EHI:Init()
    local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
    self._cache.DifficultyIndex = DifficultyToIndex(difficulty)
    self:AddCallback(self.CallbackMessage.InitManagers, function(managers) ---@param managers managers
        local mutator = managers.mutators
        if mutator:can_mutators_be_active() then
            self._cache.UnlockablesAreDisabled = mutator:are_achievements_disabled()
        end
        local level = Global.game_settings.level_id
        if level == "Enemy_Spawner" or level == "enemy_spawner2" or level == "modders_devmap" then -- These 3 maps disable achievements
            self._cache.UnlockablesAreDisabled = true
        end
    end)
end

---@return boolean
function EHI:IsVR()
    return self._cache.is_vr
end

---@param difficulty number
function EHI:IsDifficultyOrAbove(difficulty)
    return difficulty <= self._cache.DifficultyIndex
end

---@param difficulty number
function EHI:IsDifficultyOrBelow(difficulty)
    return difficulty >= self._cache.DifficultyIndex
end

---@param difficulty number
function EHI:IsDifficulty(difficulty)
    return self._cache.DifficultyIndex == difficulty
end

---@param diff_1 number
---@param diff_2 number
function EHI:IsBetweenDifficulties(diff_1, diff_2)
    if diff_1 > diff_2 then -- Swap the numbers
        diff_1, diff_2 = diff_2, diff_1
    end
    return math.within(self._cache.DifficultyIndex, diff_1, diff_2)
end

function EHI:DifficultyIndex()
    return self._cache.DifficultyIndex or 0
end

function EHI:IsMayhemOrAbove()
    return self:IsDifficultyOrAbove(self.Difficulties.Mayhem)
end

if Global.load_level then
    local function return_true()
        return true
    end
    local function return_false()
        return false
    end
    if Network:is_server() then
        EHI.IsHost = return_true
        EHI.IsClient = return_false
    else
        EHI.IsHost = return_false
        EHI.IsClient = return_true
    end
end

---@return boolean
function EHI:IsPlayingFromStart()
    return self:IsHost() or (self:IsClient() and not managers.statistics:is_dropin())
end

function EHI:IsPlayingSFN()
    return Global.game_settings.level_id == "haunted"
end

function EHI:IsNotPlayingSFN()
    return Global.game_settings.level_id ~= "haunted"
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

function EHI:Save()
    self.settings.SaveDataVer = self.SaveDataVer
    self.settings.ModVersion = self.ModVersion
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or "{}")
        file:close()
    end
end

---Delays execution of a function
---@param name string ID
---@param t number time
---@param func function
function EHI:DelayCall(name, t, func)
    DelayedCalls:Add(name, t, func)
end

---@param vr_option string Option to be checked if the game is running in VR version
---@param option string Option to be checked if the game is running in non-VR version
---@param expected_value { [any]: boolean }|any What the expected value in the option should be
---@param vr_expected_value { [any]: boolean }|any? What the expected value in the VR option should be in VR (don't pass a value if the same value is expected for both options)
---@return boolean
function EHI:CheckVRAndNonVROption(vr_option, option, expected_value, vr_expected_value)
    if self:IsVR() then
        if type(vr_expected_value or expected_value) == "table" then
            local tbl = vr_expected_value or expected_value
            return tbl[self:GetOption(vr_option)]
        end
        return self:GetOption(vr_option) == (vr_expected_value or expected_value)
    elseif type(expected_value) == "table" then
        return expected_value[self:GetOption(option)]
    end
    return self:GetOption(option) == expected_value
end

---@param option string
function EHI:OptionAndLoadTracker(option)
    if self.OptionTracker[option] then
        local tracker = self.OptionTracker[option]
        tracker.count = tracker.count - 1
        if tracker.count == 0 then
            dofile(string.format("%s%s%s.lua", self.LuaPath, "trackers/", tracker.file))
        end
    end
end

---@param option string
function EHI:GetOptionAndLoadTracker(option)
    local result = self:GetOption(option)
    if result and self.OptionTracker[option] then
        local tracker = self.OptionTracker[option]
        tracker.count = tracker.count - 1
        if tracker.count == 0 then
            dofile(string.format("%s%s%s.lua", self.LuaPath, "trackers/", tracker.file))
        end
    end
    return result
end

---@param option string
function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

---@param option string
---@param color string
function EHI:GetColorFromOption(option, color)
    if option and self.settings.colors[option] then
        return self:GetColor(self.settings.colors[option][color])
    end
    return Color.white
end

---@param color string
function EHI:GetTWColor(color)
    if color and self.settings.colors.tracker_waypoint[color] then
        return self:GetColor(self.settings.colors.tracker_waypoint[color])
    end
    return Color.white
end

---@return boolean
function EHI:ShowMissionAchievements()
    return self:GetUnlockableAndOption("show_achievements_mission") and self:GetUnlockableOption("show_achievements")
end

function EHI:ShowTimedTrackerOpened()
    return self:GetOption("show_waypoints") and not self:GetOption("show_waypoints_only")
end

---@param id string Achievement ID
---@return boolean
function EHI:CanShowAchievement(id)
    if self:ShowMissionAchievements() then
        return self:IsAchievementLocked(id)
    end
    return false
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

---@param equipment string
---@return Color
function EHI:GetEquipmentColor(equipment)
    if equipment then
        return self:GetColor(self.settings.equipment_color[equipment])
    end
    return Color.white
end

function EHI:GetWaypointOption(waypoint)
    return self:GetOption("show_waypoints") and self:GetOption(waypoint)
end

---@param waypoint string
---@return boolean, boolean
function EHI:GetWaypointOptionWithOnly(waypoint)
    local show = self:GetWaypointOption(waypoint)
    return show, show and self:GetOption("show_waypoints_only")
end

---@param color Color?
---@return Color
function EHI:GetColor(color)
    if color and color.r and color.g and color.b then
        return Color(255, color.r, color.g, color.b) / 255
    end
    return Color.white
end

---@param option string?
function EHI:GetBuffOption(option)
    if option then
        return self.settings.buff_option[option]
    end
end

---@param option string?
function EHI:GetBuffAndOption(option)
    return self:GetOption("show_buffs") and self:GetBuffOption(option)
end

---@param deck string?
---@param option string?
function EHI:GetBuffDeckOption(deck, option)
    if deck and option and self.settings.buff_option[deck] then
        return self.settings.buff_option[deck][option]
    end
end

---@param deck string?
---@param ... string
function EHI:GetBuffDeckSelectedOptions(deck, ...)
    local deck_table = deck and self.settings.buff_option[deck]
    if deck_table then
        local selected_options = { ... }
        for _, value in ipairs(selected_options) do
            if deck_table[value] then
                return true
            end
        end
    end
    return false
end

---@param deck string?
---@param option string?
function EHI:GetBuffAndBuffDeckOption(deck, option)
    return self:GetOption("show_buffs") and self:GetBuffDeckOption(deck, option)
end

---@return boolean
function EHI:MissionTrackersAndWaypointEnabled()
    return self:GetOption("show_mission_trackers") and self:GetOption("show_waypoints")
end

function EHI:IsXPTrackerEnabled()
    return self:GetOption("show_gained_xp") and not self:IsPlayingCrimeSpree()
end

function EHI:IsXPTrackerDisabled()
    return not self:IsXPTrackerEnabled()
end

function EHI:IsXPTrackerEnabledAndVisible()
    return self:IsXPTrackerEnabled() and not self:GetOption("show_xp_in_mission_briefing_only")
end

function EHI:IsXPTrackerHidden()
    return not self:IsXPTrackerEnabledAndVisible()
end

function EHI:AreGagePackagesSpawned()
    return self._cache.GagePackagesSpawned or false
end

function EHI:IsLootCounterVisible()
    return self:GetOption("show_loot_counter") and not self:IsPlayingCrimeSpree()
end

function EHI:IsPlayingCrimeSpree()
    return Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree"
end

function EHI:AssaultDelayTrackerIsEnabled()
    return self:GetOption("show_assault_delay_tracker") and not tweak_data.levels:IsLevelSkirmish()
end

---@return boolean
function EHI:CombineAssaultDelayAndAssaultTime()
    return self:GetOption("show_assault_delay_tracker") and self:GetOption("show_assault_time_tracker") and self:GetOption("aggregate_assault_delay_and_assault_time")
end

function EHI:IsTradeTrackerDisabled()
    return not self:GetOption("show_trade_delay") or self:IsPlayingSFN()
end

---@param params XPBreakdown
function EHI:AddXPBreakdown(params)
    if self:IsXPTrackerDisabled() or not managers.menu_component then
        return
    end
    if not managers.menu_component._mission_briefing_gui then
        self:AddCallback("MissionBriefingGuiInit", function(gui)
            gui:AddXPBreakdown(params)
        end)
        return
    end
    managers.menu_component._mission_briefing_gui:AddXPBreakdown(params)
end

---@param id string|number
---@param f function
function EHI:AddCallback(id, f)
    self.Callback[id] = self.Callback[id] or {}
    self.Callback[id][#self.Callback[id] + 1] = f
end

---@param id string|number
---@param ... any
function EHI:CallCallback(id, ...)
    for _, callback in ipairs(self.Callback[id] or {}) do
        callback(...)
    end
end

---Calls all callbacks, after that they are deleted from memory
---@param id string|number
---@param ... any
function EHI:CallCallbackOnce(id, ...)
    self:CallCallback(id, ...)
    self.Callback[id] = nil
end

---@param f fun(dropin: boolean)
function EHI:AddOnAlarmCallback(f)
    self:AddCallback("Alarm", f)
end

---@param dropin boolean
function EHI:RunOnAlarmCallbacks(dropin)
    self:CallCallbackOnce("Alarm", dropin)
end

---@param f fun(custody_state: boolean)
function EHI:AddOnCustodyCallback(f)
    self:AddCallback("Custody", f)
end

---@param custody_state boolean
function EHI:RunOnCustodyCallback(custody_state)
    self:CallCallback("Custody", custody_state)
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
---@param pre_call function
---@param post_call function
function EHI:PreHookAndHook(object, func, pre_call, post_call)
    self:PreHook(object, func, pre_call)
    self:Hook(object, func, post_call)
end

---@param object table
---@param func string
---@param id string
---@param pre_call function
---@param post_call function
function EHI:PreHookAndHookWithID(object, func, id, pre_call, post_call)
    self:PreHookWithID(object, func, id, pre_call)
    self:HookWithID(object, func, id, post_call)
end

---@param object table
---@param func string
---@param id string|number
---@param post_call function
function EHI:HookElement(object, func, id, post_call)
    Hooks:PostHook(object, func, "EHI_Element_" .. id, post_call)
end

---@param id string
function EHI:Unhook(id)
    Hooks:RemovePostHook("EHI_" .. id)
end

---Hooks elements that removes loot bags (due to fire or out of bounds)
---@param elements number|number[] Index or indices of ElementCarry that removes loot bags with operation "remove"
function EHI:HookLootRemovalElement(elements)
    if type(elements) ~= "table" and type(elements) ~= "number" then
        return
    end
    local f
    local HookFunction
    local ElementFunction
    local id
    if self:IsHost() then
        HookFunction = self.PreHookWithID
        ElementFunction = self.HostElement
        id = "EHI_Prehook_Element_"
        f = function(e, instigator, ...)
            if not e._values.enabled or not alive(instigator) then
                return
            end
            if e._values.type_filter and e._values.type_filter ~= "none" then
                local carry_ext = instigator:carry_data()
                if not carry_ext then
                    return
                end
                local carry_id = carry_ext:carry_id()
                if carry_id ~= e._values.type_filter then
                    return
                end
            end
            managers.ehi_tracker:DecreaseLootCounterProgressMax()
        end
    else
        HookFunction = self.HookWithID
        ElementFunction = self.ClientElement
        id = "EHI_Element_"
        f = function(...)
            managers.ehi_tracker:DecreaseLootCounterProgressMax()
        end
    end
    if type(elements) == "table" then
        for _, index in ipairs(elements) do
            local element = managers.mission:get_element_by_id(index)
            if element then
                HookFunction(self, element, ElementFunction, id .. tostring(index), f)
            end
        end
    else -- number
        local element = managers.mission:get_element_by_id(elements)
        if element then
            HookFunction(self, element, ElementFunction, id .. tostring(elements), f)
        end
    end
end

---@return boolean
function EHI:ShowDramaTracker()
    return self:IsHost() and self:GetOption("show_drama_tracker") and self:IsNotPlayingSFN()
end

---@return boolean
function EHI:IsRunningBB()
    return BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai
end

function EHI:IsRunningUsefulBots()
    if self:IsHost() then
        return UsefulBots and Global.game_settings.team_ai
    elseif self._cache.HostHasUsefulBots ~= nil then
        return self._cache.HostHasUsefulBots
    end
    return false
end

---@param peer_id number
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
    if continent_index then
        return continent_index + math.mod(id, 100000) + 30000 + start_index
    end
    return id + 30000 + start_index
end

---@param id number
---@param start_index number
---@param continent_index number?
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
---@param n number
---@param bracket number? Number in `*10` or `/10`
---@return number
function EHI:RoundNumber(n, bracket)
    bracket = bracket or 1
    local sign = n >= 0 and 1 or -1
    return math_floor(n / bracket + sign * 0.5) * bracket
end

---@param n number
function EHI:RoundChanceNumber(n)
    return self:RoundNumber(n, 0.01) * 100
end

---@param id number Element ID
---@return Vector3?
function EHI:GetElementPosition(id)
    local element = managers.mission:get_element_by_id(id)
    return element and element:value("position")
end

---@param id number Element ID
function EHI:GetElementPositionOrDefault(id)
    return self:GetElementPosition(id) or Vector3()
end

---@param id number Unit ID
---@return Vector3?
function EHI:GetUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    return unit and unit.position and unit:position()
end

---@param message string
---@param data any
function EHI:Sync(message, data)
    LuaNetworking:SendToPeersExcept(1, message, data or "")
end
---@param message string
---@param tbl table?
function EHI:SyncTable(message, tbl)
    LuaNetworking:SendToPeersExcept(1, message, LuaNetworking:TableToString(tbl or {}))
end
if Global.game_settings and Global.game_settings.single_player then
    EHI.Sync = function(...) end
    EHI.SyncTable = function(...) end
end

---@param triggers table
function EHI:SetSyncTriggers(triggers)
    managers.ehi_manager:SetSyncTriggers(triggers)
end

function EHI:AddSyncTrigger(id, trigger)
    managers.ehi_manager:AddSyncTrigger(id, trigger)
end

---@param tracker_id string
---@param unit Unit?
---@param key string
---@param amount number
---@param peer_id number?
function EHI:DebugEquipment(tracker_id, unit, key, amount, peer_id)
    self:Log("Received garbage. Key is nil. Tracker ID: " .. tracker_id)
    self:Log("unit: " .. tostring(unit))
    if unit and alive(unit) then
        self:Log("unit:name(): " .. tostring(unit:name()))
        self:Log("unit:key(): " .. tostring(unit:key()))
    end
    self:Log("key: " .. tostring(key))
    self:Log("amount: " .. tostring(amount))
    self:Log("Peer ID: " .. tostring(peer_id))
    self:Log(debug.traceback())
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

---Adds trigger to mission element when they run
---@param new_triggers table
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHI:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
end

---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table
---@param params table?
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHI:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table
---@param type string
---|"base" # Random delay is defined in the BASE DELAY
---|"element" # Random delay is defined when calling the elements
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:AddHostTriggers(new_triggers, type, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:AddHostTriggers(new_triggers, type, trigger_id_all, trigger_icons_all)
end

---@param id number
---@param waypoint table
function EHI:AddWaypointToTrigger(id, waypoint)
    managers.ehi_manager:AddWaypointToTrigger(id, waypoint)
end

---@param id number
---@param f fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return nil
---@overload fun(self, f: fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)): integer
function EHI:RegisterCustomSF(id, f)
    return managers.ehi_manager:RegisterCustomSF(id, f)
end

---Unregisters custom special function
---@param id number
function EHI:UnregisterCustomSF(id)
    managers.ehi_manager:UnregisterCustomSF(id)
end

---@param id number
---@param f fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return nil
---@overload fun(self, f: fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)): integer
function EHI:RegisterCustomSyncedSF(id, f)
    return managers.ehi_manager:RegisterCustomSyncedSF(id, f)
end

function EHI:GetFreeCustomSFID()
    local id = (self._cache.SFFUsed or self.SpecialFunctions.CustomSF) + 1
    self._cache.SFFUsed = id
    return id
end

function EHI:GetFreeCustomSyncedSFID()
    local id = (self._cache.SyncedSFFUsed or self.SpecialFunctions.CustomSyncedSF) + 1
    self._cache.SyncedSFFUsed = id
    return id
end

---@param elements_to_hook table
function EHI:HookElements(elements_to_hook)
    managers.ehi_manager:HookElements(elements_to_hook)
end

---@param chance number
---@param check_if_does_not_exist boolean?
---@return ElementTrigger
function EHI:AddEscapeChance(chance, check_if_does_not_exist)
    local tbl =
    {
        id = "EscapeChance",
        chance = chance,
        icons = { { icon = self.Icons.Car, color = Color.red } },
        hint = "van_crash_chance",
        special_function = check_if_does_not_exist and self.SpecialFunctions.AddTrackerIfDoesNotExist,
        class = EHI.Trackers.Chance
    }
    return tbl
end

---@param params ElementTrigger
---@return ElementTrigger?
function EHI:AddAssaultDelay(params)
    if not self:GetOption("show_assault_delay_tracker") then
        if params.special_function and params.special_function > SF.CustomSF then
            self:UnregisterCustomSF(params.special_function)
        end
        return nil
    end
    local id = "AssaultDelay"
    local class = self.Trackers.Assault.Delay
    local hint = "assault_delay"
    local pos = nil
    if self:CombineAssaultDelayAndAssaultTime() then
        id = "Assault"
        class = self.Trackers.Assault.Assault
        pos = 0
        hint = "assault"
    elseif params.random_time then
        class = "EHIInaccurateAssaultDelayTracker"
    end
    local tbl = {}
    -- Copy every passed value to the trigger
    for key, value in pairs(params) do
        tbl[key] = value
    end
    if params.random_time then
        tbl.additional_time = tbl.additional_time or 30
    else
        tbl.time = tbl.time or 30
    end
    tbl.id = id
    tbl.class = class
    tbl.pos = pos
    tbl.hint = hint
    return tbl
end

---@param f function Loot counter function
---@param check boolean? Boolean value of option 'show_loot_counter'
---@param load_sync fun(self: EHIManager)? Load sync function for clients
---@param trigger_once boolean? Should the trigger run once?
---@return table?
function EHI:AddLootCounter(f, check, load_sync, trigger_once)
    if self:IsPlayingCrimeSpree() then
        return nil
    elseif check ~= nil and check == false then
        return nil
    elseif not self:GetOption("show_loot_counter") then
        return nil
    end
    local tbl =
    {
        special_function = SF.CustomCode,
        f = f
    }
    if trigger_once then
        tbl.trigger_times = 1
    end
    if load_sync then
        self:AddLoadSyncFunction(load_sync)
    end
    return tbl
end

---@param f function Loot counter function
---@param load_sync fun(self: EHIManager)? Load sync function for clients
---@param trigger_once boolean? Should the trigger run once?
---@return ElementTrigger
function EHI:AddLootCounter2(f, load_sync, trigger_once)
    local tbl =
    {
        special_function = SF.CustomCode,
        f = f
    }
    if trigger_once then
        tbl.trigger_times = 1
    end
    if load_sync then
        self:AddLoadSyncFunction(load_sync)
    end
    return tbl
end

---@param f fun(self: EHIManager, trigger: table, element: table, enabled: boolean) Loot counter function
---@param trigger_once boolean? Should the trigger run once?
---@return table
function EHI:AddLootCounter3(f, trigger_once)
    local tbl =
    {
        special_function = self:RegisterCustomSF(f)
    }
    if trigger_once then
        tbl.trigger_times = 1
    end
    return tbl
end

---@param f fun(self: EHIManager, trigger: table, element: table, enabled: boolean) Loot Counter function
---@param sequence_triggers table<number, LootCounterTable.SequenceTriggersTable> If the Loot Counter is not enabled, hook the sequence triggers so the syncing will still work
---@param loot_counter_data_function fun(self: EHIManager, trigger: table, element: table, enabled: boolean) If the Loot Counter is not enabled, sync the data to clients so the syncing will still work. The provided function `HAS TO SYNC` tracker creation so it will work on clients
---@return table?
function EHI:AddLootCounterSynced(f, sequence_triggers, loot_counter_data_function)
    if self:IsPlayingCrimeSpree() then
        return nil
    end
    local special_function
    if self:GetOption("show_loot_counter") then
        special_function = self:RegisterCustomSF(f)
    else
        self:HookLootCounterSequenceTriggers(sequence_triggers)
        special_function = self:RegisterCustomSF(loot_counter_data_function)
    end
    local tbl =
    {
        special_function = special_function,
        trigger_times = 1
    }
    return tbl
end

---@param f fun(self: EHIManager, trigger: table, element: table, enabled: boolean) Loot Counter function
---@param sequence_triggers table If the Loot Counter is not enabled, hook the sequence triggers so the syncing will still work
---@param loot_counter_data table If the Loot Counter is not enabled, sync the data to clients so the syncing will still work
---@return table?
function EHI:AddLootCounterSynced2(f, sequence_triggers, loot_counter_data)
    if self:IsPlayingCrimeSpree() then
        return nil
    elseif not self:GetOption("show_loot_counter") then
        self:HookLootCounterSequenceTriggers(sequence_triggers)
        managers.ehi_tracker:SetTrackerToSync("LootCounter", loot_counter_data)
        return nil
    end
    local tbl =
    {
        special_function = self:RegisterCustomSF(f),
        trigger_times = 1
    }
    return tbl
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHI:AddPositionFromElement(data, id, check)
    local vector = self:GetElementPosition(data.position_by_element)
    if vector then
        data.position = vector
        data.position_by_element = nil
    elseif check then
        data.position = Vector3()
        self:Log(string.format("Element with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_element, tostring(id)))
    end
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHI:AddPositionFromUnit(data, id, check)
    local vector = self:GetUnitPosition(data.position_by_unit)
    if vector then
        data.position = vector
        data.position_by_unit = nil
    elseif check then
        data.position = Vector3()
        self:Log(string.format("Unit with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_unit, tostring(id)))
    end
end

---@param achievements table Table with achievements
---@param package string Beardlib package where achievements are stored
---@param exclude table? If the achievement table contains vanilla achievements, provide their ID so they don't get marked as from Beardlib
function EHI:PreparseBeardlibAchievements(achievements, package, exclude)
    exclude = exclude or {}
    for id, data in pairs(achievements or {}) do
        if not exclude[id] then
            data.beardlib = true
            data.package = package
        end
    end
end

---@param new_triggers ParseTriggersTable
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_assault:SetDiff(new_triggers.diff or 0)
end

---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHI:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    managers.ehi_manager:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table
---@param defer_loading_waypoints boolean?
function EHI:ParseMissionInstanceTriggers(new_triggers, defer_loading_waypoints)
    managers.ehi_manager:ParseMissionInstanceTriggers(new_triggers, defer_loading_waypoints)
end

---@param triggers table<number, ElementTrigger>
---@param option string
---| "show_timers" Filters out not loaded trackers with option show_timers
function EHI:FilterOutNotLoadedTrackers(triggers, option)
    managers.ehi_manager:FilterOutNotLoadedTrackers(triggers, option)
end

---@return boolean
function EHI:ShouldDisableWaypoints()
    return self:GetOption("show_timers") and self:GetWaypointOption("show_waypoints_timers")
end

---@param id number
function EHI:DisableElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id) ---@cast element ElementWaypoint?
    if not element or self._cache.ElementWaypoint[id] then
        return
    end
    if not element.ehi_on_executed then
        self:Log(string.format("Provided id %s is not an ElementWaypoint!", tostring(id)))
        return
    end
    element.on_executed = element.ehi_on_executed
    self._cache.ElementWaypoint[id] = true
end

---@param id number
function EHI:RestoreElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id) ---@cast element ElementWaypoint?
    if not (element and self._cache.ElementWaypoint[id]) then
        return
    end
    element.on_executed = element.original_on_executed
    self._cache.ElementWaypoint[id] = nil
end

---@param waypoints table<number, boolean>
function EHI:CacheDisabledWaypoints(waypoints)
    if self.DisableOnLoad then
        for id, _ in pairs(waypoints) do
            self.DisableOnLoad[id] = true
        end
    else
        self.DisableOnLoad = waypoints
    end
    for id, _ in pairs(waypoints) do
        self._cache.IgnoreWaypoints[id] = true
    end
end

---@param waypoints table<number, boolean>?
function EHI:DisableWaypoints(waypoints)
    if not self:ShouldDisableWaypoints() or waypoints == nil then
        return
    end
    self:CacheDisabledWaypoints(waypoints)
end

---@param waypoints table<number, boolean>?
function EHI:DisableMissionWaypoints(waypoints)
    if not self:GetOption("show_mission_trackers") or waypoints == nil then
        return
    end
    self:CacheDisabledWaypoints(waypoints)
end

function EHI:DisableWaypointsOnInit()
    for id, _ in pairs(self.DisableOnLoad or {}) do
        self:DisableElementWaypoint(id)
    end
end

-- Used on clients when offset is required  
-- Do not call it directly!
---@param params LootCounterTable
---@param manager EHIManager
function EHI:ShowLootCounterOffset(params, manager)
    params.offset = nil
    params.n_offset = managers.loot:GetSecuredBagsAmount()
    params.hook_triggers = params.triggers ~= nil
    self:ShowLootCounterNoChecks(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounter(params)
    if not self:GetOption("show_loot_counter") then
        return
    end
    self:ShowLootCounterNoCheck(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounterNoCheck(params)
    if self:IsPlayingCrimeSpree() then
        return
    end
    self:ShowLootCounterNoChecks(params)
end

---@param params LootCounterTable?
function EHI:ShowLootCounterNoChecks(params)
    params = params or {}
    local n_offset = params.n_offset or 0
    if params.offset then
        if self:IsHost() or params.client_from_start then
            n_offset = managers.loot:GetSecuredBagsAmount()
        else
            managers.ehi_manager:AddFullSyncFunction(callback(self, self, "ShowLootCounterOffset", params))
            return
        end
    end
    if params.sequence_triggers or params.is_synced then
        managers.ehi_tracker:SyncShowLootCounter(params.max, params.max_random, n_offset)
    elseif params.max_bags_for_level and EHI:IsXPTrackerEnabledAndVisible() then
        if params.max_bags_for_level.objective_triggers then
            local xp_trigger = { special_function = self:RegisterCustomSF(function(manager, trigger, element, enabled)
                if enabled then
                    manager._trackers:CallFunction(trigger.id, "ObjectiveXPAwarded", element._values.amount or 0)
                end
            end) }
            local triggers = {}
            for _, id in ipairs(params.max_bags_for_level.objective_triggers) do
                triggers[id] = xp_trigger
            end
            self:AddTriggers2(triggers, nil, "LootCounter")
            params.max_bags_for_level.objective_triggers = nil
        end
        managers.ehi_tracker:ShowLootCounter(0, 0, 0, false, params.max_bags_for_level)
    else
        managers.ehi_tracker:ShowLootCounter(params.max, params.max_random, n_offset, params.no_max)
    end
    if params.load_sync then
        self:AddLoadSyncFunction(params.load_sync)
        params.no_sync_load = true
    end
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, "LootCounter")
        if params.hook_triggers then
            self:HookElements(params.triggers)
        end
    end
    if params.sequence_triggers then
        self:HookLootCounterSequenceTriggers(params.sequence_triggers)
    end
    if params.max_bags_for_level and params.max_bags_for_level.custom_counter then
        params.max_bags_for_level.custom_counter.achievement = "LootCounter"
        self:AddAchievementToCounter(params.max_bags_for_level.custom_counter)
    else
        self:HookLootCounter(params.no_sync_load)
    end
end

---@param params LootCounterTable
function EHI:ShowLootCounterSynced(params)
    if self:IsPlayingCrimeSpree() then
        return
    elseif not self:GetOption("show_loot_counter") then
        self:AddTriggers2(params.triggers or {}, nil, "LootCounter")
        self:HookLootCounterSequenceTriggers(params.sequence_triggers or {})
        managers.ehi_tracker:SetTrackerToSync("LootCounter", {
            max = params.max or 0,
            max_random = params.max_random or 0,
            offset = params.offset and managers.loot:GetSecuredBagsAmount()
        })
        return
    end
    params.is_synced = true
    self:ShowLootCounterNoChecks(params)
end

---@param sequence_triggers table<number, LootCounterTable.SequenceTriggersTable>
function EHI:HookLootCounterSequenceTriggers(sequence_triggers)
    local function IncreaseMax(...)
        managers.ehi_tracker:SyncRandomLootSpawned()
    end
    local function DecreaseRandom(...)
        managers.ehi_tracker:SyncRandomLootDeclined()
    end
    for unit_id, sequences in pairs(sequence_triggers) do
        for _, sequence in ipairs(sequences.loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, IncreaseMax)
        end
        for _, sequence in ipairs(sequences.no_loot or {}) do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, DecreaseRandom)
        end
    end
end

---@param no_sync_load boolean?
function EHI:HookLootCounter(no_sync_load)
    if not self._cache.LootCounter then
        local BagsOnly = self.LootCounter.CheckType.BagsOnly
        ---@param loot LootManager
        self:AddCallback(self.CallbackMessage.LootSecured, function(loot)
            loot:EHIReportProgress("LootCounter", BagsOnly)
        end)
        -- If sync load is disabled, the counter needs to be updated via EHIManager:AddLoadSyncFunction() to properly show number of secured loot
        -- Usually done in heists which have additional loot that spawns depending on random chance; example: Red Diamond in Diamond Heist (Classic)
        if not no_sync_load then
            ---@param loot LootManager
            self:AddCallback(self.CallbackMessage.LootLoadSync, function(loot)
                loot:EHIReportProgress("LootCounter", BagsOnly)
                managers.ehi_tracker:CallFunction("LootCounter", "CheckCanDeleteAfterSync")
            end)
        end
        self._cache.LootCounter = true
    end
end

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked(params.achievement) or params.difficulty_pass == false then
        if params.show_loot_counter then
            self:ShowLootCounter({ max = params.max, triggers = params.loot_counter_triggers, load_sync = params.loot_counter_load_sync })
        end
        return
    end
    self:ShowAchievementLootCounterNoCheck(params)
end

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounterNoCheck(params)
    if params.show_loot_counter and self:GetOption("show_loot_counter") then
        managers.ehi_achievement:AddAchievementLootCounter(params.achievement, params.max, params.loot_counter_on_fail, params.start_silent)
    else
        managers.ehi_achievement:AddAchievementProgressTracker(params.achievement, params.max, params.progress, params.show_finish_after_reaching_target, params.class)
    end
    if params.load_sync then
        self:AddLoadSyncFunction(params.load_sync)
    end
    if params.alarm_callback then
        self:AddOnAlarmCallback(params.alarm_callback)
    end
    if params.failed_on_alarm then
        self:AddOnAlarmCallback(function()
            managers.ehi_achievement:SetAchievementFailed(params.achievement)
        end)
    end
    if params.silent_failed_on_alarm then
        self:AddOnAlarmCallback(function()
            if managers.ehi_manager:GetInSyncState() then
                managers.ehi_achievement:SetAchievementFailedSilent(params.achievement)
            else
                managers.ehi_achievement:SetAchievementFailed(params.achievement)
            end
        end)
    end
    if params.triggers then
        self:AddTriggers2(params.triggers, nil, params.achievement)
        if params.hook_triggers then
            self:HookElements(params.triggers)
        end
        if params.add_to_counter then
            self:AddAchievementToCounter(params)
        end
        return
    elseif params.no_counting then
        return
    end
    self:AddAchievementToCounter(params)
end

---@param params AchievementBagValueCounterTable
function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked(params.achievement) then
        return
    end
    managers.ehi_achievement:AddAchievementBagValueCounter(params.achievement, params.value, params.show_finish_after_reaching_target)
    self:AddAchievementToCounter(params)
end

---@param params AchievementLootCounterTable|AchievementBagValueCounterTable
function EHI:AddAchievementToCounter(params)
    local check_type, loot_type, f = self.LootCounter.CheckType.BagsOnly, nil, nil
    if params.counter then
        check_type = params.counter.check_type or self.LootCounter.CheckType.BagsOnly
        loot_type = params.counter.loot_type
        f = params.counter.f
    end
    ---@param loot LootManager
    self:AddCallback(self.CallbackMessage.LootSecured, function(loot)
        loot:EHIReportProgress(params.achievement, check_type, loot_type, f)
    end)
    if not (params.load_sync or params.no_sync) then
        ---@param loot LootManager
        self:AddCallback(self.CallbackMessage.LootLoadSync, function(loot)
            loot:EHIReportProgress(params.achievement, check_type, loot_type, f)
            managers.ehi_tracker:CallFunction(params.achievement, "CheckCanDeleteAfterSync")
        end)
    end
end

---@param params AchievementKillCounterTable
function EHI:ShowAchievementKillCounter(params)
    if params.achievement_option and not self:GetUnlockableAndOption(params.achievement_option) then
        return
    end
    if self._cache.UnlockablesAreDisabled or self._cache.DisableAchievements or self:IsAchievementUnlocked2(params.achievement) or params.difficulty_pass == false then
        self:Log("Achievement disabled! id: " .. tostring(params.achievement))
        return
    end
    local id = params.achievement
    local id_stat = params.achievement_stat
    local tweak_data = tweak_data.achievement.persistent_stat_unlocks[id_stat]
    if not tweak_data then
        self:Log("No statistics found for achievement " .. tostring(id) .. "; Stat: " .. tostring(id_stat))
        return
    end
    local progress = self:GetAchievementProgress(id_stat)
    local max = tweak_data[1] and tweak_data[1].at or 0
    if progress >= max then
        self:Log("Achievement already unlocked; return")
        self:Log(string.format("progress: %d; max: %d", progress, max))
        return
    end
    managers.ehi_achievement:AddAchievementKillCounter(id, progress, max)
    self.KillCounter = self.KillCounter or {}
    self.KillCounter[id_stat] = id
    if not self.KillCounterHook then
        EHI:HookWithID(AchievmentManager, "award_progress", "EHI_award_progress_KillCounter", function(am, stat, value)
            local s = EHI.KillCounter[stat]
            if s then
                managers.ehi_tracker:IncreaseTrackerProgress(s, value)
            end
        end)
        self.KillCounterHook = true
    end
end

---@param f fun(self: EHIManager)
function EHI:AddLoadSyncFunction(f)
    managers.ehi_manager:AddLoadSyncFunction(f)
end

function EHI:FinalizeUnitsClient()
    self:FinalizeUnits(self._cache.MissionUnits)
    self:FinalizeUnits(self._cache.InstanceMissionUnits)
    self:FinalizeUnits(self._cache.InstanceUnits)
end

---@param tbl table<number, UnitUpdateDefinition>
function EHI:FinalizeUnits(tbl)
    local wd = managers.worlddefinition
    for id, unit_data in pairs(tbl) do
        local unit = wd:get_unit(id) --[[@as UnitTimer|UnitDigitalTimer?]]
        if unit then
            if unit_data.f then
                if type(unit_data.f) == "string" then
                    wd[unit_data.f](wd, id, unit_data, unit)
                else
                    unit_data.f(id, unit_data, unit)
                end
            else
                local timer_gui = unit:timer_gui()
                local digital_gui = unit:digital_gui()
                if timer_gui and timer_gui._ehi_key then
                    if unit_data.child_units then
                        timer_gui:SetChildUnits(unit_data.child_units, wd)
                    end
                    timer_gui:SetIcons(unit_data.icons)
                    timer_gui:SetRemoveOnPowerOff(unit_data.remove_on_power_off)
                    if unit_data.remove_on_alarm then
                        timer_gui:SetOnAlarm()
                    end
                    if unit_data.remove_vanilla_waypoint then
                        timer_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
                        if unit_data.restore_waypoint_on_done then
                            timer_gui:SetRestoreVanillaWaypointOnDone()
                        end
                    end
                    if unit_data.ignore_visibility then
                        timer_gui:SetIgnoreVisibility()
                    end
                    if unit_data.set_custom_id then
                        timer_gui:SetCustomID(unit_data.set_custom_id)
                    end
                    if unit_data.tracker_merge_id then
                        timer_gui:SetTrackerMergeID(unit_data.tracker_merge_id, unit_data.destroy_tracker_merge_on_done)
                    end
                    if unit_data.custom_callback then
                        timer_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.hint then
                        timer_gui:SetHint(unit_data.hint)
                    end
                    timer_gui:SetWaypointPosition(unit_data.position)
                    timer_gui:Finalize()
                end
                if digital_gui and digital_gui._ehi_key then
                    digital_gui:SetIcons(unit_data.icons)
                    digital_gui:SetIgnore(unit_data.ignore)
                    digital_gui:SetRemoveOnPause(unit_data.remove_on_pause)
                    digital_gui:SetWarning(unit_data.warning)
                    digital_gui:SetCompletion(unit_data.completion)
                    if unit_data.remove_on_alarm then
                        digital_gui:SetOnAlarm()
                    end
                    if unit_data.custom_callback then
                        digital_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.icon_on_pause then
                        digital_gui:SetIconOnPause(unit_data.icon_on_pause[1])
                    end
                    if unit_data.remove_vanilla_waypoint then
                        digital_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
                    end
                    if unit_data.ignore_visibility then
                        digital_gui:SetIgnoreVisibility()
                    end
                    if unit_data.hint then
                        digital_gui:SetHint(unit_data.hint)
                    end
                    digital_gui:Finalize()
                end
            end
            -- Clear configured unit from the table
            tbl[id] = nil
        end
    end
end

---@param tbl table<number, UnitUpdateDefinition>
function EHI:UpdateUnits(tbl)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateUnitsNoCheck(tbl)
end

---@param tbl table<number, UnitUpdateDefinition>
function EHI:UpdateUnitsNoCheck(tbl)
    self:FinalizeUnits(tbl)
    for id, data in pairs(tbl) do
        self._cache.MissionUnits[id] = data
    end
end

---@param tbl table<number, UnitUpdateDefinition>
---@param skip_finalize boolean
function EHI:UpdateInstanceMissionUnits(tbl, skip_finalize)
    if not self:GetOption("show_timers") then
        return
    end
    if not skip_finalize then
        self:FinalizeUnits(tbl)
    end
    for id, data in pairs(tbl) do
        self._cache.InstanceMissionUnits[id] = data
    end
end

---@param tbl table<number, UnitUpdateDefinition>
---@param instance_start_index number
---@param instance_continent_index number? Defaults to `100000` if not provided
function EHI:UpdateInstanceUnits(tbl, instance_start_index, instance_continent_index)
    if not self:GetOption("show_timers") then
        return
    end
    self:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
end

---@param tbl table<number, UnitUpdateDefinition>
---@param instance_start_index number
---@param instance_continent_index number? Defaults to `100000` if not provided
function EHI:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
    local new_tbl = {} ---@type ParseUnitsTable
    instance_continent_index = instance_continent_index or 100000
    for id, data in pairs(tbl) do
        local computed_id = self:GetInstanceElementID(id, instance_start_index, instance_continent_index)
        local cloned_data = deep_clone(data)
        if cloned_data.remove_vanilla_waypoint then
            cloned_data.remove_vanilla_waypoint = self:GetInstanceElementID(cloned_data.remove_vanilla_waypoint, instance_start_index, instance_continent_index)
        end
        cloned_data.base_index = id
        new_tbl[computed_id] = cloned_data
    end
    self:FinalizeUnits(new_tbl)
    for id, data in pairs(new_tbl) do
        self._cache.InstanceUnits[id] = data
    end
end

---@param tbl MissionDoorTable
function EHI:SetMissionDoorData(tbl)
    if TimerGui.SetMissionDoorData then
        TimerGui.SetMissionDoorData(tbl)
    end
end

function EHI:CheckNotLoad()
    if Global.load_level and not Global.editor_mode then
        return false
    end
    return true
end

---@param hook string
function EHI:CheckLoadHook(hook)
    if not Global.load_level or Global.editor_mode then
        return true
    end
    if self._hooks[hook] then
        return true
    end
    self._hooks[hook] = true
    return false
end

---@param hook string
function EHI:CheckHook(hook)
    if self._hooks[hook] or Global.editor_mode then
        return true
    end
    self._hooks[hook] = true
    return false
end

---Returns default keypad time reset for the current difficulty  
---Default values:  
---`normal = 5s`  
---`hard = 15s`  
---`veryhard = 15s`  
---`overkill = 20s`  
---`mayhem = 30s`  
---`deathwish = 30s`  
---`deathsentence = 40s`  
---@param time_override KeypadResetTimerTable? Overrides default keypad time reset for each difficulty
---@return number
function EHI:GetKeypadResetTimer(time_override)
    time_override = time_override or {}
    if self:IsDifficulty(self.Difficulties.Normal) then
        return time_override.normal or 5
    elseif self:IsDifficulty(self.Difficulties.Hard) then
        return time_override.hard or 15
    elseif self:IsDifficulty(self.Difficulties.VeryHard) then
        return time_override.veryhard or 15
    elseif self:IsDifficulty(self.Difficulties.OVERKILL) then
        return time_override.overkill or 20
    elseif self:IsDifficulty(self.Difficulties.Mayhem) then
        return time_override.mayhem or 30
    elseif self:IsDifficulty(self.Difficulties.DeathWish) then
        return time_override.deathwish or 30
    else
        return time_override.deathsentence or 40
    end
end

---Returns value for the current difficulty. If the value is not provided `-1` is returned
---@generic T
---@param values ValueBasedOnDifficultyTable
---@return T|number
function EHI:GetValueBasedOnDifficulty(values)
    if values.normal_or_above and self:IsDifficultyOrAbove(self.Difficulties.Normal) then
        return values.normal_or_above
    elseif self:IsDifficulty(self.Difficulties.Normal) then
        return values.normal or -1
    elseif values.hard_or_below and self:IsDifficultyOrBelow(self.Difficulties.Hard) then
        return values.hard_or_below
    elseif values.hard_or_above and self:IsDifficultyOrAbove(self.Difficulties.Hard) then
        return values.hard_or_above
    elseif self:IsDifficulty(self.Difficulties.Hard) then
        return values.hard or -1
    elseif values.veryhard_or_below and self:IsDifficultyOrBelow(self.Difficulties.VeryHard) then
        return values.veryhard_or_below
    elseif values.veryhard_or_above and self:IsDifficultyOrAbove(self.Difficulties.VeryHard) then
        return values.veryhard_or_above
    elseif self:IsDifficulty(self.Difficulties.VeryHard) then
        return values.veryhard or -1
    elseif values.overkill_or_below and self:IsDifficultyOrBelow(self.Difficulties.OVERKILL) then
        return values.overkill_or_below
    elseif values.overkill_or_above and self:IsDifficultyOrAbove(self.Difficulties.OVERKILL) then
        return values.overkill_or_above
    elseif self:IsDifficulty(self.Difficulties.OVERKILL) then
        return values.overkill or -1
    elseif values.mayhem_or_below and self:IsDifficultyOrBelow(self.Difficulties.Mayhem) then
        return values.mayhem_or_below
    elseif values.mayhem_or_above and self:IsMayhemOrAbove() then
        return values.mayhem_or_above
    elseif self:IsDifficulty(self.Difficulties.Mayhem) then
        return values.mayhem or -1
    elseif values.deathwish_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathWish) then
        return values.deathwish_or_below
    elseif values.deathwish_or_above and self:IsDifficultyOrAbove(self.Difficulties.DeathWish) then
        return values.deathwish_or_above
    elseif self:IsDifficulty(self.Difficulties.DeathWish) then
        return values.deathwish or -1
    elseif values.deathsentence_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathSentence) then
        return values.deathsentence_or_below
    else
        return values.deathsentence or -1
    end
end

---@param trigger ElementTrigger?
---@param params ElementTrigger?
---@param overwrite_SF number?
---@return ElementTrigger?
function EHI:CopyTrigger(trigger, params, overwrite_SF)
    if trigger == nil then
        return nil
    end
    local tbl = deep_clone(trigger)
    for key, value in pairs(params or {}) do
        tbl[key] = value
    end
    if overwrite_SF then
        tbl.special_function = overwrite_SF
    end
    return tbl
end

---@param trigger ElementTrigger?
---@param params ElementTrigger?
---@param overwrite_SF boolean?
---@return ElementTrigger?
function EHI:ClientCopyTrigger(trigger, params, overwrite_SF)
    if trigger == nil then
        return nil
    end
    local new_SF
    if overwrite_SF or not trigger.special_function then
        new_SF = SF.AddTrackerIfDoesNotExist
    end
    return self:CopyTrigger(trigger, params, new_SF)
end

---@param type string
---|"ammo_bag" # Ignore ammo bags
---@param pos Vector3[] Table with positions that should be ignored
function EHI:SetDeployableIgnorePos(type, pos)
    if not type then
        self:Log("[EHI:SetDeployableIgnorePos()] Type is nil")
        return
    end
    if type == "ammo_bag" and AmmoBagBase.SetIgnoredPos then
        AmmoBagBase.SetIgnoredPos(pos)
    end
end

---@param level_id string
---@return boolean
function EHI:EscapeVehicleWillReturn(level_id)
    if self:IsHost() and SWAYRMod and SWAYRMod.included(level_id) then
        return false
    end
    return true
end

function EHI:CanShowCivilianCountTracker()
    return self:GetOption("show_civilian_count_tracker") and not tweak_data.levels:IsLevelSafehouse() and not self.NoCivilianCounter[Global.game_settings.level_id]
end

---@param color_table { ["red"]: number|boolean|EHI.ColorTable.Color, ["blue"]: number|boolean|EHI.ColorTable.Color, ["green"]: number|boolean|EHI.ColorTable.Color }
---@param params EHI.ColorTable.params?
function EHI:HookColorCodes(color_table, params)
    params = params or {}
    if not (params.no_mission_check or self:GetOption("show_mission_trackers")) then
        return
    end
    local tracker_name = params.tracker_name or "ColorCodes"
    local color_sequence_hash = {} -- Precache the sequence functions from provided colors
    for color, _ in pairs(color_table) do
        local sequences = {}
        for i = 0, 9, 1 do
            sequences[i] = string.format("set_%s_0%d", color, i)
        end
        color_sequence_hash[color] = sequences
    end
    ---@param unit_id number
    ---@param color string
    local function hook(unit_id, color)
        local sequences = color_sequence_hash[color]
        for i = 0, 9, 1 do
            local sequence = sequences[i]
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequence, function(...)
                managers.ehi_tracker:CallFunction(tracker_name, "SetCode", color, i)
            end)
        end
    end
    for color, data in pairs(color_table) do
        if type(data) == "boolean" and data then
            hook(params.unit_id_all or 0, color)
        elseif type(data) == "number" then
            hook(self:GetInstanceUnitID(params.unit_id_all or 0, data), color)
        elseif data.unit_ids then
            for _, unit_id in ipairs(data.unit_ids) do
                local u_id = params.unit_id_all or unit_id
                if data.indexes then
                    for _, index in ipairs(data.indexes) do
                        hook(self:GetInstanceUnitID(u_id, index), color)
                    end
                elseif data.index then
                    hook(self:GetInstanceUnitID(u_id, data.index), color)
                else
                    hook(u_id, color)
                end
            end
        else
            local unit_id = params.unit_id_all or data.unit_id
            if data.indexes then
                for _, index in ipairs(data.indexes) do
                    hook(self:GetInstanceUnitID(unit_id, index), color)
                end
            elseif data.index then
                hook(self:GetInstanceUnitID(unit_id, data.index), color)
            else
                hook(unit_id, color)
            end
        end
    end
end

---@param time number|table
---@param trigger_name string?
---@param include_loud_check boolean?
function EHI:AddEndlessAssault(time, trigger_name, include_loud_check)
    ---@type ElementTrigger
    local tbl =
    {
        id = trigger_name or "EndlessAssault",
        icons = self.Icons.EndlessAssault,
        class = self.Trackers.Warning,
        hint = self.Hints.EndlessAssault
    }
    if type(time) == "number" then
        tbl.time = time
    else
        local start_t = time[1]
        tbl.additional_time = start_t
        tbl.random_time = time[2] - start_t
    end
    if include_loud_check then
        tbl.condition_function = self.ConditionFunctions.IsLoud
    end
    return tbl
end

---@return boolean
function EHI:IsHeistTimerInverted()
    return self._cache._heist_timer_inverted
end

Load()
if EHI:GetUnlockableOption("hide_unlocked_achievements") then
    local G = Global
    ---@param achievement string
    ---@return boolean
    function EHI:IsAchievementUnlocked(achievement)
        local a = G.achievment_manager.achievments[achievement]
        return a and a.awarded
    end
    ---@param package_id string
    ---@param achievement_id string
    ---@return boolean
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        return not self:IsBeardLibAchievementLocked(package_id, achievement_id)
    end
else -- Always show trackers for achievements
    ---@param achievement string
    ---@return boolean
    function EHI:IsAchievementUnlocked(achievement)
        return false
    end
    ---@param package_id string
    ---@param achievement_id string
    ---@return boolean
    function EHI:IsBeardLibAchievementUnlocked(package_id, achievement_id)
        self:IsBeardLibAchievementLocked(package_id, achievement_id, true)
        return false
    end
end

if EHI:GetUnlockableOption("hide_unlocked_trophies") then
    ---@param trophy string
    ---@return boolean
    function EHI:IsTrophyUnlocked(trophy)
        return managers.custom_safehouse:is_trophy_unlocked(trophy)
    end
else
    ---@param trophy string
    ---@return boolean
    function EHI:IsTrophyUnlocked(trophy)
        return false
    end
end

---@param daily_id string
---@param skip_unlockables_check boolean?
function EHI:IsSFDailyAvailable(daily_id, skip_unlockables_check)
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily_id then
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

---@param daily_id string
---@param progress_id string?
---@return number, number
function EHI:GetSFDailyProgressAndMax(daily_id, progress_id)
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily_id then
        progress_id = progress_id or daily_id
        for _, objective in ipairs(current_daily.trophy.objectives) do
            if objective.progress_id == progress_id then
                return objective.progress, objective.max_progress
            end
        end
    end
    return 0, 0
end

---@param challenge string
---@return boolean
function EHI:IsDailyJobAvailable(challenge)
    if managers.challenge:has_active_challenges(challenge) then
        local c = managers.challenge:get_active_challenge(challenge) ---@cast c -?
        if c.completed or c.rewarded then
            return false
        end
        return true
    end
    return false
end

---@param daily_id string
---@param progress_id string?
---@return number, number
function EHI:GetDailyJobProgressAndMax(daily_id, progress_id)
    local current_job = managers.challenge:get_challenge(daily_id)
    if current_job and current_job.id == daily_id and current_job.objectives then
        progress_id = progress_id or daily_id
        for _, objective in ipairs(current_job.objectives) do
            if objective.progress_id == progress_id then
                return objective.progress, objective.max_progress
            end
        end
    end
    return 0, 0
end

---@param trophy string
---@return boolean
function EHI:IsTrophyLocked(trophy)
    return not self:IsTrophyUnlocked(trophy) and not self._cache.UnlockablesAreDisabled
end

---@param achievement string
---@return boolean
function EHI:IsAchievementLocked(achievement)
    return not self:IsAchievementUnlocked(achievement) and not self._cache.UnlockablesAreDisabled
end

---@param package_id string Package ID in Beardlib
---@param achievement_id string
---@param skip_check boolean?
function EHI:IsBeardLibAchievementLocked(package_id, achievement_id, skip_check)
    local Achievement = CustomAchievementPackage:new(package_id):Achievement(achievement_id)
    if not Achievement then
        return false
    end
    if Achievement:IsUnlocked() and not skip_check then
        return false
    end
    self._cache.Beardlib = self._cache.Beardlib or {}
    self._cache.Beardlib[achievement_id] = { name = Achievement:GetName(), objective = Achievement:GetObjective() }
    tweak_data.hud_icons["ehi_" .. achievement_id] = { texture = Achievement:GetIcon() }
    return true
end

---@param achievement string Achievement ID in Vanilla; Beardlib is not supported
function EHI:GetAchievementProgress(achievement)
    return managers.network.account:get_stat(achievement)
end

--- Used for achievements that has in the description "Kill X enemies in an heist" and etc... to show them only once  
--- This is done to prevent tracker spam if the player decides to replay the same heist with a similar weapon or weapon category  
--- Once the achievement has been awarded, the achievement will no longer show on the screen
---@param achievement string
---@return boolean
function EHI:IsAchievementLocked2(achievement)
    local a = Global.achievment_manager.achievments[achievement]
    return a and not a.awarded
end

---@param achievement string
---@return boolean
function EHI:IsAchievementUnlocked2(achievement)
    return not self:IsAchievementLocked2(achievement)
end

if EHI.debug.achievements then
    ---@param achievement string
    function EHI:IsAchievementLocked2(achievement)
        return true
    end
end

if EHI.debug.all_instances then -- For testing purposes
    ---@param instance_name string
    function EHI:DebugInstance(instance_name)
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

---@param tbl table
---@param ... any
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

---@param tbl table
---@param tables_to_ignore string|table
---@param ... any
function EHI:PrintTable2(tbl, tables_to_ignore, ...)
    local s = ""
    if ... then
        local _tbl = { ... }
        for _, _s in ipairs(_tbl) do
            s = s .. " " .. tostring(_s)
        end
    end
    if _G.PrintTableDeep then
        _G.PrintTableDeep(tbl, 5000, true, "[EHI]" .. s, tables_to_ignore, false)
    else
        if s ~= "" then
            self:Log(s)
        end
        _G.PrintTable(tbl)
    end
end