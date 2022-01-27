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
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local mayhem_and_up = EHI:IsDifficultyOrAbove("mayhem")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local very_hard_and_up = EHI:IsDifficultyOrAbove("very_hard")
local very_hard_and_below = EHI:IsDifficultyOrBelow("very_hard")
local hard_and_above = EHI:IsDifficultyOrAbove("hard")
local DisableWaypoints = {}
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = {}
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local Icon = EHI.Icons
local TT = EHI.Trackers -- Tracker Type
local AchievementTT =
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
}
local rotations =
{
    [1] = Rotation(0, 0, -0)
}
local client = Network:is_client()
local CarEscape = { Icon.Car, Icon.Escape, Icon.LootDrop }
local HeliEscape = { Icon.Heli, Icon.Escape, Icon.LootDrop }
local HeliEscapeNoLoot = { Icon.Heli, Icon.Escape }
local HeliDropC4 = { Icon.Heli, "pd2_c4", "pd2_goto" }
local HeliDropDrill = { Icon.Heli, "pd2_drill", "pd2_goto" }
local BoatEscape = { Icon.Boat, Icon.Escape, Icon.LootDrop }
local FirstAssaultDelay = { { icon = "assaultbox", color = Color(1, 1, 0) } }
if level_id == "election_day_1" then -- Election Day 1
    triggers = {
        [100003] = { time = 60, id = "slakt_1", class = TT.Achievement },
        [100012] = { id = "bob_8", class = TT.AchievementNotification },
        [101248] = { id = "bob_8", special_function = SF.SetAchievementComplete },
        [100469] = { id = "bob_8", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "election_day_3" or level_id == "election_day_3_skip1" or level_id == "election_day_3_skip2" then -- Election Day 2 Plan C
    local drill_spawn_delay = { time = 30, id = "DrillSpawnDelay", icons = { "pd2_drill", "pd2_goto" } }
    triggers = {
        [101284] = { chance = 50, id = "CrashChance", icons = { "wp_hack", "pd2_fix" }, class = TT.Chance },
        [103568] = { time = 60, id = "Hack", icons = { "wp_hack" }, special_function = SF.ED3_SetWhiteColorWhenUnpaused },
        [103585] = { id = "Hack", special_function = SF.ED3_SetPausedColor },
        [103579] = { amount = 25, id = "CrashChance", special_function = SF.DecreaseChance },
        [100741] = { id = "CrashChance", special_function = SF.RemoveTracker },
        [103572] = { time = 50, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103573] = { time = 40, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103574] = { time = 30, id = "CrashChanceTime", icons = { "wp_hack", "pd2_fix", "pd2_question" } },
        [103478] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } },
        [103169] = drill_spawn_delay,
        [103179] = drill_spawn_delay,
        [103190] = drill_spawn_delay,
        [103195] = drill_spawn_delay,

        [103535] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
    }
elseif level_id == "escape_overpass" or level_id == "escape_overpass_night" then -- Escape: Overpass
    triggers = {
        [101148] = { id = "you_shall_not_pass", class = TT.AchievementNotification },
        [102471] = { id = "you_shall_not_pass", special_function = SF.SetAchievementFailed },
        [100426] = { id = "you_shall_not_pass", special_function = SF.SetAchievementComplete },
        [101145] = { time = 180, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101158] = { time = 240, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
        [101977] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101978] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
        [101979] = { special_function = SF.AddToCache, data = { icon = Icon.Car } }, -- Van
    }
    trigger_id_all = "Escape"
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
elseif level_id == "kenaz" then -- Golden Grin Casino
    local heli_delay = 22 + 1 + 1.5
    local heli_icon = { Icon.Heli, "equipment_winch_hook", "pd2_goto" }
    local refill_icon = { "pd2_water_tap", "pd2_goto" }
    local heli_60 = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
    local heli_30 = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
    triggers = {
        [100282] = { time = 840, id = "kenaz_4", class = TT.Achievement },

        [EHI:GetInstanceElementID(100173, 66615)] = { time = 5 + 25, id = "ArmoryKeypadReboot", icons = { "faster" }, waypoint = { time = 5 + 25, position = Vector3(9823.0, -40877.0, -2987.0) + Vector3(0, 0, 0):rotate_with(Rotation()) } },

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

        [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

        -- Water during drilling
        [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60, cache_id = "Water1" } },
        [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60, cache_id = "Water2" } },
        [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

        -- Skylight Hack
        [EHI:GetInstanceElementID(100018, 29650)] = { time = 30, id = "SkylightHack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100037, 29650)] = { id = "SkylightHack", special_function = SF.PauseTracker },

        [100159] = { id = "BlimpWithTheDrill", icons = { "pd2_question", "pd2_drill" }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 } },
        [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { "pd2_question", "pd2_drill", "pd2_goto" } },

        [EHI:GetInstanceElementID(100173, 66365)] = { time = 30, id = "VaultKeypadReset", icons = { "restarter" } }
    }
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    local start_index = { 1100, 1400, 1700, 2000, 2300, 2600, 2900, 3500, 3800, 4100, 4400, 4700 }
    local interact = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } }
    local element_sync_triggers = {}
    for _, index in pairs(start_index) do
        for i = 100169, 100172, 1 do
            local element_id = EHI:GetInstanceElementID(i, index)
            element_sync_triggers[element_id] = EHI:DeepClone(interact)
            element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
        end
    end
    local chopper_delay = 25 + 1 + 2.5
    triggers = {
        [104086] = { id = "cow_10", status = "ok", class = TT.AchievementNotification },
        [102480] = { id = "cow_10", special_function = SF.SetAchievementFailed },
        [106581] = { id = "cow_10", special_function = SF.SetAchievementComplete },

        [101737] = { time = 60, id = "cow_11", class = TT.Achievement },
        [102466] = { id = "cow_11", special_function = SF.RemoveTracker },
        [102479] = { id = "cow_11", special_function = SF.SetAchievementComplete },

        [102120] = { time = 5400/30, id = "ShipMove", icons = { Icon.Boat, Icon.Wait }, special_function = SF.RemoveTriggerWhenExecuted },

        [101545] = { time = 100 + chopper_delay, id = "C4FasterPilot", icons = HeliDropC4 },
        [101749] = { time = 160 + chopper_delay, id = "C4", icons = HeliDropC4 },

        [106295] = { time = 705/30, id = "VanEscape", icons = CarEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [106294] = { time = 1200/30, id = "HeliEscape", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [100339] = { time = 0.2 + 450/30, id = "BoatEscape", icons = BoatEscape, special_function = SF.ExecuteIfElementIsEnabled }
    }
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
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
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

        [102825] = { id = "WaterFill", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
        [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
        [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

        [1] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
        [2] = { id = "HeliWaterReset", icons = { Icon.Heli, "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

        [103461] = { time = 5, id = "cow_3", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement },
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
        triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = { Icon.Heli, "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
        triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
        triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
    end
-- Art Gallery starts here (also as Framing Frame Day 1)
elseif level_id == "arena" then -- The Alesso Heist
    triggers = {
        [100241] = { time = 19, id = "HeliEscape", icons = HeliEscape },
        [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
        [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

        [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { "faster" } },
        [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { "pd2_generic_interact" }, class = TT.Warning },

        [100304] = { time = 5, id = "live_3", icons = { "C_Bain_H_Arena_Even" }, class = TT.AchievementUnlock }
    }
elseif level_id == "pal"then -- Counterfeit
    local element_sync_triggers =
    {
        [102887] = { time = 1800/30, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, hook_element = 102892 }
    }
    triggers = {
        --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
        [102502] = { time = 60, id = "PAL", icons = { Icon.Money }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [102505] = { id = "PAL", special_function = SF.RemoveTracker },
        [102749] = { id = "PAL", special_function = SF.PauseTracker },
        [102738] = { id = "PAL", special_function = SF.PauseTracker },
        [102744] = { id = "PAL", special_function = SF.UnpauseTracker },
        [102826] = { id = "PAL", special_function = SF.RemoveTracker },

        [102301] = { time = 15, id = "Trap", icons = { "pd2_c4" }, class = TT.Warning },
        [101566] = { id = "Trap", special_function = SF.RemoveTracker },

        [101230] = { time = 120, id = "Water", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [101231] = { id = "Water", special_function = SF.PauseTracker }
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
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "red2" then -- First World Bank
    triggers = {
        [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
        [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
        [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
        [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker },
        [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
        [103373] = { time = 817, id = "green_3", class = TT.Achievement },
        [107072] = { id = "cac_10", special_function = SF.SetAchievementComplete },
        [101544] = { id = "cac_10", special_function = SF.RemoveTriggerAndStartAchievementCountdown },
        [101341] = { time = 30, id = "cac_10", class = TT.AchievementTimedProgressTracker, condition = show_achievement and ovk_and_up, condition_function = CF.IsLoud, dont_flash_max = true },
        [107066] = { id = "cac_10", special_function = SF.IncreaseProgressMax },
        [107067] = { id = "cac_10", special_function = SF.IncreaseProgress },
        [101684] = { time = 5.1, id = "C4", icons = { "pd2_c4" } },
        [102567] = { id = "green_3", special_function = SF.SetAchievementFailed }
    }
    for i = 0, 300, 100 do
        -- Hacking PC (repair icon)
        DisableWaypoints[EHI:GetInstanceElementID(100024, i)] = true
    end
elseif level_id == "dark" then -- Murky Station
    triggers = {
        [100296] = { time = 420, id = "dark_2", class = TT.Achievement },
        [106026] = { time = 10, id = "Van", icons = CarEscape },

        [106036] = { time = 410/30, id = "Boat", icons = { "boat", "pd2_escape", "pd2_lootdrop" } }
    }
elseif level_id == "mad" then -- Boiling Point
    triggers = {
        [100891] = { time = 15.33, id = "emp_bomp_drop", icons = { "pd2_goto" } },
        [101906] = { time = 1200, id = "daily_cake", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up, exclude_from_sync = true },
        [100547] = { special_function = SF.Trigger, data = { 1005471, 1005472 } },
        [1005471] = { id = "mad_2", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },
        [1005472] = { id = "cac_13", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },

        [EHI:GetInstanceElementID(100019, 3150)] = { time = 90, id = "Scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100049, 3150)] = { id = "Scan", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100030, 3150)] = { id = "Scan", special_function = SF.RemoveTracker }, -- Just in case

        [EHI:GetInstanceElementID(100013, 1350)] = { time = 120, id = "EMP", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100023, 1350)] = { id = "EMP", special_function = SF.PauseTracker },

        [101400] = { id = "mad_2", special_function = SF.SetAchievementFailed },
        [101823] = { id = "mad_2", special_function = SF.SetAchievementComplete },

        [101925] = { id = "cac_13", special_function = SF.SetAchievementFailed },
        [101924] = { id = "cac_13", special_function = SF.SetAchievementComplete }
    }
    if client then
        triggers[101410] = { id = "Scan", special_function = SF.RemoveTracker } -- Just in case
    end
elseif level_id == "peta" then -- Goat Simulator Heist Day 1
    triggers = {
        [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = CarEscape },
        [101706] = { time = 1283/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [101727] = { time = 895/30, id = "Escape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },
        [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait } },
        [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait } },
        [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait } },
        [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait } },
        [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, id = "peta_2", class = TT.Achievement },
        [EHI:GetInstanceElementID(100080, 2900)] = { id = "peta_2", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "peta2" then -- Goat Simulator Heist Day 2
    local bag_drop = { Icon.Heli, Icon.Bag, "pd2_goto" }
    local goat_pick_up = { Icon.Heli, Icon.Interact }
    triggers = {
        [100109] = { time = 100 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning },

        [100002] = { max = (mayhem_and_up and 15 or 13), id = "peta_5", class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
        [102211] = { id = "peta_5", special_function = SF.IncreaseProgress },
        [100580] = { special_function = SF.CustomCode, f = function()
            EHI:DelayCall("peta_5_finalize", 2, function()
                managers.ehi:CallFunction("peta_5", "Finalize")
            end)
        end},

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

        [101720] = { time = 80, id = "Bridge", icons = { "faster" }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
        [101718] = { id = "Bridge", special_function = SF.PauseTracker },

        [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } },
        [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } },
        [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = { Icon.Heli, Icon.Interact }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } }
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
        [EHI:GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { Icon.Heli, "pd2_goto" } }
    }
    for _, index in pairs({0, 120, 240, 360, 480}) do
        local recharge = EHI:DeepClone(fire_recharge)
        recharge.id = recharge.id .. index
        triggers[EHI:GetInstanceElementID(100024, index)] = recharge
        local fire = EHI:DeepClone(fire_t)
        fire.id = fire.id .. index
        triggers[EHI:GetInstanceElementID(100022, index)] = fire
    end
elseif level_id == "cage" then -- Car Shop
    triggers = {
        [100107] = { time = 240, id = "fort_4", class = TT.Achievement }
    }
elseif level_id == "born" then -- The Biker Heist Day 1
    trigger_icon_all = { "pd2_defend" }
    triggers = {
        [101034] = { id = "MikeDefendTruck", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033 },
        [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
        [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

        [101535] = { id = "MikeDefendGarage", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532 },
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
        triggers[101034].synced = { class = TT.Pausable }
        EHI:AddSyncTrigger(101034, triggers[101034])
        triggers[101535].time = 90
        triggers[101535].random_time = 30
        triggers[101535].special_function = SF.UnpauseTrackerIfExists
        triggers[101535].icons = trigger_icon_all
        triggers[101535].delay_only = true
        triggers[101535].class = "EHIInaccuratePausableTracker"
        triggers[101535].synced = { class = TT.Pausable }
        EHI:AddSyncTrigger(101535, triggers[101535])
    end
elseif level_id == "chew" then -- The Biker Heist Day 2
    triggers = {
        [100595] = { time = 120, id = "born_5", class = TT.Achievement, condition = ovk_and_up and show_achievement }
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
elseif level_id == "chill_combat" then -- Safehouse Raid
    triggers = {
        [100979] = { id = "cac_30", class = TT.AchievementNotification, condition = show_achievement and dw_and_above, exclude_from_sync = true },
        [102831] = { id = "cac_30", special_function = SF.SetAchievementComplete },
        [102829] = { id = "cac_30", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "flat" then -- Panic Room
    local kills = 7 -- Normal + Hard
    if EHI:IsBetweenDifficulties("very_hard", "overkill") then
        -- Very Hard + OVERKILL
        kills = 10
    elseif mayhem_and_up then
        -- Mayhem+
        kills = 15
    end
    triggers = {
        [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 } },
        [100182] = { id = "SniperDeath", special_function = SF.RemoveTracker },
        [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },
        [100147] = { time = 18.2, id = "HeliWinchLoop", icons = { Icon.Heli, "equipment_winch_hook", Icon.Loop }, special_function = SF.ExecuteIfElementIsEnabled },
        [102181] = { id = "HeliWinchLoop", special_function = SF.RemoveTracker },

        [100809] = { time = 60, id = "cac_9", class = TT.Achievement, condition = ovk_and_up and show_achievement, special_function = SF.RemoveTriggerAndShowAchievement, exclude_from_sync = true },

        [100068] = { max = kills, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = TT.Progress },
        [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = { Icon.Heli, "pd2_c4", "pd2_goto" } },
        [100082] = { time = 40, id = "HeliComesWithMagnet", icons = { Icon.Heli, "equipment_winch_hook" } },

        [104859] = { id = "flat_2", special_function = SF.SetAchievementComplete },
        [100805] = { id = "cac_9", special_function = SF.SetAchievementComplete },

        [100206] = { time = 30, id = "LoweringTheWinch", icons = { Icon.Heli, "equipment_winch_hook", "pd2_goto" } },

        [100049] = { time = 20, id = "flat_2", class = TT.Achievement },
        [102001] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
    }
elseif level_id == "help" then -- Prison Nightmare
    triggers = {
        [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, id = "orange_4", class = TT.Achievement, condition = mayhem_and_up and show_achievement, exclude_from_sync = true },
        [EHI:GetInstanceElementID(100461, 21700)] = { id = "orange_4", special_function = SF.SetAchievementComplete },
        [100279] = { max = 15, id = "orange_5", class = TT.AchievementProgress, status_is_overridable = true, remove_after_reaching_target = false, condition = mayhem_and_up and show_achievement, exclude_from_sync = true },
        [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = HeliDropDrill },
        [EHI:GetInstanceElementID(100471, 21700)] = { id = "orange_5", special_function = SF.SetAchievementFailed },
        [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
        [EHI:GetInstanceElementID(100474, 21700)] = { id = "orange_5", special_function = SF.IncreaseProgress }
    }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        -- First Assault Delay
        --[[[EHI:GetInstanceElementID(100003, 7950)] = { time = 3 + 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },
        [EHI:GetInstanceElementID(100024, 7950)] = { time = 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100053, 7950)] = { time = 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100026, 7950)] = { time = 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100179, 7950)] = { time = 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
        [EHI:GetInstanceElementID(100295, 7950)] = { time = 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },]]

        [101989] = { special_function = SF.Trigger, data = { 1019891, 1019892 } },
        -- It was 7 minutes before the change
        [1019891] = { time = 360, id = "spa_5", class = TT.Achievement, condition = ovk_and_up and show_achievement, exclude_from_sync = true },
        [101997] = { id = "spa_5", special_function = SF.SetAchievementComplete },
        [1019892] = { max = 8, id = "spa_6", class = TT.AchievementProgress, remove_after_reaching_target = false, condition = ovk_and_up and show_achievement, exclude_from_sync = true },
        [101999] = { id = "spa_6", special_function = SF.IncreaseProgress },
        [102002] = { id = "spa_6", special_function = SF.FinalizeAchievement },

        [103419] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

        [100681] = { time = 60, id = "CharonPickLock", icons = { "pd2_door" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },

        [102266] = { max = 6, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
        [100833] = { id = "SniperDeath", special_function = SF.RemoveTracker },

        [100549] = { time = 20, id = "ObjectiveWait", icons = { "faster" } },
        [101202] = { time = 15, id = "Escape", icons = CarEscape },
        [101313] = { time = 75, id = "Escape", icons = CarEscape }
    }
elseif level_id == "fish" then -- The Yacht Heist
    triggers = {
        -- 100244 is ´Players_spawned´
        [100244] = { special_function = SF.Trigger, data = { 1002441, 1002442 } },
        -- "fish_4" achievement is not in the Mission Script
        [1002441] = { time = 360, id = "fish_4", class = TT.Achievement, condition = show_achievement and ovk_and_up },
        [1002442] = { id = "fish_5", class = TT.AchievementNotification, exclude_from_sync = true },
        [100395] = { id = "fish_5", special_function = SF.SetAchievementFailed },
        [100842] = { id = "fish_5", special_function = SF.SetAchievementComplete }
    }
elseif level_id == "man" then -- Undercover
    local deal = { "pd2_car", "pd2_goto" }
    local delay = 4 + 356/30
    local start_chance = 15 -- Normal
    if EHI:IsBetweenDifficulties("hard", "very_hard") then
        -- Hard + Very Hard
        start_chance = 10
    elseif ovk_and_up then
        -- OVERKILL+
        start_chance = 5
    end
    local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, "wp_hack" }, flash_times = 1, class = "EHIChanceTracker" }
    triggers = {
        [100698] = { special_function = SF.Trigger, data = { 1006981, 1006982 } },
        [1006981] = { id = "man_2", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, special_function = SF.RemoveTriggerAndShowAchievement },
        [1006982] = { id = "man_3", class = TT.AchievementNotification, special_function = SF.RemoveTriggerAndShowAchievement },
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

        [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance },

        [103989] = { id = "man_4", special_function = SF.IncreaseProgress },

        [103963] = { id = "man_2", special_function = SF.SetAchievementFailed },
        [103957] = { id = "man_3", special_function = SF.SetAchievementFailed }
    }
elseif level_id == "dinner" then -- Slaughterhouse
    local c4 = { time = 5, id = "C4", icons = { "pd2_c4" } }
    triggers = {
        [100484] = { time = 300, id = "farm_2", icons = { "C_Classics_H_Slaughterhouse_ButHow" }, class = TT.AchievementUnlock },
        [100485] = { time = 30, id = "farm_4", class = TT.Achievement },
        [100915] = { time = 4640/30, id = "CraneMoveGas", icons = { "equipment_winch_hook", Icon.Fire, "pd2_goto" } },
        [100967] = { time = 3660/30, id = "CraneMoveGold", icons = { Icon.Escape } },
        [100319] = { id = "farm_2", special_function = SF.SetAchievementFailed },
        [102841] = { id = "farm_4", special_function = SF.SetAchievementComplete },
        [101553] = { id = "farm_3", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
        [103394] = { id = "farm_3", special_function = SF.SetAchievementFailed },
        [102880] = { id = "farm_3", special_function = SF.SetAchievementComplete },
        -- C4 (Doors)
        [100985] = c4,
        -- C4 (GenSec Truck)
        [100830] = c4,
        [100961] = c4
    }
elseif level_id == "nail" then -- Lab Rats
    triggers = {
        [101505] = { time = 10, id = "TruckDoorOpens", icons = { "pd2_door" } },
        -- There are a lot of delays in the ID. Using average instead (5.2)
        [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, "pd2_methlab", "pd2_goto" } },

        [101936] = { time = 30 + 12, id = "Escape", icons = { Icon.Heli, "pd2_escape" } }
    }
elseif level_id == "pbr" then -- Beneath the Mountain
    triggers = {
        [102290] = { id = "berry_3", special_function = SF.SetAchievementComplete },
        [102292] = { time = 600, id = "berry_3", class = TT.Achievement, condition = ovk_and_up and show_achievement },

        [101774] = { time = 90, id = "EscapeHeli", icons = { "pd2_escape" } }
    }
elseif level_id == "pbr2" then -- Birth of Sky
    local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
    local ring = { id = "voff_4", special_function = SF.IncreaseProgress }
    triggers = {
        [102504] = { id = "cac_33", status = "ready", class = TT.AchievementNotification, condition = show_achievement and dw_and_above, exclude_from_sync = true },
        [103486] = { id = "cac_33", status = "ok", special_function = SF.SetAchievementStatus },
        [103479] = { id = "cac_33", special_function = SF.SetAchievementComplete },
        [103475] = { id = "cac_33", special_function = SF.SetAchievementFailed },
        [103487] = { max = 200, id = "cac_33_kills", icons = { "pd2_kill" }, class = TT.Progress, flash_times = 1, condition = show_achievement and dw_and_above, special_function = SF.ShowAchievementCustom, data = "cac_33", exclude_from_sync = true },
        [103477] = { id = "cac_33_kills", special_function = SF.IncreaseProgress },
        [103481] = { id = "cac_33_kills", special_function = SF.RemoveTracker },
        [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli, "equipment_winch_hook" } }, -- Time before Locke arrives with heli to pickup the money
        [102452] = { id = "jerry_4", special_function = SF.SetAchievementComplete },
        [102453] = { special_function = SF.Trigger, data = { 1024531, 1024532 } },
        [1024531] = { id = "jerry_3", class = TT.AchievementNotification, condition = ovk_and_up and show_achievement },
        [1024532] = { time = 83, id = "jerry_4", class = TT.Achievement, condition = ovk_and_up and show_achievement },
        [102816] = { id = "jerry_3", special_function = SF.SetAchievementFailed },
        [101314] = { id = "jerry_3", special_function = SF.SetAchievementComplete },

        [103248] = ring,

        [101985] = thermite, -- First grate
        [101984] = thermite -- Second grate
    }
    for i = 103252, 103339, 3 do
        triggers[i] = ring
    end
elseif level_id == "run" then -- Heat Street
    triggers = {
        [100120] = { time = 1800, id = "run_9", icons = { "C_Classics_H_HeatStreet_Patience" }, class = TT.AchievementDone },
        [100377] = { time = 90, id = "ClearPickupZone", icons = { "faster" }, class = TT.Achievement, condition = true }, -- Not really an achievement, but I want to use "SetCompleted" function :p
        [101550] = { id = "ClearPickupZone", special_function = SF.SetAchievementComplete },

        -- Parking lot
        [102543] = { time = 6.5 + 8 + 4, id = "ObjectiveWait", icons = { "faster" } },

        [101521] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { Icon.Heli, "pd2_escape" }, special_function = SF.RemoveTriggerWhenExecuted },

        [100144] = { special_function = SF.Trigger, data = { 1001441, 1001442, 1001443 } },
        [1001441] = { id = "run_9", special_function = SF.SetAchievementFailed },
        [1001442] = { id = "GasAmount", class = "EHIGasTracker" },
        [1001443] = { special_function = SF.RemoveTriggers, data = { 100144 } },
        [102426] = { special_function = SF.Trigger, data = { 1024261, 1024262 } },
        [1024261] = { max = 8, id = "run_8", class = TT.AchievementProgress, exclude_from_sync = true },
        [1024262] = { id = "run_10", class = TT.AchievementNotification, condition = show_achievement and hard_and_above },
        [100658] = { id = "run_8", special_function = SF.IncreaseProgress },
        [100111] = { id = "run_10", special_function = SF.SetAchievementFailed },
        [100664] = { id = "run_10", special_function = SF.SetAchievementComplete },

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
elseif level_id == "glace" then -- Green Bridge
    triggers = {
        [102368] = { id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333 },
        [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
        [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [102370] = { id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732 },

        [101732] = { special_function = SF.Trigger, data = { 1017321, 1017322 } },
        [1017321] = { id = "glace_9", status = "ready", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },
        [1017322] = { max = 6, id = "glace_10", class = TT.AchievementProgress, exclude_from_sync = true },
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
        triggers[102368].synced = { class = TT.Pausable }
        triggers[102368].special_function = SF.AddTrackerIfDoesNotExist
        EHI:AddSyncTrigger(102368, triggers[102368])
        triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
        triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
        triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
        triggers[102370].time = 35
        triggers[102370].random_time = 10
        triggers[102370].delay_only = true
        triggers[102370].class = "EHIInaccuratePausableTracker"
        triggers[102370].synced = { class = TT.Pausable }
        triggers[102370].special_function = SF.AddTrackerIfDoesNotExist
        EHI:AddSyncTrigger(102370, triggers[102370])
        triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    end
elseif level_id == "wwh" then -- Alaskan Deal
    triggers = {
        [100946] = { max = 4, id = "wwh_10", class = TT.AchievementProgress },
        [100944] = { id = "wwh_9", class = TT.AchievementNotification, contidition = show_achievement and ovk_and_up },
        [101250] = { id = "wwh_9", special_function = SF.SetAchievementFailed },
        [100082] = { id = "wwh_9", special_function = SF.SetAchievementComplete },
        [100322] = { time = 120, id = "Fuel", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100323] = { id = "Fuel", special_function = SF.PauseTracker },
        [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
    }
elseif level_id == "dah" then -- Diamond Heist
    local heli_delay = 26 + 6
    local element_sync_triggers =
    {
        [103569] = { time = 25, id = "CFOFall", icons = { "hostage", "pd2_goto" }, hook_element = 100438 }
    }
    triggers = {
        [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, "pd2_goto" } },

        [101343] = { time = 30, id = "KeypadReset", icons = { "restarter" } },

        [102259] = { id = "dah_8", special_function = SF.SetAchievementComplete },

        [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = HeliEscapeNoLoot },
        [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = HeliEscapeNoLoot },

        [102261] = { id = "dah_8", special_function = SF.IncreaseProgress }
    }
    if client then
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "hvh" then -- Cursed Kill Room
    triggers = {
        [100212] = { max = 6, id = "cac_21", class = TT.AchievementProgress, condition = show_achievement and very_hard_and_up, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
        [100224] = { id = "cac_21", special_function = SF.IncreaseProgress },
        [100181] = { special_function = SF.CustomCode, f = function()
            EHI:CallCallback("hvhCleanUp")
        end}
    }
elseif level_id == "rvd1" then -- Reservoir Dogs Heist Day 2
    local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, "pd2_goto" }
    triggers = {
        [100107] = { id = "rvd_9", class = TT.AchievementNotification, exclude_from_sync = true },
        [100839] = { id = "rvd_9", special_function = SF.SetAchievementFailed },
        [100869] = { id = "rvd_9", special_function = SF.SetAchievementComplete },

        [100179] = { time = 1 + 9.5 + 11 + 1 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning },

        [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = CarEscape },
        [100057] = { time = 60, id = "rvd_10", class = TT.Achievement, condition = dw_and_above and show_achievement, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
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
    local element_sync_triggers =
    {
        [101374] = { id = "VaultTeargas", icons = { Icon.Teargas }, hook_element = 101377 }
    }
    triggers = {
        [100903] = { time = 120, id = "LiquidNitrogen", icons = { "equipment_liquid_nitrogen_canister" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 } },
        [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = HeliDropC4 },

        [100699] = { time = 8 + 25 + 13, id = "ObjectiveWait", icons = { "faster" } },
    }
    if client then
        triggers[101366] = { time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas } }
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [101136] = { max = 12, id = "brb_8", icons = { "C_Locke_H_BrooklynBank_AlltheGold" }, remove_after_reaching_target = false, class = TT.AchievementProgress, condition = show_achievement and very_hard_and_up, exclude_from_sync = true },
        [100128] = { time = 38, id = "WinchDropTrainA", icons = { "equipment_winch_hook", "pd2_goto" } },
        [100164] = { time = 38, id = "WinchDropTrainB", icons = { "equipment_winch_hook", "pd2_goto" } },

        [100654] = { time = 120, id = "Winch", icons = { "equipment_winch_hook" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100655] = { id = "Winch", special_function = SF.PauseTracker },
        [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
        [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { "equipment_glasscutter" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker },

        [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } },

        [100275] = { time = 20, id = "Van", icons = CarEscape }

        -- Will fix that later when OVK pulls out their head from their asses and fix the elements
        --[100837] = { time = 50, delay = 10, id = "VaultThermite", icons = { "pd2_fire" }, class = "EHIInaccurateTracker", trigger_at = 4, trigger_count = 0 }
    }
elseif level_id == "tag" then -- Breakin' Feds
    local time = 10 -- Normal
    if EHI:IsBetweenDifficulties("hard", "very_hard") then
        -- Hard + Very Hard
        time = 15
    elseif EHI:IsDifficulty("overkill") then
        -- OVERKILL
        time = 20
    elseif EHI:IsBetweenDifficulties("mayhem", "death_wish") then
        -- Mayhem + Death Wish
        time = 30
    elseif EHI:IsDifficulty("death_sentence") then
        -- Death Sentence
        time = 40
    end
    triggers = {
        [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
        [1001071] = { id = "tag_9", class = TT.AchievementNotification, contidition = show_achievement and ovk_and_up, exclude_from_sync = true },
        [1001072] = { id = "tag_10", status = "ready", class = TT.AchievementNotification, exclude_from_sync = true },
        [101335] = { time = 7, id = "C4BasementWall", icons = { "pd2_c4" } },
        [101968] = { time = 10, id = "LureDelay", icons = { "faster" } },

        [101282] = { time = 5 + time, id = "KeypadReset", icons = { "faster" } },

        [100609] = { id = "tag_9", special_function = SF.SetAchievementComplete },
        [100617] = { id = "tag_9", special_function = SF.SetAchievementFailed }
    }
    for _, index in pairs({13350, 14450, 14950, 15450, 15950, 16450, 16950, 17450}) do
        triggers[EHI:GetInstanceElementID(100176, index)] = { time = 30, id = "KeypadRebootECM", icons = { "restarter" } }
    end
    for _, index in pairs({4550, 5450}) do
        triggers[EHI:GetInstanceElementID(100319, index)] = { id = "tag_10", special_function = SF.SetAchievementFailed }
        triggers[EHI:GetInstanceElementID(100321, index)] = { id = "tag_10", status = "ok", special_function = SF.SetAchievementStatus }
        triggers[EHI:GetInstanceElementID(100282, index)] = { id = "tag_10", special_function = SF.SetAchievementComplete }
    end
elseif level_id == "des" then -- Henry's Rock
    triggers = {
        [103391] = { id = "uno_5", special_function = SF.IncreaseProgress },
        [103395] = { id = "uno_5", special_function = SF.SetAchievementFailed },

        [103025] = { time = 3, id = "des_11", class = TT.Achievement },
        [102822] = { id = "des_11", special_function = SF.SetAchievementComplete },
        [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

        [100296] = { max = 2, id = "uno_5", class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
        [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = HeliEscape },
        -- 60s delay after flare has been placed
        -- 25s to land
        -- 3s to open the heli doors

        [102593] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
        [101217] = { time = 30, id = "ChemSetInterrupted", icons = { "restarter" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
        [102595] = { time = 30, id = "ChemSetCooking", icons = { "pd2_defend" } },

        [102009] = { time = 60, id = "Crane", icons = { "equipment_winch_hook" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [101702] = { id = "Crane", special_function = SF.PauseTracker }
    }
    if client then
        triggers[100564] = { time = 25 + 3, id = "EscapeHeli", icons = HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
        -- Not worth adding the 3s delay here
    end
elseif level_id == "sah" then -- Shacklethorne Auction
    triggers = {
        [100107] = { time = 300, id = "sah_9", class = TT.Achievement, condition = ovk_and_up and show_achievement, exclude_from_sync = true },

        [100643] = { time = 30, id = "CrowdAlert", icons = { "enemy" }, class = TT.Warning },
        [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

        [101725] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = HeliEscape }, -- West
        [101845] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = HeliEscape } -- East
    }
elseif level_id == "bph" then -- Hell's Island
    triggers = {
        [100109] = { max = (very_hard_and_below and 30 or 40), id = "EnemyDeathShowers", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
        [101433] = { id = "EnemyDeathShowers", special_function = SF.RemoveTracker },

        [101742] = { max = 3, id = "bph_10", class = TT.AchievementProgress, special_function = SF.RemoveTriggerAndShowAchievement, condition = ovk_and_up and show_achievement },
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
elseif level_id == "nmh" then -- No Mercy
    triggers = {
        [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
        [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
        [103456] = { time = 5, id = "nmh_11", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievementFromStart, condition = hard_and_above and show_achievement, exclude_from_sync = true },
        [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
        [102619] = { id = "EscapeElevator", special_function = SF.NMH_LowerFloor },

        [103460] = { id = "nmh_11", special_function = SF.SetAchievementComplete },

        [103443] = { id = "EscapeElevator", icons = { "pd2_door" }, class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists },
        [104072] = { id = "EscapeElevator", special_function = SF.UnpauseTracker },

        [102682] = { time = 20, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
        [102683] = { id = "AnswerPhone", special_function = SF.RemoveTracker },

        [103743] = { time = 25, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },
        [103744] = { time = 35, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },
        [103746] = { time = 15, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },

        [103745] = { time = 10, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },
        [103749] = { time = 19, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },
        [103750] = { time = 30, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },

        [102992] = { chance = 1, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance },
        [103013] = { amount = 1, id = "CorrectPaperChance", special_function = SF.IncreaseChance },
        [103006] = { chance = 100, id = "CorrectPaperChance", special_function = SF.SetChanceWhenTrackerExists },
        [104752] = { id = "CorrectPaperChance", special_function = SF.RemoveTracker }
    }
    local outcome =
    {
        [100013] = { time = 25 + 40/30 + 15, random_time = 5, id = "VialFail", icons = { "equipment_bloodvial", "restarter" } },
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
    EHI:AddOnAlarmCallback(function()
        local remove = {
            "AnswerPhone",
            "Patrol",
            "ExtraCivilianElevatorLeft",
            "ExtraCivilianElevatorRight",
            "CorrectPaperChance"
        }
        for _, tracker in pairs(remove) do
            managers.ehi:RemoveTracker(tracker)
        end
    end)
elseif level_id == "vit" then -- The White House
    local element_sync_triggers =
    {
        -- Time before the tear gas is removed
        [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073 }
    }
    triggers = {
        [102949] = { time = 17, id = "HeliDropWait", icons = { "faster" } },
        [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance", trigger = 100808 } },
        [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = very_hard_and_up, class = TT.Chance },
        -- Disabled in the mission script
        --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
        [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
        [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },
        [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning },

        [102335] = { time = 60, id = "Thermite", icons = { "pd2_fire" } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
        [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = { Icon.Heli, "pd2_escape" } } -- 30s delay + 26s escape zone delay
    }
    if client then
        triggers[102073] = { time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist }
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "mex" then -- Border Crossing
    triggers = {
        [100107] = { max = 4, id = "mex_9", class = TT.AchievementProgress },
        [101983] = { time = 15, id = "C4Trap", icons = { "pd2_c4" }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
        [101722] = { id = "C4Trap", special_function = SF.RemoveTracker },

        [102685] = { special_function = SF.Trigger, data = { 1026851, 1026852 } },
        [1026851] = { id = "Refueling", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.MEX_CheckIfLoud, data = { yes = 121, no = 91 } },
        [1026852] = { special_function = SF.RemoveTriggers, data = { 102685 } },
        [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
        [102684] = { id = "Refueling", special_function = SF.PauseTracker }
    }
    for i = 101502, 101509, 1 do
        triggers[i] = { id = "mex_9", special_function = SF.IncreaseProgress }
    end
elseif level_id == "mex_cooking" then -- Border Crystals
    local element_sync_triggers =
    {
        [103575] = { id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, hook_element = 103573 },
        [103576] = { id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, hook_element = 103574 },
        [EHI:GetInstanceElementID(100078, 55850)] = { id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, hook_element = EHI:GetInstanceElementID(100173, 55850) },
        [EHI:GetInstanceElementID(100078, 56850)] = { id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, hook_element = EHI:GetInstanceElementID(100173, 56850) },
        [EHI:GetInstanceElementID(100157, 55850)] = { id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, hook_element = EHI:GetInstanceElementID(100174, 55850) },
        [EHI:GetInstanceElementID(100157, 56850)] = { id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, hook_element = EHI:GetInstanceElementID(100174, 56850) }
    }
    if client then
        local cooking_start = { time = 30, delay = 10, id = "CookingStartDelay", icons = { "pd2_methlab", "faster" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
        local meth_ready = { time = 10, delay = 5, id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
        local next_ingredient = { time = 40, delay = 5, id = "NextIngredient", icons = { "pd2_methlab", "restarter" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
        triggers = {
            -- Also handles next ingredient when meth is picked up
            [EHI:GetInstanceElementID(100056, 55850)] = { time = 15, id = "NextIngredient", icons = { Icon.Methlab, "restarter" }, special_function = SF.AddTrackerIfDoesNotExist },
            [EHI:GetInstanceElementID(100056, 56850)] = { time = 15, id = "NextIngredient", icons = { Icon.Methlab, "restarter" }, special_function = SF.AddTrackerIfDoesNotExist },

            [103573] = cooking_start,
            [103574] = cooking_start,

            [EHI:GetInstanceElementID(100173, 55850)] = next_ingredient,
            [EHI:GetInstanceElementID(100173, 56850)] = next_ingredient,
            [EHI:GetInstanceElementID(100174, 55850)] = meth_ready,
            [EHI:GetInstanceElementID(100174, 56850)] = meth_ready
        }
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "bex" then -- San Martín Bank
    local element_sync_triggers =
    {
        [102290] = { id = "VaultGas", icons = { Icon.Teargas }, hook_element = 102157 }
    }
    local hack_start = EHI:GetInstanceElementID(100015, 20450)
    triggers = {
        [EHI:GetInstanceElementID(100108, 35450)] = { time = 4.8, id = "SuprisePull", icons = { Icon.Wait } },
        [103919] = { time = 25 + 1 + 13, random_time = 5, id = "Van", icons = CarEscape },
        [100840] = { time = 1 + 13, id = "Van", icons = CarEscape, special_function = SF.SetTrackerAccurate },

        [101818] = { time = 50 + 9.3, random_time = 30, id = "HeliDropLance", icons = HeliDropDrill, class = "EHIInaccurateTracker" },
        [hack_start] = { id = "ServerHack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = EHI:GetInstanceElementID(100014, 20450) },
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
        triggers[hack_start].synced = { class = TT.Pausable }
        EHI:AddSyncTrigger(hack_start, triggers[hack_start])
        triggers[EHI:GetInstanceElementID(100011, 20450)] = { id = "ServerHack", special_function = SF.RemoveTracker }
        triggers[102157] = { time = 60, random_time = 15, id = "VaultGas", icons = { "teargas" }, class = "EHIInaccurateTracker", special_function = SF.AddTrackerIfDoesNotExist }
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
elseif level_id == "pex" then -- Breakfast in Tijuana
    triggers = {
        [101392] = { time = 120, id = "FireEvidence", icons = { "pd2_fire" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },

        [103735] = { id = "pex_11", special_function = SF.IncreaseProgress },

        [101460] = { time = 18, id = "DoorBreach", icons = { "pd2_door" } },

        [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" } }
    }
    for _, index in ipairs({ 5300, 6300, 7300 }) do
        triggers[EHI:GetInstanceElementID(100025, index)] = { time = 120, id = "ArmoryHack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
        triggers[EHI:GetInstanceElementID(100026, index)] = { id = "ArmoryHack", special_function = SF.PauseTracker }
    end
    if client then
        triggers[100233] = { time = 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" }, special_function = SF.AddTrackerIfDoesNotExist }
    end
    DisableWaypoints =
    {
        -- pex_evidence_room_1
        [EHI:GetInstanceElementID(100080, 13300)] = true, -- Defend
        [EHI:GetInstanceElementID(100084, 13300)] = true, -- Fix
        -- pex_evidence_room_2
        [EHI:GetInstanceElementID(100072, 14300)] = true, -- Defend
        [EHI:GetInstanceElementID(100079, 14300)] = true -- Fix
        -- Why they use 2 instances for one objective ???
    }
elseif level_id == "" then -- Fourth and last heist in City of Gold campaign
elseif level_id == "Triad Takedown Yacht Heist" then -- Custom Heist
    local bag_delay = 24.700000762939 -- I'm not even kidding
    triggers = {
        [100285] = { time = 125 + bag_delay, id = "HeliDrillDrop", icons = HeliDropDrill },
        [100286] = { time = 130 + bag_delay, id = "HeliDrillDrop", icons = HeliDropDrill },
        [100297] = { time = 65 + 23, id = "HeliEscape", icons = HeliEscape }
    }
elseif level_id == "ttr_yct_lvl" then -- Triad Takedown Remastered Custom Heist
    local escape_delay = 24
    triggers = {
        [100518] = { time = 60 + escape_delay, id = "EscapeHeliSlow", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [100519] = { time = escape_delay, id = "EscapeHeliFast", icons = HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
        [100182] = { time = 54, id = "HeliDropC4", icons = HeliDropC4 }
    }
elseif level_id == "ruswl" then -- Scorched Earth Custom Heist
    local obj_delay = { time = 30, id = "ObjectiveDelay", icons = { "faster" } }
    triggers = {
        [100404] = obj_delay,
        [100405] = obj_delay,
        [101181] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
        [101182] = { time = 30, id = "ChemSetCooking", icons = { "pd2_methlab" } },
        [101088] = { time = 84, id = "HeliEscape", icons = HeliEscapeNoLoot }
    }
elseif level_id == "rusdl" then -- Cold Stones Custom Heist
    triggers = {
        [100114] = { time = 17 * 18, id = "Thermite", icons = { "pd2_fire" } },
        [100138] = { time = 20, id = "ObjectiveWait", icons = { "faster" } }
    }
elseif level_id == "crimepunishlvl" then -- Crime and Punishment Custom Heist
    triggers = {
        [100157] = { time = 60 + 43, id = "EscapeHeli", icons = HeliEscapeNoLoot, class = TT.Pausable },
        [101137] = { time = 43, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
        [101144] = { time = 43, id = "EscapeHeli", icons = HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists }
    }
elseif level_id == "RogueCompany" then -- Yaeger - Rogue Company Custom Heist
    local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { "faster" } }
    triggers = {
        --[100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.Achievement, condition = show_achievement and ovk_and_up }
        --[100756] = { id = "RC_Achieve_speedrun", special_function = SF.SetAchievementComplete },
        -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
        [100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.AchievementUnlock, condition = show_achievement and ovk_and_up },
        [100271] = ObjectiveWait,
        [100269] = ObjectiveWait
    }
    tweak_data.hud_icons.ehi_rc_6mins = { texture = "guis/achievements/rc_6mins", texture_rect = nil }
elseif level_id == "hunter_party" then -- Hunter and Hunted (Party) Day 1
    local escape_fly_in = 30 + 35 + 24
    local fire_wait = { time = 20, id = "FireWait", icons = { "pd2_fire" } }
    triggers = {
        [100045] = { id = "hunter_party", status = "ok", icons = { "ehi_hunter_no_civie_kills" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, special_function = SF.ShowAchievementFromStart },
        [100679] = { id = "hunter_party", special_function = SF.SetAchievementFailed },
        [100201] = { time = 99, id = "AmbushWait", icons = { "faster" } },
        [100218] = fire_wait,
        [100364] = fire_wait,
        [100417] = { time = 78 + 25 + escape_fly_in, id = "EscapeHeli", icons = HeliEscapeNoLoot, class = TT.Pausable },
        [100422] = { time = escape_fly_in, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
        [100423] = { time = escape_fly_in, id = "EscapeHeli", icons = HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable }
    }
    tweak_data.hud_icons.ehi_hunter_no_civie_kills = { texture = "textures/hunter_party", texture_rect = nil }
elseif level_id == "hunter_departure" then -- Hunter and Hunted (Departure) Day 2
    local repair = { time = 90, id = "RepairWait", icons = { "pd2_fix" } }
    triggers = {
        [100132] = { max = 21, id = "hunter_loot", icons = { "ehi_hunter_departure_all_loot" }, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart, condition = show_achievement and ovk_and_up },
        [100416] = { id = "hunter_loot", special_function = SF.IncreaseProgress },
        [100030] = repair,
        [100065] = repair,
        [100080] = repair,
        [100123] = repair
    }
    tweak_data.hud_icons.ehi_hunter_departure_all_loot = { texture = "textures/hunter_loot", texture_rect = nil }
elseif level_id == "hunter_fall" then -- Hunter and Hunted (Fall) Day 3
    triggers = {
        [100077] = { time = 62, id = "hunter_fall", icons = { "ehi_hunter_fall_60s" }, class = TT.Achievement, special_function = SF.ShowAchievementFromStart }
    }
    tweak_data.hud_icons.ehi_hunter_fall_60s = { texture = "textures/hunter_speedrun", texture_rect = nil }
elseif level_id == "constantine_harbor_lvl" then -- Harboring a Grudge
    local interact = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } }
    local element_sync_triggers = {}
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, 7750)
        element_sync_triggers[element_id] = EHI:DeepClone(interact)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, 7750)
    end
    local escape_delay = 24 + 1
    triggers = {
        [100246] = { time = 60 + escape_delay, id = "HeliEscapeSlow", icons = HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled },
        [100247] = { time = escape_delay, id = "HeliEscapeFast", icons = HeliEscapeNoLoot, special_function = SF.ExecuteIfElementIsEnabled }
    }
    triggers[EHI:GetInstanceElementID(100118, 7750)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, "faster" } }
    triggers[EHI:GetInstanceElementID(100152, 7750)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } }
    if client then
        local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
        triggers[EHI:GetInstanceElementID(100149, 7750)] = random_time
        triggers[EHI:GetInstanceElementID(100150, 7750)] = random_time
        triggers[EHI:GetInstanceElementID(100184, 7750)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
        EHI:SetSyncTriggers(element_sync_triggers)
    else
        EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
    end
end

for id, data in pairs(triggers) do
    -- Mark every tracker, that has random time, as inaccurate
    if data.random_time then
        if not data.class then
            triggers[id].class = TT.Inaccurate
        elseif data.class ~= "EHIInaccuratePausableTracker" and data.class == TT.Warning then
            triggers[id].class = TT.InaccurateWarning
        end
    end
    -- Fill the rest table properties for Achievement trackers
    if data.class and AchievementTT[data.class] then
        if not data.special_function then
            triggers[id].special_function = SF.ShowAchievement
        end
        if data.condition == nil then
            triggers[id].condition = show_achievement
        end
        if not data.icons then
            triggers[id].icons = EHI:GetAchievementIcon(triggers[id].id)
        end
    end
    -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
    if data.special_function == SF.ShowWaypoint then
        triggers[id].data.distance = true
        triggers[id].data.state = "sneak_present"
        triggers[id].data.present_timer = 0
        triggers[id].data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
    end
end

EHI:AddTriggers(triggers, trigger_id_all, trigger_icon_all)
EHI:DisableWaypoints(DisableWaypoints)