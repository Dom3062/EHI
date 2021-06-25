if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.MissionScriptElement then -- Don't hook twice, pls
    return
else
    EHI._hooks.MissionScriptElement = true
end
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = difficulty_index >= 5
local mayhem_and_up = difficulty_index >= 4
local ovk_and_below = difficulty_index <= 3
local ovk_and_up = difficulty_index >= 3
local very_hard_and_up = difficulty_index >= 2
local very_hard_and_below = difficulty_index <= 2
local hard_and_above = difficulty_index >= 1
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = {}
local SF = EHI.SpecialFunctions
local CF = EHI:GetConditionFunctions()
local Icon = EHI:GetIcons()
local TT = -- Tracker Type
{
    MallcrasherMoney = "EHIMoneyCounterTracker",
    Warning = "EHIWarningTracker",
    Pausable = "EHIPausableTracker",
    Chance = "EHIChanceTracker",
    Progress = "EHIProgressTracker",
    Achievement = "EHIAchievementTracker",
    AchievementProgress = "EHIAchievementProgressTracker",
    AchievementNotification = "EHIAchievementNotificationTracker",
    Inaccurate = "EHIInaccurateTracker",
    InaccurateWarning = "EHIInaccurateWarningTracker"
}
local AchievementTT =
{
    EHIAchievementTracker = true,
    EHIAchievementDoneTracker = true,
    EHIAchievementUnlockTracker = true,
    EHIAchievementProgressTracker = true,
    EHIAchievementObtainableTracker = true,
    EHIAchievementNotificationTracker = true,
}
local Holdout =
{
    skm_run = true,
    skm_red2 = true,
    skm_mus = true,
    skm_arena = true,
    skm_bex = true,
    skm_big2 = true,
    skm_cas = true,
    skm_mallcrasher = true,
    skm_watchdogs_stage2 = true
}
SF.WATCHDOGS_2_AddToCache = 90
SF.WATCHDOGS_2_GetFromCache = 91
SF.KOSUGI_DisableTriggerAndExecute = 93
SF.CROJOB3_PauseTrackerAndAddNewTracker = 95
SF.CROJOB3_SetTimeByElement = 96
SF.MEX_CheckIfLoud = 98 -- Custom special function
SF.FRIEND_ExecuteIfElementIsEnabledAndRemoveTrigger = 99
SF.NMH_LowerFloor = 191
SF.ED3_SetWhiteColorWhenUnpaused = 192
SF.ED3_SetPausedColor = 193
SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists = 194
SF.WD2_SetTrackerAccurate = 199
--SF.IncreaseProgressMax = 399
SF.ALEX_1_SetTimeIfMoreThanOrCreateTracker = 497
SF.KOSUGI_ExecuteAndDisableTriggers = 498
SF.MeltdownAddCrowbar = 999
SF.SAND_ExecuteIfProgressMatch = 1099
local client = Network:is_client()
local host = not client
local CarEscape = { Icon.Car, Icon.Escape, Icon.LootDrop }
local CarWait = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }
local HeliEscape = { Icon.Heli, Icon.Escape, Icon.LootDrop }
local HeliDropDrill = { Icon.Heli, "pd2_drill", "pd2_goto" }
local BoatEscape = { Icon.Boat, Icon.Escape, Icon.LootDrop }
if level_id == "short2_stage2b" then -- Basic Mission: Loud - Plan B
    triggers = {
        [100806] = { time = 62 + 24, id = "Heli", icons = HeliEscape }
    }
elseif level_id == "four_stores" then -- Four Stores
    local van_anim_delay = 320 / 30
    local assault_delay = 0
    triggers = { -- Time before escape vehicle arrives
        [102492] = { time = 40 + van_anim_delay },
        [102493] = { time = 30 + van_anim_delay },
        [102494] = { time = 20 + van_anim_delay },
        [102495] = { time = 50 + van_anim_delay },
        [102496] = { time = 60 + van_anim_delay },
        [102497] = { time = 70 + van_anim_delay },
        [102498] = { time = 100 + van_anim_delay },
        [102499] = { time = 90 + van_anim_delay },
        [102511] = { time = 80 + van_anim_delay },
        [102512] = { time = 110 + van_anim_delay },
        [102513] = { time = 120 + van_anim_delay },
        [102526] = { time = 130 + van_anim_delay },
        [103592] = { time = 160 + van_anim_delay },
        [103593] = { time = 180 + van_anim_delay },
        [103594] = { time = 200 + van_anim_delay }
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = CarEscape
elseif level_id == "mallcrasher" then -- Mallcrasher
    triggers = { -- Time before escape vehicle arrives
        [300248] = { time = (ovk_and_below and 120 or 300) + 25 },
        -- 120: Base Delay on OVK or below
        -- 300: Base Delay on Mayhem or above
        -- 25: Escape zone activation delay

        [300043] = { id = "MallDestruction", class = TT.MallcrasherMoney, icons = { "C_Vlad_H_Mallcrasher_Shoot" } },
        [300852] = { amount = 40, id = "MallDestruction", special_function = SF.AddMoney },
        [300853] = { amount = 80, id = "MallDestruction", special_function = SF.AddMoney },
        [300854] = { amount = 250, id = "MallDestruction", special_function = SF.AddMoney },
        [300855] = { amount = 500, id = "MallDestruction", special_function = SF.AddMoney },
        [300856] = { amount = 800, id = "MallDestruction", special_function = SF.AddMoney },
        [300857] = { amount = 2000, id = "MallDestruction", special_function = SF.AddMoney },
        [300858] = { amount = 2800, id = "MallDestruction", special_function = SF.AddMoney },
        [300859] = { amount = 4000, id = "MallDestruction", special_function = SF.AddMoney },
        [300873] = { amount = 5600, id = "MallDestruction", special_function = SF.AddMoney },
        --[300863] = { amount = 5600, id = "MallDestruction", special_function = true },
        --[300867] = { amount = 5600, id = "MallDestruction", special_function = true },
        --[300869] = { amount = 5600, id = "MallDestruction", special_function = true },
        --[300870] = { amount = 5600, id = "MallDestruction", special_function = true },
        --[300830] = { amount = 8000, id = "MallDestruction", special_function = true },

        [301148] = { time = 180, id = "uno_3", icons = { "C_Vlad_H_Mallcrasher_SelfCheck" }, class = TT.Achievement },
        [300241] = { id = "uno_3", special_function = SF.SetAchievementComplete }
    }
    trigger_id_all = "EscapeHeli"
    trigger_icon_all = { Icon.Heli, Icon.Escape }
elseif level_id == "nightclub" then -- Nightclub
    triggers = {
        -- Time before escape van comes in
        [102808] = { time = 65 },
        [102811] = { time = 80 },
        [103591] = { time = 126 },
        [102813] = { time = 186 },
        [100797] = { time = 240 },
        [100832] = { time = 270 },

        -- Fire
        [101412] = { time = 300, id = "fire1", icons = { Icon.Fire }, class = TT.Warning },
        [101453] = { time = 300, id = "fire2", icons = { Icon.Fire }, class = TT.Warning },

        -- Asset
        [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = { Icon.Car, Icon.LootDrop } }
        -- 20: Base Delay
        -- 40/3: Animation finish delay
        -- Total 33.33 s
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = CarEscape
elseif level_id == "escape_cafe" or level_id == "escape_cafe_day" then -- Escape: Cafe and Escape: Cafe (Day)
    triggers = {
        [100247] = { time = 180 },
        [100248] = { time = 120 },
        [100287] = { time = 30, id = "frappucino_to_go_please", icons = { "C_Escape_H_Cafe_Cappuccino" }, class = TT.Achievement },
        [101379] = { id = "frappucino_to_go_please", special_function = SF.SetAchievementComplete }
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = CarEscape
elseif level_id == "escape_overpass" or level_id == "escape_overpass_night" then -- Escape: Overpass
    triggers = {
        [101148] = { id = "you_shall_not_pass", icons = { "C_Escape_H_Overpass_YouShallNot" }, status = "ok", class = TT.AchievementNotification },
        [102471] = { id = "you_shall_not_pass", special_function = SF.SetAchievementFailed },
        [100426] = { id = "you_shall_not_pass", special_function = SF.SetAchievementComplete },
        [101145] = { time = 180, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101158] = { time = 240, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101977] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101978] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101979] = { special_function = SF.AddToCache, data = { icon = Icon.Car } }, -- Van
    }
    trigger_id_all = "Escape"
elseif level_id == "escape_park" or level_id == "escape_park_day" then -- Escape: Park and Escape: Park (Day)
    triggers = {
        [102444] = { id = "king_of_the_hill", icons = { "C_Escape_H_Park_King" }, status = "ok", class = TT.AchievementNotification },
        [101297] = { id = "king_of_the_hill", special_function = SF.SetAchievementFailed },
        [101343] = { id = "king_of_the_hill", special_function = SF.SetAchievementComplete },
        [102449] = { time = 240 },
        [102450] = { time = 180 },
        [102451] = { time = 300 }
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = CarEscape
elseif level_id == "escape_street" then -- Escape: Street
    triggers = {
        [101959] = { id = "bullet_dodger", icons = { "C_Escape_H_Street_Bullet" }, status = "ok", class = TT.AchievementNotification },
        [101872] = { id = "bullet_dodger", special_function = SF.SetAchievementFailed },
        [101874] = { id = "bullet_dodger", special_function = SF.SetAchievementComplete },
        [101961] = { time = 120 },
        [101962] = { time = 90 }
    }
    trigger_id_all = "EscapeHeli"
    trigger_icon_all = HeliEscape
elseif level_id == "election_day_1" then -- Election Day 1
    triggers = {
        [100003] = { time = 60, id = "slakt_1", icons = { "C_Elephant_H_ElectionDay_Speedlock" }, class = TT.Achievement },
        [100012] = { id = "bob_8", icons = { "C_Elephant_H_ElectionDay_HotLava" }, class = TT.AchievementNotification },
        [101248] = { id = "bob_8", special_function = SF.SetAchievementComplete },
        [100469] = { id = "bob_8", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "election_day_3" or level_id == "election_day_3_skip1" or level_id == "election_day_3_skip2" then -- Election Day 2 Plan C
    triggers = {
        [101284] = { chance = 50, id = "CrashChance", icons = { "wp_hack", "pd2_fix" }, class = TT.Chance },
        [103568] = { time = 60, id = "Hack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.ED3_SetWhiteColorWhenUnpaused },
        [103585] = { id = "Hack", special_function = SF.ED3_SetPausedColor },
        [103579] = { amount = 25, id = "CrashChance", special_function = SF.DecreaseChance },
        [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
        [103572] = { time = 50, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103573] = { time = 40, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103574] = { time = 30, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103478] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } },
        [103169] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } },
        [103179] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } },
        [103190] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } },
        [103195] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } },

        [103535] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
    }
elseif level_id == "framing_frame_3" then -- Framing Frame Day 3
    triggers = {
        [100931] = { time = 23 },
        [104910] = { time = 24 },
        [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = { Icon.Heli, Icon.Escape }
elseif level_id == "pbr" then -- Beneath the Mountain
    triggers = {
        [102290] = { id = "berry_3", special_function = SF.SetAchievementComplete },
        [102292] = { time = 600, id = "berry_3", icons = { "C_Locke_H_Beneath_Commando" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },

        [101774] = { time = 90, id = "EscapeHeli", icons = { "pd2_escape" } }
    }
elseif level_id == "pbr2" then -- Birth of Sky
    local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
    local ring = { id = "voff_4", special_function = SF.IncreaseProgress }
    triggers = {
        [102504] = { id = "cac_33", status = "ready", icons = { "C_Locke_H_BirthOfSky_Expert" }, class = TT.AchievementNotification, condition = show_achievement and dw_and_above },
        [103486] = { id = "cac_33", status = "ok", special_function = SF.SetAchievementStatus },
        [103479] = { id = "cac_33", special_function = SF.SetAchievementComplete },
        [103475] = { id = "cac_33", special_function = SF.SetAchievementFailed },
        [103487] = { max = 200, id = "cac_33_kills", icons = { "pd2_kill" }, class = TT.Progress, flash_times = 1, condition = show_achievement and dw_and_above, special_function = SF.ShowAchievementCustom, data = "cac_33" },
        [103477] = { id = "cac_33_kills", special_function = SF.IncreaseProgress },
        [103481] = { id = "cac_33_kills", special_function = SF.RemoveTracker },
        [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli, "equipment_winch_hook" } }, -- Time before Locke arrives with heli to pickup the money
        [102452] = { id = "jerry_4", special_function = SF.SetAchievementComplete },
        [102453] = { time = 83, id = "jerry_4", icons = { "C_Locke_H_BirthOfSky_OneTwoThree" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },

        [103248] = ring,
        [103252] = ring,
        [103255] = ring,
        [103258] = ring,
        [103261] = ring,
        [103264] = ring,
        [103267] = ring,
        [103270] = ring,
        [103273] = ring,
        [103276] = ring,
        [103279] = ring,
        [103282] = ring,
        [103285] = ring,
        [103288] = ring,
        [103291] = ring,
        [103294] = ring,
        [103297] = ring,
        [103300] = ring,
        [103303] = ring,
        [103306] = ring,
        [103309] = ring,
        [103312] = ring,
        [103315] = ring,
        [103318] = ring,
        [103321] = ring,
        [103324] = ring,
        [103327] = ring,
        [103330] = ring,
        [103333] = ring,
        [103336] = ring,
        [103339] = ring,

        [101985] = thermite, -- First grate
        [101984] = thermite -- Second grate
    }
elseif level_id == "mus" then -- The Diamond
    local delay = 5
    local gas_delay = 0.5
    triggers = {
        [102442] = { time = 130 + delay, special_function = SF.AddTrackerIfDoesNotExist },
        [102441] = { time = 120 + delay, special_function = SF.AddTrackerIfDoesNotExist },
        [102434] = { time = 110 + delay, special_function = SF.AddTrackerIfDoesNotExist },
        [102433] = { time = 80 + delay, special_function = SF.AddTrackerIfDoesNotExist },
        [100840] = { time = 600, id = "bat_4", icons = { "C_Dentist_H_Diamond_Smoke" }, class = TT.Achievement },

        [102065] = { time = 50 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102067] = { time = 65 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102068] = { time = 80 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102069] = { time = 95 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102070] = { time = 110 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102071] = { time = 125 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
        [102072] = { time = 140 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } }
    }
    trigger_id_all = "EscapeHeli"
    trigger_icon_all = HeliEscape
elseif level_id == "mia_1" then -- Hotline Miami Day 1
    local delay = 1.5
    triggers = {
        [102177] = { time = (ovk_and_up and (3 + 60 + 23 + 5) or (30 + 23 + 5)), id = "heli", icons = { Icon.Heli, Icon.Bag, "pd2_goto" } }, -- Time before Bile arrives
        --,[105967] = { time = 60 + 23 + 5 }
        --,[103808] = { time = 30 + 23 + 5 }

        [EHI:GetInstanceElementID(100152, 7800)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } },
        [EHI:GetInstanceElementID(100152, 8200)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } },
        [EHI:GetInstanceElementID(100152, 8600)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } },

        [106013] = { time = (very_hard_and_below and 40 or 60), id = "Truck", icons = { "pd2_car" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [106017] = { id = "Truck", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100038, 1300)] = { time = 90 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100039, 1300)] = { time = 120 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100040, 1300)] = { time = 180 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100045, 1300)] = { id = "reader", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100051, 1300)] = { id = "reader", special_function = SF.UnpauseTracker }
    }
    local start_index = { 7800, 8200, 8600 }
    if client then
        local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
        local delete_interact = { id = "MethlabInteract", special_function = SF.RemoveTracker }
        for _, index in pairs(start_index) do
            triggers[EHI:GetInstanceElementID(100149, index)] = random_time
            triggers[EHI:GetInstanceElementID(100150, index)] = random_time
            triggers[EHI:GetInstanceElementID(100184, index)] = delete_interact
        end
    end
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    triggers = {
        [101228] = { time = 210, id = "pig_2", icons = { "C_Dentist_H_HotlineMiami_WalkFaster" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [100788] = { id = "pig_2", special_function = SF.SetAchievementComplete },

        [100225] = { time = 5 + 5 + 22, id = "heli", icons = HeliEscape },
        -- 5 = Base Delay
        -- 5 = Delay when executed
        -- 22 = Heli door anim delay
        -- Total: 32 s
    }
    local start = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Achievement }
    local fail = { id = "HostageBomb", special_function = SF.SetAchievementFailed } -- Hostage blew out
    local complete = { id = "HostageBomb", special_function = SF.SetAchievementComplete } -- Hostage saved
    local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100024, index)] = start
        triggers[EHI:GetInstanceElementID(100039, index)] = fail
        triggers[EHI:GetInstanceElementID(100027, index)] = complete
    end
elseif level_id == "born" then -- The Biker Heist Day 2
    trigger_icon_all = { "pd2_defend" }
    triggers = {
        [101034] = { id = "MikeDefendTruck", class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033 },
        [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
        [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

        [101535] = { id = "MikeDefendGarage", class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532 },
        [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
        [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker }
    }
    if client then
        triggers[101034].time = 80
        triggers[101034].random_time = 10
        triggers[101034].special_function = SF.UnpauseTrackerIfExists
        triggers[101034].icons = trigger_icon_all
        triggers[101034].delay_only = true
        triggers[101034].class = "EHIInaccuratePausableTracker"
        triggers[101034].synced = { class = "EHIPausableTracker" }
        EHI:AddSyncTrigger(101034, triggers[101034])
        triggers[101535].time = 90
        triggers[101535].random_time = 30
        triggers[101535].special_function = SF.UnpauseTrackerIfExists
        triggers[101535].icons = trigger_icon_all
        triggers[101535].delay_only = true
        triggers[101535].class = "EHIInaccuratePausableTracker"
        triggers[101535].synced = { class = "EHIPausableTracker" }
        EHI:AddSyncTrigger(101535, triggers[101535])
    end
elseif level_id == "glace" then -- Green Bridge
    triggers = {
        [102368] = { id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = "EHIPausableTracker", special_function = SF.GetElementTimerAccurate, element = 102333 },
        [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
        [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [102370] = { time = 45, id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = "EHIPausableTracker" },

        [101732] = { special_function = SF.Trigger, data = { 1017321, 1017322 } },
        [1017321] = { id = "glace_9", status = "ready", icons = { "C_Classics_H_GreenBridge_Caution" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
        [1017322] = { max = 6, id = "glace_10", icons = { "C_Classics_H_GreenBridge_BackToPrison" }, class = TT.AchievementProgress },
        [105758] = { id = "glace_9", special_function = SF.SetAchievementFailed },
        [105756] = { id = "glace_9", status = "ok", special_function = SF.SetAchievementStatus },
        [105759] = { id = "glace_9", special_function = SF.SetAchievementComplete },
        [105761] = { id = "glace_10", special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
        [105721] = { id = "glace_10", special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
    }
    if client then
        triggers[102368].time = 120
        triggers[102368].random_time = 10
        triggers[102368].delay_only = true
        triggers[102368].class = "EHIInaccuratePausableTracker"
        triggers[102368].synced = { class = "EHIPausableTracker" }
        EHI:AddSyncTrigger(102368, triggers[102368])
    end
elseif level_id == "moon" then -- Stealing Xmas
    triggers = {
        [101176] = { time = 67 + 400/30, id = "WinchInteract", icons = { Icon.Heli, Icon.Winch } },
        [106390] = { time = 6 + 30 + 25 + 15 + 2.5, id = "C4", icons = { Icon.Heli, Icon.C4, "pd2_goto" } },
        -- 6s delay before Bile speaks
        -- 30s delay before random logic
        -- 25s delay to execute random logic
        -- Random logic has defined 2 heli fly ins
        -- First is shorter (6.5 + 76/30) 76/30 => 2.533333 (rounded to 2.5 in Mission Script)
        -- Second is longer (15 + 76/30)
        -- Second animation is counted in this trigger, the first is in CoreElementUnitSequence.lua.
        -- If the first fly in is selected, the tracker is updated to reflect that

        [100107] = { max = 2, id = "moon_4", icons = { "C_Vlad_H_StealingXmas_Imitations" }, class = TT.AchievementProgress, special_function = SF.RemoveTriggerAndShowAchievement },

        [100647] = { time = 10, id = "SantaTalk", icons = { "pd2_talk" }, special_function = SF.ExecuteIfElementIsEnabled },
        [100159] = { time = 5 + 7 + 7.3, id = "Escape", icons = { "pd2_escape" }, special_function = SF.ExecuteIfElementIsEnabled },

        [104219] = { id = "moon_4", special_function = SF.IncreaseProgress }, -- Chains
        [104220] = { id = "moon_4", special_function = SF.IncreaseProgress }, -- Dallas

        [100578] = { time = 9, id = "C4", icons = { "heli", Icon.C4, "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "dark" then -- Murky Station
    triggers = {
        [100296] = { time = 420, id = "dark_2", icons = { "C_Jimmy_H_MurkyStation_GhostRun" }, class = TT.Achievement },
        [106026] = { time = 10, id = "Van", icons = CarEscape },

        [106036] = { time = 410/30, id = "Boat", icons = { "boat", "pd2_escape", "pd2_lootdrop" } }
    }
elseif level_id == "mad" then -- Boiling Point
    triggers = {
        [100891] = { time = 15.33, id = "emp_bomp_drop", icons = { "pd2_goto" } },
        [101906] = { time = 1200, id = "daily_cake", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up },
        [100547] = { special_function = SF.Trigger, data = { 1005471, 1005472 } },
        [1005471] = { id = "mad_2", icons = { "C_Jimmy_H_Boiling_TheGround" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
        [1005472] = { id = "cac_13", icons = { "C_Jimmy_H_Boiling_Remember" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },

        [EHI:GetInstanceElementID(100019, 3150)] = { time = 90, id = "Scan", icons = { "mad_scan" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100049, 3150)] = { id = "Scan", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100030, 3150)] = { id = "Scan", special_function = SF.RemoveTracker }, -- Just in case

        [EHI:GetInstanceElementID(100013, 1350)] = { time = 120, id = "EMP", icons = { "pd2_defend" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100023, 1350)] = { id = "EMP", special_function = SF.PauseTracker },

        [101400] = { id = "mad_2", special_function = SF.SetAchievementFailed },
        [101823] = { id = "mad_2", special_function = SF.SetAchievementComplete },

        [101925] = { id = "cac_13", special_function = SF.SetAchievementFailed },
        [101924] = { id = "cac_13", special_function = SF.SetAchievementComplete }
    }
    if client then
        triggers[101410] = { id = "Scan", special_function = SF.RemoveTracker } -- Just in case
    end
elseif level_id == "chew" then -- The Biker Heist Day 2
    triggers = {
        [100595] = { time = 120, id = "born_5", icons = { "C_Elephant_H_Biker_FullThrottle" }, class = TT.Achievement, condition = ovk_and_up and show_achievement }
    }
    local sync_triggers =
    {
        [100558] = { id = "BileReturn", icons = HeliEscape }
    }
    if client then
        triggers[100558] = { time = 5, random_time = 5, id = "BileReturn", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
        EHI:SetSyncTriggers(sync_triggers)
    else
        EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
    end
elseif level_id == "vit" then -- The White House
    triggers = {
        [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance", trigger = 100808 } },
        [100808] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = very_hard_and_up, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [101378] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
        [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire } },

        [102335] = { time = 60, id = "Thermite", icons = { "pd2_fire" } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
        [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = { "heli", "pd2_escape" } } -- 30s delay + 26s escape zone delay
    }
elseif level_id == "wwh" then -- Alaskan Deal
    triggers = {
        [100946] = { max = 4, id = "wwh_10", icons = { "C_Locke_H_AlsDeal_HeadlessSnow" }, class = TT.AchievementProgress },
        [100944] = { id = "wwh_9", icons = { "C_Locke_H_AlsDeal_TheFuelMust" }, class = TT.AchievementNotification, contidition = show_achievement and ovk_and_up },
        [101250] = { id = "wwh_9", special_function = SF.SetAchievementFailed },
        [100082] = { id = "wwh_9", special_function = SF.SetAchievementComplete },
        [100322] = { time = 120, id = "Fuel", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [100323] = { id = "Fuel", special_function = SF.PauseTracker },
        [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "big" then -- The Big Bank
    local pc_hack = { time = 20, id = "PCHack", icons = { "wp_hack" } }
    local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
    triggers = {
        [1] = { time = 720, id = "bigbank_4", icons = { "C_Dentist_H_BigBank_TwelveAngry" }, class = TT.Achievement, condition = show_achievement and hard_and_above },
        [2] = { special_function = SF.RemoveTriggers, data = { 100107, 106140, 106150 } },
        [100107] = bigbank_4,
        [106140] = bigbank_4,
        [106150] = bigbank_4,
        [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },

        [100800] = { id = "cac_22", icons = { "C_Dentist_H_BigBank_Matrix" }, class = TT.AchievementNotification, condition = show_achievement and dw_and_above, special_function = SF.ShowAchievementFromStart },
        [106250] = { id = "cac_22", special_function = SF.SetAchievementFailed },
        [106247] = { id = "cac_22", special_function = SF.SetAchievementComplete },

        [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
        [104532] = pc_hack,
        [103179] = pc_hack,
        [103259] = pc_hack,
        [103590] = pc_hack,
        [103620] = pc_hack,
        [103671] = pc_hack,
        [103734] = pc_hack,
        [103776] = pc_hack,
        [103815] = pc_hack,
        [103903] = pc_hack,
        [103920] = pc_hack,
        [103936] = pc_hack,
        [103956] = pc_hack,
        [103974] = pc_hack,
        [103988] = pc_hack,
        [104014] = pc_hack,
        [104029] = pc_hack,
        [104051] = pc_hack,

        -- Heli escape
        [104126] = { time = 23 + 1, id = "HeliEscape", icons = HeliEscape },

        [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" } },
        [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" } },
        [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" } },

        [105623] = { time = 8, id = "Bus", icons = { Icon.Wait } }
    }
elseif level_id == "cane" then -- Santa's Workshop
    local fire_recharge = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } }
    local fire_t = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = TT.Warning }
    triggers = {
        [100647] = { time = 240 + 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop } },
        [EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
        [EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
        [EHI:GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { "heli", "pd2_goto" } }
    }
    for _, index in pairs({0, 120, 240, 360, 480}) do
        local recharge = EHI:DeepClone(fire_recharge)
        recharge.id = recharge.id .. index
        triggers[EHI:GetInstanceElementID(100024, index)] = recharge
        local fire = EHI:DeepClone(fire_t)
        fire.id = fire.id .. index
        triggers[EHI:GetInstanceElementID(100022, index)] = fire
    end
elseif level_id == "red2" then -- First World Bank
    triggers = {
        [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
        [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
        [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
        [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker },
        [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
        [103373] = { time = 817, id = "green_3", icons = { "C_Classics_H_FirstWorldBank_LEET" }, class = TT.Achievement },
        [107072] = { id = "cac_10", special_function = SF.SetAchievementComplete },
        [101544] = { time = 30, id = "cac_10", icons = { "C_Classics_H_FirstWorldBank_Federal" }, class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement, condition_function = CF.IsLoud },
        [101684] = { time = 5.1, id = "C4", icons = { "pd2_c4" } }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    triggers = {
        [100484] = { time = 300, id = "farm_2", icons = { "C_Classics_H_Slaughterhouse_ButHow" }, class = "EHIAchievementUnlockTracker" },
        [100485] = { time = 30, id = "farm_4", icons = { "C_Classics_H_Slaughterhouse_Pyromaniacs" }, class = TT.Achievement },
        [100915] = { time = 4640/30, id = "CraneGasMove", icons = { "equipment_winch_hook", Icon.Fire, "pd2_goto" } },
        [100967] = { time = 3660/30, id = "CraneGoldMove", icons = { Icon.Escape } },
        [100319] = { id = "farm_2", special_function = SF.SetAchievementFailed },
        [102841] = { id = "farm_4", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "flat" then -- Panic Room
    local kills = 7 -- Normal + Hard
    if difficulty_index == 2 or difficulty_index == 3 then
        -- Very Hard + OVERKILL
        kills = 10
    elseif difficulty_index >= 4 then
        -- Mayhem+
        kills = 15
    end
    triggers = {
        [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 } },
        [100182] = { id = "SniperDeath", special_function = SF.RemoveTracker },
        [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },
        [100147] = { time = 18.2, id = "HeliWinchLoop", icons = { Icon.Heli, "equipment_winch_hook", Icon.Loop }, special_function = SF.ExecuteIfElementIsEnabled },
        [102181] = { id = "HeliWinchLoop", special_function = SF.RemoveTracker },

        [100809] = { time = 60, id = "cac_9", icons = { "C_Classics_H_PanicRoom_QuickDraw" }, class = TT.Achievement, condition = ovk_and_up and show_achievement, special_function = SF.RemoveTriggerAndShowAchievement },

        [100068] = { max = kills, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
        [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = { "heli", "pd2_c4", "pd2_goto" } },
        [100082] = { time = 40, id = "HeliComesWithMagnet", icons = { "heli", "equipment_winch_hook" } },

        [104859] = { id = "flat_2", special_function = SF.SetAchievementComplete },
        [100805] = { id = "cac_9", special_function = SF.SetAchievementComplete },

        [100206] = { time = 30, id = "LoweringTheWinch", icons = { "heli", "equipment_winch_hook", "pd2_goto" } },

        [100049] = { time = 20, id = "flat_2", icons = { "C_Classics_H_PanicRoom_Cardio" }, class = TT.Achievement },
        [102001] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = {
        [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, "pd2_goto" } },

        [101343] = { time = 30, id = "KeypadReset", icons = { "restarter" } },

        [102259] = { id = "dah_8", special_function = SF.SetAchievementComplete },

        [104875] = { time = 45 + 26 + 6, id = "HeliEscapeLoud", icons = { Icon.Heli, Icon.Escape } },
        [103159] = { time = 30 + 26 + 6, id = "HeliEscapeLoud", icons = { Icon.Heli, Icon.Escape } },

        [102261] = { id = "dah_8", special_function = SF.IncreaseProgress }
    }
elseif level_id == "arena" then -- The Alesso Heist
    triggers = {
        [100241] = { time = 19, id = "HeliEscape", icons = HeliEscape },
        [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
        [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

        [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { "faster" } },
        [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { "pd2_generic_interact" }, class = TT.Warning },

        [100304] = { time = 5, id = "live_3", icons = { "C_Bain_H_Arena_Even" }, class = "EHIAchievementUnlockTracker" }
    }
elseif level_id == "run" then -- Heat Street
    triggers = {
        [100120] = { time = 1800, id = "run_9", icons = { "C_Classics_H_HeatStreet_Patience" }, class = "EHIAchievementDoneTracker" },
        [100377] = { time = 90, id = "ClearPickupZone", icons = { "faster" }, class = TT.Achievement }, -- Not really an achievement, but I want to use "SetCompleted" function :p
        [101550] = { id = "ClearPickupZone", special_function = SF.SetAchievementComplete },

        [101521] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { "heli", "pd2_escape" }, special_function = SF.RemoveTriggerWhenExecuted },

        [100144] = { special_function = SF.Trigger, data = { 1001441, 1001442, 1001443 } },
        [1001441] = { id = "run_9", special_function = SF.SetAchievementFailed },
        [1001442] = { id = "GasAmount", class = "EHIGasTracker" },
        [1001443] = { special_function = SF.RemoveTriggers, data = { 100144 } },
        [102426] = { max = 8, id = "run_8", icons = { "C_Classics_H_HeatStreet_Zookeeper" }, class = TT.AchievementProgress },
        [100658] = { id = "run_8", special_function = SF.IncreaseProgress },

        [1] = { id = "GasAmount", special_function = SF.IncreaseProgress },
        [2] = { special_function = SF.RemoveTriggers, data = { 102775, 102776, 102868 } }, -- Don't blink twice, just set the max once and remove the triggers

        [102876] = { special_function = SF.Trigger, data = { 1028761, 1 } },
        [1028761] = { time = 60, id = "Gas1", icons = { Icon.Fire } },
        [102875] = { special_function = SF.Trigger, data = { 1028751, 1 } },
        [1028751] = { time = 60, id = "Gas2", icons = { Icon.Fire } },
        [102874] = { special_function = SF.Trigger, data = { 1028741, 1 } },
        [1028741] = { time = 60, id = "Gas3", icons = { Icon.Fire } },
        [102873] = { special_function = SF.Trigger, data = { 1028731, 1 } },
        [1028731] = { time = 80, id = "Gas4", icons = { Icon.Fire, Icon.Escape } },

        [102775] = { special_function = SF.Trigger, data = { 1027751, 2 } },
        [1027751] = { max = 4, id = "GasAmount", special_function = SF.SetProgressMax },
        [102776] = { special_function = SF.Trigger, data = { 1027761, 2 } },
        [1027761] = { max = 3, id = "GasAmount", special_function = SF.SetProgressMax },
        [102868] = { special_function = SF.Trigger, data = { 1028681, 2 } },
        [1028681] = { max = 2, id = "GasAmount", special_function = SF.SetProgressMax }
    }
elseif level_id == "tag" then -- Breakin' Feds
    local time = 10 -- Normal
    if difficulty_index == 1 or difficulty_index == 2 then
        -- Hard + Very Hard
        time = 15
    elseif difficulty_index == 3 then
        -- OVERKILL
        time = 20
    elseif difficulty_index == 4 or difficulty_index == 5 then
        -- Mayhem + Death Wish
        time = 30
    elseif difficulty_index == 6 then
        -- Death Sentence
        time = 40
    end
    triggers = {
        [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
        [1001071] = { id = "tag_9", icons = { "C_Locke_H_BreakinFeds_AMoment" }, class = TT.AchievementNotification, contidition = show_achievement and ovk_and_up },
        [1001072] = { id = "tag_10", status = "ready", icons = { "C_Locke_H_BreakinFeds_Salker" }, class = TT.AchievementNotification },
        [1001073] = { id = "tag_11", status = "no", icons = { "C_Locke_H_BreakinFeds_Staple" }, class = TT.AchievementNotification },
        [101335] = { time = 7, id = "C4BasementWall", icons = { "pd2_c4" } },
        [101968] = { time = 10, id = "LureDelay", icons = { "faster" } },

        [101282] = { time = 5 + time, id = "KeypadReset", icons = { "faster" } },

        [100609] = { id = "tag_9", special_function = SF.SetAchievementComplete },
        [100617] = { id = "tag_9", special_function = SF.SetAchievementFailed },
        [101929] = { id = "tag_11", special_function = SF.SetAchievementComplete }
    }
    for _, index in pairs({4550, 5450}) do
        triggers[EHI:GetInstanceElementID(100319, index)] = { id = "tag_10", special_function = SF.SetAchievementFailed }
        triggers[EHI:GetInstanceElementID(100321, index)] = { id = "tag_10", status = "ok", special_function = SF.SetAchievementStatus }
        triggers[EHI:GetInstanceElementID(100282, index)] = { id = "tag_10", special_function = SF.SetAchievementComplete }
    end
elseif level_id == "fish" then -- The Yacht Heist
    triggers = {
        -- 100244 is ´Players_spawned´
        [100244] = { special_function = SF.Trigger, data = { 1002441, 1002442 } },
        -- "fish_4" achievement is not in the Mission Script
        [1002441] = { time = 360, id = "fish_4", icons = { "C_Continental_H_YachtHeist_Thalasso" }, class = TT.Achievement, condition = show_achievement and ovk_and_up },
        [1002442] = { id = "fish_5", icons = { "C_Continental_H_YachtHeist_Pacifish" }, class = TT.AchievementNotification },
        [100395] = { id = "fish_5", special_function = SF.SetAchievementFailed },
        [100842] = { id = "fish_5", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "rat" then -- Cook Off
    local van_delay = 47 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0), 31s before the timer gets activated; 10s before the timer is started; total 47s; Mayhem difficulty and above
    local van_delay_ovk = 6 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0); OVERKILL difficulty and below
    local heli_delay = 19
    local van_icon = { "pd2_car", "pd2_escape", "pd2_lootdrop", "faster" }
    local anim_delay = 743/30 -- 743/30 is a animation duration; 3s is zone activation delay (never used when van is coming back)
    local heli_delay_full = 13 + 19 -- 13 = Base Delay; 19 = anim delay
    local heli_icon = { "heli", "pd2_methlab", "pd2_goto" }
    triggers = {
        [101081] = { id = "halloween_1", status = "ready", icons = { "C_Hector_H_Rats_IAmTheOne" }, class = TT.AchievementNotification },
        [101907] = { id = "halloween_1", status = "ok", special_function = SF.SetAchievementStatus },
        [101917] = { id = "halloween_1", special_function = SF.SetAchievementComplete },
        [101914] = { id = "halloween_1", special_function = SF.SetAchievementFailed },
        [101780] = { max = 25, id = "voff_5", icons = { "C_Bain_H_CookOff_KissTheChef" }, class = TT.AchievementProgress },
        [102318] = { time = 60 + 60 + 30 + 15 + anim_delay, id = "Van", icons = CarEscape },
        [102319] = { time = 60 + 60 + 60 + 30 + 15 + anim_delay, id = "Van", icons = CarEscape },
        [101001] = { special_function = SF.RemoveTrackers, data = { "CookChance", "CantTakeTheHeat", "VanStayDelay" } },

        [102383] = { time = 2 + 5, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1023831 } },
        [1023831] = { time = 2 + 20 + 4 + 3 + 3 + 3 + 5 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning },
        [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
        [1007211] = { chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [100724] = { time = 20, random_time = 5, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetTimeNoAnimOrCreateTracker },

        [102221] = { time = 40, id = "CantTakeTheHeat", icons = { Icon.Car, "faster" }, condition = ovk_and_below },

        [102167] = { time = 60 + heli_delay, id = "HeliMeth", icons = heli_icon },
        [102168] = { time = 90 + heli_delay, id = "HeliMeth", icons = heli_icon },

        [102220] = { time = 60 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102219] = { time = 45 + van_delay, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102229] = { time = 90 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102235] = { time = 100 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102236] = { time = 50 + van_delay, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102237] = { time = 80 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = TT.Warning },
        [102238] = { time = 70 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = TT.Warning },

        [102611] = { id = "voff_5", special_function = SF.IncreaseProgress },

        [1] = { special_function = SF.RemoveTriggers, data = { 101972, 101973, 101974, 101975 } },
        [101972] = { time = 240 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
        [101973] = { time = 180 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
        [101974] = { time = 120 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
        [101975] = { time = 60 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },

        [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { "heli", "heavy", "pd2_goto" }, class = TT.Warning },

        [101982] = { time = 589/30 + 3, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },

        [100723] = { amount = 15, id = "CookChance", special_function = SF.IncreaseChance }
    }
    if mayhem_and_up then
        triggers[102197] = { time = 180 + heli_delay_full, id = "HeliMeth", icons = heli_icon }
    end
    if difficulty_index == 3 then -- OVK
        triggers[102197] = { time = 120 + heli_delay_full, id = "HeliMeth", icons = heli_icon }
    end
    if difficulty_index == 2 then -- Very Hard
        triggers[102197] = { time = 120 + heli_delay_full, id = "HeliMeth", icons = heli_icon }
    end
    trigger_id_all = "Van"
    trigger_icon_all = CarEscape
elseif level_id == "alex_1" then -- Rats Day 1
    local anim_delay = 2 + 727/30 + 2 -- 2s is function delay; 727/30 is a animation duration; 2s is zone activation delay; total 28,23333
    local assault_delay_methlab = 20 + 4 + 3 + 3 + 3 + 5 + 1 + 30
    local assault_delay = 4 + 3 + 3 + 3 + 5 + 1 + 30
    triggers = {
        [101088] = { id = "halloween_1", status = "ready", icons = { "C_Hector_H_Rats_IAmTheOne" }, class = TT.AchievementNotification },
        [101907] = { id = "halloween_1", status = "ok", special_function = SF.SetAchievementStatus },
        [101917] = { id = "halloween_1", special_function = SF.SetAchievementComplete },
        [101914] = { id = "halloween_1", special_function = SF.SetAchievementFailed },
        [100378] = { time = 42 + 50 + assault_delay, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning },
        [100380] = { time = 45 + 40 + assault_delay, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning },
        [101001] = { special_function = SF.Trigger, data = { 1010011, 1010012 } },
        [1010011] = { id = "CookChance", special_function = SF.RemoveTracker },
        [1010012] = { id = "halloween_2", special_function = SF.SetAchievementFailed },
        [101970] = { time = (240 + 12) - 3, id = "Van", icons = CarEscape },
        [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
        [1007211] = { chance = 5, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [100724] = { time = 25, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop } },

        [1] = { special_function = SF.RemoveTriggers, data = { 101974, 101975 } },
        [101974] = { special_function = SF.Trigger, data = { 1019741, 1 } },
        -- There is an issue in the scripts. Even if the van driver says 2 minutes, he arrives in a minute
        [1019741] = { time = (60 + 30 + anim_delay) - 58, special_function = SF.AddTrackerIfDoesNotExist },
        [101975] = { special_function = SF.Trigger, data = { 1019751, 1 } },
        [1019751] = { time = 30 + anim_delay, special_function = SF.AddTrackerIfDoesNotExist },

        [100707] = { time = assault_delay_methlab, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.ALEX_1_SetTimeIfMoreThanOrCreateTracker },

        [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { "heli", "heavy", "pd2_goto" }, class = TT.Warning },

        [100723] = { amount = 10, id = "CookChance", special_function = SF.IncreaseChance }
    }
    trigger_id_all = "Van"
    trigger_icon_all = CarEscape
elseif level_id == "alex_2" then -- Rats Day 2
    local assault_delay = 15 + 1 + 30
    triggers = {
        [104488] = { time = assault_delay, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.SetTimeOrCreateTracker },
        [104489] = { time = assault_delay, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist }
    }
elseif level_id == "alex_3" then -- Rats Day 3
    local delay = 2
    triggers = {
        [1] = { special_function = SF.RemoveTriggers, data = { 100668, 100669, 100670 } },
        [100668] = { time = 240 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
        [100669] = { time = 180 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
        [100670] = { time = 120 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } }
    }
    trigger_id_all = "HeliLootDrop"
    trigger_icon_all = { "heli", "pd2_lootdrop" }
elseif level_id == "watchdogs_1" or level_id == "watchdogs_1_night" then -- Watchdogs Day 1
    local escape_delay = 18
    triggers = {
        [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = { Icon.Car, Icon.LootDrop } },

        [101256] = { time = 28 + 3 + 10 + 10, id = "CarEscape", icons = { "pd2_car", "pd2_escape" } },

        [101218] = { time = 180 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [101219] = { time = 120 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [101221] = { time = 60 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
    }
elseif level_id == "watchdogs_2_day" or level_id == "watchdogs_2" then -- Watchdogs Day 2
    local anim_delay = 450/30
    local boat_delay = 60 + 30 + 30 + 450/30
    local boat_icon = { Icon.Boat, Icon.LootDrop }
    triggers = {
        [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst" },
        -- 101127 tracked in 101560
        [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
        [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
        [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },

        [100323] = { time = 50 + 23, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },

        [101129] = { time = 180 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },
        [101134] = { time = 150 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },
        [101144] = { time = 130 + anim_delay, special_function = SF.WATCHDOGS_2_AddToCache },

        [101148] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },
        [101149] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },
        [101150] = { icons = boat_icon, special_function = SF.WATCHDOGS_2_GetFromCache },

        [1011480] = { time = 130 + anim_delay, random_time = 50 + anim_delay, id = "BoatLootDropReturnRandom", icons = boat_icon, class = "EHIInaccurateTracker" }
    }
    trigger_icon_all = { Icon.Boat, Icon.LootDrop }
    trigger_id_all = "BoatLootDropReturn"
    if client then
        local boat_return = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SF.WD2_SetTrackerAccurate }
        triggers[100470] = boat_return
        triggers[100472] = boat_return
        triggers[100474] = boat_return
    end
elseif level_id == "kenaz" then -- Golden Grin Casino
    local heli_delay = 22 + 1 + 1.5
    local heli_icon = { Icon.Heli, "equipment_winch_hook", "pd2_goto" }
    local refill_icon = { "pd2_water_tap", "pd2_goto" }
    local heli_60 = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
    local heli_30 = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
    triggers = {
        [100282] = { time = 840, id = "kenaz_4", icons = { "C_Dentist_H_GoldenGrinCasino_HighRoller" }, class = TT.Achievement },

        [EHI:GetInstanceElementID(100021, 29150)] = heli_60,
        [EHI:GetInstanceElementID(100042, 29150)] = heli_30,
        [EHI:GetInstanceElementID(100021, 29225)] = heli_60,
        [EHI:GetInstanceElementID(100042, 29225)] = heli_30,
        [EHI:GetInstanceElementID(100021, 15220)] = heli_60,
        [EHI:GetInstanceElementID(100042, 15220)] = heli_30,
        [EHI:GetInstanceElementID(100021, 15295)] = heli_60,
        [EHI:GetInstanceElementID(100042, 15295)] = heli_30,

        -- Toilets
        [EHI:GetInstanceElementID(100181, 13000)] = { time = 30, id = "RefillLeft01", icons = refill_icon },
        [EHI:GetInstanceElementID(100233, 13000)] = { time = 30, id = "RefillRight01", icons = refill_icon },
        [EHI:GetInstanceElementID(100299, 13000)] = { time = 30, id = "RefillLeft02", icons = refill_icon },
        [EHI:GetInstanceElementID(100300, 13000)] = { time = 30, id = "RefillRight02", icons = refill_icon },

        [100489] = { special_function = SF.RemoveTrackers, data = { "WaterTimer1", "WaterTimer2" } },

        [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

        -- Water during drilling
        [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60, cache_id = "Water1" } },
        [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60, cache_id = "Water2" } },
        [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

        -- Skylight Hack
        [EHI:GetInstanceElementID(100018, 29650)] = { time = 30, id = "SkylightHack", icons = { "wp_hack" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100037, 29650)] = { id = "SkylightHack", special_function = SF.PauseTracker },

        [100159] = { id = "BlimpWithTheDrill", icons = { "pd2_question", "pd2_drill" }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 } },
        [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { "pd2_question", "pd2_drill", "pd2_goto" } },

        [EHI:GetInstanceElementID(100173, 66365)] = { time = 30, id = "VaultKeypadReset", icons = { "restarter" } }
    }
elseif level_id == "nmh" then -- No Mercy
    triggers = {
        [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
        [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
        [103456] = { time = 5, id = "nmh_11", icons = { "C_Classics_H_NoMercy_Nyctophobia" }, class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement, condition = hard_and_above and show_achievement },
        [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
        [102619] = { id = "EscapeElevator", special_function = SF.NMH_LowerFloor },

        [103460] = { id = "nmh_11", special_function = SF.SetAchievementComplete },

        [103443] = { id = "EscapeElevator", icons = { "pd2_door" }, class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists },
        [104072] = { id = "EscapeElevator", special_function = SF.UnpauseTracker }
    }
    local outcome =
    {
        [100013] = { time = 25 + 40/30 + 15, random_time = 5, id = "VialFail", icons = { "equipment_bloodvial", "restarter" }, class = "EHIInaccurateTracker" },
        [100017] = { time = 30, id = "VialSuccess", icons = { "equipment_bloodvialok" } }
    }

    local start_index_table =
    {
        2100, 2200, 2300, 2400, 2500, 2600, 2700
    }

    for id, value in pairs(outcome) do
        for _, index in ipairs(start_index_table) do
            local element = EHI:GetInstanceElementID(id, index)
            triggers[element] = EHI:DeepClone(value)
            triggers[element].id = triggers[element].id .. tostring(element)
        end
    end
elseif level_id == "firestarter_3" or level_id == "branchbank" or level_id == "branchbank_gold" or level_id == "branchbank_cash" or level_id == "branchbank_deposit" then
    -- Firestarter Day 3, Branchbank: Random, Branchbank: Gold, Branchbank: Cash, Branchbank: Deposit
    if level_id == "firestarter_3" then
        triggers = {
            [102144] = { time = 90, id = "MoneyBurn", icons = { Icon.Fire, "money" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1021441 } },
            [1021441] = { time = 90, id = "slakt_5", icons = { "C_Hector_H_Firestarter_ItsGettingHot" }, class = "EHIAchievementDoneTracker", condition = dw_and_above and show_achievement },
            [102073] = { id = "slakt_5", special_function = SF.RemoveTracker },
            [105237] = { id = "slakt_5", special_function = SF.SetAchievementComplete },
            [105217] = { id = "slakt_5", special_function = SF.RemoveTracker }
        }
    end
    triggers[101425] = { time = 24 + 7, id = "TeargasIncoming1", icons = { "teargas", "pd2_generic_look" }, class = TT.Warning }
    triggers[105611] = { time = 24 + 7, id = "TeargasIncoming2", icons = { "teargas", "pd2_generic_look" }, class = TT.Warning }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        -- First Assault Delay
        --[[[EHI:GetInstanceElementID(100003, 7950)] = { time = 3 + 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },
        [EHI:GetInstanceElementID(100024, 7950)] = { time = 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100053, 7950)] = { time = 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100026, 7950)] = { time = 4 + 20 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100179, 7950)] = { time = 20 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100295, 7950)] = { time = 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },]]

        [101989] = { special_function = SF.Trigger, data = { 1019891, 1019892 } },
        -- It was 7 minutes before the change
        [1019891] = { time = 360, id = "spa_5", icons = { "C_Continental_H_Brooklyn_ARendezvous" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [101997] = { id = "spa_5", special_function = SF.SetAchievementComplete },
        [1019892] = { max = 8, id = "spa_6", icons = { "C_Continental_H_Brooklyn_PassTheAmmo" }, class = TT.AchievementProgress, remove_after_reaching_target = false, condition = ovk_and_up and show_achievement },
        [101999] = { id = "spa_6", special_function = SF.IncreaseProgress },
        [102002] = { id = "spa_6", special_function = SF.SetAchievementComplete },

        [103419] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

        [100681] = { time = 60, id = "CharonPickLock", icons = { "pd2_door" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },

        [102266] = { max = 6, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
        [100833] = { id = "SniperDeath", special_function = SF.RemoveTracker },

        [100549] = { time = 20, id = "ObjectiveWait", icons = { "faster" } },
        [101202] = { time = 15, id = "Escape", icons = CarEscape },
        [101313] = { time = 75, id = "Escape", icons = CarEscape }
    }
elseif level_id == "welcome_to_the_jungle_1" or level_id == "welcome_to_the_jungle_1_night" then -- Big Oil Day 1
    triggers = {
        [102064] = { time = 60 + 1 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },
        [101282] = { time = 60, id = "cac_24", icons = { "C_Elephant_H_BigOil_Junkyard" }, class = TT.Achievement }
    }
elseif level_id == "welcome_to_the_jungle_2" then -- Big Oil Day 2
    local inspect = 30
    local escape = 23 + 7
    triggers = {
        [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
        [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
        [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
        [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.AddTrackerIfDoesNotExist },
        [100265] = { time = 45 + 75 + inspect, id = "Inspect", icons = { Icon.Wait } },

        --[103132] = { time = 330 + 240, id = "Refuel", icons = { "restarter" } },

        [103132] = { time = 330 + 240, id = "HeliArrival", icons = { Icon.Heli, Icon.LootDrop } }, -- Includes heli refuel (330s)
        [100372] = { time = 150, id = "HeliArrival", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [100371] = { time = 120, id = "HeliArrival", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [100363] = { time = 90, id = "HeliArrival", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [100355] = { time = 60, id = "HeliArrival", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },

        -- Heli escape
        [100898] = { time = 15 + escape, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [100902] = { time = 30 + escape, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [100904] = { time = 45 + escape, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [100905] = { time = 60 + escape, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } }
    }
elseif level_id == "sah" then -- Shacklethorne Auction
    triggers = {
        [100107] = { time = 300, id = "sah_9", icons = { "C_Locke_H_Shacklethorne_AuctionCry" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },

        [100643] = { time = 30, id = "CrowdAlert", icons = { "enemy" }, class = TT.Warning },
        [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

        [101050] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled }, -- West
        [101039] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled } -- East
    }
elseif level_id == "jolly" then -- Aftershock
    local c4_drop = { time = 120 + 25 + 0.25 + 2, id = "C4Drop", icons = { Icon.Heli, Icon.C4, "pd2_goto" } }
    triggers = {
        [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait } },
        [EHI:GetInstanceElementID(100047, 21250)] = { time = 1 + 60 + 60 + 60 + 20 + 15, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },

        [101240] = c4_drop,
        [101241] = c4_drop,
        [101242] = c4_drop,
        [101243] = c4_drop,
        [101249] = c4_drop
    }
elseif level_id == "cage" then -- Car Shop
    triggers = {
        [100107] = { time = 240, id = "fort_4", icons = { "C_Bain_H_Car_Gone" }, class = TT.Achievement }
    }
elseif level_id == "family" then -- Diamond Store
    triggers = {
        [102611] = { time = 1, id = "VanDriveAway", icons = CarWait, class = TT.Warning },
        [102612] = { time = 3, id = "VanDriveAway", icons = CarWait, class = TT.Warning },
        [102613] = { time = 5, id = "VanDriveAway", icons = CarWait, class = TT.Warning },

        [100750] = { time = 120 + 80, id = "Van", icons = CarEscape },
        [101568] = { time = 20, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101566] = { time = 40, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101572] = { time = 60, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101573] = { time = 80, id = "Van", icons = CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    }
elseif level_id == "jewelry_store" then -- Jewelry Store
    triggers = {
        [100073] = { id = "ameno_7", status = "ready", icons = { "C_Bain_H_JewelryStore_PrivateParty" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
        [100624] = { id = "ameno_7", special_function = SF.SetAchievementFailed },
        [100634] = { id = "ameno_7", special_function = SF.SetAchievementComplete },
        [101541] = { time = 2, id = "VanDriveAway", icons = CarWait, class = TT.Warning },
        [101558] = { time = 5, id = "VanDriveAway", icons = CarWait, class = TT.Warning },
        [101601] = { time = 7, id = "VanDriveAway", icons = CarWait, class = TT.Warning },

        [103172] = { time = 45 + 830/30, id = "Van", icons = CarEscape },
        [103182] = { time = 600/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [103181] = { time = 580/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101770] = { time = 650/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "ukrainian_job" then -- Ukrainian Job
    local cac_12_disable = { id = "cac_12", special_function = SF.SetAchievementFailed }
    local zone_delay = 12
    triggers = {
        [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = CarWait, class = TT.Warning },
        [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = CarWait, class = TT.Warning },

        [103172] = { time = 2 + 830/30, id = "Van", icons = CarEscape },
        [103182] = { time = 600/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [103181] = { time = 580/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101770] = { time = 650/30, id = "Van", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },

        [100073] = { time = 36, id = "lets_do_this", icons = { "C_Vlad_H_Ukrainian_LetsDoTh" }, class = TT.Achievement },
        [100074] = { id = "cac_12", status = "ready", icons = { "C_Vlad_H_Ukrainian_ImSure" }, class = TT.AchievementNotification },
        [104406] = { id = "cac_12", status = "ok", special_function = SF.SetAchievementStatus },
        [104408] = { id = "cac_12", special_function = SF.SetAchievementComplete },
        [104409] = cac_12_disable,
        [103116] = cac_12_disable
    }
elseif level_id == "peta" then -- Goat Simulator Heist Day 1
    triggers = {
        [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = CarEscape },
        [101706] = { time = 1283/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101727] = { time = 895/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait } },
        [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait } },
        [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait } },
        [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait } },
        [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, id = "peta_2", icons = { "C_Vlad_H_GoatSim_GoatIn" }, class = TT.Achievement },
        [EHI:GetInstanceElementID(100080, 2900)] = { id = "peta_2", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "peta2" then -- Goat Simulator Heist Day 2
    local bag_drop = { Icon.Heli, Icon.Bag, "pd2_goto" }
    local goat_pick_up = { Icon.Heli, Icon.Interact }
    triggers = {
        [100109] = { time = 100 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning },

        -- Formerly 5 minutes
        [101540] = { time = 240, id = "peta_3", icons = { "C_Vlad_H_GoatSim_Hazzard" }, class = TT.Achievement },
        [101533] = { id = "peta_3", special_function = SF.SetAchievementComplete },

        [EHI:GetInstanceElementID(100022, 2850)] = { time = 180 + 6.9, id = "BagsDropin", icons = bag_drop },
        [EHI:GetInstanceElementID(100022, 3150)] = { time = 180 + 6.9, id = "BagsDropin", icons = bag_drop },
        [EHI:GetInstanceElementID(100022, 3450)] = { time = 180 + 6.9, id = "BagsDropin", icons = bag_drop },
        [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = bag_drop, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },

        [101720] = { time = 80, id = "Bridge", icons = { "faster" }, special_function = SF.UnpauseTrackerIfExists, class = "EHIPausableTracker" },
        [101718] = { id = "Bridge", special_function = SF.PauseTracker },

        [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { "PilotComingIn" } },
        [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { "PilotComingIn" } },
        [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { "heli", Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { "PilotComingIn" } }
    }
elseif level_id == "pines" then -- White Xmas
    triggers = {
        [101471] = { max = 40, id = "uno_9", icons = { "C_Vlad_H_XMas_Whats" }, class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
        [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up },
        [103367] = { chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance },
        [101001] = { time = 1200, id = "PresentDropChance50", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101002] = { time = 600, id = "PresentDropChance40", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101003] = { time = 600, id = "PresentDropChance30", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101004] = { time = 600, id = "PresentDropChance20", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101045] = { time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Wait } },
        [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry", "pd2_goto" }, special_function = SF.RemoveTriggerWhenExecuted },
        [105102] = { time = 30, id = "HeliLoot", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        -- Hooked to 105072 instead of 105076 to track the take off accurately
        [105072] = { time = 82, id = "HeliLootTakeOff", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },

        [101005] = { chance = 50, class = "EHIChanceTracker", special_function = SF.SetChanceWhenTrackerExists },
        [101006] = { chance = 40, class = "EHIChanceTracker", special_function = SF.SetChanceWhenTrackerExists },
        [101007] = { chance = 20, class = "EHIChanceTracker", special_function = SF.SetChanceWhenTrackerExists },
        [101008] = { chance = 30, class = "EHIChanceTracker", special_function = SF.SetChanceWhenTrackerExists }
    }
    if show_achievement and ovk_and_up then
        triggers[104385] = { id = "uno_9", special_function = SF.IncreaseProgress }
    end
    trigger_id_all = "PresentDrop"
    trigger_icon_all = { "C_Vlad_H_XMas_Impossible" }
elseif level_id == "friend" then -- Scarface Mansion
    local random_car = { time = 18, id = "RandomCar", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } }
    local caddilac = { time = 18, id = "Caddilac", icons = { Icon.Heli, "pd2_goto" } }
    triggers = {
        [100109] = { time = 30 + 1 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },

        [100107] = { time = 901, id = "uno_7", icons = { "C_Butcher_H_Scarface_Setting" }, class = "EHIAchievementObtainableTracker", condition = mayhem_and_up and show_achievement },
        [102291] = { max = 2, id = "friend_5", icons = { "C_Butcher_H_Scarface_LookAtThese" }, class = TT.AchievementProgress },
        [102430] = { time = 780, id = "friend_6", icons = { "C_Butcher_H_Scarface_WhatYouWant" }, class = TT.Achievement, condition = mayhem_and_up and show_achievement },

        [100103] = { time = 15 + 5, random_time = 10, id = "BileArrival", icons = { Icon.Heli } },

        [100238] = random_car,
        [100249] = random_car,
        [100310] = random_car,
        [100313] = random_car,
        [100314] = random_car,

        [102231] = { time = 20, id = "BileDropCar", icons = { Icon.Heli, Icon.Car, "pd2_goto" } },

        [100718] = caddilac,
        [100720] = caddilac,
        [100732] = caddilac,
        [100733] = caddilac,
        [100734] = caddilac,

        [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, { icon = Icon.Car, color = Color("FFFF00") }, "pd2_goto" } },

        [100213] = { time = 450/30, id = "EscapeCar1", icons = CarEscape },
        [100214] = { time = 160/30, id = "EscapeCar2", icons = CarEscape },
        [100216] = { time = 662/30, random_time = 10, id = "EscapeBoat", icons = BoatEscape },

        [102814] = { time = 180, id = "Safe", icons = { "equipment_winch_hook" }, special_function = SF.UnpauseTrackerIfExists, class = "EHIPausableTracker" },
        [102815] = { id = "Safe", special_function = SF.PauseTracker },

        [102280] = { id = "friend_5", special_function = SF.IncreaseProgress }
    }
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    local chopper_delay = 25 + 1 + 2.5
    triggers = {
        [101737] = { time = 60, id = "cow_11", icons = { "C_Butcher_H_BombDock_Done" }, class = TT.Achievement },

        [102120] = { time = 5400/30, id = "ShipMove", icons = { Icon.Boat, Icon.Wait }, special_function = SF.RemoveTriggerWhenExecuted },

        [101545] = { time = 100 + chopper_delay, id = "C4FasterPilot", icons = { Icon.Heli, Icon.C4, "pd2_goto" } },
        [101749] = { time = 160 + chopper_delay, id = "C4", icons = { Icon.Heli, Icon.C4, "pd2_goto" } },

        [106295] = { time = 705/30, id = "VanEscape", icons = CarEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [106294] = { time = 1200/30, id = "HeliEscape", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [100339] = { time = 0.2 + 450/30, id = "BoatEscape", icons = BoatEscape, special_function = SF.ExecuteIfElementIsEnabled },

        [102479] = { id = "cow_11", special_function = SF.SetAchievementComplete }
    }
    local start_index = { 1100, 1400, 1700, 2000, 2300, 2600, 2900, 3500, 3800, 4100, 4400, 4700 }
    for _, index in pairs(start_index) do
        triggers[EHI:GetInstanceElementID(100118, index)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, "faster" } }
        triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } }
    end
    if client then
        local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
        for _, index in pairs(start_index) do
            triggers[EHI:GetInstanceElementID(100149, index)] = random_time
            triggers[EHI:GetInstanceElementID(100150, index)] = random_time
            triggers[EHI:GetInstanceElementID(100184, index)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
        end
    end
elseif level_id == "crojob3" or level_id == "crojob3_night" then -- The Bomb: Forest
    local heli_anim = 35
    local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
    local thermite_right = { time = 86, id = "Thermite", icons = { "pd2_fire" } }
    local thermite_left_top = { time = 90, id = "Thermite", icons = { "pd2_fire" } }
    local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled }
    local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled }
    triggers = {
        [101499] = { time = 155 + 25, id = "EscapeHeli", icons = HeliEscape },
        [101253] = heli_65,
        [101254] = heli_20,
        [101255] = heli_65,
        [101256] = heli_20,
        [101259] = heli_65,
        [101278] = heli_20,
        [101279] = heli_65,
        [101280] = heli_20,

        [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = HeliEscape },

        [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

        [102825] = { id = "WaterFill", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
        [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
        [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

        [1] = { id = "HeliWaterReset", icons = { "heli", "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

        [103461] = { time = 5, id = "cow_3", icons = { "C_Butcher_H_BombForest_Beaver" }, class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement },
        [103458] = { id = "cow_3", special_function = SF.SetAchievementComplete },

        -- Right
        [100283] = thermite_right,
        [100284] = thermite_right,
        [100288] = thermite_right,

        -- Left
        [100285] = thermite_left_top,
        [100286] = thermite_left_top,
        [100560] = thermite_left_top,

        -- Top
        [100282] = thermite_left_top,
        [100287] = thermite_left_top,
        [100558] = thermite_left_top,
        [100559] = thermite_left_top
    }
    local indexes = { 100, 150, 250, 300 }
    for _, index in pairs(indexes) do
        triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = { "heli", "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists }
        triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
        triggers[EHI:GetInstanceElementID(100037, index)] = { id = "HeliWaterFill", special_function = SF.CROJOB3_PauseTrackerAndAddNewTracker, data = { fake_id = 1 } }
    end
elseif level_id == "shoutout_raid" then -- Meltdown
    triggers = {
        [102314] = { id = "Vault", class = "EHIVaultTemperatureTracker", special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100032, 2850)] = { id = "Vault", special_function = SF.RemoveTracker },
        [100107] = { time = 420, id = "trophy_longfellow", icons = { "trophy" }, class = TT.Warning, condition = ovk_and_up },

        [107062] = { id = "Vault", special_function = SF.MeltdownAddCrowbar }
    }
elseif level_id == "roberts" then -- GO Bank
    local start_delay = 1
    local delay = 20 + (math.random() * (7.5 - 6.2) + 6.2)
    triggers = {
        [101929] = { time = 30, id = "PlaneWait", icons = { Icon.Heli, Icon.Wait } },
        [101931] = { time = 90 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } },
        [101932] = { time = 120 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } },
        [101933] = { time = 150 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } },

        [101959] = { time = 90 + start_delay, id = "Plane", icons = { "heli", "faster" } },
        [101960] = { time = 120 + start_delay, id = "Plane", icons = { "heli", "faster" } },
        [101961] = { time = 150 + start_delay, id = "Plane", icons = { "heli", "faster" } }
    }
elseif level_id == "rvd1" then -- Reservoir Dogs Heist Day 2
    local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, "pd2_goto" }
    triggers = {
        [100107] = { id = "rvd_9", icons = { "C_Bain_H_ReservoirDogs_GetOffMy" }, class = TT.AchievementNotification },
        [100839] = { id = "rvd_9", special_function = SF.SetAchievementFailed },
        [100869] = { id = "rvd_9", special_function = SF.SetAchievementComplete },

        [100179] = { time = 1 + 9.5 + 11 + 1 + 30, id = "FirstAssaultDelay", icons = { "assaultbox" }, class = TT.Warning },

        [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = CarEscape },
        [100057] = { time = 60, id = "rvd_10", icons = { "C_Bain_H_ReservoirDogs_Pinky" }, class = TT.Achievement, condition = dw_and_above and show_achievement, special_function = SF.ShowAchievementFromStart },
        [100169] = { time = 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car },
        --260/30 anim_crash_02
        --310/30 anim_crash_04
        --201/30 anim_crash_05
        --284/30 anim_crash_03

        [100247] = { id = "rvd_10", special_function = SF.SetAchievementComplete },

        [100207] = { time = 260/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [100209] = { time = 250/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },

        [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
        [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
        [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "rvd2" then -- Reservoir Dogs Heist Day 1
    triggers = {
        [100903] = { time = 120, id = "LiquidNitrogen", icons = { "equipment_liquid_nitrogen_canister" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 } },
        [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = { Icon.Heli, Icon.C4, "pd2_goto" } }
    }
    if client then
        triggers[101366] = { time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas } }
    end
elseif level_id == "des" then -- Henry's Rock
    triggers = {
        [103391] = { id = "uno_5", special_function = SF.IncreaseProgress },
        [103395] = { id = "uno_5", special_function = SF.SetAchievementFailed },

        [103025] = { time = 3, id = "des_11", icons = { "C_Locke_H_HenrysRock_BoomHead" }, class = TT.Achievement },
        [102822] = { id = "des_11", special_function = SF.SetAchievementComplete },
        [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

        [100296] = { max = 2, id = "uno_5", icons = { "C_Locke_H_HenrysRock_Hack" }, class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
        [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = HeliEscape },
        -- 60s delay after flare has been placed
        -- 25s to land
        -- 3s to open the heli doors

        [102593] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
        [101217] = { time = 30, id = "ChemSetInterrupted", icons = { "restarter" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
        [102595] = { time = 30, id = "ChemSetCooking", icons = { "pd2_defend" } },

        [102009] = { time = 60, id = "Crane", icons = { "equipment_winch_hook" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101702] = { id = "Crane", special_function = SF.PauseTracker }
    }
elseif level_id == "hvh" then -- Cursed Kill Room
    triggers = {
        [100107] = { max = 6, id = "cac_21", icons = { "C_Event_H_CursedKillRoom_FasterFaster" }, class = TT.AchievementProgress, condition = show_achievement and very_hard_and_up, special_function = SF.RemoveTriggerAndShowAchievement },
        [100224] = { id = "cac_21", special_function = SF.IncreaseProgress }
    }
elseif level_id == "arm_cro" then -- Transport: Crossroads
    local van_delay = 674/30
    triggers = {
        [101880] = { time = 120 + van_delay },
        [101881] = { time = 100 + van_delay },
        [101882] = { time = 80 + van_delay },
        [101883] = { time = 60 + van_delay }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = CarEscape
elseif level_id == "arm_fac" then -- Transport: Harbor
    local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is in CoreElementUnitSequence
    triggers = {
        [100259] = { time = 120 + delay },
        [100258] = { time = 100 + delay },
        [100257] = { time = 80 + delay },
        [100209] = { time = 60 + delay },

        [100215] = { time = 674/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [100216] = { time = 543/30, id = "Escape", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "arm_hcm" then -- Transport: Downtown
    local van_delay = 363/30
    triggers = {
        [100215] = { time = 120 + van_delay },
        [100216] = { time = 100 + van_delay },
        [100218] = { time = 80 + van_delay },
        [100219] = { time = 60 + van_delay },

        -- Heli
        [102200] = { time = 23, special_function = SF.SetTimeOrCreateTracker }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "arm_par" then -- Transport: Park
    local van_delay = 543/30
    triggers = {
        [100258] = { time = 120 + van_delay },
        [100257] = { time = 100 + van_delay },
        [100209] = { time = 80 + van_delay },
        [100208] = { time = 60 + van_delay },

        -- Heli
        [102200] = { time = 23, special_function = SF.SetTimeOrCreateTracker }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "arm_und" then -- Transport: Underpass
    local van_delay = 674/30
    triggers = {
        [101235] = { time = 120 + van_delay },
        [100257] = { time = 100 + van_delay },
        [100209] = { time = 80 + van_delay },
        [100208] = { time = 60 + van_delay }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = CarEscape
elseif level_id == "arm_for" then -- Transport: Train Heist
    local truck_delay = 524/30
    local boat_delay = 450/30
    triggers = {
        [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = HeliDropDrill },

        -- Boat
        [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = { Icon.Boat, Icon.LootDrop } },
        [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = { Icon.Boat, Icon.LootDrop } },

        -- Truck
        [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = { Icon.Car, Icon.LootDrop } },
        [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = { Icon.Car, Icon.LootDrop } }
    }
elseif level_id == "kosugi" then -- Shadow Raid
    local trigger = { special_function = SF.Trigger, data = { 1, 2 } }
    triggers = {
        [1] = { time = 300, id = "Blackhawk", icons = { "heli", "pd2_goto" } },
        [2] = { special_function = SF.RemoveTriggers, data = { 101131, 100900 } },
        [101131] = trigger,
        [100900] = trigger,

        [100955] = { time = 10, id = "KeycardLeft", icons = { "equipment_bank_manager_key" }, class = TT.Warning, special_function = SF.KOSUGI_DisableTriggerAndExecute, data = { id = 100957 } },
        [100957] = { time = 10, id = "KeycardRight", icons = { "equipment_bank_manager_key" }, class = TT.Warning, special_function = SF.KOSUGI_DisableTriggerAndExecute, data = { id = 100955 } },
        [100967] = { special_function = SF.RemoveTrackers, data = { "KeycardLeft", "KeycardRight" } }
    }
elseif level_id == "man" then -- Undercover
    local deal = { "pd2_car", "pd2_goto" }
    local delay = 4 + 356/30
    local start_chance = 15 -- Normal
    if difficulty_index == 1 or difficulty_index == 2 then
        -- Hard + Very Hard
        start_chance = 10
    elseif ovk_and_up then
        -- OVERKILL+
        start_chance = 5
    end
    local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, "wp_hack" }, flash_times = 1, class = "EHIChanceTracker" }
    triggers = {
        [101587] = { time = 30 + delay, id = "DealGoingDown", icons = deal },
        [101588] = { time = 40 + delay, id = "DealGoingDown", icons = deal },
        [101589] = { time = 50 + delay, id = "DealGoingDown", icons = deal },
        [101590] = { time = 60 + delay, id = "DealGoingDown", icons = deal },
        [101591] = { time = 70 + delay, id = "DealGoingDown", icons = deal },

        [102891] = { id = "CodeChance", special_function = SF.RemoveTracker },

        [101825] = CodeChance, -- First hack
        [102016] = CodeChance, -- Second and Third Hack
        [102121] = { time = 10, id = "Escape", icons = { Icon.Escape } },

        [103163] = { time = 1.5 + 25, random_time = 10, id = "Faint", icons = { "hostage", "faster" }, class = "EHIInaccurateTracker" },

        [102866] = { time = 5, id = "GotCode", icons = { "faster" } },

        [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance }
    }
elseif level_id == "pal" then -- Counterfeit
    triggers = {
        [101566] = { id = "Trap", special_function = SF.RemoveTracker },
        --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
        [102502] = { time = 60, id = "PAL", icons = { "money" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [102505] = { id = "PAL", special_function = SF.RemoveTracker },

        [102301] = { time = 15, id = "Trap", icons = { "pd2_c4" }, class = TT.Warning },

        [101230] = { time = 120, id = "Water", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101231] = { id = "Water", special_function = SF.PauseTracker },

        [102749] = { id = "PAL", special_function = SF.PauseTracker },

        [102738] = { id = "PAL", special_function = SF.PauseTracker },
        [102744] = { id = "PAL", special_function = SF.UnpauseTracker },

        [102826] = { id = "PAL", special_function = SF.RemoveTracker }
    }
    local heli = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
    local sync_triggers = {
        [EHI:GetInstanceElementID(100013, 4700)] = heli,
        [EHI:GetInstanceElementID(100013, 4750)] = heli,
        [EHI:GetInstanceElementID(100013, 4800)] = heli,
        [EHI:GetInstanceElementID(100013, 4850)] = heli
    }
    if client then
        triggers[102892] = { time = 1800/30 + 120, random_time = 60, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
        triggers[EHI:GetInstanceElementID(100013, 4700)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100013, 4750)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100013, 4800)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100013, 4850)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
        EHI:SetSyncTriggers(sync_triggers)
    else
        EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
    end
elseif level_id == "nail" then -- Lab Rats
    triggers = {
        [101505] = { time = 10, id = "TruckDoorOpens", icons = { "pd2_door" } },
        -- There are a lot of delays in the ID. Using average instead (5.2)
        [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, "pd2_methlab", "pd2_goto" } },

        [101936] = { time = 30 + 12, id = "Escape", icons = { "heli", "pd2_escape" } }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [101136] = { max = 12, id = "brb_8", icons = { "C_Locke_H_BrooklynBank_AlltheGold" }, remove_after_reaching_target = false, class = "EHIAchievementProgressTracker", condition = show_achievement and very_hard_and_up },
        [100128] = { time = 38, id = "WinchDropTrainA", icons = { "equipment_winch_hook", "pd2_goto" } },
        [100164] = { time = 38, id = "WinchDropTrainB", icons = { "equipment_winch_hook", "pd2_goto" } },

        [100654] = { time = 120, id = "Winch", icons = { "equipment_winch_hook" }, class = "EHIPausableTracker" },
        [100655] = { id = "Winch", special_function = SF.PauseTracker },
        [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
        [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { "equipment_glasscutter" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker },

        [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } },

        [100275] = { time = 20, id = "Van", icons = CarEscape }

        --[100837] = { time = 50, delay = 10, id = "VaultThermite", icons = { "pd2_fire" }, class = "EHIInaccurateTracker", trigger_at = 4, trigger_count = 0 }
    }
elseif level_id == "bph" then -- Hell's Island
    triggers = {
        [100109] = { max = (very_hard_and_below and 30 or 40), id = "EnemyDeathShowers", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
        [101433] = { id = "EnemyDeathShowers", special_function = SF.RemoveTracker },

        [101742] = { max = 3, id = "bph_10", icons = { "C_Locke_H_HellsIsland_Another" }, class = TT.AchievementProgress, special_function = SF.RemoveTriggerAndShowAchievement, condition = ovk_and_up and show_achievement },
        [101885] = { id = "bph_10", special_function = SF.SetAchievementFailed },

        [101815] = { time = 10, id = "MoveWalkway", icons = { Icon.Wait } },

        [101221] = { time = 11, id = "Thermite1", icons = { "pd2_fire" } },
        [101714] = { time = 11, id = "Thermite2", icons = { "pd2_fire" } },
        [101715] = { time = 11, id = "Thermite3", icons = { "pd2_fire" } },
        [101716] = { time = 11, id = "Thermite4", icons = { "pd2_fire" } },

        [101137] = { max = 10, id = "EnemyDeathOutside", icons = { "pd2_kill" }, flash_times = 1, class = "EHIProgressTracker" },
        [101405] = { id = "EnemyDeathOutside", special_function = SF.RemoveTracker },

        [101339] = { id = "EnemyDeathShowers", special_function = SF.IncreaseProgress },
        [101412] = { id = "EnemyDeathOutside", special_function = SF.IncreaseProgress },
        [102171] = { id = "bph_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "hox_1" then -- Hoxton Breakout Day 1
    triggers = {
        [101595] = { time = 6, id = "Wait", icons = { Icon.Wait } }
    }
elseif level_id == "hox_2" then -- Hoxton Breakout Day 2
    local request = { "wp_hack", Icon.Wait }
    triggers = {
        [100107] = { id = "cac_26", icons = { "C_Dentist_H_HoxtonBreakout_WatchThePower" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
        [100320] = { id = "cac_26", special_function = SF.SetAchievementComplete },
        [100322] = { id = "cac_26", special_function = SF.SetAchievementFailed },

        [104579] = { time = 15, id = "Request", icons = request },
        [104580] = { time = 25, id = "Request", icons = request },
        [104581] = { time = 20, id = "Request", icons = request },
        [104582] = { time = 30, id = "Request", icons = request }, -- Disabled in the mission script

        [104509] = { time = 30, id = "HackRestartWait", icons = { "wp_hack", "restarter" } },

        [104314] = { max = 4, id = "RequestCounter", icons = { "wp_hack" }, class = TT.Progress, special_function = SF.AddTrackerIfDoesNotExist },

        [104599] = { id = "RequestCounter", special_function = SF.RemoveTracker },

        [104591] = { id = "RequestCounter", special_function = SF.IncreaseProgress }
    }
    if client then
        triggers[EHI:GetInstanceElementID(100055, 6690)] = { id = "SecurityOfficeTeargas", icons = { "teargas" }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 45, 55, 65 } }
    end
elseif level_id == "hox_3" then -- Hoxton Revenge
    local drill_delay = 30 + 2 + 1.5
    local escape_delay = 3 + 27 + 1
    triggers = {
        [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
        [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
        [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
        [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
        [101844] = { time = drill_delay, id = "LanceDrop", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },

        [102223] = { time = 90 + escape_delay, id = "Escape", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
        [102188] = { time = 60 + escape_delay, id = "Escape", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
        [102187] = { time = 45 + escape_delay, id = "Escape", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
        [102186] = { time = 30 + escape_delay, id = "Escape", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
        [102190] = { time = escape_delay, id = "Escape", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    }
elseif level_id == "chill_combat" then -- Safehouse Raid
    triggers = {
        [100979] = { id = "cac_30", icons = { "C_Hoxton_H_SafeHouse_TheRaid" }, class = TT.AchievementNotification, condition = show_achievement and dw_and_above },
        [102831] = { id = "cac_30", special_function = SF.SetAchievementComplete },
        [102829] = { id = "cac_30", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, id = "orange_4", icons = { "C_Event_H_PrisonNightmare_SalemAsylum" }, class = TT.Achievement, condition = mayhem_and_up and show_achievement },
        [EHI:GetInstanceElementID(100461, 21700)] = { id = "orange_4", special_function = SF.SetAchievementComplete },
        [100279] = { max = 15, id = "orange_5", icons = { "C_Event_H_PrisonNightmare_ALongNight" }, class = TT.AchievementProgress, status_is_overridable = true, remove_after_reaching_target = false, condition = mayhem_and_up and show_achievement },
        [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = { Icon.Heli, "pd2_c4", "pd2_goto" } },
        [EHI:GetInstanceElementID(100471, 21700)] = { id = "orange_5", special_function = SF.SetAchievementFailed },
        [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
        [EHI:GetInstanceElementID(100474, 21700)] = { id = "orange_5", special_function = SF.IncreaseProgress }
    }
elseif level_id == "mex" then -- Border Crossing
    local mex_9 = { id = "mex_9", special_function = SF.IncreaseProgress }
    triggers = {
        [100107] = { max = 4, id = "mex_9", icons = { "C_Locke_H_BorderCrossing_Identity" }, class = TT.AchievementProgress },
        [101983] = { time = 15, id = "C4Trap", icons = { "pd2_c4" }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
        [101722] = { id = "C4Trap", special_function = SF.RemoveTracker },

        [102685] = { id = "Refueling", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.MEX_CheckIfLoud, data = { yes = 121, no = 91 } },
        [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
        [102684] = { id = "Refueling", special_function = SF.PauseTracker },

        [101502] = mex_9,
        [101506] = mex_9,
        [101503] = mex_9,
        [101504] = mex_9,
        [101509] = mex_9,
        [101505] = mex_9,
        [101507] = mex_9,
        [101508] = mex_9
    }
elseif level_id == "mex_cooking" then -- Border Crystals
    if client then
        triggers = {
            -- Also handles next ingredient when meth is picked up
            [EHI:GetInstanceElementID(100056, 55850)] = { time = 15, id = "NextIngredient", icons = { Icon.Methlab, "restarter" }, special_function = SF.AddTrackerIfDoesNotExist },
            [EHI:GetInstanceElementID(100056, 56850)] = { time = 15, id = "NextIngredient", icons = { Icon.Methlab, "restarter" }, special_function = SF.AddTrackerIfDoesNotExist },

            [103573] = { time = 30, delay = 10, id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
            [103574] = { time = 30, delay = 10, id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },

            [EHI:GetInstanceElementID(100173, 55850)] = { time = 40, delay = 5, id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
            [EHI:GetInstanceElementID(100173, 56850)] = { time = 40, delay = 5, id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
            [EHI:GetInstanceElementID(100174, 55850)] = { time = 10, delay = 5, id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist },
            [EHI:GetInstanceElementID(100174, 56850)] = { time = 10, delay = 5, id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
        }
    end
elseif level_id == "bex" then -- San Martín Bank
    local hack_start = EHI:GetInstanceElementID(100015, 20450)
    triggers = {
        [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },
        [103919] = { time = 25 + 1 + 13, random_time = 5, id = "Van", icons = CarEscape },
        [100840] = { time = 1 + 13, id = "Van", icons = CarEscape, special_function = SF.SetTrackerAccurate },

        [101818] = { time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = HeliDropDrill, class = "EHIInaccurateTracker" },
        [hack_start] = { id = "ServerHack", icons = { "wp_hack" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExistsAccurate, element = EHI:GetInstanceElementID(100014, 20450) },
        [EHI:GetInstanceElementID(100016, 20450)] = { id = "ServerHack", special_function = SF.PauseTracker },

        [102302] = { time = 28.05 + 418/30, id = "Suprise", icons = { "pd2_question" } },

        [101820] = { time = 9.3, id = "HeliDropLance", icons = HeliDropDrill, special_function = SF.SetTrackerAccurate }
    }
    if client then
        triggers[hack_start].time = 90
        triggers[hack_start].random_time = 10
        triggers[hack_start].special_function = SF.UnpauseTrackerIfExists
        triggers[hack_start].delay_only = true
        triggers[hack_start].class = "EHIInaccuratePausableTracker"
        triggers[hack_start].synced = { class = "EHIPausableTracker" }
        EHI:AddSyncTrigger(hack_start, triggers[hack_start])
        triggers[EHI:GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
        triggers[102157] = { time = 60, random_time = 15, id = "VaultGas", icons = { "teargas" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
    end
elseif level_id == "pex" then -- Breakfast in Tijuana
    local armory_hack_start = { time = 120, id = "ArmoryHack", icons = { "wp_hack" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists }
    local armory_hack_pause = { id = "ArmoryHack", special_function = SF.PauseTracker }
    local start_index = { 5300, 6300, 7300 }
    triggers = {
        --[102355] = { max = 7, id = "pex_11", icons = { "C_Locke_H_BreakfastInTijuana_StolenValor" }, class = TT.AchievementProgress },
        [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" } },

        [101392] = { time = 120, id = "FireEvidence", icons = { "pd2_fire" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },

        [103735] = { id = "pex_11", special_function = SF.IncreaseProgress },

        [101460] = { time = 18, id = "DoorBreach", icons = { "pd2_door" } }
    }
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100025, index)] = armory_hack_start
        triggers[EHI:GetInstanceElementID(100026, index)] = armory_hack_pause
    end
elseif level_id == "fex" then -- Buluc's Mansion
    local start = { time = 60, id = "ExplosivesTimer", icons = { "equipment_timer" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists }
    local pause = { id = "ExplosivesTimer", special_function = SF.PauseTracker }
    triggers = {
        -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in CoreElementUnitSequence
        [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = CarEscape },
        [EHI:GetInstanceElementID(100358, 10130)] = { time = 1 + 210/30, id = "MayanDoorOpen", icons = { "pd2_door" } },

        [EHI:GetInstanceElementID(100008, 8130)] = start,
        [EHI:GetInstanceElementID(100007, 8130)] = pause,
        [EHI:GetInstanceElementID(100008, 8630)] = start,
        [EHI:GetInstanceElementID(100007, 8630)] = pause,

        [102943] = { time = 180 + 2, id = "HeliEscape", icons = HeliEscape },

        [EHI:GetInstanceElementID(100007, 25580)] = { time = 6, id = "ThermiteWineCellarDoor1", icons = { Icon.Fire } },
        [EHI:GetInstanceElementID(100007, 25780)] = { time = 6, id = "ThermiteWineCellarDoor2", icons = { Icon.Fire } },

        -- Wanker car
        [EHI:GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },

        [EHI:GetInstanceElementID(100026, 24580)] = { time = 26.5 + 5, id = "CarBurn", icons = { "pd2_car", "pd2_fire" } },

        [EHI:GetInstanceElementID(100049, 5200)] = { time = 6, id = "FrontGateThermite", icons = { "pd2_fire" } }
    }
elseif level_id == "chas" then -- Dragon Heist
    triggers = {
        [100107] = { time = 360, id = "chas_11", icons = { "C_JiuFeng_H_DragonHeist_Speed" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [EHI:GetInstanceElementID(100017, 11325)] = { id = "Gas", special_function = SF.RemoveTracker },

        [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { "pd2_question", "pd2_drill", "pd2_goto" } },
        [101660] = { time = 120, id = "Gas", icons = { "teargas" } }
    }
    if client then
        triggers[100602] = { time = 90 + 5, random_time = 20, id = "LoudEscape", icons = CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
        triggers[102453] = { time = 60 + 12.5, random_time = 20, id = "HeliArrivesWithDrill", icons = HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist }
    end
elseif level_id == "sand" then -- The Ukrainian Prisoner Heist
    local boat_anim = 614/30
    local skid = { { icon = Icon.Car, color = Color("1E90FF") } }
    local sand_9_buttons = { id = "sand_9_buttons", special_function = SF.IncreaseProgress }
    triggers = {
        -- Players spawned
        [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
        [1001071] = { max = 10, id = "sand_9", icons = { "C_JiuFeng_H_UkrainianPrisoner_Thinking" }, remove_after_reaching_target = false, class = TT.AchievementProgress },
        [1001072] = { max = 3, id = "sand_9_buttons", icons = { "pd2_generic_interact" }, class = TT.Progress, special_function = SF.ShowAchievementCustom, data = "sand_9" },
        [1001073] = { max = 8, id = "sand_10", icons = { "C_JiuFeng_H_UkrainianPrisoner_JustToCheese" }, class = TT.AchievementProgress },
        [103161] = sand_9_buttons,
        [101369] = { special_function = SF.SAND_ExecuteIfProgressMatch, data = 0 },
        [103167] = sand_9_buttons,
        [103175] = sand_9_buttons,
        [103208] = { id = "sand_9", special_function = SF.FinalizeAchievement },

        [EHI:GetInstanceElementID(100045, 7100)] = { time = 5, id = "RoomHack", icons = { "wp_hack" } },

        [EHI:GetInstanceElementID(100043, 4800)] = { special_function = SF.Trigger, data = { 1000431, 1000432 } },
        [1000431] = { time = 15, id = "DoorOpenGas", icons = { "pd2_door" } },
        [1000432] = { time = 20, random_time = 5, id = "RoomGas", icons = { Icon.Teargas } },

        --[103157] = { time = 710/30, id = "SkidDriving1", icons = skid },
        [103333] = { time = 613/30, id = "SkidDriving2", icons = skid },
        [103178] = { time = 386/30, id = "SkidDriving3", icons = skid },
        [104043] = { time = 28, id = "SkidDriving4", icons = skid }, -- More accurate
        [104101] = { time = 597/30, id = "SkidDriving5", icons = skid },
        [104102] = { time = 477/30, id = "SkidDriving6", icons = skid },
        [104233] = { time = 30, id = "SkidDriving7", icons = skid }, -- More accurate
        [104262] = { time = 549/30, id = "SkidDriving8", icons = skid },
        [104304] = { time = 40, id = "SkidDriving9", icons = skid }, -- More accurate
        [103667] = { time = 1399/30, id = "SkidDriving10", icons = skid },
        [100782] = { time = 18, id = "SkidDriving11", icons = skid }, -- More accurate
        [104227] = { time = 37, id = "SkidDriving12", icons = skid }, -- More accurate
        [104305] = { time = 25, id = "SkidDriving13", icons = skid }, -- More accurate
        [101009] = { time = 210/30, id = "RampRaise", icons = { "faster" } },
        [101799] = { time = 181/30, id = "RampLower", icons = { "faster" } },

        [104528] = { time = 22, id = "Crane", icons = { "equipment_winch_hook" } }, -- 104528 -> 100703

        [103870] = { chance = 34, id = "ReviveVlad", icons = { "equipment_defibrillator" }, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist },
        [103871] = { id = "ReviveVlad", special_function = SF.RemoveTracker },

        [103925] = { id = "BoatEscape", icons = BoatEscape, special_function = SF.MEX_CheckIfLoud, data = { yes = 30 + boat_anim, no = 19 + boat_anim } }
    }
    local time = 5 -- Normal
    if difficulty_index == 1 or difficulty_index == 2 then
        -- Hard + Very Hard
        time = 15
    elseif difficulty_index == 3 then
        -- OVERKILL
        time = 20
    elseif difficulty_index == 4 or difficulty_index == 5 then
        -- Mayhem + Death Wish
        time = 30
    elseif difficulty_index == 6 then
        -- Death Sentence
        time = 40
    end
    for _, index in pairs({8530, 9180, 9680}) do
        triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadReboot", icons = { "restarter" } } -- ECM Jammer
        triggers[EHI:GetInstanceElementID(100210, index)] = { time = 3 + time, id = "KeypadReboot", icons = { "restarter" } }
    end
    for i = 105290, 105329, 1 do
        triggers[i] = { id = "sand_10", special_function = SF.IncreaseProgress }
    end
    for i = 16580, 16780, 100 do
        triggers[EHI:GetInstanceElementID(100057, i)] = { amount = 33, id = "ReviveVlad", special_function = SF.IncreaseChance }
    end
elseif Holdout[level_id] then
    local level_index =
    {
        skm_run = 1650,
        skm_red2 = 7950,
        skm_mus = 7400,
        skm_arena = 10600,
        skm_bex = 4100,
        skm_cas = 37550
    }
    local start_index = level_index[level_id] or 0
    triggers = {
        [EHI:GetInstanceElementID(100032, start_index)] = { time = 7, id = "HostageRescue", icons = { "pd2_kill" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100036, start_index)] = { id = "HostageRescue", special_function = SF.RemoveTracker }
    }
elseif level_id == "Triad Takedown Yacht Heist" then -- Custom Heist
    local bag_delay = 24.700000762939 -- I'm not even kidding
    triggers = {
        [100285] = { time = 125 + bag_delay, id = "HeliDrillDrop", icons = HeliDropDrill },
        [100286] = { time = 130 + bag_delay, id = "HeliDrillDrop", icons = HeliDropDrill },
        [100297] = { time = 65 + 23, id = "HeliEscape", icons = HeliEscape }
    }
elseif level_id == "ruswl" then -- Scorched Earth Custom Heist
    local obj_delay = { time = 30, id = "ObjectiveDelay", icons = { "faster" } }
    triggers = {
        [100404] = obj_delay,
        [100405] = obj_delay,
        [101181] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
        [101182] = { time = 30, id = "ChemSetCooking", icons = { "pd2_methlab" } },
        [101088] = { time = 84, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } }
    }
elseif level_id == "rusdl" then -- Cold Stones Custom Heist
    triggers = {
        [100114] = { time = 17 * 18, id = "Thermite", icons = { "pd2_fire" } },
        [100138] = { time = 20, id = "ObjectiveWait", icons = { "faster" } }
    }
end

-- Mark every tracker, that has random time, as inaccurate
for id, data in pairs(triggers) do
    if data.random_time then
        if not data.class then
            triggers[id].class = TT.Inaccurate
        elseif data.class ~= "EHIInaccuratePausableTracker" and data.class == TT.Warning then
            triggers[id].class = TT.InaccurateWarning
        end
    end
    if data.class and AchievementTT[data.class] then
        if not data.special_function then
            triggers[id].special_function = SF.ShowAchievement
        end
        if data.condition == nil then
            triggers[id].condition = show_achievement
        end
    end
end

EHI:AddTriggers(triggers, trigger_id_all, trigger_icon_all)