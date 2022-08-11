EHIGasTracker = class(EHIProgressTracker)
function EHIGasTracker:init(panel, params)
    params.max = params.max or 0
    params.icons = { "pd2_fire" }
    EHIGasTracker.super.init(self, panel, params)
end

function EHIGasTracker:Format()
    if self._max == 0 then
        return self._progress .. "/?"
    end
    return EHIGasTracker.super.Format(self)
end

EHIZoneTracker = class(EHIWarningTracker)
EHIZoneTracker.update = EHIAchievementTracker.update
EHIZoneTracker.SetCompleted = EHIAchievementTracker.SetCompleted

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local SetProgressMax = EHI:GetFreeCustomSpecialFunctionID()
local SetZoneComplete = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [100377] = { time = 90, id = "ClearPickupZone", icons = { Icon.Wait }, class = "EHIZoneTracker" },
    [101550] = { id = "ClearPickupZone", special_function = SetZoneComplete },

    -- Parking lot
    [102543] = { time = 6.5 + 8 + 4, id = "ObjectiveWait", icons = { Icon.Wait } },

    [101521] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { Icon.Heli, Icon.Escape }, special_function = SF.RemoveTriggerWhenExecuted },

    [100144] = { special_function = SF.Trigger, data = { 1001441, 1001442 } },
    [1001441] = { id = "GasAmount", class = "EHIGasTracker" },
    [1001442] = { special_function = SF.RemoveTriggers, data = { 100144 } },
    [100051] = { id = "GasAmount", special_function = SF.RemoveTracker }, -- In case the tracker gets stuck for drop-ins

    [1] = { id = "GasAmount", special_function = SF.IncreaseProgress },
    [2] = { special_function = SF.RemoveTriggers, data = { 102775, 102776, 102868 } }, -- Don't blink twice, just set the max once and remove the triggers
    [3] = { special_function = SF.CustomCode, f = function()
        managers.hud:SoftRemoveWaypoint(101290)
    end }, -- Hide "exclamation" waypoint
    [4] = { special_function = SF.CustomCode, f = function()
        managers.hud:RestoreWaypoint(101290)
    end }, -- Show "exclamation" waypoint

    [102876] = { special_function = SF.Trigger, data = { 1028761, 1 } },
    [1028761] = { time = 60, id = "Gas1", icons = { Icon.Fire } },
    [102875] = { special_function = SF.Trigger, data = { 1028751, 1 } },
    [1028751] = { time = 60, id = "Gas2", icons = { Icon.Fire } },
    [102874] = { special_function = SF.Trigger, data = { 1028741, 1 } },
    [1028741] = { time = 60, id = "Gas3", icons = { Icon.Fire } },
    [102873] = { special_function = SF.Trigger, data = { 1028731, 1 } },
    [1028731] = { time = 80, id = "Gas4", icons = { Icon.Fire, Icon.Escape } },

    [102775] = { special_function = SF.Trigger, data = { 1027751, 2 } },
    [1027751] = { max = 4, id = "GasAmount", special_function = SetProgressMax },
    [102776] = { special_function = SF.Trigger, data = { 1027761, 2 } },
    [1027761] = { max = 3, id = "GasAmount", special_function = SetProgressMax },
    [102868] = { special_function = SF.Trigger, data = { 1028681, 2 } },
    [1028681] = { max = 2, id = "GasAmount", special_function = SetProgressMax }
}
if EHI:MissionTrackersAndWaypointEnabled() then
    triggers[102876].data[3] = 3
    triggers[1028761].waypoint = { position_by_element = 101290 }
    triggers[102875].data[3] = 3
    triggers[1028751].waypoint = { position_by_element = 101290 }
    triggers[102874].data[3] = 3
    triggers[1028741].waypoint = { position_by_element = 101290 }
    triggers[102873].data[3] = 3
    triggers[1028731].waypoint = { icon = Icon.Escape, position_by_element = 101290 }
    triggers[102775].data[2] = 4
    triggers[102776].data[2] = 4
    triggers[102868].data[2] = 4
end

local achievements =
{
    [100120] = { time = 1800, id = "run_9", class = TT.AchievementDone },
    [100144] = { id = "run_9", special_function = SF.SetAchievementFailed },

    [102426] = { special_function = SF.Trigger, data = { 1024261, 1024262 } },
    [1024261] = { max = 8, id = "run_8", class = TT.AchievementProgress, exclude_from_sync = true },
    [1024262] = { id = "run_10", class = TT.AchievementStatus, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard) },
    [100658] = { id = "run_8", special_function = SF.IncreaseProgress },
    [100111] = { id = "run_10", special_function = SF.SetAchievementFailed },
    [100664] = { id = "run_10", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers, achievements)
local ProgressMaxSet = false
EHI:RegisterCustomSpecialFunction(SetProgressMax, function(id, trigger, element, enabled)
    if ProgressMaxSet then
        return
    end
    if managers.ehi:TrackerExists(trigger.id) then
        managers.ehi:SetTrackerProgressMax(trigger.id, trigger.max)
    else
        managers.ehi:AddTracker({
            id = trigger.id,
            progress = 1,
            max = trigger.max,
            class = "EHIGasTracker"
        })
    end
    ProgressMaxSet = true
end)
EHI:RegisterCustomSpecialFunction(SetZoneComplete, function(id, trigger, ...)
    managers.ehi:CallFunction(trigger.id, "SetCompleted")
end)