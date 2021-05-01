if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = difficulty_index >= 5
local ovk_and_below = difficulty_index <= 3
local ovk_and_up = difficulty_index >= 3
local mayhem_and_up = difficulty_index >= 4
local death_wish_and_up = difficulty_index >= 5
local very_hard_and_up = difficulty_index >= 2
local very_hard_and_below = difficulty_index <= 2
local hard_and_above = difficulty_index >= 1
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = {}
local SF = EHI:GetSpecialFunctions()
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
    Inaccurate = "EHIInaccurateTracker",
    InaccurateWarning = "EHIInaccurateWarningTracker"
}
SF.ExecuteIfIDDoesNotExists = 95
SF.AddToGlobalAndExecute = 96
SF.DecreaseChance = 97
SF.UnpauseAndSetTime = 98
SF.SetTrackerAccurate2 = 99
local SFF =
{
    PAL_UnpauseOrCreate = 100
}
local _cache = {}
if level_id == "short2_stage2b" then -- Basic Mission: Loud - Plan B
    triggers = {
        [100806] = { time = 62 + 24, id = "Heli", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "four_stores" then -- Four Stores
    local van_anim_delay = 320 / 30
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
    trigger_icon_all = { Icon.Car, Icon.Escape, Icon.LootDrop }
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
        [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = { Icon.LootDrop } }
        -- 20: Base Delay
        -- 40/3: Animation finish delay
        -- Total 33.33 s
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = { Icon.Car, Icon.Escape, Icon.LootDrop }
elseif level_id == "escape_cafe" or level_id == "escape_cafe_day" then -- Escape: Cafe and Escape: Cafe (Day)
    triggers = {
        [100247] = { time = 180 },
        [100248] = { time = 120 },
        [100287] = { time = 30, id = "frappucino_to_go_please", icons = { "C_Escape_H_Cafe_Cappuccino" } , condition = show_achievement, class = TT.Achievement }
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "escape_overpass" or level_id == "escape_overpass_night" then -- Escape: Overpass
    triggers = {
        [101145] = { time = 180, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101158] = { time = 240, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101977] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101978] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101979] = { special_function = SF.AddToCache, data = { icon = Icon.Car } }, -- Van
    }
    trigger_id_all = "Escape"
elseif level_id == "escape_park" or level_id == "escape_park_day" then -- Escape: Park and Escape: Park (Day)
    triggers = {
        [102449] = { time = 240 },
        [102450] = { time = 180 },
        [102451] = { time = 300 }
    }
    trigger_id_all = "EscapeVan"
    trigger_icon_all = { Icon.Car, Icon.Escape, Icon.LootDrop }
elseif level_id == "escape_street" then -- Escape: Street
    triggers = {
        [101961] = { time = 120 },
        [101962] = { time = 90 }
    }
    trigger_id_all = "EscapeHeli"
    trigger_icon_all = { Icon.Heli, Icon.Escape, Icon.LootDrop }
elseif level_id == "election_day_1" then -- Election Day 1
    triggers = {
        [100003] = { time = 60, id = "slakt_1", icons = { "C_Elephant_H_ElectionDay_Speedlock" }, class = TT.Achievement }
    }
elseif level_id == "election_day_3" or level_id == "election_day_3_skip1" or level_id == "election_day_3_skip2" then -- Election Day 2 Plan C
    triggers = {
        [101284] = { chance = 50, id = "CrashChance", icons = { "wp_hack", "pd2_fix" }, class = TT.Chance },
        [103568] = { time = 60, id = "Hack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseAndSetTime },
        [103585] = { id = "Hack", special_function = SF.PauseTracker },
        [103579] = { chance = 25, id = "CrashChance", special_function = SF.DecreaseChance },
        [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
        [103572] = { time = 50, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103573] = { time = 40, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103574] = { time = 30, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103478] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } },
        [103169] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" }, class = TT.Warning },
        [103179] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" }, class = TT.Warning },
        [103190] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" }, class = TT.Warning },
        [103195] = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" }, class = TT.Warning }
    }
elseif level_id == "framing_frame_3" then -- Framing Frame Day 3
    triggers = {
        [100931] = { time = 23 },
        [104910] = { time = 24 },
        [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning }
    }
    trigger_id_all = "Escape"
    trigger_icon_all = { Icon.Heli, "pd2_goto" }
elseif level_id == "pbr" then -- Beneath the Mountain
    triggers = {
        [102290] = { id = "berry_3", special_function = SF.RemoveTracker },
        [102292] = { time = 600, id = "berry_3", icons = { "C_Locke_H_Beneath_Commando" }, class = TT.Achievement, condition = ovk_and_up and show_achievement }
    }
elseif level_id == "pbr2" then -- Birth of Sky
    triggers = {
        [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli } }, -- Time before Locke arrives with heli to pickup the money
        [102453] = { time = 83, id = "jerry_4", icons = { "C_Locke_H_BirthOfSky_OneTwoThree" }, class = TT.Achievement, condition = ovk_and_up and show_achievement }
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
    trigger_icon_all = { Icon.Heli, Icon.Escape, Icon.LootDrop }
elseif level_id == "mia_1" then -- Hotline Miami Day 1
    triggers = {
        [102177] = { time = (ovk_and_up and (3 + 60 + 23 + 5) or (30 + 23 + 5)), id = "heli", icons = { Icon.Bag } } -- Time before Bile arrives
        --,[105967] = { time = 60 + 23 + 5 }
        --,[103808] = { time = 30 + 23 + 5 }
        --[[,[106014] = { time = (very_hard_and_below and 40 or 60) + 1, id = "Truck", class = TT.Pausable, special_function = SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused, delay_time = 1, icons = { Icon.Defend } }
        ,[106020] = { id = "Truck", special_function = SF.PauseTracker }]]
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    triggers = {
        [101228] = { time = 210, id = "pig_2", icons = { "C_Dentist_H_HotlineMiami_WalkFaster" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [100788] = { id = "pig_2", special_function = SF.SetAchievementComplete },

        [100225] = { time = 5 + 5 + 22, id = "heli", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop } },
        -- 5 = Base Delay
        -- 5 = Delay when executed
        -- 22 = Heli door anim delay
        -- Total: 32 s

        -- Bomb Guy
        -- Bomb armed
        [EHI:GetInstanceElementID(100024, 3500)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 3750)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 3900)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 4450)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 4900)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 6100)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 17600)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning },
        [EHI:GetInstanceElementID(100024, 17650)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning }

        -- Bomb disarmed
        -- In ElementAwardAchievment.lua

        -- Bomb exploded
        -- In CoreElementUnitSequenceTrigger.lua
    }
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

        [100107] = { max = 2, id = "moon_4", icons = { "C_Vlad_H_StealingXmas_Imitations" }, class = TT.AchievementProgress, special_function = SF.RemoveTriggerWhenExecuted }
    }
elseif level_id == "dark" then -- Murky Station
    triggers = {
        [100296] = { time = 420, id = "dark_2", icons = { "C_Jimmy_H_MurkyStation_GhostRun" }, class = TT.Achievement, condition = show_achievement },
        [106026] = { time = 10, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "mad" then -- Boiling Point
    triggers = {
        [100891] = { time = 15.33, id = "emp_bomp_drop", icons = { "pd2_goto" } },
        [101906] = { time = 1200, id = "daily_cake", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up },
        [EHI:GetInstanceElementID(100016, 3150)] = { time = 90, id = "scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    }
elseif level_id == "born" then -- The Biker Heist Day 1
    triggers = {
        -- Mike (Truck)
        [100728] = { time = 80, random_time = { low = 0, high = 10 }, id = "mike_defend_truck", icons = { Icon.Defend }, class = "EHIInaccuratePausableTracker" },
        [100672] = { id = "mike_defend_truck", special_function = SF.PauseTracker },
        [100647] = { id = "mike_defend_truck", special_function = SF.UnpauseTracker },

        -- Mike (Garage)
        [101589] = { time = 90, random_time = { low = 0, high = 30 }, id = "mike_defend_garage", icons = { Icon.Defend }, class = "EHIInaccuratePausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101461] = { id = "mike_defend_garage", special_function = SF.PauseTracker }--,
        --[101462] = { id = "mike_defend_garage", special_function = SF.UnpauseTracker }
    }
elseif level_id == "chew" then -- The Biker Heist Day 2
    triggers = {
        [100595] = { time = 120, id = "born_5", icons = { "C_Elephant_H_Biker_FullThrottle" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [100558] = { random_time = { low = 5, high = 10 }, id = "BileReturn", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "vit" then -- The White House
    triggers = {
        [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance", trigger = 100808 } },
        [100808] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = very_hard_and_up, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [101378] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
        [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire } }
    }
elseif level_id == "des" then -- Henry's Rock
    triggers = {
        [103110] = { id = "Crane", special_function = SF.PauseTracker }
    }
elseif level_id == "wwh" then -- Alaskan Deal
    if show_achievement then -- Optimization
        triggers = {
            [100944] = { max = 4, id = "wwh_10", icons = { "C_Locke_H_AlsDeal_HeadlessSnow" }, class = TT.AchievementProgress }
        }
    else
        return
    end
elseif level_id == "big" then -- The Big Bank
    triggers = {
        [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },
        [104217] = { time = 2.5, id = "PigDrop", icons = { "piggy", "pd2_goto" } }
    }
elseif level_id == "cane" then -- Santa's Workshop
    triggers = {
        [100647] = { time = 240 + 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop } },
        [EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
        [EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } }
    }
elseif level_id == "red2" then -- First World Bank
    triggers = {
        [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
        [1012991] = { time = 90, id = "ThermiteShortTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
        [101325] = { time = 180, id = "Thermite", special_function = SF.ExecuteIfTrackerExists, data = { id = "ThermiteShortTime" } },
        [103373] = { time = 817, id = "green_3", icons = { "C_Classics_H_FirstWorldBank_LEET" }, class = TT.Achievement, condition = show_achievement }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    if show_achievement then -- Optimization
        triggers = {
            [100484] = { time = 300, id = "farm_2", icons = { "C_Classics_H_Slaughterhouse_ButHow" }, class = TT.Achievement },
            [100485] = { time = 30, id = "farm_4", icons = { "C_Classics_H_Slaughterhouse_Pyromaniacs" }, class = TT.Achievement }
        }
    else
        return
    end
elseif level_id == "flat" then -- Panic Room
    triggers = {
        [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli } },
        [100182] = { id = "SniperDeath", special_function = SF.RemoveTracker },
        [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },
        [100147] = { time = 18.2, id = "HeliWinchLoop", icons = { Icon.Heli, "equipment_winch_hook", Icon.Loop }, special_function = SF.ExecuteIfElementIsEnabled },
        [102181] = { id = "HeliWinchLoop", special_function = SF.RemoveTracker }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = {
        [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, "pd2_goto" } },
        --[103969] = { max = 12, id = "dah_8", icons = { "C_Classics_H_DiamondHesit_TheHuntfor" }, class = TT.AchievementProgress, condition = ovk_and_up and show_achievement }
    }
elseif level_id == "arena" then -- The Alesso Heist
    triggers = {
        [100241] = { time = 19, id = "HeliEscape", icons = { Icon.Escape, Icon.LootDrop } },
        [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
        [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker }
    }
elseif level_id == "run" then -- Heat Street
    triggers = {
        [100120] = { time = 1800, id = "run_9", icons = { "C_Classics_H_HeatStreet_Patience" }, class = "EHIAchievementDoneTracker", condition = show_achievement },
        [102426] = { max = 8, id = "run_8", icons = { "C_Classics_H_HeatStreet_Zookeeper" }, class = TT.AchievementProgress, condition = show_achievement },
        [100377] = { time = 90, id = "ClearPickupZone", icons = { "faster" }, class = TT.Warning },
        [101550] = { id = "ClearPickupZone", special_function = SF.RemoveTracker }
    }
elseif level_id == "tag" then -- Breakin' Feds
    triggers = {
        [101335] = { time = 7, id = "C4BasementWall", icons = { "pd2_c4" } },
        [101968] = { time = 10, id = "LureDelay", icons = { "faster" } }
    }
elseif level_id == "fish" then -- The Yacht Heist
    triggers = {
        -- 100244 is ´Players_spawned´, the achievement is not in the Mission Script
        [100244] = { time = 360, id = "fish_4", icons = { "C_Continental_H_YachtHeist_Thalasso" }, class = TT.Achievement, condition = show_achievement and ovk_and_up }
    }
elseif level_id == "rat" then -- Cook Off
    local anim_delay = 743/30 -- 743/30 is a animation duration; 3s is zone activation delay (never used when van is coming back)
    triggers = {
        [102318] = { time = 60 + 60 + 30 + 15 + anim_delay, id = "VanReturn", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.AddToGlobalAndExecute },
        [102319] = { time = 60 + 60 + 60 + 30 + 15 + anim_delay, id = "VanReturn", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.AddToGlobalAndExecute },

        [102383] = { time = 7, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait } },
        [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
        [1007211] = { chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [100724] = { random_time = { low = 20, high = 25 }, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetTimeNoAnimOrCreateTracker },

        [102221] = { time = 40, id = "CantTakeTheHeat", icons = { Icon.Car, "faster" }, condition = ovk_and_below }
    }
elseif level_id == "alex_1" then -- Rats Day 1
    triggers = {
        [101970] = { time = 240 + 12, id = "VanComeAfterExplosion", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
        [1007211] = { chance = 5, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
        [100724] = { time = 25, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop } },
    }
elseif level_id == "watchdogs_1" or level_id == "watchdogs_1_night" then -- Watchdogs Day 1
    local escape_delay = 18
    triggers = {
        [100944] = { time = 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = { Icon.Car, Icon.LootDrop } },

        [101218] = { time = 180 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [101219] = { time = 120 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
        [101221] = { time = 60 + escape_delay, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } }
    }
elseif level_id == "watchdogs_2_day" or level_id == "watchdogs_2" then -- Watchdogs Day 2
    local boat_delay = 60 + 30 + 30 + 450/30
    triggers = {
        [101560] = { time = 35 + 75 + 30 + boat_delay, id = "BoatLootFirst" },
        -- 101127 tracked in 101560
        [101117] = { time = 60 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
        [101122] = { time = 40 + 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },
        [101119] = { time = 30 + boat_delay, id = "BoatLootFirst", special_function = SF.SetTimeOrCreateTracker },

        [100323] = { time = 50 + 23, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } },
    }
    trigger_icon_all = { Icon.Boat, Icon.LootDrop }
    if Network:is_client() then
        triggers[100470] = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SF.SetTrackerAccurate2 }
        triggers[100472] = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SF.SetTrackerAccurate2 }
        triggers[100474] = { time = 450/30, id = "BoatLootDropReturnRandom", id2 = "BoatLootDropReturn", id3 = "BoatLootFirst", special_function = SF.SetTrackerAccurate2 }
    end
elseif level_id == "kenaz" then -- Golden Grin Casino
    local heli_delay = 22 + 1 + 1.5
    local heli_icon = { Icon.Heli, "equipment_winch_hook", "pd2_goto" }
    local refill_icon = { "pd2_water_tap", "pd2_goto" }
    triggers = {
        [100282] = { time = 840, id = "kenaz_4", icons = { "C_Dentist_H_GoldenGrinCasino_HighRoller" }, class = TT.Achievement, condition = show_achievement },

        [EHI:GetInstanceElementID(100021, 29150)] = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100042, 29150)] = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100021, 29225)] = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100042, 29225)] = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100021, 15220)] = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100042, 15220)] = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100021, 15295)] = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100042, 15295)] = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled },

        -- Toilets
        [EHI:GetInstanceElementID(100181, 13000)] = { time = 30, id = "RefillLeft01", icons = refill_icon },
        [EHI:GetInstanceElementID(100233, 13000)] = { time = 30, id = "RefillRight01", icons = refill_icon },
        [EHI:GetInstanceElementID(100299, 13000)] = { time = 30, id = "RefillLeft02", icons = refill_icon },
        [EHI:GetInstanceElementID(100300, 13000)] = { time = 30, id = "RefillRight02", icons = refill_icon },

        [100489] = { special_function = SF.RemoveTrackers, data = { "WaterTimer1", "WaterTimer2" } }
    }
elseif level_id == "nmh" then -- No Mercy
    triggers = {
        [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
        [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
        [103456] = { time = 5, id = "nmh_11", icons = { "C_Classics_H_NoMercy_Nyctophobia" }, class = TT.Achievement, special_function = SF.RemoveTriggerWhenExecuted, condition = hard_and_above and show_achievement },
    }
elseif level_id == "chas" then -- Dragon Heist
    triggers = {
        [100107] = { time = 360, id = "chas_11", icons = { "C_JiuFeng_H_DragonHeist_Speed" }, class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [EHI:GetInstanceElementID(100017, 11325)] = { id = "Gas", special_function = SF.RemoveTracker }
    }
    if Network:is_client() then
        triggers[100602] = { time = 90 + 5, random_time = { low = 0, high = 20 }, id = "LoudEscape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
        triggers[102453] = { time = 60 + 12.5, random_time = { low = 0, high = 20 }, id = "HeliArrivesWithDrill", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist }
    end
elseif level_id == "firestarter_3" then -- Firestarter Day 3
    triggers = {
        [102144] = { time = 90, id = "MoneyBurn", icons = { Icon.Fire, "money" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1021441 } },
        [1021441] = { time = 90, id = "slakt_5", icons = { "C_Hector_H_Firestarter_ItsGettingHot" }, class = "EHIAchievementDoneTracker", condition = dw_and_above and show_achievement },
        [102073] = { id = "slakt_5", special_function = SF.RemoveTracker }
    }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        -- It was 7 minutes before the change
        [101989] = { time = 360, id = "spa_5", icons = { "C_Continental_H_Brooklyn_ARendezvous" }, class = TT.Achievement }
    }
elseif level_id == "welcome_to_the_jungle_1" or level_id == "welcome_to_the_jungle_1_night" then -- Big Oil Day 1
    triggers = {
        [101282] = { time = 60, id = "cac_24", icons = { "C_Elephant_H_BigOil_Junkyard" }, class = TT.Achievement, condition = show_achievement }
    }
elseif level_id == "welcome_to_the_jungle_2" then -- Big Oil Day 2
    local inspect = 30
    local escape = 23 + 7
    triggers = {
        [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait } },
        [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait } },
        [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait } },
        [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait } },

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
        [100107] = { time = 300, id = "sah_9", icons = { "C_Locke_H_Shacklethorne_AuctionCry" }, class = TT.Achievement, condition = ovk_and_up and show_achievement }
    }
elseif level_id == "jolly" then -- Aftershock
    triggers = {
        [101644] = { time = 60, id = "BainWait", icons = { Icon.Wait } },
        [EHI:GetInstanceElementID(100047, 21250)] = { time = 1 + 60 + 60 + 60 + 20 + 15, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape } }
    }
elseif level_id == "cage" then -- Car Shop
    triggers = {
        [100107] = { time = 240, id = "fort_4", icons = { "C_Bain_H_Car_Gone" }, class = TT.Achievement, condition = show_achievement, special_function = SF.RemoveTriggerWhenExecuted }
    }
elseif level_id == "family" then -- Diamond Store
    triggers = {
        [102611] = { time = 1, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },
        [102612] = { time = 3, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },
        [102613] = { time = 5, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },

        [100750] = { time = 120, id = "VanDelay", icons = { Icon.Car, Icon.Wait } },
        [101568] = { time = 20, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [101566] = { time = 40, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [101572] = { time = 60, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [101573] = { time = 80, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "jewelry_store" then -- Jewelry Store
    triggers = {
        [101541] = { time = 2, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },
        [101558] = { time = 5, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },
        [101601] = { time = 7, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },

        [103172] = { time = 45 + 830/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [103182] = { time = 600/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [103181] = { time = 580/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [101770] = { time = 650/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker }
    }
elseif level_id == "ukrainian_job" then -- Ukrainian Job
    local zone_delay = 12
    triggers = {
        [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },
        [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = { Icon.Car, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning },

        [103172] = { time = 2 + 830/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [103182] = { time = 600/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [103181] = { time = 580/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [101770] = { time = 650/30, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },

        [100073] = { time = 36, id = "lets_do_this", icons = { "C_Vlad_H_Ukrainian_LetsDoTh" }, class = TT.Achievement, condition = show_achievement }
    }
elseif level_id == "peta" then -- Goat Simulator Heist Day 1
    triggers = {
        [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [101706] = { time = 1283/30, id = "Escape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [101727] = { time = 895/30, id = "Escape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTimeOrCreateTracker },
        [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait } },
        [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait } },
        [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait } },
        [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait } },
        [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, id = "peta_2", icons = { "C_Vlad_H_GoatSim_GoatIn" }, class = TT.Achievement, condition = show_achievement }
    }
elseif level_id == "peta2" then -- Goat Simulator Heist Day 2
    triggers = {
        -- Formerly 5 minutes
        [101540] = { time = 240, id = "peta_3", icons = { "C_Vlad_H_GoatSim_Hazzard" }, class = TT.Achievement, condition = show_achievement },

        [EHI:GetInstanceElementID(100022, 2850)] = { time = 180 + 6.9, id = "BagsDropin", icons = { Icon.Bag, "pd2_goto" } },
        [EHI:GetInstanceElementID(100022, 3150)] = { time = 180 + 6.9, id = "BagsDropin", icons = { Icon.Bag, "pd2_goto" } },
        [EHI:GetInstanceElementID(100022, 3450)] = { time = 180 + 6.9, id = "BagsDropin", icons = { Icon.Bag, "pd2_goto" } },
        [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = { Icon.Bag, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled },
        [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ExecuteIfElementIsEnabled }
    }
elseif level_id == "pines" then -- White Xmas
    triggers = {
        [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up },
        [103367] = { chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance },
        [101001] = { time = 1200, id = "PresentDropChance50", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101002] = { time = 600, id = "PresentDropChance40", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101003] = { time = 600, id = "PresentDropChance30", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101004] = { time = 600, id = "PresentDropChance20", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
        [101045] = { random_time = { low = 50, high = 60 }, id = "WaitTime", icons = { Icon.Wait } },
        [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry", "pd2_goto" }, special_function = SF.RemoveTriggerWhenExecuted },
        [105102] = { time = 30, id = "HeliLoot", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        -- Hooked to 105072 instead of 105076 to track the take off accurately
        [105072] = { time = 82, id = "HeliLootTakeOff", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop, Icon.Wait }, class = TT.Warning }
    }
    if show_achievement and ovk_and_up then
        triggers[104385] = { id = "uno_9", special_function = SF.IncreaseProgress }
    end
elseif level_id == "friend" then -- Scarface Mansion
    triggers = {
        [100107] = { time = 901, id = "uno_7", icons = { "C_Butcher_H_Scarface_Setting" }, class = "EHIAchievementObtainableTracker", condition = mayhem_and_up and show_achievement },
        [102291] = { max = 2, id = "friend_5", icons = { "C_Butcher_H_Scarface_LookAtThese" }, class = TT.AchievementProgress, condition = show_achievement },
        [102430] = { time = 780, id = "friend_6", icons = { "C_Butcher_H_Scarface_WhatYouWant" }, class = TT.Achievement, condition = mayhem_and_up and show_achievement },

        [100103] = { time = 15, random_time = { low = 5, high = 15 }, id = "BileArrival", icons = { Icon.Heli } },

        [100238] = { time = 18, id = "RandomCar1", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } },
        [100249] = { time = 18, id = "RandomCar2", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } },
        [100310] = { time = 18, id = "RandomCar3", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } },
        [100313] = { time = 18, id = "RandomCar4", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } },
        [100314] = { time = 18, id = "RandomCar5", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } },

        [102231] = { time = 20, id = "BileCarDropToWater", icons = { Icon.Heli, Icon.Car, "pd2_goto" } },

        [100718] = { time = 18, id = "Caddilac1", icons = { Icon.Heli, "pd2_goto" } },
        [100720] = { time = 18, id = "Caddilac2", icons = { Icon.Heli, "pd2_goto" } },
        [100732] = { time = 18, id = "Caddilac3", icons = { Icon.Heli, "pd2_goto" } },
        [100733] = { time = 18, id = "Caddilac4", icons = { Icon.Heli, "pd2_goto" } },
        [100734] = { time = 18, id = "Caddilac5", icons = { Icon.Heli, "pd2_goto" } },

        [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, Icon.Car, "pd2_goto" } },

        [100213] = { time = 450/30, id = "EscapeCar1", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100214] = { time = 160/30, id = "EscapeCar2", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100216] = { time = 662/30, random_time = { low = 0, high = 10 }, id = "EscapeBoat", icons = { Icon.Boat, Icon.Escape, Icon.LootDrop } }
    }
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    local chopper_delay = 25 + 1 + 2.5
    triggers = {
        [101737] = { time = 60, id = "cow_11", icons = { "C_Butcher_H_BombDock_Done" }, class = TT.Achievement, condition = show_achievement },

        [102120] = { time = 5400/30, id = "ShipMove", icons = { Icon.Boat, Icon.Wait } },

        [101545] = { time = 100 + chopper_delay, id = "C4FasterPilot", icons = { Icon.Heli, Icon.C4, "pd2_goto" } },
        [101749] = { time = 160 + chopper_delay, id = "C4", icons = { Icon.Heli, Icon.C4, "pd2_goto" } },

        [106295] = { time = 705/30, id = "VanEscape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.ExecuteIfElementIsEnabled },
        [106294] = { time = 1200/30, id = "HeliEscape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.ExecuteIfElementIsEnabled },
        [100339] = { time = 0.2 + 450/30, id = "BoatEscape", icons = { Icon.Boat, Icon.Escape, Icon.LootDrop }, special_function = SF.ExecuteIfElementIsEnabled }
    }
elseif level_id == "crojob3" or level_id == "crojob3_night" then -- The Bomb: Forest
    local heli_anim = 35
    triggers = {
        [101499] = { time = 155 + 25, id = "EscapeHeli", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop } },
        [101253] = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101254] = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101255] = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101256] = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101259] = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101278] = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101279] = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
        [101280] = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, "pd2_water_tap", "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },

        [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop } },

        [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
    }
elseif level_id == "shoutout_raid" then -- Meltdown
    triggers = {
        [102314] = { id = "Vault", class = "EHIVaultTemperatureTracker", special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100032, 2850)] = { id = "Vault", special_function = SF.RemoveTracker },
        [100107] = { time = 420, id = "trophy_longfellow", icons = { "trophy" }, class = TT.Warning, condition = ovk_and_up }
    }
elseif level_id == "roberts" then -- GO Bank
    local delay = 20 + (math.random() * (7.5 - 6.2) + 6.2)
    triggers = {
        [101929] = { time = 30, id = "PlaneWait", icons = { Icon.Wait } },
        [101931] = { time = 90 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } },
        [101932] = { time = 120 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } },
        [101933] = { time = 150 + delay, id = "CageDrop", icons = { Icon.Heli, Icon.LootDrop, "pd2_goto" } }
    }
elseif level_id == "rvd1" then -- Reservoir Dogs Heist Day 2
    triggers = {
        [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100057] = { time = 60, id = "rvd_10", icons = { "C_Bain_H_ReservoirDogs_Pinky" }, class = TT.Achievement, condition = death_wish_and_up and show_achievement },
        [100169] = { time = 17 + 1 + 310/30, id = "PinkArrival", icons = { "pd2_goto" } }
        --260/30 anim_crash_02
        --310/30 anim_crash_04
        --201/30 anim_crash_05
        --284/30 anim_crash_03
    }
elseif level_id == "rvd2" then -- Reservoir Dogs Heist Day 1
    triggers = {
        [100903] = { time = 120, id = "LiquidNitrogen", icons = { "equipment_liquid_nitrogen_canister" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 } },
        [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = { Icon.C4, "pd2_goto" } },
        [101366] = { time = 5, random_time = { low = 40, high = 50 }, id = "VaultTeargas", icons = { Icon.Teargas } }
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
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "arm_fac" then -- Transport: Harbor
    local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is in CoreElementUnitSequence
    triggers = {
        [100259] = { time = 120 + delay },
        [100258] = { time = 100 + delay },
        [100257] = { time = 80 + delay },
        [100209] = { time = 60 + delay }
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
    trigger_icon_all = { Icon.Escape, Icon.LootDrop }
elseif level_id == "arm_for" then -- Transport: Train Heist
    local truck_delay = 524/30
    local boat_delay = 450/30
    triggers = {
        [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = { Icon.Heli, "pd2_drill", "pd2_goto" } },

        -- Boat
        [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = { Icon.Boat, Icon.LootDrop } },
        [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = { Icon.Boat, Icon.LootDrop } },

        -- Truck
        [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = { Icon.Car, Icon.LootDrop } }
    }
elseif level_id == "pal" then -- Counterfeit
    triggers = {
        [101566] = { id = "Trap", special_function = SF.RemoveTracker },
        [100240] = { id = "PAL", special_function = SF.RemoveTracker },
        [102502] = { id = "PAL", class = "EHIPALTracker", special_function = SFF.PAL_UnpauseOrCreate },
        [102892] = { time = 1800/30, random_time = { low = 120, high = 180 }, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop } },
        [EHI:GetInstanceElementID(100013, 4700)] = { random_time = { low = 180, high = 240 }, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4750)] = { random_time = { low = 180, high = 240 }, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4800)] = { random_time = { low = 180, high = 240 }, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100013, 4850)] = { random_time = { low = 180, high = 240 }, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
    }
elseif level_id == "nail" then -- Lab Rats
    triggers = {
        [101505] = { time = 10, id = "TruckDoorOpens", icons = { "pd2_door" } },
        -- There are a lot of delays in the ID. Using average instead (5.2)
        [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, "pd2_methlab", "pd2_goto" } }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [100128] = { time = 38, id = "WinchDropTrainA", icons = { "equipment_winch_hook", "pd2_goto" } },
        [100164] = { time = 38, id = "WinchDropTrainB", icons = { "equipment_winch_hook", "pd2_goto" } },
    }
elseif level_id == "bph" then -- Hell's Island
    triggers = {
        [101815] = { time = 10, id = "MoveWalkway", icons = { Icon.Wait } },
        [101433] = { id = "EnemyDeathShowers", special_function = SF.RemoveTracker },
        [100109] = { max = (very_hard_and_below and 30 or 40), id = "EnemyDeathShowers", icons = { "pd2_kill" }, dont_flash = true, class = TT.Progress },
        [101742] = { max = 3, id = "bph_10", icons = { "C_Locke_H_HellsIsland_Another" }, class = TT.AchievementProgress, special_function = SF.RemoveTriggerWhenExecuted, condition = ovk_and_up and show_achievement },
        [101885] = { id = "bph_10", special_function = SF.RemoveTracker }
    }
elseif level_id == "hox_1" then -- Hoxton Breakout Day 1
    triggers = {
        [101595] = { time = 6, id = "Wait", icons = { Icon.Wait } }
    }
elseif level_id == "hox_2" then -- Hoxton Breakout Day 2
    triggers = {
        [104579] = { time = 15, id = "Request", icons = { "wp_hack", Icon.Wait } },
        [104580] = { time = 25, id = "Request", icons = { "wp_hack", Icon.Wait } },
        [104581] = { time = 20, id = "Request", icons = { "wp_hack", Icon.Wait } },
        [104582] = { time = 30, id = "Request", icons = { "wp_hack", Icon.Wait } }, -- Disabled in the mission script

        [104509] = { time = 30, id = "HackRestartWait", icons = { "wp_hack", "restarter" } },

        [104314] = { max = 4, id = "RequestCounter", icons = { "wp_hack" }, class = TT.Progress, special_function = SF.AddTrackerIfDoesNotExist },

        [104599] = { id = "RequestCounter", special_function = SF.RemoveTracker }
    }
elseif level_id == "hox_3" then -- Hoxton Revenge
    local drill_delay = 30 + 2 + 1.5
    local escape_delay = 3 + 27 + 1
    triggers = {
        [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist },
        [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist },
        [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist },
        [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist },
        [101844] = { time = drill_delay, id = "LanceDrop", icons = { Icon.Heli, "pd2_drill", "pd2_goto" }, special_function = SF.AddTrackerIfDoesNotExist },

        [102223] = { time = 90 + escape_delay, id = "Escape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [102188] = { time = 60 + escape_delay, id = "Escape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [102187] = { time = 45 + escape_delay, id = "Escape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [102186] = { time = 30 + escape_delay, id = "Escape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
        [102190] = { time = escape_delay, id = "Escape", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
    }
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, id = "orange_4", icons = { "C_Event_H_PrisonNightmare_SalemAsylum" }, class = TT.Achievement, condition = mayhem_and_up and show_achievement },
        [EHI:GetInstanceElementID(100461, 21700)] = { id = "orange_4", special_function = SF.RemoveTracker },
        [100279] = { max = 15, id = "orange_5", icons = { "C_Event_H_PrisonNightmare_ALongNight" }, class = TT.AchievementProgress, remove_after_reaching_target = true, condition = mayhem_and_up and show_achievement },
        [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = { Icon.Heli, "pd2_c4", "pd2_goto" } }
    }
elseif level_id == "mex" then -- Border Crossing
    triggers = {
        [100107] = { max = 4, id = "mex_9", icons = { "C_Locke_H_BorderCrossing_Identity" }, class = TT.AchievementProgress, condition = show_achievement },
        [101983] = { time = 15, id = "C4Trap", icons = { "pd2_c4" }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
        [101722] = { id = "C4Trap", special_function = SF.RemoveTracker }
    }
elseif level_id == "mex_cooking" then -- Border Crystals
    triggers = {
        [EHI:GetInstanceElementID(100056, 55850)] = { time = 15, id = "MethlabRestart", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100056, 56850)] = { time = 15, id = "MethlabRestart", icons = { Icon.Methlab, "restarter" } }
    }
elseif level_id == "bex" then -- San Martín Bank
    triggers = {
        [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },
        [103919] = { time = 25 + 1 + 13, random_time = { low = 0, high = 5 }, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [100840] = { time = 1 + 13, id = "Van", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, special_function = SF.SetTrackerAccurate }
    }
elseif level_id == "pex" then -- Breakfast in Tijuana
    triggers = {
        [102355] = { max = 6, id = "pex_10", icons = { "C_Locke_H_BreakfastInTijuana_PaidInFull" }, class = TT.AchievementProgress, condition = show_achievement, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1023551 } },
        [1023551] = { max = 7, id = "pex_11", icons = { "C_Locke_H_BreakfastInTijuana_StolenValor" }, class = TT.AchievementProgress, condition = show_achievement },
        [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" } },
        [100640] = { id = "pex_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "fex" then -- Buluc's Mansion
    triggers = {
        -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in CoreElementUnitSequence
        [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop } },
        [EHI:GetInstanceElementID(100358, 10130)] = { time = 1 + 210/30, id = "MayanDoorOpen", icons = { "pd2_door" } }
    }
elseif level_id == "skm_run" or level_id == "skm_red2" or level_id == "skm_mus" or level_id == "skm_arena" or level_id == "skm_bex" or level_id == "skm_big2" or level_id == "skm_cas" or level_id == "skm_mallcrasher" or level_id == "skm_watchdogs_stage2" then -- Holdout missions
    local start_index = 0
    if level_id == "skm_run" then
        start_index = 1650
    elseif level_id == "skm_red2" then
        start_index = 7950
    elseif level_id == "skm_mus" then
        start_index = 7400
    elseif level_id == "skm_arena" then
        start_index = 10600
    elseif level_id == "skm_bex" then
        start_index = 4100
    elseif level_id == "skm_big2" or level_id == "skm_mallcrasher" or level_id == "skm_watchdogs_stage2" then
        -- nothing, start index is 0
    elseif level_id == "skm_cas" then
        start_index = 37550
    else
        return
    end
    triggers = {
        [EHI:GetInstanceElementID(100032, start_index)] = { time = 7, id = "HostageRescue", icons = { "pd2_kill" }, class = TT.Warning },
        [EHI:GetInstanceElementID(100036, start_index)] = { id = "HostageRescue", special_function = SF.RemoveTracker }
    }
else
    return
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
end

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.random(triggers[id].random_time.low, triggers[id].random_time.high) or 0)
    return full_time
end

local function CreateTrackerForReal(id, icon2)
    if icon2 then
        triggers[id].icons[1] = icon2
    end
    managers.hud:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = GetTime(id),
        chance = triggers[id].chance,
        max = triggers[id].max,
        dont_flash = triggers[id].dont_flash,
        remove_after_reaching_target = triggers[id].remove_after_reaching_target,
        icons = triggers[id].icons or trigger_icon_all,
        class = triggers[id].class
    })
end

local function CreateTracker(id)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTrackerForReal(id)
        end
    else
        CreateTrackerForReal(id)
    end
end

local function Trigger(id, enabled)
    --[[if managers.hud and managers.hud.Debug then
        managers.hud:Debug(id, "MissionScriptElement")
    end]]
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.hud:RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                managers.hud:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.hud:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:ResetTrackerTimeAndUnpause(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if not managers.hud:TrackerExists(triggers[id].id or trigger_id_all) then
                    CreateTracker(id)
                end
            elseif f == SF.SetAchievementComplete then
                managers.hud.ehi:CallFunction(triggers[id].id, "SetCompleted")
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].data
            elseif f == SF.GetFromCache then
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                CreateTrackerForReal(id, data.icon)
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                if triggers[id].data.trigger then
                    triggers[triggers[id].data.trigger] = nil -- Removes trigger from the list, used in The White House
                end
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.CreateAnotherTrackerWithTracker then
                CreateTracker(id)
                Trigger(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.hud:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.hud:TrackerExists(trigger.id) then
                    managers.hud.ehi:SetChance(trigger.id, trigger.chance)
                else
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.SetTimeOrCreateTracker then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    CreateTracker(id)
                end
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.hud:RemoveTracker(tracker)
                end
            elseif f == SF.CreateTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    CreateTracker(tracker)
                end
            elseif f == SF.UnpauseTrackersOrCreateThem then
                for _, tracker in ipairs(triggers[id].data) do
                    if managers.hud:TrackerExists(triggers[tracker].id) then
                        managers.hud:UnpauseTracker(triggers[tracker].id)
                    else
                        CreateTracker(tracker)
                    end
                end
            elseif f == SF.IncreaseProgress then
                managers.hud:IncreaseProgress(triggers[id].id)
            elseif f == SF.SetTimeNoAnimOrCreateTracker then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTimeNoAnim(triggers[id].id, GetTime(id))
                else
                    CreateTracker(id)
                end
            elseif f == SF.SetTrackerAccurate then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTrackerAccurate(triggers[id].id)
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.SetTrackerAccurate2 then -- Used in Watchdogs D2
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTrackerAccurate(triggers[id].id)
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                elseif not (managers.hud:TrackerExists(triggers[id].id2) or managers.hud:TrackerExists(triggers[id].id3)) then
                    CreateTracker(id)
                end
            elseif f == SF.UnpauseAndSetTime then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.DecreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.AddToGlobalAndExecute then
                EHI._cache.VanReturn = true
                CreateTracker(id)
            elseif f == SFF.PAL_UnpauseOrCreate then
                if managers.hud:TrackerExists(triggers[id].id) then
                    managers.hud.ehi:CallFunction(triggers[id].id, "ResumeAll")
                else
                    CreateTracker(id)
                end
            end
        elseif triggers[id].on_executed then
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = MissionScriptElement.client_on_executed
function MissionScriptElement:client_on_executed()
    _f_client_on_executed(self)
    Trigger(self._id, self._values.enabled)
end

local _f_on_executed = MissionScriptElement.on_executed
function MissionScriptElement:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id, self._values.enabled)
end