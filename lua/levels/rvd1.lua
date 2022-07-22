local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local dw_and_above = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish)
local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, "pd2_goto" }
local ExecuteIfEnabled = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [100107] = { id = "rvd_9", class = TT.AchievementNotification, exclude_from_sync = true },
    [100839] = { id = "rvd_9", special_function = SF.SetAchievementFailed },
    [100869] = { id = "rvd_9", special_function = SF.SetAchievementComplete },

    [100179] = { time = 1 + 9.5 + 11 + 1 + 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [100057] = { time = 60, id = "rvd_10", class = TT.Achievement, difficulty_pass = dw_and_above, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
    [100247] = { id = "rvd_10", special_function = SF.SetAchievementComplete },

    [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape },
    [100207] = { time = 260/30, id = "Escape", icons = Icon.CarEscape, special_function = ExecuteIfEnabled },
    [100209] = { time = 250/30, id = "Escape", icons = Icon.CarEscape, special_function = ExecuteIfEnabled },

    [100169] = { time = 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car },
    --260/30 anim_crash_02; Waypoint ID 101196
    --310/30 anim_crash_04; Waypoint ID 100490
    --201/30 anim_crash_05; Waypoint ID 101201
    --284/30 anim_crash_03; Waypoint ID 101138
    [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },

    [101105] = { id = 100490, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-640, 396, 200) } },
    [101104] = { id = 101196, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-4329, -2159, 202) } },
    [101106] = { id = 101201, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1633, -1002, 199) } },
    [101102] = { id = 101138, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3256, 1004, 180) } }
}

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(ExecuteIfEnabled, function(id, trigger, element, enabled)
    if enabled then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerTime(trigger.id, trigger.time)
        else
            EHI:CheckCondition(id)
        end
    end
end)