if _G.EHI then
    return
end

_G.EHI =
{
    debug =
    {
        achievements = false,
        all_instances = false,
        gained_experience = { enabled = false, log = true },
        created_waypoints = false
    },
    settings = {},

    OptionTracker =
    {
        show_timers =
        {
            file = "EHITimerTracker"
        },
        show_sniper_tracker =
        {
            file = "EHISniperTrackers"
        },
        show_captain_damage_reduction =
        {
            file = "EHIPhalanxDamageReductionTracker"
        },
        show_captain_spawn_chance =
        {
            file = "EHIPhalanxChanceTracker"
        },
        show_enemy_count_tracker =
        {
            file = "EHIEnemyCountTracker"
        },
        show_hostage_count_tracker =
        {
            file = "EHIHostageCountTracker"
        },
        show_escape_chance =
        {
            file = "EHIEscapeChanceTracker",
            count = 3
        },
        show_money_tracker =
        {
            file = "EHIMoneyTracker"
        },
        show_trade_delay =
        {
            file = "EHITradeDelayTracker",
            count = 4
        },
        show_trophies =
        {
            file = "EHITrophyTrackers"
        },
        show_minion_health =
        {
            file = "EHIMinionTracker"
        },
        show_ping_tracker =
        {
            file = "EHIPlayerPingTracker"
        }
    },

    _hooks = {},

    Const =
    {
        Trackers =
        {
            -- Used with options `tracker_alignment` or `vr_tracker_alignment`
            Alignment =
            {
                Vertical_TopToBottom = 1,
                Vertical_BottomToTop = 2,
                Vertical = { [1] = true, [2] = true }, -- There should be a better way to do this
                Horizontal_LeftToRight = 3,
                Horizontal_RightToLeft = 4,
                Horizontal = { [3] = true, [4] = true }
            },
            Achievement =
            {
                Status =
                {
                    Alarm = "alarm",
                    Defend = "defend",
                    Destroy = "destroy",
                    Find = "find",
                    Finish = "finish",
                    Kill = "kill",
                    Loud = "loud",
                    Mark = "mark",
                    Move = "move",
                    NoDown = "no_down",
                    Ok = "ok",
                    Ready = "ready",
                    Objective = "objective",
                    Push = "push",
                    Secure = "secure"
                }
            },
            -- Used with option `show_icon_position`
            IconStartPosition =
            {
                Left = 1,
                Right = 2
            },
            -- Used with option `tracker_hint_position`
            Hint =
            {
                v_right_h_down = 1,
                v_left_h_up = 2
            },
            Horizontal =
            {
                NewRCAnim =
                {
                    Top = 1,
                    Bottom = 2
                }
            },
            Vertical =
            {
                -- Used with option `tracker_vertical_w_anim`
                WidthAnim =
                {
                    LeftToRight = 1,
                    RightToLeft = 2
                }
            }
        },
        LootCounter =
        {
            CheckType =
            {
                BagsOnly = 1,
                ValueOfBags = 2,
                ValueOfSmallLoot = 3,
                CheckTypeOfLoot = 4,
                CustomCheck = 5,
                Debug = 6
            }
        },
        ---@enum GameEnd
        GameEnd =
        {
            Abort = 1,
            End = 2,
            Restart = 3
        }
    },

    _cache =
    {
        AchievementsDisabled = false,
        Mod = {} ---@type { [string]: true|false }
    },

    _callback = {}, ---@type table<string|number, CallbackEventHandler>
    CallbackMessage =
    {
        -- Provides `success` (a boolean value) -> MissionEndState
        MissionEnd = "MissionEnd",
        -- -> GamePlayCentralManager
        GameRestart = "GameRestart",
        -- -> MenuCallbackHandler:_dialog_end_game_yes() (quit game)
        GameAborted = "GameAborted",
        -- -> All network activity stopped (managers.network:session())
        GameEnd = "GameEnd",
        -- Provides `managers` (a global table with all managers)
        InitManagers = "InitManagers",
        InitFinalize = "InitFinalize",
        -- Provides `unit` (a UnitEnemy value), `local_peer` (a boolean value) and `peer_id` (a number value)
        OnMinionAdded = "OnMinionAdded",
        -- Provides `key` (a unit key; not put through `tostring`), `local_peer` (a boolean value) and `peer_id` (a number value)
        OnMinionKilled = "OnMinionKilled",
        -- Provides `skill` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAISkillChange = "TeamAISkillChanged",
        -- Provides `ability` (a string value) and `operation` (a string value -> `add`, `remove`)
        TeamAIAbilityChange = "TeamAIAbilityChanged",
        -- Provides `visibility` (a boolean value)
        HUDVisibilityChanged = "HUDVisibilityChanged",
        -- Provides `picked_up` (a number value), `max_units` (a number value) and `client_sync_load` (a boolean value)
        SyncGagePackagesCount = "SyncGagePackagesCount",
        -- Callbacks for anything related to UnitPlayer
        Player =
        {
            -- Provides `character_damage` (a PlayerDamage class)
            ArmorKitUsed = "PlayerDamageArmorKitUsed"
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
        SetTimeOrCreateTracker = 20,
        -- Requires `id` and `time`
        SetTimeOrCreateTrackerIfEnabled = 21,
        ExecuteIfElementIsEnabled = 22,
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
        ---@see EHIMissionElementTrigger.init
        ShowWaypoint = 51,
        -- Requires `id` and `max`
        DecreaseProgressMax = 52,
        -- Requires `id` and `progress`
        DecreaseProgress = 53,
        -- Requires `id`  
        -- Optional `count`
        IncreaseCounter = 54,
        -- Requires `id`
        DecreaseCounter = 55,
        -- Requires `id` and `count`
        SetCounter = 56,

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

        DebugElement = 1000,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)`
        CustomCode = 1001,
        -- Requires `f (function that accepts EHIMissionElementTrigger)`  
        -- Optional `arg (1 argument to pass to the function as a second argument)`
        CustomCode2 = 1002,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)`
        CustomCodeIfEnabled = 1003,
        -- Requires `f (function)`  
        -- Optional `arg (1 argument to pass to the function)` and `t`
        CustomCodeDelayed = 1004,

        -- Don't use it directly! Instead, call `EHI.Trigger:RegisterCustomSF()`
        CustomSF = 100000,
        CustomSyncedSF = 200000
    },

    ConditionFunctions =
    {
        ---Checks if loud is active
        IsLoud = function()
            return not managers.groupai:state():whisper_mode()
        end,
        ---Checks if stealth is active
        IsStealth = function()
            return managers.groupai:state():whisper_mode()
        end,
        ---Checks if playing from the start
        PlayingFromStart = function()
            return not managers.statistics:is_dropin()
        end
    },

    Hints =
    {
        -- Generic hints
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
        nmh_DestroyCameras = "nmh_destroy_cameras",
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
        ExclamationMark = "pd2_generic_look",

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
        -- Loaded on demand; load it manually if created in registered custom function or other trackers need it
        TimePreSync = "EHITimePreSyncTracker",
        Warning = "EHIWarningTracker",
        -- Optional `paused (boolean)`
        Pausable = "EHIPausableTracker",
        -- Optional `chance (number)`
        Chance = "EHIChanceTracker",
        -- Optional `count (number)`
        Counter = "EHICountTracker",
        -- Optional `max (number)` and `progress (number)`
        Progress = "EHIProgressTracker",
        NeededValue = "EHINeededValueTracker",
        Timed =
        {
            -- Optional `chance (number)`
            Chance = "EHITimedChanceTracker",
            -- Optional `max (number)`, `progress (number)` and `remove_on_max_progress (boolean)`
            Progress = "EHITimedProgressTracker",
            -- Optional `chance (number)`
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
            -- Optional `count` and `remaining_snipers`
            Count = "EHISniperCountTracker",
            -- Requires `chance`  
            -- Optional `chance_success` and `single_sniper`
            Chance = "EHISniperChanceTracker",
            -- Requires `time` and `refresh_t`
            Timed = "EHISniperTimedTracker",
            -- Requires `time`  
            -- Optional `count_on_refresh`
            TimedCount = "EHISniperTimedCountTracker",
            -- Requires `time`  
            -- Optional `count_on_refresh`
            TimedCountOnce = "EHISniperTimedCountOnceTracker",
            -- Requires `chance`, `time` and `recheck_t`   
            -- Optional `no_logic_annoucement`, `single_sniper`
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
            -- Optional `count`
            LoopBuffer = "EHISniperLoopBufferTracker",
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
        Assault = "EHIAssaultTracker",
        -- Loaded on demand; load it manually if created in registered custom function or other trackers need it
        Code = "EHICodeTracker",
        -- Loaded on demand; load it manually if created in registered custom function or other trackers need it
        ColoredCodes = "EHIColoredCodesTracker",
        Inaccurate = "EHIInaccurateTracker",
        InaccurateWarning = "EHIInaccurateWarningTracker",
        InaccuratePausable = "EHIInaccuratePausableTracker",
        Trophy = "EHITrophyTracker",
        SideJob =
        {
            Base = "EHISideJobTracker",
            Progress = "EHISideJobProgressTracker"
        },
        Group =
        {
            Base = "EHIGroupTracker",
            Warning = "EHIWarningGroupTracker",
            Progress = "EHIProgressGroupTracker"
        },
        Event =
        {
            Base = "EHIEventMissionTracker",
            Group = "EHIEventMissionGroupTracker"
        },
        -- Do not use it directly, it is here to provide base unlockable classes to be used for achievement, sidejob, trophy or event trackers
        Unlockable =
        {
            Base = "EHIUnlockableTracker",
            Progress = "EHIUnlockableProgressTracker",
            TimedProgress = "EHIUnlockableTimedProgressTracker"
        }
    },

    Waypoints =
    {
        Base = "EHIWaypoint",
        TimePreSync = "EHITimePreSyncWaypoint",
        Warning = "EHIWarningWaypoint",
        Progress = "EHIProgressWaypoint",
        Pausable = "EHIPausableWaypoint",
        Chance = "EHIChanceWaypoint",
        Inaccurate = "EHIInaccurateWaypoint",
        InaccuratePausable = "EHIInaccuratePausableWaypoint",
        InaccurateWarning = "EHIInaccurateWarningWaypoint",
        LootCounter =
        {
            Base = "EHILootWaypoint",
            Timed = "EHITimedLootWaypoint"
        },
        -- Loaded on demand; load it manually if created in registered custom function or other waypoints need it; depends on the tracker class (EHICodeTracker) that must be loaded first!
        Code = "EHICodeWaypoint",
        -- Loaded on demand; load it manually if created in registered custom function or other waypoints need it; depends on the tracker class (EHICodeTracker) that must be loaded first!
        ColoredCodes = "EHIColoredCodesWaypoint",
        Less =
        {
            Base = "EHIWaypointLessWaypoint",
            Chance = "EHIWaypointLessChanceWaypoint"
        }
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

    ModInstance = ModInstance,
    -- PAYDAY 2/mods/Extra Heist Info/
    ModPath = ModPath,
    -- PAYDAY 2/mods/Extra Heist Info/lua/
    LuaPath = ModPath .. "lua/",
    -- PAYDAY 2/mods/Extra Heist Info/menu/
    MenuPath = ModPath .. "menu/",
    -- PAYDAY 2/mods/saves/ehi.json
    SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "ehi.json",
    SaveDataVer = 1
}

---@param self table
local function LoadDefaultValues(self)
    self.settings =
    {
        mod_language = 1, -- Auto (default)

        -- Menu Only
        show_preview_text = true,
        show_preview_trackers = true,
        show_preview_buffs = true,

        -- Common
        x_offset = 0,
        y_offset = 150,
        text_scale = 1,
        scale = 1,
        time_format = 2, -- 1 = Seconds only, 2 = Minutes and seconds
        tracker_alignment = 1, -- 1 = Vertical; Top to Bottom, 2 = Vertical; Bottom to Top, 3 = Horizontal; Left to Right, 4 = Horizontal; Right to Left
        tracker_vertical_w_anim = 1, -- 1 = Left to Right; 2 = Right to Left
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
                drill_not_powered =
                {
                    r = 255,
                    g = 95,
                    b = 21
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
                },
                sniper_chance =
                {
                    r = 0,
                    g = 255,
                    b = 255
                },
                sniper_count =
                {
                    r = 255,
                    g = 165,
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
            },
            unlockables =
            {
                achievement =
                {
                    r = 255,
                    g = 184,
                    b = 78
                },
                sidejob =
                {
                    r = 135,
                    g = 206,
                    b = 235
                },
                trophy =
                {
                    r = 214,
                    g = 116,
                    b = 0
                },
                event =
                {
                    r = 255,
                    g = 168,
                    b = 0
                }
            },
            equipment =
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
            bag_contour =
            {
                light =
                {
                    r = 111,
                    g = 255,
                    b = 0
                },
                heavy =
                {
                    r = 255,
                    g = 0,
                    b = 40
                },
                body =
                {
                    r = 20,
                    g = 80,
                    b = 100
                }
            }
        },

        -- Visuals
        show_tracker_bg = true,
        show_tracker_corners = true,
        show_one_icon = false,
        show_icon_position = 2, -- 1 = Left; 2 = Right
        show_tracker_hint = true,
        show_tracker_hint_t = 15,
        tracker_hint_position = 1, -- 1 = (Vertical) Right / (Horizontal) Down; 2 = (Vertical) Left / (Horizontal) Up

        -- Trackers
        trackers_n_of_rc = 0, -- Number of Rows / Columns
        trackers_rc_horizontal_new_column_position = 1, -- 1 = Top; 2 = Bottom
        show_trackers = true,
        show_mission_trackers = true,
        show_mission_trackers_cheaty = true,
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
            show_daily_started_popup = true,

            -- Event missions
            show_events = true,
            show_event_description = false,
            show_event_started_popup = true
        },
        show_gained_xp = true,
        xp_format = 3,
        xp_panel = 2,
        total_xp_difference = 2,
        show_trade_delay = true,
        show_trade_delay_option = 1,
        show_trade_delay_other_players_only = true,
        show_trade_delay_suppress_in_stealth = true,
        show_trade_delay_amount_of_killed_civilians = false,
        show_timers = true,
        show_timers_max_in_group = 4, -- 1 - 10
        show_camera_loop = true,
        show_enemy_turret_trackers = true,
        show_zipline_timer = true,
        show_gage_tracker = true,
        gage_tracker_panel = 1,
        show_captain_damage_reduction = true,
        show_captain_spawn_chance = true,
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
        show_equipment_aggregate_all = true,
        show_minion_tracker = true,
        show_minion_option = 3, -- 1 = You only; 2 = Total number of minions in one number; 3 = Number of minions per player
        show_minion_health = true,
        show_minion_killed_message = true,
        show_minion_killed_message_type = 1, -- 1 = Popup; 2 = Hint
        show_difficulty_tracker = true,
        show_drama_tracker = true,
        show_pager_tracker = true,
        show_pager_callback = true,
        show_pager_callback_answered_behavior = 1, -- 1 = Set green, then delete; 2 = Delete
        show_enemy_count_tracker = true,
        show_enemy_count_show_pagers = true,
        show_civilian_count_tracker = true,
        civilian_count_tracker_format = 2, -- 1 = No format; one number only; 2 = Tied|Untied; 3 = Untied|Tied
        show_hostage_count_tracker = true,
        hostage_count_tracker_format = 4, -- 1 = Total only; 2 = Total | Police; 3 = Police | Total; 4 = Civilians | Police; 5 = Police | Civilians
        show_laser_tracker = false,
        show_assault_delay_tracker = true,
        show_assault_time_tracker = true,
        show_assault_diff_in_assault_trackers = true,
        show_assault_enemy_count = false,
        show_loot_counter = true,
        show_all_loot_secured_popup = true,
        variable_random_loot_format = 3, -- 1 = Progress/Max-(Max+Random)?; 2 = Progress/MaxRandom?; 3 = Progress/Max+Random?
        show_loot_max_xp_bags = true,
        show_bodybags_counter = true,
        show_escape_chance = true,
        show_sniper_tracker = true,
        show_sniper_spawned_popup = true,
        show_sniper_logic_start_popup = true,
        show_sniper_logic_end_popup = true,
        show_marshal_initial_time = true,
        show_money_tracker = false,
        money_tracker_format = 1, -- 1 = Offshore/Spending; 2 = Spending/Offshore; 3 = Offshore; 4 = Spending
        show_ping_tracker = true,
        show_ping_tracker_refresh_t = 2,

        -- Waypoints
        show_waypoints = true,
        show_waypoints_present_timer = 2,
        show_waypoints_mission = true,
        show_waypoints_mission_cheaty = true,
        show_waypoints_escape = true,
        show_waypoints_enemy_turret = true,
        show_waypoints_timers = true,
        show_waypoints_pager = true,
        show_waypoints_cameras = true,
        show_waypoints_zipline = true,
        show_waypoints_ecmjammer = true,
        show_waypoints_loot_counter = true,

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
        buffs_show_upper_text = true,
        buffs_group_text_color = false,
        -- Colors
        -- 1 = White
        -- 2 = Red
        -- 3 = Orange
        -- 4 = Green
        -- 5 = Yellow
        -- 6 = Blue
        -- 7 = Cyan
        -- 8 = Pink
        -- 9 = Purple
        -- 10 = Violet
        -- 11 = Magenta
        -- 12 = Azure
        -- 13 = Brown
        -- 14 = Crimson
        -- 15 = Salmon
        -- 16 = Gold
        -- 17 = Turquoise
        buffs_group_color_cooldown = 2,
        buffs_group_color_weapon_damage_increase = 1,
        buffs_group_color_melee_damage_increase = 1,
        buffs_group_color_player_damage_reduction = 1,
        buffs_group_color_player_damage_absorption = 1,
        buffs_group_color_increased_weapon_reload = 1,
        buffs_group_color_player_movement_increase = 1,
        buffs_group_color_dodge = 1,
        buffs_group_color_crit = 1,
        buffs_group_color_health_regen = 1,
        buff_option =
        {
            -- Skills
            -- Mastermind
            inspire_basic = true,
            inspire_basic_persistent = false,
            inspire_ace = true,
            inspire_ace_persistent = false,
            inspire_reload = true,
            inspire_reload_persistent = false,
            inspire_movement = true,
            inspire_movement_persistent = false,
            uppers = true,
            uppers_persistent = false,
            uppers_range = true,
            uppers_range_refresh = 2, -- 1 / value
            uppers_range_persistent = false,
            quick_fix = true,
            quick_fix_persistent = false,
            painkillers = true,
            painkillers_persistent = false,
            combat_medic = true,
            combat_medic_persistent = false,
            hostage_taker_muscle = true,
            hostage_taker_muscle_persistent = false,
            forced_friendship = true,
            forced_friendship_persistent = false,
            ammo_efficiency = true,
            ammo_efficiency_persistent = false,
            aggressive_reload = true,
            aggressive_reload_persistent = false,
            -- Enforcer
            overkill = true,
            overkill_persistent = false,
            underdog = true,
            underdog_persistent = false,
            bullseye = true,
            bullseye_persistent = false,
            bulletstorm = true,
            bulletstorm_persistent = false,
            -- Ghost
            sixth_sense_initial = true,
            sixth_sense_initial_persistent = false,
            sixth_sense_marked = true,
            sixth_sense_marked_persistent = false,
            sixth_sense_refresh = true,
            sixth_sense_refresh_persistent = false,
            dire_need = true,
            dire_need_persistent = false,
            second_wind = true,
            second_wind_persistent = false,
            unseen_strike = true,
            unseen_strike_persistent = false,
            unseen_strike_initial = true,
            unseen_strike_initial_persistent = false,
            -- Fugitive
            trigger_happy = true,
            trigger_happy_persistent = false,
            desperado = true,
            desperado_persistent = false,
            running_from_death_reload = true,
            running_from_death_reload_persistent = false,
            running_from_death_swap = true,
            running_from_death_swap_persistent = false,
            running_from_death_movement = true,
            running_from_death_movement_persistent = false,
            up_you_go = true,
            up_you_go_persistent = false,
            swan_song = true,
            swan_song_persistent = false,
            bloodthirst = true,
            bloodthirst_reload = true,
            bloodthirst_reload_persistent = false,
            berserker = true,
            berserker_refresh = 4, -- 1 / value
            berserker_format = 1, -- 1 = Multiplier; 2 = Percent
            berserker_text_format = 1, -- 1 = Weapon Damage | Melee / Saw Damage; 2 = Melee / Saw Damage | Weapon Damage; 3 = Weapon Damage; 4 = Melee / Saw Damage 

            -- Perks
            infiltrator =
            {
                melee_cooldown = true,
                melee_cooldown_persistent = false
            },
            gambler =
            {
                regain_health_cooldown = true,
                regain_health_cooldown_persistent = false,
                ammo_give_out_cooldown = true,
                ammo_give_out_cooldown_persistent = false
            },
            grinder =
            {
                regen_duration = true,
                regen_duration_persistent = false,
                stack_cooldown = true,
                stack_cooldown_persistent = false
            },
            maniac =
            {
                stack = true,
                stack_convert_rate = true,
                stack_decay = true
            },
            anarchist =
            {
                continuous_armor_regen = true,
                continuous_armor_regen_persistent = false,
                immunity = true,
                immunity_persistent = false,
                immunity_cooldown = true,
                immunity_cooldown_persistent = false,
                kill_armor_regen_cooldown = true,
                kill_armor_regen_cooldown_persistent = false
            }, -- +Armorer
            yakuza =
            {
                irezumi = true,
                irezumi_refresh = 2, -- 1 / value
                irezumi_format = 1, -- 1 = Multiplier; 2 = Percent
                irezumi_text_format = 1 -- 1 = Armor Regen Speed | Movement Speed; 2 = Movement Speed | Armor Regen Speed; 3 = Armor Regen Speed; 4 = Movement Speed 
            },
            expresident =
            {
                stored_health = true
            },
            biker =
            {
                kill_counter = true
            },
            kingpin =
            {
                injector = true,
                injector_persistent = false,
                injector_cooldown = true,
                injector_cooldown_persistent = false
            },
            sicario =
            {
                smoke_bomb = true,
                smoke_bomb_persistent = false,
                smoke_bomb_cooldown = true,
                smoke_bomb_cooldown_persistent = false,
                twitch = true,
                twitch_persistent = false,
                twitch_cooldown = true,
                twitch_cooldown_persistent = false
            },
            stoic =
            {
                duration = true,
                duration_persistent = false,
                cooldown = true,
                cooldown_persistent = false
            },
            tag_team =
            {
                cooldown = true,
                cooldown_persistent = false,
                effect = true,
                effect_persistent = false,
                absorption = true,
                absorption_persistent = false,
                tagged = true,
                tagged_persistent = false
            },
            hacker =
            {
                pecm_cooldown = true,
                pecm_cooldown_persistent = false,
                pecm_dodge = true,
                pecm_dodge_persistent = false,
                pecm_jammer = true,
                pecm_jammer_persistent = false,
                pecm_feedback = true,
                pecm_feedback_persistent = false
            },
            leech =
            {
                ampule = true,
                ampule_persistent = false,
                ampule_cooldown = true,
                ampule_cooldown_persistent = false
            },
            copycat =
            {
                primary_reload_secondary = true,
                secondary_reload_primary = true,
                head_games_cooldown = true,
                head_games_cooldown_persistent = false,
                grace_period = true,
                grace_period_persistent = false,
                grace_period_cooldown = true,
                grace_period_cooldown_persistent = false
            },
            gage_boosts =
            {
                life_steal = true,
                life_steal_persistent = false,
                melee_invulnerability = true,
                melee_invulnerability_persistent = false
            },

            -- Other
            interact = true,
            interact_persistent = false,
            reload = true,
            reload_persistent = false,
            melee_charge = true,
            melee_charge_persistent = false,
            shield_regen = true,
            shield_regen_persistent = false,
            stamina = true,
            weapon_swap = true,
            weapon_swap_persistent = false,
            carry_interaction_cooldown = true,
            carry_interaction_cooldown_persistent = false,
            dodge = true,
            dodge_refresh = 1, -- 1 / value
            dodge_persistent = false,
            crit = true,
            crit_refresh = 1, -- 1 / value
            crit_persistent = false,
            damage_absorption = true,
            damage_absorption_refresh = 1, -- 1 / value
            damage_absorption_persistent = false,
            damage_reduction = true,
            damage_reduction_refresh = 1, -- 1 / value
            damage_reduction_persistent = false,
            inspire_ai = true,
            inspire_ai_persistent = false,
            regen_throwable_ai = true,
            health = false,
            health_check_sniper_damage = true,
            health_check_heavy_swat_ds_damage = true,
            armor = false
        },

        -- Inventory
        show_inventory_detailed_description = false,
        hide_original_desc = true,

        -- Other
        show_remaining_xp = true,
        show_remaining_xp_to_100 = false,
        show_mission_xp_overview = true,
        show_floating_health_bar = true,
        show_floating_health_bar_style = 1, -- 1 = Poco; 2 = Circle; 3 = Rectangle
        show_floating_health_bar_style_poco_blur = true,
        show_floating_health_bar_converts = true,
        show_floating_health_bar_civilians = true,
        show_floating_health_bar_team_ai = true,
        show_floating_health_bar_regular_enemies = true,
        show_floating_health_bar_special_enemies_tank = true,
        show_floating_health_bar_special_enemies_shield = true,
        show_floating_health_bar_special_enemies_taser = true,
        show_floating_health_bar_special_enemies_cloaker = true,
        show_floating_health_bar_special_enemies_sniper = true,
        show_floating_health_bar_special_enemies_medic = true,
        show_floating_health_bar_special_enemies_turret = true,
        show_floating_health_bar_special_enemies_other = true,
        show_floating_damage_popup = true,
        show_floating_damage_popup_accumulate = false,
        show_floating_damage_popup_size = 22, -- 10 - 30
        show_floating_damage_popup_time_on_screen = 10, -- 2 - 15
        show_floating_damage_popup_my_damage = true,
        show_floating_damage_popup_ai_damage = true,
        show_floating_damage_popup_crew_damage = true,
        show_use_left_ammo_bag = true,
        show_use_left_doctor_bag = true,
        show_use_left_bodybags_bag = true,
        show_use_left_grenades = true,
        show_colored_bag_contour = true,
        show_real_time_ingame = false,
        show_minion_colored_to_owner = true,
        show_progress_reload = false,
        show_progress_melee = false,
        show_end_game_stats = false,
        show_end_game_stats_kills = 4, -- 1 = No kills; 2 = Total kills only; 3 = Special kills only; 4 = Total kills + Special kills; 5 = Special kills + Total kills
        show_end_game_stats_headshots = true,
        show_end_game_stats_dps = true,
        show_end_game_stats_kpm = true,
        show_end_game_stats_acc = true,
        show_end_game_stats_downs = true
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
    self._cache.AchievementsDisabled = not self:ShowMissionAchievements()
end

function EHI:Init()
    self._cache.Difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
    self._cache.DifficultyIndex = table.index_of({
        "easy", -- Leftover from PD:TH
        "normal",
        "hard",
        "overkill",
        "overkill_145",
        "easy_wish",
        "overkill_290",
        "sm_wish"
    }, self._cache.Difficulty) - 2
    self:AddCallback(self.CallbackMessage.InitManagers, function(managers) ---@param managers managers
        local mutator = managers.mutators
        self._cache.UnlockablesAreDisabled = mutator:can_mutators_be_active() and mutator:are_achievements_disabled()
        local level = Global.game_settings.level_id
        if level == "Enemy_Spawner" or level == "enemy_spawner2" or level == "modders_devmap" then -- These 3 maps disable achievements
            self._cache.UnlockablesAreDisabled = true
            self._cache.PlayingDevMap = true
        elseif _G.ch_settings and not _G.ch_settings.settings.u24_progress then -- Classic Heisting disables achievements if U24 setting is disabled
            self._cache.UnlockablesAreDisabled = true
        end
    end)
end

---@param name string
---@param author string
function EHI:IsModInstalled(name, author)
    local mod_key = string.format("%s_%s", name, author)
    if self._cache.Mod[mod_key] ~= nil then
        return self._cache.Mod[mod_key]
    end
    if BLT and BLT.Mods then
        for _, mod in ipairs(BLT.Mods:Mods()) do
            if mod:IsEnabled() and mod:GetName() == name and mod:GetAuthor() == author then
                self._cache.Mod[mod_key] = true
                return true
            end
        end
    end
    self._cache.Mod[mod_key] = false
    return false
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
    return math.within(self._cache.DifficultyIndex, math.min_max(diff_1, diff_2))
end

function EHI:DifficultyIndex()
    return tweak_data and tweak_data:difficulty_to_index(self._cache.Difficulty) - 2 or self._cache.DifficultyIndex
end

function EHI:IsMayhemOrAbove()
    return self:IsDifficultyOrAbove(self.Difficulties.Mayhem)
end

if Global.load_level then
    EHI.IsHost = Network:is_server() ---@type boolean
    EHI.IsClient = Network:is_client() ---@type boolean
end

---@return boolean
function EHI:IsPlayingFromStart()
    return self.IsHost or (self.IsClient and not managers.statistics:is_dropin())
end

function EHI:Log(s)
    log("[EHI] " .. (s or "nil"))
end

---@param prefix AnyExceptNil
---@param s AnyExceptNil
function EHI:Log2(prefix, s)
    log(string.format("[EHI] [%s] %s", prefix, s))
end

---Logs provided string from the file it was called from
---@param s AnyExceptNil
function EHI:LogWithCurrentFile(s)
    local info = debug.getinfo(2, "S")
    local last_pos, file
    while true do
        local st, _ = string.find(info.source, "/", last_pos)
        if st then
            last_pos = st + 1
        else
            break
        end
    end
    if last_pos then
        file = string.gsub(info.source, string.sub(info.source, 0, last_pos - 1), "")
    else
        file = "unknown"
    end
    self:Log2(file, s)
end

---Logs provided string from the line in the file it was called from
---@param s AnyExceptNil
function EHI:LogWithCurrentLine(s)
    local info = debug.getinfo(2, "Sl")
    local last_pos, file
    while true do
        local st, _ = string.find(info.source, "/", last_pos)
        if st then
            last_pos = st + 1
        else
            break
        end
    end
    if last_pos then
        file = string.gsub(info.source, string.sub(info.source, 0, last_pos - 1), "")
    else
        file = "unknown"
    end
    self:Log2(string.format("%s:%s", file, tostring(info.currentline or "???")), s)
end

---Logs provided string from the line and function in the file it was called from
---@param s AnyExceptNil
function EHI:LogWithCurrentLineAndFunction(s)
    local info = debug.getinfo(2, "Sln")
    local last_pos, file
    while true do
        local st, _ = string.find(info.source, "/", last_pos)
        if st then
            last_pos = st + 1
        else
            break
        end
    end
    if last_pos then
        file = string.gsub(info.source, string.sub(info.source, 0, last_pos - 1), "")
    else
        file = "unknown"
    end
    self:Log2(string.format("%s:%s %s()", file, tostring(info.currentline or "???"), info.name), s)
end

---Works the same way as EHI:Log(), but the string is not saved on HDD
---@param s AnyExceptNil
function EHI:LogFast(s)
    local prefix = os.date("%I:%M:%S %p")
    io.stdout:write(prefix .. " Lua: [EHI] " .. (s or "nil") .. "\n")
end

function EHI:LogTraceback()
    log("[EHI] " .. debug.traceback())
end

function EHI:LogToChat(s)
    managers.chat:_receive_message(1, "[EHI]", tostring(s), Color.white)
end

function EHI:SaveOptions()
    self.settings.SaveDataVer = self.SaveDataVer
    local file = io.open(self.SettingsSaveFilePath, "w+")
    if file then
        file:write(json.encode(self.settings) or "{}")
        file:close()
    end
end

---@param vr_option string Option to be checked if the game is running in VR version
---@param option string Option to be checked if the game is running in non-VR version
---@param expected_value { [any]: boolean }|any What the expected value in the option should be
---@param vr_expected_value { [any]: boolean }|any? What the expected value in the VR option should be in VR (don't pass a value if the same value is expected for both options)
---@return boolean
function EHI:CheckVRAndNonVROption(vr_option, option, expected_value, vr_expected_value)
    if _G.IS_VR then
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
        tracker.count = (tracker.count or 1) - 1
        if tracker.count == 0 then
            self:LoadTracker(tracker.file)
            self.OptionTracker[option] = nil
        end
    end
end

---@param option string
function EHI:GetOptionAndLoadTracker(option)
    local result = self:GetTrackerOption(option)
    if result and self.OptionTracker[option] then
        local tracker = self.OptionTracker[option]
        tracker.count = (tracker.count or 1) - 1
        if tracker.count == 0 then
            self:LoadTracker(tracker.file)
            self.OptionTracker[option] = nil
        end
    end
    return result
end

---@param filename string
function EHI:LoadTracker(filename)
    dofile(string.format("%s%s%s.lua", self.LuaPath, "trackers/", filename))
end

---@param filename string
function EHI:LoadWaypoint(filename)
    dofile(string.format("%s%s%s.lua", self.LuaPath, "waypoints/", filename))
end

---@param filename string
function EHI:LoadBuff(filename)
    dofile(string.format("%s%s%s.lua", self.LuaPath, "buffs/", filename))
end

---@param filename string
function EHI:LoadMaster(filename)
    if not EHIBaseMaster then
        dofile(string.format("%sshared/EHIBaseMaster.lua", self.LuaPath))
    end
    dofile(string.format("%s%s%s.lua", self.LuaPath, "shared/", filename))
end

---@param option string
function EHI:GetOption(option)
    if option then
        return self.settings[option]
    end
end

---@param option string
function EHI:IsVerticalAlignmentAndOption(option)
    if self:GetOption("tracker_alignment") <= self.Const.Trackers.Alignment.Vertical_BottomToTop then
        return self:GetOption(option)
    end
    return -1
end

---@param option string
---@param color string
function EHI:GetColorFromOption(option, color)
    local c = option and self.settings.colors[option] and self.settings.colors[option][color or ""]
    if c and c.r and c.g and c.b then
        return Color(255, c.r, c.g, c.b) / 255
    end
    return Color.white
end

function EHI:GetVectorFromOption(option, color)
    local c = option and self.settings.colors[option] and self.settings.colors[option][color or ""]
    if c then
        return Vector3(c.r / 255, c.g / 255, c.b / 255)
    end
    return Vector3()
end

---@param option string
function EHI:GetTrackerOption(option)
    return self:GetOption("show_trackers") and self:GetOption(option)
end

---@return boolean
function EHI:ShowMissionAchievements()
    return self:GetUnlockableAndOption("show_achievements_mission") and self:GetUnlockableOption("show_achievements")
end

function EHI:ShowTimedTrackerOpened()
    return self:GetOption("show_waypoints") and not self:GetOption("show_waypoints_only")
end

---@param id string Achievement ID
function EHI:CanShowAchievement(id)
    return self:ShowMissionAchievements() and self:IsAchievementLocked(id)
end

---@param id string Achievement ID
---@param unlockable_option string
function EHI:CanShowAchievement2(id, unlockable_option)
    return self:ShowMissionAchievements() and self:IsAchievementLocked2(id) and self:GetUnlockableOption(unlockable_option)
end

---@param option string
function EHI:GetUnlockableOption(option)
    if option then
        return self.settings.unlockables[option]
    end
end

---@param option string
function EHI:GetUnlockableAndOption(option)
    return self:GetTrackerOption("show_unlockables") and self:GetUnlockableOption(option)
end

---@param option string
function EHI:GetEquipmentOption(option)
    return self:GetTrackerOption("show_equipment_tracker") and self:GetOption(option)
end

---@param tracker string
---@param waypoint string
function EHI:GetTrackerOrWaypointOption(tracker, waypoint)
    return self:GetTrackerOption(tracker) or self:GetWaypointOption(waypoint)
end

---@param waypoint string
---@return boolean
function EHI:GetWaypointOption(waypoint)
    return self:GetOption("show_waypoints") and self:GetOption(waypoint)
end

---@param tracker string
---@param waypoint string
---@return boolean, boolean
function EHI:GetShowTrackerAndWaypoint(tracker, waypoint)
    return self:GetTrackerOption(tracker), self:GetWaypointOption(waypoint)
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
function EHI:GetBuffDeckAndOption(deck, option)
    return self:GetOption("show_buffs") and self:GetBuffDeckOption(deck, option)
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
    local deck_table = self:GetBuffOption(deck)
    if deck_table then
        for _, value in ipairs({ ... }) do
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
    return self:GetTrackerOption("show_mission_trackers") and self:GetWaypointOption("show_waypoints_mission")
end

function EHI:IsXPTrackerEnabled()
    return self:GetTrackerOption("show_gained_xp") and not self:IsPlayingCrimeSpree()
end

function EHI:IsXPTrackerDisabled()
    return not self:IsXPTrackerEnabled()
end

function EHI:IsLootCounterVisible()
    return self:GetTrackerOrWaypointOption("show_loot_counter", "show_waypoints_loot_counter") and not self:IsPlayingCrimeSpree()
end

function EHI:IsSyncedLootCounterVisible()
    return self.IsHost and not self:IsPlayingCrimeSpree()
end

function EHI:IsPlayingCrimeSpree()
    return Global.game_settings and Global.game_settings.gamemode == "crime_spree"
end

---@return boolean
function EHI:IsAssaultTrackerEnabled()
    if self:GetOption("show_trackers") then
        return self:GetOption("show_assault_delay_tracker") or self:GetOption("show_assault_time_tracker")
    end
    return false
end

---@param option string
---@return boolean
function EHI:IsAssaultTrackerEnabledAndOption(option)
    return self:IsAssaultTrackerEnabled() and self:GetOption(option)
end

---@return boolean
function EHI:CombineAssaultDelayAndAssaultTime()
    return self:GetOption("show_trackers") and self:GetOption("show_assault_delay_tracker") and self:GetOption("show_assault_time_tracker")
end

function EHI:IsEscapeChanceEnabled()
    return self:GetOptionAndLoadTracker("show_escape_chance") and not self:IsPlayingCrimeSpree()
end

function EHI:IsTradeTrackerDisabled()
    return Global.game_settings.level_id == "haunted" or not self:GetOptionAndLoadTracker("show_trade_delay")
end

---@param params XPBreakdown
function EHI:AddXPBreakdown(params)
    if not EHI:GetOption("show_mission_xp_overview") or not managers.menu_component then
        return
    elseif not managers.menu_component._mission_briefing_gui then
        self:AddCallback("MissionBriefingGuiInit", function(gui) ---@param gui MissionBriefingGui
            gui:AddXPBreakdown(params)
        end)
        return
    end
    managers.menu_component._mission_briefing_gui:AddXPBreakdown(params)
end

---@param id string|number
---@param f function
function EHI:AddCallback(id, f)
    self._callback[id] = self._callback[id] or CallbackEventHandler:new()
    self._callback[id]:add(f)
end

---@param id string|number
function EHI:CallCallback(id, ...)
    local handler = self._callback[id]
    if handler then
        handler:dispatch(...)
    end
end

---Calls all callbacks, after that they are deleted from memory
---@param id string|number
function EHI:CallCallbackOnce(id, ...)
    local handler = table.remove_key(self._callback, id)
    if handler then
        handler:dispatch(...)
        handler:clear()
    end
end

---@param f fun(dropin: boolean)
function EHI:AddOnAlarmCallback(f)
    if self._cache.Alarm then
        return
    end
    self:AddCallback("Alarm", f)
end

---@param dropin boolean
function EHI:RunOnAlarmCallbacks(dropin)
    self._cache.Alarm = true
    self:CallCallbackOnce("Alarm", dropin)
end

---@param f fun(custody_state: boolean)
function EHI:AddOnCustodyCallback(f)
    self:AddCallback("Custody", f)
end

---@param f function
function EHI:AddOnSpawnedCallback(f)
    self:AddCallback("Spawned", f)
end

---@param f fun(self: IngameWaitingForPlayersState, job: string, level: string, from_beginning: boolean)
function EHI:AddOnSpawnedExtendedCallback(f)
    self:AddCallback("Spawned2", f)
end

---@param f fun(loc: LocalizationManager, lang_name: string)
function EHI:AddOnLocalizationLoaded(f)
    if self._cache.LocLoaded then
        return
    end
    self:AddCallback("LocLoaded", f)
end

---@param loc LocalizationManager
---@param lang_name string
function EHI:RunOnLocalizationLoaded(loc, lang_name)
    self._cache.LocLoaded = true
    self:CallCallbackOnce("LocLoaded", loc, lang_name)
end

---@param f function
function EHI:AddEndGameCallback(f)
    self:AddCallback(self.CallbackMessage.GameAborted, f)
    self:AddCallback(self.CallbackMessage.GameEnd, f)
    self:AddCallback(self.CallbackMessage.GameRestart, f)
end

---@param type GameEnd
function EHI:RunEndGameCallback(type)
    if type == 1 then
        self:CallCallbackOnce(self.CallbackMessage.GameAborted)
        self._callback[self.CallbackMessage.GameEnd] = nil
        self._callback[self.CallbackMessage.GameRestart] = nil
    elseif type == 2 then
        self:CallCallbackOnce(self.CallbackMessage.GameEnd)
        self._callback[self.CallbackMessage.GameAborted] = nil
        self._callback[self.CallbackMessage.GameRestart] = nil
    elseif type == 3 then
        self:CallCallbackOnce(self.CallbackMessage.GameRestart)
        self._callback[self.CallbackMessage.GameAborted] = nil
        self._callback[self.CallbackMessage.GameEnd] = nil
    end
end

---@generic T
---@param object T
---@param func string
---@param pre_call fun(self: T, ...)
---@param post_call fun(self: T, ...)
function EHI:PreHookAndHook(object, func, pre_call, post_call)
    Hooks:PreHook(object, func, string.format("EHI_Pre_%s", func), pre_call)
    Hooks:PostHook(object, func, string.format("EHI_%s", func), post_call)
end

---@generic T
---@param object T
---@param func string
---@param id string
---@param pre_call fun(self: T, ...)
---@param post_call fun(self: T, ...)
function EHI:PreHookAndHookWithID(object, func, id, pre_call, post_call)
    Hooks:PreHook(object, func, id, pre_call)
    Hooks:PostHook(object, func, id, post_call)
end

---@return boolean
function EHI:ShowDramaTracker()
    return self.IsHost and self:GetTrackerOption("show_drama_tracker") and Global.game_settings.level_id ~= "haunted" and Global.game_settings.level_id ~= "hvh"
end

---@return boolean
function EHI:IsRunningBB()
    return BB and BB.grace_period and Global.game_settings.single_player and Global.game_settings.team_ai
end

function EHI:IsRunningUsefulBots()
    if self.IsHost then
        return UsefulBots and Global.game_settings.team_ai
    end
    return self._cache.HostHasUsefulBots and self._cache.HostHasBots
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

---@param id string
function EHI:GetAchievementIcon(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and { achievement.icon_id }
end

---@param id string
function EHI:GetAchievementIconString(id)
    local achievement = tweak_data.achievement.visual[id]
    return achievement and achievement.icon_id
end

---@param id string
---@param events string|string[]
---@param f function
---@overload fun(self: EHI, id: string, f: function)
function EHI:AddEventListener(id, events, f)
    if self:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission") then
        if f then
            self.Trigger:AddEventListener(id, events, f)
        else
            self.Trigger:AddEventListener(id, id, events --[[@as function]])
        end
    end
end

---@param trigger ElementTrigger
function EHI:CleanupCustomSFTrigger(trigger)
    if trigger.special_function and trigger.special_function > self.SpecialFunctions.CustomSF then
        self.Trigger:UnregisterCustomSF(trigger.special_function)
    end
end

---@param triggers table<number, ElementTrigger>
function EHI:CleanupCustomSFTriggers(triggers)
    for _, trigger in pairs(triggers) do
        if trigger.special_function and trigger.special_function > self.SpecialFunctions.CustomSF then
            self.Trigger:UnregisterCustomSF(trigger.special_function)
        end
    end
end

---@param params AssaultElementTrigger
---@return ElementTrigger?
function EHI:AddAssaultDelay(params)
    if not self:GetTrackerOption("show_assault_delay_tracker") then
        self:CleanupCustomSFTrigger(params)
        return nil
    end
    local id = "AssaultDelay"
    local hint = "assault_delay"
    if self:CombineAssaultDelayAndAssaultTime() then
        id = "Assault"
        hint = "assault"
    end
    local tbl = {}
    -- Copy every passed value to the trigger
    for key, value in pairs(params) do
        if key ~= "control" and key ~= "control_additional_time" then
            tbl[key] = value
        end
    end
    if params.random_time then
        tbl.additional_time = (params.control_additional_time or 0) + (tbl.additional_time or 30)
    else
        tbl.time = (params.control or 0) + (tbl.time or 30)
    end
    tbl.id = id
    tbl.class = self.Trackers.Assault
    tbl.pos = 0
    tbl.hint = hint
    return tbl
end

---Creates trigger as `SF.CustomCode` with boolean check of the Loot Counter option
---@param f function Loot counter function
---@param wp_params WaypointLootCounterTable? Waypoint params for the Loot Counter
---@param check boolean? Boolean value of options 'show_loot_counter' and 'show_waypoints_loot_counter'
---@param load_sync fun(self: EHIMissionElementTrigger)? Load sync function for clients
---@param trigger_once boolean? Should the trigger run once?
---@return ElementTrigger?
function EHI:AddLootCounter(f, wp_params, check, load_sync, trigger_once)
    if self:IsPlayingCrimeSpree() then
        return nil
    elseif check ~= nil and check == false then
        return nil
    elseif not self:GetTrackerOrWaypointOption("show_loot_counter", "show_waypoints_loot_counter") then
        return nil
    end
    local tbl =
    {
        special_function = self.SpecialFunctions.CustomCode,
        f = f,
        trigger_once = trigger_once,
        load_sync = self.IsClient and load_sync
    }
    self:ShowLootCounterWaypoint(wp_params)
    return tbl
end

---Creates trigger as `SF.CustomCode`
---@param f function Loot counter function
---@param wp_params WaypointLootCounterTable? Waypoint params for the Loot Counter
---@param load_sync fun(self: EHIMissionElementTrigger)? Load sync function for clients
---@param trigger_once boolean? Should the trigger run once?
function EHI:AddLootCounter2(f, wp_params, load_sync, trigger_once)
    local tbl = ---@type ElementTrigger
    {
        special_function = self.SpecialFunctions.CustomCode,
        f = f,
        trigger_once = trigger_once,
        load_sync = self.IsClient and load_sync
    }
    self:ShowLootCounterWaypoint(wp_params)
    return tbl
end

---Creates a trigger as `EHI.CustomCode2` with `EHIMissionElementTrigger` as a parameter
---@param f fun(self: EHIMissionElementTrigger)
---@param wp_params WaypointLootCounterTable?
---@param load_sync fun(self: EHIMissionElementTrigger)? Load sync function for clients
---@param trigger_once boolean?
function EHI:AddLootCounter3(f, wp_params, load_sync, trigger_once)
    self:ShowLootCounterWaypoint(wp_params)
    local trigger = self:AddCustomCode(f, trigger_once)
    trigger.load_sync = self.IsClient and load_sync
    return trigger
end

---Creates trigger as custom trigger function in `EHIManager`
---@param f fun(self: EHIMissionElementTrigger, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean) Loot counter function
---@param wp_params WaypointLootCounterTable? Waypoint params for the Loot Counter
---@param trigger_once boolean? Should the trigger run once?
---@return ElementTrigger
function EHI:AddLootCounter4(f, wp_params, trigger_once)
    self:ShowLootCounterWaypoint(wp_params)
    return {
        special_function = self.Trigger:RegisterCustomSF(f),
        trigger_once = trigger_once
    }
end

---Creates trigger as `SF.CustomCodeDelayed`
---@param f function Loot counter function
---@param wp_params WaypointLootCounterTable? Waypoint params for the Loot Counter
---@param t number Delays the loot counter
---@param load_sync fun(self: EHIMissionElementTrigger)? Load sync function for clients
---@param trigger_once boolean? Should the trigger run once?
---@return ElementTrigger
function EHI:AddLootCounter5(f, wp_params, t, load_sync, trigger_once)
    self:ShowLootCounterWaypoint(wp_params)
    return {
        special_function = self.SpecialFunctions.CustomCodeDelayed,
        t = t,
        f = f,
        trigger_once = trigger_once,
        load_sync = self.IsClient and load_sync
    }
end

---@param f fun(self: EHIMissionElementTrigger)
---@param trigger_once boolean?
---@return ElementTrigger
function EHI:AddCustomCode(f, trigger_once)
    return
    {
        special_function = self.SpecialFunctions.CustomCode2,
        f = f,
        trigger_once = trigger_once
    }
end

---@param params LootCounterTable?
---@param waypoint_params WaypointLootCounterTable?
function EHI:ShowLootCounter(params, waypoint_params)
    if self:GetTrackerOrWaypointOption("show_loot_counter", "show_waypoints_loot_counter") then
        self:ShowLootCounterNoCheck(params, waypoint_params)
    end
end

---@param params LootCounterTable?
---@param waypoint_params WaypointLootCounterTable?
function EHI:ShowLootCounterNoCheck(params, waypoint_params)
    if self:IsPlayingCrimeSpree() then
        return
    end
    self:ShowLootCounterNoChecks(params, waypoint_params)
end

---@param params LootCounterTable?
---@param waypoint_params WaypointLootCounterTable?
function EHI:ShowLootCounterNoChecks(params, waypoint_params)
    params = params or {}
    local offset = params.offset or 0
    if not params.skip_offset and managers.job:IsPlayingMultidayHeist() then
        if self.IsHost or params.client_from_start then
            offset = managers.loot:GetSecuredBagsAmount()
        else
            managers.ehi_sync:AddFullSyncFunction(function()
                params.skip_offset = true
                params.offset = managers.loot:GetSecuredBagsAmount()
                params.hook_triggers = params.triggers ~= nil
                self:ShowLootCounterNoChecks(params, waypoint_params)
            end)
            return
        end
    end
    if params.sequence_triggers or params.is_synced then
        managers.ehi_loot:SyncShowLootCounter(params.max, params.max_random, offset)
        managers.ehi_loot:AddSequenceTriggers(params.sequence_triggers)
    elseif params.max_bags_for_level and self:IsXPTrackerEnabled() and not _G.ch_settings then
        if params.max_bags_for_level.objective_triggers then
            local xp_trigger = self:AddLootCounter4(function(manager, trigger, element, enabled) ---@cast element ElementExperience
                if enabled then
                    managers.ehi_loot:ObjectiveXPAwarded(element._values.amount or 0)
                end
            end)
            local triggers = {}
            for _, id in ipairs(params.max_bags_for_level.objective_triggers) do
                triggers[id] = xp_trigger
            end
            self.Trigger:__AddTriggers(triggers, managers.ehi_loot._id)
            params.max_bags_for_level.objective_triggers = nil
        end
        params.no_sync_load = true
        managers.ehi_loot:ShowLootCounter(0, 0, 0, 0, false, false, params.max_bags_for_level, nil, nil, nil)
    else
        if not self:GetOption("show_loot_max_xp_bags") or _G.ch_settings then
            params.max_xp_bags = 0
        end
        managers.ehi_loot:ShowLootCounter(params.max, params.max_random, params.max_xp_bags, offset, params.unknown_random, params.no_max, nil, params.loot_distribution, params.random_loot_distribution, waypoint_params and waypoint_params.class)
    end
    if params.load_sync then
        self.Trigger:AddLoadSyncFunction(params.load_sync)
        params.no_sync_load = true
    end
    if params.triggers and (not params.no_triggers_if_max_xp_bags_gt_max or (params.max_xp_bags or 0) >= (params.max or 0)) then
        self.Trigger:__AddTriggers(params.triggers, managers.ehi_loot._id)
        if params.hook_triggers then
            self.Trigger:__FindAndHookElements(params.triggers)
        end
    end
    if params.max_bags_for_level and params.max_bags_for_level.custom_counter and self:IsXPTrackerEnabled() and not _G.ch_settings then
        params.max_bags_for_level.custom_counter.achievement = managers.ehi_loot._id
        managers.ehi_loot:AddAchievementListener(params.max_bags_for_level.custom_counter, 0, true)
    else
        managers.ehi_loot:AddLootListener(params.no_sync_load)
    end
    if params.carry_data then
        if params.carry_data.loot and EHICarryData then
            EHICarryData._enabled = true
        end
        if params.carry_data.no_loot and EHINoCarryData then
            EHINoCarryData._enabled = true
        end
        if params.carry_data.at_loot and EHIATCarryData then
            EHIATCarryData._enabled = true
        end
        if params.carry_data.no_at_loot and EHIATNoCarryData then
            EHIATNoCarryData._enabled = true
        end
        if params.carry_data.at_loot and params.carry_data.no_at_loot and EHIATExplosionData then
            EHIATExplosionData._enabled = true
        end
    end
    self:ShowLootCounterWaypoint(waypoint_params)
end

---Hooks waypoints during game load so they correctly show in the game world  
---If the Loot Counter is created during spawn, this function needs to be called before Loot Counter has a chance to initialize
---@param waypoint_params WaypointLootCounterTable?
function EHI:ShowLootCounterWaypoint(waypoint_params)
    if waypoint_params and waypoint_params.element and self:GetWaypointOption("show_waypoints_loot_counter") and not self:IsPlayingCrimeSpree() then
        ---@param element ElementWaypoint
        ---@param instigator UnitPlayer
        local function on_executed(element, instigator, ...)
            if not element._values.enabled then
                return
            elseif element._values.only_on_instigator and instigator ~= managers.player:player_unit() then
                ElementWaypoint.super.on_executed(element, instigator, ...)
                return
            elseif not element._values.only_in_civilian or managers.player:current_state() == "civilian" then
                local text = managers.localization:text(element._values.text_id)
                if managers.ehi_loot:IsMasterActive() and managers.ehi_loot:IsMasterWaypointCheckValid() then
                    managers.hud:AddWaypointSoft(element._id, {
                        distance = true,
                        state = "sneak_present",
                        present_timer = 0,
                        text = text,
                        icon = element._values.icon,
                        position = element._values.position
                    })
                    managers.ehi_loot:OverrideWaypoint(element)
                else
                    managers.hud:add_waypoint(element._id, {
                        distance = true,
                        state = "sneak_present",
                        present_timer = 0,
                        text = text,
                        icon = element._values.icon,
                        position = element._values.position
                    })
                end
            elseif managers.hud:get_waypoint_data(element._id) then
                managers.hud:remove_waypoint(element._id)
            end
            ElementWaypoint.super.on_executed(element, instigator, ...)
        end
        ---@param element ElementWaypoint
        local function operation_remove(element)
            if managers.ehi_loot:CanRemoveWaypointCheck() then
                managers.ehi_loot:RemoveWaypoint(element._id)
            end
        end
        if type(waypoint_params.element) == "number" then
            self.Element:AddElementToOverride(waypoint_params.element --[[@as number]], on_executed, operation_remove)
            managers.ehi_loot:AddWaypointElement(waypoint_params.element --[[@as number]])
        else
            for _, element in ipairs(waypoint_params.element --[[@as number[] ]]) do
                self.Element:AddElementToOverride(element, on_executed, operation_remove)
                managers.ehi_loot:AddWaypointElement(element)
            end
        end
        if waypoint_params.present_timer then
            managers.ehi_loot:SetPresentTimerForWaypoints(waypoint_params.present_timer)
        end
        if waypoint_params.check_function then
            managers.ehi_loot:WaypointFunctionCheck(waypoint_params.check_function)
        end
        if waypoint_params.remove_check then
            managers.ehi_loot:WaypointRemoveFunctionCheck(waypoint_params.remove_check)
        end
    end
end

---@param params LootCounterTable
---@param waypoint_params WaypointLootCounterTable?
function EHI:ShowLootCounterSynced(params, waypoint_params)
    if self:IsPlayingCrimeSpree() then
        return
    elseif not self:GetTrackerOrWaypointOption("show_loot_counter", "show_waypoints_loot_counter") then
        self.Trigger:__AddTriggers(params.triggers or {}, managers.ehi_loot._id)
        managers.ehi_loot:AddSequenceTriggers(params.sequence_triggers)
        managers.ehi_loot:SetSyncData({
            max = params.max or 0,
            max_random = params.max_random or 0,
            offset = params.offset and managers.loot:GetSecuredBagsAmount()
        })
        return
    end
    params.is_synced = true
    self:ShowLootCounterNoChecks(params, waypoint_params)
end

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.AchievementsDisabled or self:IsAchievementUnlocked(params.achievement) or params.difficulty_pass == false then
        if params.show_loot_counter then
            self:ShowLootCounter({ max = params.max, triggers = params.loot_counter_triggers, load_sync = params.loot_counter_load_sync }, params.waypoint_loot_counter)
        elseif params.triggers then
            self:CleanupCustomSFTriggers(params.triggers)
        end
        return
    end
    self:ShowAchievementLootCounterNoCheck(params)
end

---@param params AchievementLootCounterTable
function EHI:ShowAchievementLootCounterNoCheck(params)
    if params.show_loot_counter and self:GetTrackerOption("show_loot_counter") and not self:IsPlayingCrimeSpree() then
        managers.ehi_unlockable:AddAchievementLootCounter(params.achievement, params.max, params.loot_counter_on_fail, params.start_silent)
        managers.ehi_loot:_create_waypoint_tracker(params.achievement, params.max)
        self:ShowLootCounterWaypoint(params.waypoint_loot_counter)
    else
        managers.ehi_unlockable:AddAchievementProgressTracker(params.achievement, params.max, params.progress, params.show_finish_after_reaching_target)
    end
    if params.load_sync then
        self.Trigger:AddLoadSyncFunction(params.load_sync)
    end
    if params.alarm_callback then
        self:AddOnAlarmCallback(params.alarm_callback)
    end
    if params.failed_on_alarm then
        self:AddOnAlarmCallback(function()
            managers.ehi_unlockable:SetAchievementFailed(params.achievement)
        end)
    end
    if params.silent_failed_on_alarm then
        self:AddOnAlarmCallback(function()
            managers.ehi_unlockable:SetAchievementFailed(params.achievement, managers.ehi_sync:IsSyncing())
        end)
    end
    if params.triggers then
        self.Trigger:__AddTriggers(params.triggers, params.achievement)
        if params.hook_triggers then
            self.Trigger:__FindAndHookElements(params.triggers)
        end
        if params.add_to_counter then
            managers.ehi_loot:AddAchievementListener(params, params.start_silent and params.silent_max or params.max)
        end
        return
    elseif params.no_counting then
        return
    end
    managers.ehi_loot:AddAchievementListener(params, params.start_silent and params.silent_max or params.max)
end

---@param params AchievementBagValueCounterTable
function EHI:ShowAchievementBagValueCounter(params)
    if self._cache.UnlockablesAreDisabled or self._cache.AchievementsDisabled or self:IsAchievementUnlocked(params.achievement) then
        return
    end
    managers.ehi_unlockable:AddAchievementBagValueCounter(params.achievement, params.value, params.show_finish_after_reaching_target)
    managers.ehi_loot:AddAchievementListener(params, params.value)
end

---@param params AchievementKillCounterTable
function EHI:ShowAchievementKillCounter(params)
    if params.achievement_option and not self:GetUnlockableAndOption(params.achievement_option) then
        return
    elseif self._cache.UnlockablesAreDisabled or self._cache.AchievementsDisabled or self:IsAchievementUnlocked2(params.achievement) or params.difficulty_pass == false then
        self:Log("Achievement disabled! id: " .. tostring(params.achievement))
        return
    end
    local id = params.achievement
    local id_stat = params.achievement_stat
    local tweak_data = tweak_data.achievement.persistent_stat_unlocks[id_stat]
    if not tweak_data then
        return
    end
    local progress = self:GetAchievementProgress(id_stat)
    local max = tweak_data[1] and tweak_data[1].at or 0
    if progress >= max then
        self:Log("Achievement already unlocked; return")
        self:Log(string.format("progress: %d; max: %d", progress, max))
        return
    end
    managers.ehi_unlockable:AddAchievementKillCounter(id, progress, max)
    managers.ehi_hook:HookAchievementAwardProgress(id, function(am, stat, value)
        if stat == id_stat then
            managers.ehi_tracker:IncreaseProgress(id, value)
        end
    end)
end

---Caches Mission Door Data as the units are not ready during mission load
---@param tbl table<integer, number|MissionDoorTable|MissionDoorTable[]>
function EHI:SetMissionDoorData(tbl)
    if TimerGui.AddMissionDoorData then
        for id, data in pairs(tbl) do
            if type(data) == "table" and data.restore and not data.unit_id then
                data.unit_id = id
            end
        end
        self._cache.MissionDoor = tbl
        TimerGui._ehi_MissionDoorData = true
    end
end

---Sets values in TimerGui once the units are ready (called from MissionDoor.lua)
---@param id integer Mission Door Editor ID
---@param tbl Vector3[]
function EHI:_SetMissionDoorData(id, tbl)
    local door = self._cache.MissionDoor and self._cache.MissionDoor[id]
    if door and tbl then
        if type(door) == "number" then
            TimerGui.AddMissionDoorData(tbl[1], door)
        elseif type(door) == "table" then
            if type(door[1]) == "table" then -- Multiple drills in one door data
                for i, data in ipairs(door) do
                    TimerGui.AddMissionDoorData(tbl[i], data)
                end
            else -- Single drill in one door data
                TimerGui.AddMissionDoorData(tbl[1], door)
            end
        end
    end
end

function EHI:CheckNotLoad()
    if Global.load_level and not Global.editor_mode then
        return false
    end
    return true
end

---Disables code if level has not been loaded
---@param hook string
function EHI:CheckLoadHook(hook)
    if not Global.load_level or Global.editor_mode or self._hooks[hook] then
        return true
    end
    self._hooks[hook] = true
    return false
end

---Disables code if level has been loaded
---@param hook string
function EHI:CheckMenuHook(hook)
    if Global.load_level or Global.editor_mode or self._hooks[hook] then
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

---@param hook string
function EHI:CheckHookMultiple(hook)
    if self._hooks[hook] or Global.editor_mode then
        local count = (self._hooks[hook] or 0) + 1
        self._hooks[hook] = count
        return count < 9
    end
    self._hooks[hook] = 1
    return true
end

---@param hook string
---@param condition boolean
function EHI:CheckHookConditional(hook, condition)
    if condition then
        return self:CheckHookMultiple(hook)
    else
        return self:CheckHook(hook)
    end
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
    end
    return time_override.deathsentence or 40
end

---Returns value for the current difficulty. If the value is not provided `-1` is returned
---@generic T
---@param values ValueBasedOnDifficultyTable
---@return T|number
function EHI:GetValueBasedOnDifficulty(values)
    if values.normal_or_above and self:IsDifficultyOrAbove(self.Difficulties.Normal) then
        return values.normal_or_above
    elseif values.normal and self:IsDifficulty(self.Difficulties.Normal) then
        return values.normal
    elseif values.hard_or_below and self:IsDifficultyOrBelow(self.Difficulties.Hard) then
        return values.hard_or_below
    elseif values.hard_or_above and self:IsDifficultyOrAbove(self.Difficulties.Hard) then
        return values.hard_or_above
    elseif values.hard and self:IsDifficulty(self.Difficulties.Hard) then
        return values.hard
    elseif values.veryhard_or_below and self:IsDifficultyOrBelow(self.Difficulties.VeryHard) then
        return values.veryhard_or_below
    elseif values.veryhard_or_above and self:IsDifficultyOrAbove(self.Difficulties.VeryHard) then
        return values.veryhard_or_above
    elseif values.veryhard and self:IsDifficulty(self.Difficulties.VeryHard) then
        return values.veryhard
    elseif values.overkill_or_below and self:IsDifficultyOrBelow(self.Difficulties.OVERKILL) then
        return values.overkill_or_below
    elseif values.overkill_or_above and self:IsDifficultyOrAbove(self.Difficulties.OVERKILL) then
        return values.overkill_or_above
    elseif values.overkill and self:IsDifficulty(self.Difficulties.OVERKILL) then
        return values.overkill
    elseif values.mayhem_or_below and self:IsDifficultyOrBelow(self.Difficulties.Mayhem) then
        return values.mayhem_or_below
    elseif values.mayhem_or_above and self:IsMayhemOrAbove() then
        return values.mayhem_or_above
    elseif values.mayhem and self:IsDifficulty(self.Difficulties.Mayhem) then
        return values.mayhem
    elseif values.deathwish_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathWish) then
        return values.deathwish_or_below
    elseif values.deathwish_or_above and self:IsDifficultyOrAbove(self.Difficulties.DeathWish) then
        return values.deathwish_or_above
    elseif values.deathwish and self:IsDifficulty(self.Difficulties.DeathWish) then
        return values.deathwish
    elseif values.deathsentence_or_below and self:IsDifficultyOrBelow(self.Difficulties.DeathSentence) then
        return values.deathsentence_or_below
    elseif values.deathsentence and self:IsDifficulty(self.Difficulties.DeathSentence) then
        return values.deathsentence
    end
    return -1
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
        new_SF = self.SpecialFunctions.AddTrackerIfDoesNotExist
    end
    return self:CopyTrigger(trigger, params, new_SF)
end

---@param type "ammo_bag"
---@param pos Vector3[] Table with positions that should be ignored
function EHI:SetDeployableIgnorePos(type, pos)
    if not type then
        return
    elseif type == "ammo_bag" and AmmoBagBase._ehi_ignored_pos then
        for _, _pos in ipairs(pos) do
            AmmoBagBase._ehi_ignored_pos[tostring(_pos)] = true
        end
    end
end

function EHI:CanShowCivilianCountTracker()
    return self:GetTrackerOption("show_civilian_count_tracker") and not tweak_data.levels:IsLevelSafehouse() and not tweak_data.levels:IsLevelSkirmish() and not table.has({
        alex_1 = true, -- Rats Day 1
        haunted = true, -- Safehouse Nightmare
        man = true, -- Undercover
        bph = true, -- Hell's Island
        chill_combat = true -- Safehouse Raid
    }, Global.game_settings.level_id)
end

---@param color_table { ["red"]: number|boolean|EHI.ColorTable.Color, ["blue"]: number|boolean|EHI.ColorTable.Color, ["green"]: number|boolean|EHI.ColorTable.Color }
---@param params EHI.ColorTable.params?
function EHI:HookColorCodes(color_table, params)
    params = params or {}
    if not (params.no_mission_check or self:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission")) then
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
    local color_map = self.TrackerUtils:GetColorCodesMap()
    ---@param unit_id number
    ---@param color string
    local function hook(unit_id, color)
        local sequences = color_sequence_hash[color]
        for i = 0, 9, 1 do
            managers.mission:add_runned_unit_sequence_trigger(unit_id, sequences[i], function(...)
                managers.ehi_tracking:SetColorCode(color, i, unit_id, color_map[color], tracker_name)
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

---@param time number|EHIRandomTime
---@param trigger_name string?
---@param loud_check boolean?
function EHI:AddEndlessAssault(time, trigger_name, loud_check)
    local tbl = ---@type ElementTrigger
    {
        id = trigger_name or "EndlessAssault",
        icons = { { icon = "padlock", color = Color.red } },
        class = self.Trackers.Warning,
        hint = "endless_assault"
    }
    if type(time) == "number" then
        tbl.time = time
    else
        local start_t = time[1]
        tbl.additional_time = start_t
        tbl.random_time = time[2] - start_t
    end
    if loud_check then
        tbl.condition_function = self.ConditionFunctions.IsLoud
    end
    return tbl
end

---@param t number
---@param wp_vector Vector3
---@param id string?
---@param trigger_once boolean?
---@param condition boolean?
---@return ElementTrigger?
function EHI:AddIncomingTurret(t, wp_vector, id, trigger_once, condition)
    if condition ~= false then
        return {
            id = id or "SWATTurretArrival",
            time = t,
            icons = { self.Icons.Turret, self.Icons.Goto },
            class = self.Trackers.Warning,
            waypoint =
            {
                icon = self.Icons.Turret,
                position = wp_vector
            },
            hint = "turret_en_route",
            trigger_once = trigger_once
        }
    end
end

---@param single_sniper boolean?
---@param trigger_once boolean?
---@return ElementTrigger?
function EHI:AddSniperSpawnedPopup(single_sniper, trigger_once)
    if not (self:GetTrackerOption("show_sniper_tracker") and self:GetOption("show_sniper_spawned_popup")) then
        return nil
    end
    return {
        special_function = self.SpecialFunctions.CustomCode,
        f = function()
            managers.hud:ShowSnipersSpawned(single_sniper)
        end,
        trigger_once = trigger_once
    }
end

---Checks if EHI hook for given object and function exists
---@param object any
---@param func string
---@param id string
function EHI:HookExists(object, func, id)
    local function_hooks = Hooks._function_hooks[object] and Hooks._function_hooks[object][func]
    if not function_hooks then
        return false
    end
    local overrides = function_hooks.overrides
    for _, func_tbl in ipairs(overrides.pre) do
        if func_tbl.id == id then
            return true
        end
    end
    for _, func_tbl in ipairs(overrides.post) do
        if func_tbl.id == id then
            return true
        end
    end
    return false
end

---Updates existing EHI hook for given object and function
---@generic T
---@param object T
---@param func string
---@param id string
---@param new_f fun(self: T, ...)
function EHI:UpdateExistingHook(object, func, id, new_f)
    local function_hooks = Hooks._function_hooks[object] and Hooks._function_hooks[object][func]
    if not function_hooks then
        return
    end
    local overrides = function_hooks.overrides
    for _, func_tbl in ipairs(overrides.pre) do
        if func_tbl.id == id then
            func_tbl.func = new_f
            return
        end
    end
    for _, func_tbl in ipairs(overrides.post) do
        if func_tbl.id == id then
            func_tbl.func = new_f
            return
        end
    end
end

---Checks if EHI hook for given object and function exists and updates its function; else if will create a new hook
---@generic T
---@param object T
---@param func string
---@param id string
---@param new_f fun(self: T, ...)
function EHI:UpdateExistingHookIfExistsOrHook(object, func, id, new_f)
    if self:HookExists(object, func, id) then
        self:UpdateExistingHook(object, func, id, new_f)
    else
        Hooks:PostHook(object, func, id, new_f)
    end
end

Load()
if EHI:GetOption("show_trackers") then
    if EHI:GetUnlockableOption("hide_unlocked_achievements") then
        local G = Global
        ---@param achievement string
        ---@return boolean
        function EHI:IsAchievementUnlocked(achievement)
            local a = G.achievment_manager.achievments[achievement]
            return a and a.awarded
        end
    else -- Always show trackers for achievements
        ---@param achievement string
        function EHI:IsAchievementUnlocked(achievement)
            return false
        end
    end
    if EHI:GetUnlockableOption("hide_unlocked_trophies") then
        ---@param trophy string
        function EHI:IsTrophyUnlocked(trophy)
            return managers.custom_safehouse:is_trophy_unlocked(trophy)
        end
    else
        ---@param trophy string
        function EHI:IsTrophyUnlocked(trophy)
            return false
        end
    end
else
    ---@param achievement string
    function EHI:IsAchievementUnlocked(achievement)
        return true
    end
    ---@param trophy string
    function EHI:IsTrophyUnlocked(trophy)
        return true
    end
end

---@param daily_id string
---@param skip_unlockables_check boolean?
function EHI:IsSHSideJobAvailable(daily_id, skip_unlockables_check)
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily.id == daily_id and managers.custom_safehouse:can_progress_trophies(daily_id) then
        if current_daily.state == "completed" or current_daily.state == "rewarded" then
            return false
        elseif skip_unlockables_check then
            return true
        end
        return not self._cache.UnlockablesAreDisabled
    end
    return false
end

---@param objectives table
---@param progress_id string
---@return integer progress, integer max
function EHI._get_objective_progress(objectives, progress_id)
    for _, objective in ipairs(objectives) do
        if objective.progress_id == progress_id then
            return objective.progress, objective.max_progress
        end
    end
    return 0, 0
end

---@param daily_id string
---@param progress_id string?
---@return number progress, number max
function EHI:GetSHSideJobProgressAndMax(daily_id, progress_id)
    local current_daily = managers.custom_safehouse:get_daily_challenge()
    if current_daily and current_daily.id == daily_id and managers.custom_safehouse:can_progress_trophies(daily_id) then
        return self._get_objective_progress(current_daily.trophy.objectives, progress_id or daily_id)
    end
    return 0, 0
end

---@param daily_id string
---@param progress_id string?
---@return number progress, number max
function EHI:GetDailyChallengeProgressAndMax(daily_id, progress_id)
    local current_job = managers.challenge:get_active_challenge(daily_id)
    if current_job and current_job.id == daily_id and current_job.objectives and managers.challenge:can_progress_challenges() then
        return self._get_objective_progress(current_job.objectives, progress_id or daily_id)
    end
    return 0, 0
end

---@param event SideJobEventManager_Challenge
---@param stat_id string
---@return integer progress, integer max
function EHI:GetEventMissionProgressAndMax(event, stat_id)
    for _, objective in ipairs(event.objectives) do
        if objective.challenge_choices then
            for _, choice in ipairs(objective.challenge_choices) do
                if choice.progress_id == stat_id then
                    return choice.progress, choice.max_progress
                end
            end
        end
    end
    return 0, 0
end

---@param trophy string
function EHI:IsTrophyLocked(trophy)
    return not self:IsTrophyUnlocked(trophy) and not self._cache.UnlockablesAreDisabled
end

---@param achievement string
function EHI:IsAchievementLocked(achievement)
    return not self:IsAchievementUnlocked(achievement) and not self._cache.UnlockablesAreDisabled
end

---@param achievement string Achievement ID in Vanilla; Beardlib is not supported
function EHI:GetAchievementProgress(achievement)
    return managers.network.account:get_stat(achievement)
end

--- Used for achievements that has in the description `Kill X enemies in an heist` and etc... to show them only once  
--- This is done to prevent tracker spam if the player decides to replay the same heist with a similar weapon or weapon category  
--- Once the achievement has been awarded, the achievement will no longer show on the screen
---@param achievement string
---@return boolean
function EHI:IsAchievementLocked2(achievement)
    local a = Global.achievment_manager.achievments[achievement]
    return a and not a.awarded
end

---@param achievement string
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
        local element_f = managers.ehi_hook._element_hook_function
        for _, instance in ipairs(managers.world_instance:instance_data()) do
            if instance.name == instance_name then
                self:PrintTable(instance)
                local start = self:GetInstanceElementID(100000, instance.start_index)
                local function f(e, ...) ---@param e MissionScriptElement
                    managers.chat:_receive_message(1, "[EHI]", string.format("Base ID: %d; ID: %d; Element: %s; Instance: %s", EHI:GetBaseUnitID(e._id, instance.start_index, 100000), e._id, e:editor_name(), instance_name), Color.white)
                end
                self:Log(string.format("Hooking elements in instance '%s'", instance_name))
                for _, script in pairs(scripts) do
                    for i = start, start + instance.index_size - 1, 1 do
                        local element = script:element(i)
                        if element then
                            Hooks:PostHook(element, element_f, "EHI_Debug_Element_" .. tostring(i), f)
                        end
                    end
                end
                self:Log("Hooking done")
            end
        end
    end
end

---@param tbl table
---@param tables_to_ignore string|string[]?
---@param ... any
function EHI:PrintTable(tbl, tables_to_ignore, ...)
    local s = ""
    if ... then
        for _, _s in ipairs({ ... }) do
            s = s .. " " .. tostring(_s)
        end
    end
    if _G.PrintTableDeep then
        _G.PrintTableDeep(tbl, 5000, true, "[EHI]" .. s, tables_to_ignore, false)
    else
        if s ~= "" then
            self:Log(s)
        end
        Utils.PrintTable(tbl)
    end
end

---@param tbl table
---@param ... any
function EHI:PrintClass(tbl, ...)
    if ... then
        for _, _s in ipairs({ ... }) do
            self:Log(_s)
        end
    end
    Utils.PrintTable(tbl)
end

--- ["path"] = Idstring(path):key()
local paths = {
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_gold"] = "5dcd1776e3f2f767",
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_money"] = "8d8c766828915eb9",
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_deposit/spawn_jewelry"] = "51da6d6c91d378c1",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_special_money"] = "eee53eb5be4a40f7",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_a"] = "8c6bb6d9e7c729ef",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_b"] = "34542bae5d32069e",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_c"] = "92c7be115bbd2886",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_d"] = "825640d06a632353",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_value_e"] = "6b344f61865251a3",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_crap_a"] = "2bf8e3a9464bf3e0",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_crap_b"] = "7018d5bfd34e2981",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_crap_c"] = "38a21571a66976ef",
    ["units/payday2/props/bnk_prop_vault_loot/bnk_prop_vault_loot_crap_d"] = "03967aa3cba558ed",
    ["units/pd2_dlc_jfr/pickups/spawn_german_folder/spawn_german_folder"] = "d2d7c5a3aced6f0f",
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_deposit_box"] = "e4bc87015ed9fd46",
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/str_vehicle_truck_gensec_transport_deposit_box_intel"] = "50aac55917cba830",
    ["units/pd2_dlc1/vehicles/str_vehicle_truck_gensec_transport/spawn_gensec_doors/spawn_gensec_doors"] = "899966c1e07635cf",
    ["units/payday2/characters/ene_sniper_1/ene_sniper_1"] = "ffcb30c12128fc5b",
    ["units/payday2/characters/ene_sniper_2/ene_sniper_2"] = "490944f03e56fcf0",
    ["units/pd2_dlc_rvd/equipment/rvd_interactable_saw_no_jam/rvd_interactable_saw_no_jam"] = "0cec8292d88a4875"
}
local unit_key = "8f6601ad58a9bc7d" -- unit
Hooks:Add("BeardLibPreInit", "EHI_BeardLib_Crash_Fix", function()
    if Global.EHI_VanillaHeist == nil and Global.EHI_AppliedBeardLibFix == nil then -- First launch, avoid doing anything as the game will shortly crash because it will try to load snipers
        return
    elseif not Global.fm then
        Global.fm = { added_files = {} }
    end
    if Global.EHI_VanillaHeist and Global.EHI_AppliedBeardLibFix ~= false then
        if Global.fm.added_files[unit_key] then -- Check if the unit table exists, otherwise it may crash
            for _, key in pairs(paths) do
                Global.fm.added_files[unit_key][key] = nil
            end
        end
        Global.EHI_AppliedBeardLibFix = false
    elseif not Global.EHI_VanillaHeist and not Global.EHI_AppliedBeardLibFix then
        Global.fm.added_files[unit_key] = Global.fm.added_files[unit_key] or {}
        for path, key in pairs(paths) do
            Global.fm.added_files[unit_key][key] = { path = path }
        end
        Global.EHI_AppliedBeardLibFix = true
    end
end)