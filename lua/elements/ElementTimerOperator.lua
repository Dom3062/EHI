
if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementTimerOperator then -- Don't hook twice, pls
    return
else
    EHI._hooks.ElementTimerOperator = true
end

core:module("CoreElementTimer")

local function deep_clone(o)
	if type(o) == "userdata" then
		return o
	end

	local res = {}

	setmetatable(res, getmetatable(o))

	for k, v in pairs(o) do
		if type(v) == "table" then
			res[k] = deep_clone(v)
		else
			res[k] = v
		end
	end

	return res
end

local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local difficulty_index = EHI:DifficultyToIndex(difficulty)
local mayhem_and_up = difficulty_index >= 4
local very_hard_and_below = difficulty_index <= 2
local SF = EHI:GetSpecialFunctions()
SF.GetTimeAccurate = 91
SF.UnpauseTrackerIfExistsAccurate = 92
SF.DisableTriggerAndExecute = 93
SF.UnpauseOrSetTimeByPreplanning = 94
SF.PauseTrackerAndAddNewTracker = 95
SF.SetTimeByElement = 96
SF.UnpauseOrSetTimeByElement = 97
SF.CheckIfLoud = 98 -- Custom special function
SF.CustomCondition = 99
local SFF =
{
    PAL_Pause = 101,
    PAL_Unpause = 102,
    PAL_PauseMoney = 103,
    PAL_PausePaper = 104,
    PAL_PauseInk = 105,
    PAL_ResetMoneyTimer = 106,
    PAL_ResetPaperTimer = 107,
    PAL_ResetInkTimer = 108
}

local triggers = {}
local _cache = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = nil
if level_id == "mia_1" then -- Hotline Miami Day 1
    local delay = 1.5
    triggers =
    {
        [106013] = { time = (very_hard_and_below and 40 or 60), id = "Truck", icons = { "pd2_car" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [106017] = { id = "Truck", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100038, 1300)] = { time = 90 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100039, 1300)] = { time = 120 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100040, 1300)] = { time = 180 + delay, id = "reader", icons = { "wp_hack" }, class = "EHIPausableTracker" },
        [EHI:GetInstanceElementID(100045, 1300)] = { id = "reader", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100051, 1300)] = { id = "reader", special_function = SF.UnpauseTracker }
    }
elseif level_id == "arena" then -- The Alesso Heist
    triggers = {
        [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { "faster" } },
        [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { "pd2_generic_interact" }, class = "EHIWarningTracker" }
    }
elseif level_id == "rat" then -- Cook Off
    local van_delay = 47 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0), 31s before the timer gets activated; 10s before the timer is started; total 47s; Mayhem difficulty and above
    local van_delay_ovk = 6 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0); OVERKILL difficulty and below
    local heli_delay = 19
    local heli_icon = { "heli", "pd2_methlab", "pd2_goto" }
    local van_icon = { "pd2_car", "pd2_escape", "pd2_lootdrop", "faster" }
    triggers = {
        [102167] = { time = 60 + heli_delay, id = "HeliMeth", icons = heli_icon },
        [102168] = { time = 90 + heli_delay, id = "HeliMeth", icons = heli_icon },

        [102220] = { time = 60 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102219] = { time = 45 + van_delay, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102229] = { time = 90 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102235] = { time = 100 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102236] = { time = 50 + van_delay, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102237] = { time = 80 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
        [102238] = { time = 70 + van_delay_ovk, id = "VanStayDelay", icons = van_icon, class = "EHIWarningTracker" },
    }
    if very_hard_and_below then
        triggers[102175] = { time = 120 + heli_delay, id = "HeliMeth", icons = heli_icon }
    end
elseif level_id == "watchdogs_2_day" or level_id == "watchdogs_2" then -- Watchdogs Day 2
    local anim_delay = 450/30
    local boat_icon = { "boat", "pd2_lootdrop" }
    triggers = {
        [101129] = { time = 180 + anim_delay, special_function = SF.AddToCache },
        [101134] = { time = 150 + anim_delay, special_function = SF.AddToCache },
        [101144] = { time = 130 + anim_delay, special_function = SF.AddToCache },

        [101148] = { icons = boat_icon, special_function = SF.GetFromCache },
        [101149] = { icons = boat_icon, special_function = SF.GetFromCache },
        [101150] = { icons = boat_icon, special_function = SF.GetFromCache },

        [1011480] = { random_time = { low = 130 + anim_delay, high = 180 + anim_delay }, id = "BoatLootDropReturnRandom", icons = boat_icon, class = "EHIInaccurateTracker" }
    }
    trigger_id_all = "BoatLootDropReturn"
elseif level_id == "peta2" then -- Goat Simulator Heist Day 2
    triggers = {
        [101720] = { time = 80, id = "Bridge", icons = { "faster" }, special_function = SF.UnpauseTrackerIfExists, class = "EHIPausableTracker" },
        [101718] = { id = "Bridge", special_function = SF.PauseTracker }
    }
elseif level_id == "friend" then -- Scarface Mansion
    triggers = {
        [102814] = { time = 180, id = "Safe", icons = { "pd2_defend" }, special_function = SF.UnpauseTrackerIfExists, class = "EHIPausableTracker" },
        [102815] = { id = "Safe", special_function = SF.PauseTracker }
    }
elseif level_id == "roberts" then -- GO Bank
    local start_delay = 1
    triggers = {
        [101959] = { time = 90 + start_delay, id = "Plane", icons = { "heli", "faster" } },
        [101960] = { time = 120 + start_delay, id = "Plane", icons = { "heli", "faster" } },
        [101961] = { time = 150 + start_delay, id = "Plane", icons = { "heli", "faster" } }
    }
elseif level_id == "cane" then -- Santa's Workshop
    triggers = {
        [EHI:GetInstanceElementID(100024, 0)] = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } },
        [EHI:GetInstanceElementID(100024, 120)] = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } },
        [EHI:GetInstanceElementID(100024, 240)] = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } },
        [EHI:GetInstanceElementID(100024, 360)] = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } },
        [EHI:GetInstanceElementID(100024, 480)] = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } },

        [EHI:GetInstanceElementID(100022, 0)] = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = "EHIWarningTracker" },
        [EHI:GetInstanceElementID(100022, 120)] = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = "EHIWarningTracker" },
        [EHI:GetInstanceElementID(100022, 240)] = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = "EHIWarningTracker" },
        [EHI:GetInstanceElementID(100022, 360)] = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = "EHIWarningTracker" },
        [EHI:GetInstanceElementID(100022, 480)] = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = "EHIWarningTracker" }
    }
elseif level_id == "pal" then -- Counterfeit
    triggers = {
        [102301] = { time = 15, id = "Trap", icons = { "pd2_c4" }, class = "EHIWarningTracker" },

        [101230] = { time = 120, id = "Water", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101231] = { id = "Water", special_function = SF.PauseTracker },

        --[[[102747] = { id = "PAL", special_function = SFF.PAL_PausePaper },
        [102748] = { id = "PAL", special_function = SFF.PAL_PauseInk },]]
        [102749] = { id = "PAL", special_function = SF.PauseTracker },

        [102738] = { id = "PAL", special_function = SF.PauseTracker },
        [102744] = { id = "PAL", special_function = SF.UnpauseTracker }
    }
elseif level_id == "spa" then -- Brooklyn 10-10
    triggers = {
        [100681] = { time = 60, id = "CharonPickLock", icons = { "pd2_generic_interact" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },
        [101202] = { time = 15, id = "Escape", icons = { "pd2_car", "pd2_escape", "pd2_lootdrop" } },
        [101313] = { time = 75, id = "Escape", icons = { "pd2_car", "pd2_escape", "pd2_lootdrop" } },
        [100549] = { time = 20, id = "ObjectiveWait", icons = { "faster" } }
    }
elseif level_id == "sah" then -- Shacklethorne Auction
    triggers = {
        [100643] = { time = 30, id = "CrowdAlert", icons = { "enemy" }, class = "EHIWarningTracker" },
        [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker }
    }
elseif level_id == "brb" then -- Brooklyn Bank
    triggers = {
        [100654] = { time = 120, id = "Winch", icons = { "equipment_winch_hook" }, class = "EHIPausableTracker" },
        [100655] = { id = "Winch", special_function = SF.PauseTracker },
        [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
        [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { "equipment_glasscutter" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker }
    }
elseif level_id == "crojob3" or level_id == "crojob3_night" then -- The Bomb: Forest
    local heli_anim = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
    triggers = {
        [102825] = { id = "WaterFill", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.SetTimeByElement, data = { id = 104301, yes = 160, no = 300 } },
        [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
        [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

        [EHI:GetInstanceElementID(100032, 100)] = { time = 240, id = "HeliWaterFill", icons = { "heli", "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100032, 150)] = { time = 240, id = "HeliWaterFill", icons = { "heli", "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100032, 250)] = { time = 240, id = "HeliWaterFill", icons = { "heli", "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100032, 300)] = { time = 240, id = "HeliWaterFill", icons = { "heli", "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100030, 100)] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100030, 150)] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100030, 250)] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100030, 300)] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100037, 100)] = { id = "HeliWaterFill", special_function = SF.PauseTrackerAndAddNewTracker, data = { fake_id = 1 } },
        [EHI:GetInstanceElementID(100037, 150)] = { id = "HeliWaterFill", special_function = SF.PauseTrackerAndAddNewTracker, data = { fake_id = 2 } },
        [EHI:GetInstanceElementID(100037, 250)] = { id = "HeliWaterFill", special_function = SF.PauseTrackerAndAddNewTracker, data = { fake_id = 3 } },
        [EHI:GetInstanceElementID(100037, 300)] = { id = "HeliWaterFill", special_function = SF.PauseTrackerAndAddNewTracker, data = { fake_id = 4 } },

        [1] = { id = "HeliWaterReset", icons = { "heli", "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByElement, data = { id = EHI:GetInstanceElementID(100047, 100), yes = 62 + heli_anim, no = 122 + heli_anim } },
        [2] = { id = "HeliWaterReset", icons = { "heli", "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByElement, data = { id = EHI:GetInstanceElementID(100047, 150), yes = 62 + heli_anim, no = 122 + heli_anim } },
        [3] = { id = "HeliWaterReset", icons = { "heli", "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByElement, data = { id = EHI:GetInstanceElementID(100047, 250), yes = 62 + heli_anim, no = 122 + heli_anim } },
        [4] = { id = "HeliWaterReset", icons = { "heli", "pd2_water_tap", "restarter" }, special_function = SF.SetTimeByElement, data = { id = EHI:GetInstanceElementID(100047, 300), yes = 62 + heli_anim, no = 122 + heli_anim } },

        [103461] = { time = 5, id = "cow_3", icons = { "C_Butcher_H_BombForest_Beaver" }, class = "EHIAchievementTracker", special_function = SF.RemoveTriggerWhenExecuted }
    }
elseif level_id == "kenaz" then -- Golden Grin Casino
    triggers = {
        [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { "equipment_winch_hook", "pd2_drill", "pd2_goto" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
        [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

        -- Water during drilling
        [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByElement, data = { id = EHI:GetInstanceElementID(100229, 37575), yes = 120, no = 60, cache_id = "Water1" } },
        [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseOrSetTimeByElement, data = { id = EHI:GetInstanceElementID(100230, 37575), yes = 120, no = 60, cache_id = "Water2" } },
        [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

        -- Skylight Hack
        [EHI:GetInstanceElementID(100018, 29650)] = { time = 30, id = "SkylightHack", icons = { "wp_hack" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100037, 29650)] = { id = "SkylightHack", special_function = SF.PauseTracker }
    }
elseif level_id == "glace" then -- Green Bridge
    triggers = {
        [102368] = { id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = "EHIPausableTracker", special_function = SF.GetTimeAccurate, element = 102333 },
        [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
        [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
        [102370] = { time = 45, id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = "EHIPausableTracker" }
    }
    if Network:is_client() then
        triggers[102368].time = 120
        triggers[102368].random_time = { low = 0, high = 10 }
        triggers[102368].class = "EHIInaccuratePausableTracker"
        EHI:AddSyncTrigger(102368, triggers[102368])
    end
elseif level_id == "kosugi" then -- Shadow Raid
    triggers = {
        [100955] = { time = 10, id = "KeycardLeft", icons = { "equipment_bank_manager_key" }, class = "EHIWarningTracker", special_function = SF.DisableTriggerAndExecute, data = { id = 100957 } },
        [100957] = { time = 10, id = "KeycardRight", icons = { "equipment_bank_manager_key" }, class = "EHIWarningTracker", special_function = SF.DisableTriggerAndExecute, data = { id = 100955 } },
        [100967] = { special_function = SF.RemoveTrackers, data = { "KeycardLeft", "KeycardRight" } }
    }
elseif level_id == "born" then -- The Biker Heist Day 1
    trigger_icon_all = { "pd2_defend" }
    triggers = {
        [101034] = { id = "MikeDefendTruck", class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033 },
        [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
        [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

        [101535] = { id = "MikeDefendGarage", class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532 },
        [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
        [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker }
    }
    if Network:is_client() then
        triggers[101034].time = 80
        triggers[101034].random_time = { low = 0, high = 10 }
        triggers[101034].special_function = SF.UnpauseTrackerIfExists
        triggers[101034].class = "EHIInaccuratePausableTracker"
        EHI:AddSyncTrigger(101034, triggers[101034])
        triggers[101535].time = 90
        triggers[101535].random_time = { low = 0, high = 30 }
        triggers[101535].special_function = SF.UnpauseTrackerIfExists
        triggers[101535].class = "EHIInaccuratePausableTracker"
        EHI:AddSyncTrigger(101535, triggers[101535])
    end
elseif level_id == "wwh" then -- Alaskan Deal
    triggers = {
        [100322] = { time = 120, id = "Fuel", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [100323] = { id = "Fuel", special_function = SF.PauseTracker }
    }
elseif level_id == "mex" then -- Border Crossing
    triggers = {
        [102685] = { id = "Refueling", icons = { "pd2_water_tap" }, class = "EHIPausableTracker", special_function = SF.CheckIfLoud, data = { yes = 121, no = 91 } },
        [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
        [102684] = { id = "Refueling", special_function = SF.PauseTracker },
    }
elseif level_id == "bex" then -- San Martín Bank
    triggers = {
        [101818] = { time = 50 + 9.3, random_time = { low = 0, high = 30 }, id = "HeliDropLance", icons = { "heli", "pd2_drill", "pd2_goto" }, class = "EHIInaccurateTracker" },
        [EHI:GetInstanceElementID(100015, 20450)] = { time = 90, random_time = { low = 0, high = 10 }, id = "ServerHack", icons = { "wp_hack", "pd2_defend" }, class = "EHIInaccuratePausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100016, 20450)] = { id = "ServerHack", special_function = SF.PauseTracker }
    }
elseif level_id == "pex" then -- Breakfast in Tijuana
    local armory_hack_start = { time = 120, id = "ArmoryHack", icons = { "wp_hack" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists }
    local armory_hack_pause = { id = "ArmoryHack", special_function = SF.PauseTracker }
    local start_index = { 5300, 6300, 7300 }
    triggers = {
        [101392] = { time = 120, id = "FireEvidence", icons = { "pd2_fire" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },
    }
    for _, index in ipairs(start_index) do
        local start = EHI:GetInstanceElementID(100025, index)
        triggers[start] = deep_clone(armory_hack_start)
        local pause = EHI:GetInstanceElementID(100026, index)
        triggers[pause] = deep_clone(armory_hack_pause)
    end
elseif level_id == "fex" then -- Buluc's Mansion
    triggers = {
        [EHI:GetInstanceElementID(100008, 8130)] = { time = 60, id = "ExplosivesTimer", icons = { "equipment_timer" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100007, 8130)] = { id = "ExplosivesTimer", special_function = SF.PauseTracker },
        [EHI:GetInstanceElementID(100008, 8630)] = { time = 60, id = "ExplosivesTimer", icons = { "equipment_timer" }, class = "EHIPausableTracker", special_function = SF.UnpauseTrackerIfExists },
        [EHI:GetInstanceElementID(100007, 8630)] = { id = "ExplosivesTimer", special_function = SF.PauseTracker }
    }
else
    return
end

local function GetTime(id)
    local full_time = triggers[id].time or 0
    full_time = full_time + (triggers[id].random_time and math.random(triggers[id].random_time.low, triggers[id].random_time.high) or 0)
    return full_time
end

local function CreateTrackerForReal(id, sync)
    managers.ehi:AddTracker({
        id = triggers[id].id or trigger_id_all,
        time = GetTime(id),
        chance = triggers[id].chance,
        max = triggers[id].max,
        icons = triggers[id].icons or trigger_icon_all,
        class = triggers[id].class
    })
    if sync then
        managers.ehi:Sync(id, GetTime(id))
    end
end

local function CreateTracker(id, sync)
    if triggers[id].condition ~= nil then
        if triggers[id].condition == true then
            CreateTrackerForReal(id, sync)
        end
    else
        CreateTrackerForReal(id, sync)
    end
end

local function Trigger(id)
    if triggers[id] then
        if triggers[id].special_function then
            local f = triggers[id].special_function
            if f == SF.AddMoney then
                managers.hud:AddMoney(triggers[id].id, triggers[id].amount)
            elseif f == SF.RemoveTracker then
                managers.hud:RemoveTracker(triggers[id].id)
            elseif f == SF.PauseTracker then
                managers.ehi:PauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTracker then
                managers.ehi:UnpauseTracker(triggers[id].id)
            elseif f == SF.UnpauseTrackerIfExists then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.GetTimeAccurate then
                if Network:is_server() then
                    local element = managers.mission:get_element_by_id(triggers[id].element)
                    if element then
                        local t = element._timer or 0
                        triggers[id].time = t
                        CreateTracker(id, true)
                    end
                else
                    CreateTracker(id)
                end
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    if Network:is_server() then
                        local element = managers.mission:get_element_by_id(triggers[id].element)
                        if element then
                            local t = element._timer or 0
                            triggers[id].time = t
                            CreateTracker(id, true)
                        end
                    else
                        CreateTracker(id)
                    end
                end
            elseif f == SF.ResetTrackerTimeWhenUnpaused then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.hud:ResetTrackerTimeAndUnpause(triggers[id].id)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if managers.ehi:TrackerDoesNotExist(triggers[id].id) then
                    CreateTracker(id)
                end
            elseif f == SF.CreateTrackerIfDoesNotExistOrAddDelayWhenUnpaused then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud:AddDelayToTrackerAndUnpause(trigger.id, trigger.delay_time)
                else
                    CreateTracker(id)
                end
            elseif f == SF.AddToCache then
                _cache[triggers[id].id or trigger_id_all] = triggers[id].time
            elseif f == SF.GetFromCache then -- Watchdogs Day 2
                local data = _cache[triggers[id].id or trigger_id_all]
                _cache[triggers[id].id or trigger_id_all] = nil
                if data then
                    triggers[id].time = data
                    CreateTracker(id)
                    triggers[id].time = nil
                else
                    EHI:Log("No time saved in cache for id " .. tostring(id) .. "! This happens when client connected after the time was saved.")
                    EHI:Log("Inaccurate timer created to represent the missing tracker.")
                    CreateTracker(1011480)
                end
            elseif f == SF.ReplaceTrackerWithTracker then
                managers.hud:RemoveTracker(triggers[id].data.id)
                triggers[triggers[id].data.trigger] = nil -- Removes trigger from the list, used in The White House
                CreateTracker(id)
            elseif f == SF.IncreaseChance then
                local trigger = triggers[id]
                managers.hud.ehi:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.CreateAnotherTrackerWithTracker then
                CreateTracker(id)
                CreateTracker(triggers[id].data.fake_id)
            elseif f == SF.ExecuteIfTrackerExists then
                local data = triggers[id].data
                if managers.ehi:TrackerExists(data.id) then
                    managers.hud:SetTime(triggers[id].id, triggers[id].time)
                    managers.hud:RemoveTracker(data.id)
                end
            elseif f == SF.SetChanceWhenTrackerExists then
                local trigger = triggers[id]
                if managers.ehi:TrackerExists(trigger.id) then
                    managers.hud.ehi:SetChance(trigger.id, trigger.chance)
                else
                    CreateTracker(id)
                end
            elseif f == SF.ExecuteWhenHUDManagerExists then
                if managers.hud then
                    CreateTracker(id)
                end
            elseif f == SF.PauseTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.ehi:PauseTracker(tracker)
                end
            elseif f == SF.UnpauseTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.ehi:UnpauseTracker(tracker)
                end
            elseif f == SF.AddTime then
                managers.hud:AddDelay(triggers[id].id, triggers[id].time)
                triggers[id] = nil
            elseif f == SF.CheckIfLoud then
                if managers.groupai then
                    if managers.groupai:state():whisper_mode() then -- Stealth
                        triggers[id].time = triggers[id].data.no
                    else -- Loud
                        triggers[id].time = triggers[id].data.yes
                    end
                    CreateTracker(id)
                end
            elseif f == SF.PauseTrackerAndAddNewTracker then
                managers.ehi:PauseTracker(triggers[id].id)
                Trigger(triggers[id].data.fake_id)
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    if managers.preplanning:IsAssetBought(triggers[id].data.id) then
                        triggers[id].time = triggers[id].data.yes
                    else
                        triggers[id].time = triggers[id].data.no
                    end
                    CreateTracker(id)
                end
            elseif f == SF.SetTimeByElement then
                if triggers[id].data.cache_id and _cache[triggers[id].data.cache_id] then
                    CreateTracker(id)
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
                        _cache[triggers[id].data.cache_id] = true
                    end
                    CreateTracker(id)
                end
            elseif f == SF.UnpauseOrSetTimeByElement then
                if managers.ehi:TrackerExists(triggers[id].id) then
                    managers.ehi:UnpauseTracker(triggers[id].id)
                else
                    if triggers[id].data.cache_id and _cache[triggers[id].data.cache_id] then
                        CreateTracker(id)
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
                            _cache[triggers[id].data.cache_id] = true
                        end
                        CreateTracker(id)
                    end
                end
            elseif f == SF.RemoveTriggerWhenExecuted then
                CreateTracker(id)
                triggers[id] = nil
            elseif f == SF.RemoveTrackers then
                for _, tracker in ipairs(triggers[id].data) do
                    managers.hud:RemoveTracker(tracker)
                end
            elseif f == SF.DisableTriggerAndExecute then
                triggers[triggers[id].data.id] = nil
                CreateTracker(id)
            elseif f == SFF.PAL_Pause then
                managers.ehi:CallFunction(triggers[id].id, "StopAll")
            elseif f == SFF.PAL_Unpause then
                managers.ehi:CallFunction(triggers[id].id, "ResumeAll")
            elseif f == SFF.PAL_PauseMoney then
                managers.ehi:CallFunction(triggers[id].id, "SetMoneyPaused", true)
            elseif f == SFF.PAL_PausePaper then
                managers.ehi:CallFunction(triggers[id].id, "SetPaperPaused", true)
            elseif f == SFF.PAL_PauseInk then
                managers.ehi:CallFunction(triggers[id].id, "SetInkPaused", true)
            elseif f == SFF.PAL_ResetMoneyTimer then
                managers.ehi:CallFunction(triggers[id].id, "ResetMoneyTime")
            elseif f == SFF.PAL_ResetPaperTimer then
                managers.ehi:CallFunction(triggers[id].id, "ResetPaperTime")
            elseif f == SFF.PAL_ResetInkTimer then
                managers.ehi:CallFunction(triggers[id].id, "ResetInkTime")
            end
        else
            CreateTracker(id)
        end
    end
end

local _f_client_on_executed = ElementTimerOperator.client_on_executed
function ElementTimerOperator:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementTimerOperator.on_executed
function ElementTimerOperator:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end