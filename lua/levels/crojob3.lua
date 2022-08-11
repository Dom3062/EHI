local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_anim = 35
local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
local thermite_right = { time = 86, id = "Thermite", icons = { Icon.Fire } }
local thermite_left_top = { time = 90, id = "Thermite", icons = { Icon.Fire } }
local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled }
local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled }
local triggers = {
    [101499] = { time = 155 + 25, id = "EscapeHeli", icons = Icon.HeliEscape },
    [101253] = heli_65,
    [101254] = heli_20,
    [101255] = heli_65,
    [101256] = heli_20,
    [101259] = heli_65,
    [101278] = heli_20,
    [101279] = heli_65,
    [101280] = heli_20,

    [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = Icon.HeliEscape },

    [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

    [102825] = { id = "WaterFill", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
    [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
    [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

    [1] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
    [2] = { id = "HeliWaterReset", icons = { Icon.Heli, Icon.Water, "restarter" }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

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
for _, index in pairs({ 100, 150, 250, 300 }) do
    triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = { Icon.Heli, Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
    triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
end

local achievements =
{
    [103461] = { time = 5, id = "cow_3", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement },
    [103458] = { id = "cow_3", special_function = SF.SetAchievementComplete },
}

EHI:ParseTriggers(triggers, achievements)