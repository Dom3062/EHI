local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_delay = 22 + 1 + 1.5
local heli_icon = { Icon.Heli, Icon.Winch, "pd2_goto" }
local refill_icon = { Icon.Water, Icon.Loop }
local heli_60 = { time = 60 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
local heli_30 = { time = 30 + heli_delay, id = "HeliWithWinch", icons = heli_icon, special_function = SF.ExecuteIfElementIsEnabled }
if EHI:GetOption("show_one_icon") then
    refill_icon = { { icon = Icon.Water, color = Color("D4F1F9") } }
end
local triggers = {
    [EHI:GetInstanceElementID(100173, 66615)] = { time = 5 + 25, id = "ArmoryKeypadReboot", icons = { Icon.Wait }, waypoint = { position = Vector3(9823.0, -40877.0, -2987.0) + Vector3(0, 0, 0):rotate_with(Rotation()) } },

    [EHI:GetInstanceElementID(100030, 11750)] = { time = 5, id = "C4Lower", icons = { Icon.C4 } },
    [EHI:GetInstanceElementID(100030, 11850)] = { time = 5, id = "C4Top", icons = { Icon.C4 } },

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

    [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, "pd2_goto" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, "pd2_goto" }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

    -- Water during drilling
    [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 } },
    [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 } },
    [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

    -- Skylight Hack
    [EHI:GetInstanceElementID(100018, 29650)] = { time = 30, id = "SkylightHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100037, 29650)] = { id = "SkylightHack", special_function = SF.PauseTracker },

    [100159] = { id = "BlimpWithTheDrill", icons = { Icon.Blimp, Icon.Drill }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 } },
    [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { Icon.Blimp, Icon.Drill, "pd2_goto" } },

    [EHI:GetInstanceElementID(100173, 66365)] = { time = 30, id = "VaultKeypadReset", icons = { Icon.Loop } }
}

local kenaz_5 = { id = "kenaz_5", class = TT.AchievementStatus }
local achievements =
{
    [100282] = { time = 840, id = "kenaz_4", class = TT.Achievement },

    [EHI:GetInstanceElementID(100008, 12500)] = kenaz_5,
    [EHI:GetInstanceElementID(100008, 12580)] = kenaz_5,
    [EHI:GetInstanceElementID(100008, 12660)] = kenaz_5,
    [EHI:GetInstanceElementID(100008, 18700)] = kenaz_5,
    [102806] = { status = "finish", id = "kenaz_5", special_function = SF.SetAchievementStatus },
    [102808] = { id = "kenaz_5", special_function = SF.SetAchievementFailed },

    [102807] = { id = "kenaz_3", class = TT.AchievementStatus },
    [102809] = { id = "kenaz_3", special_function = SF.SetAchievementFailed },
    [103163] = { status = "finish", id = "kenaz_3", special_function = SF.SetAchievementStatus },
}
EHI:ParseTriggers(triggers, achievements)
EHI:HookWithID(MissionEndState, "at_enter", function(self, ...)
    if self._success then
        managers.ehi:SetAchievementComplete("kenaz_4", true)
    end
end)
if EHI:GetOption("show_achievement") then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("kenaz_4", 840)
    end)
end

local DisableWaypoints =
{
    -- Defend
    [EHI:GetInstanceElementID(100347, 37575)] = true,
    [EHI:GetInstanceElementID(100347, 44535)] = true
}
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --levels/instances/unique/kenaz/the_drill
    --units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill
    [EHI:GetInstanceElementID(100000, 37575)] = { icons = { Icon.Drill }, ignore_visibility = true },
    [EHI:GetInstanceElementID(100000, 44535)] = { icons = { Icon.Drill }, ignore_visibility = true }
}
EHI:UpdateUnits(tbl)