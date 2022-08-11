local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local goat_pick_up = { Icon.Heli, Icon.Interact }
local function f_PilotComingInAgain(id, trigger, ...)
    managers.ehi:RemoveTracker("PilotComingIn")
    if managers.ehi:TrackerExists(trigger.id) then
        managers.ehi:SetTrackerTime(trigger.id, trigger.time)
    else
        EHI:CheckCondition(id)
    end
end
local PilotComingInAgain = EHI:GetFreeCustomSpecialFunctionID()
local PilotComingInAgain2 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [100109] = { time = 100 + 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [EHI:GetInstanceElementID(100022, 2850)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3150)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3450)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = Icon.HeliDropBag, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },
    [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },
    [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain },

    [101720] = { time = 80, id = "Bridge", icons = { Icon.Wait }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
    [101718] = { id = "Bridge", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 },
    [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 },
    [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = PilotComingInAgain2 }
}

local achievements =
{
    [100002] = { max = (EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and 15 or 13), id = "peta_5", class = TT.AchievementProgress, difficulty_pass = ovk_and_up },
    [102211] = { id = "peta_5", special_function = SF.IncreaseProgress },
    [100580] = { special_function = SF.CustomCode, f = function()
        EHI:DelayCall("peta_5_finalize", 2, function()
            managers.ehi:CallFunction("peta_5", "Finalize")
        end)
    end},

    -- Formerly 5 minutes
    [101540] = { time = 240, id = "peta_3", class = TT.Achievement },
    [101533] = { id = "peta_3", special_function = SF.SetAchievementComplete },
}

EHI:ParseTriggers(triggers, achievements)
EHI:RegisterCustomSpecialFunction(PilotComingInAgain, function(id, trigger, element, enabled)
    if enabled then
        f_PilotComingInAgain(id, trigger)
    end
end)
EHI:RegisterCustomSpecialFunction(PilotComingInAgain2, f_PilotComingInAgain)

local DisableWaypoints =
{
    -- Drill waypoint on mission door
    [101738] = true
}
EHI:DisableWaypoints(DisableWaypoints)