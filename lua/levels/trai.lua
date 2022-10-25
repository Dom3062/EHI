local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local WinchFix = { Icon.Winch, Icon.Fix }
if EHI:GetOption("show_one_icon") then
    WinchFix = { Icon.Fix }
end

local triggers =
{
    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire } },

    [101098] = { time = 5 + 7 + 2, id = "walkieTalkie", icons = { "pagers_used" } },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Water } },

    [EHI:GetInstanceElementID(100024, 11650)] = { time = 25, id = "Turntable", icon = { Icon.Loop }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100025, 11650)] = { id = "Turntable", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100089, 22250)] = { time = 0.1 + 400/30, id = "CraneLowerHooks", icons = { Icon.Winch } },
    [EHI:GetInstanceElementID(100010, 22250)] = { special_function = SF.Trigger, data = { 1, 2 } },
    [1] = { time = 400/30 + 105 + 2 + 400/30, id = "CraneMove", icons = { Icon.Winch }, class = TT.Pausable },
    [2] = { chance = 30, id = "CraneFixChance", icons = WinchFix, class = TT.Chance },
    [EHI:GetInstanceElementID(100047, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100059, 22250)] = { id = "CraneMove", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100060, 22250)] = { id = "CraneMove", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100035, 22250)] = { id = "CraneFixChance", special_function = SF.IncreaseChanceFromElement }, -- +10%
    [EHI:GetInstanceElementID(100039, 22250)] = { id = "CraneFixChance", special_function = SF.RemoveTracker }, -- Fix needed, runs once
    [EHI:GetInstanceElementID(100048, 22250)] = { id = "CraneFixChance", special_function = SF.RemoveTracker } -- 33s passed, no fix will be executed
}

local other =
{
    [100109] = { time = 30 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = EHI:GetOption("show_assault_delay_tracker") }
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})