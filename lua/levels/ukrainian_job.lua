local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local zone_delay = 12
local cac_12_disable = { id = "cac_12", special_function = SF.SetAchievementFailed }
local ExecuteAchievementIfInteractionExists = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [103172] = { time = 2 + 830/30, id = "Van", icons = Icon.CarEscape },
    [103183] = { id = 103194, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(1600.0, 5700.0, 167.0) } },
    [103182] = { special_function = SF.Trigger, data = { 1031821, 1031822 } },
    [1031821] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031822] = { id = 103193, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3781.0, 1779.0, 112.0) } },
    [103181] = { special_function = SF.Trigger, data = { 1031811, 1031812 } },
    [1031811] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031812] = { id = 103192, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3297.0, 2218.0, 170.0) } },
    [101770] = { special_function = SF.Trigger, data = { 1017701, 1017702 } },
    [1017701] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1017702] = { id = 101776, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-2341.0, 4437.0, 150.0) } },

    [100073] = { time = 36, id = "lets_do_this", class = TT.Achievement },
    [101784] = { id = "lets_do_this", special_function = SF.SetAchievementComplete },
    [100074] = { id = "cac_12", status = "ready", class = TT.AchievementNotification, special_function = ExecuteAchievementIfInteractionExists, exclude_from_sync = true },
    [104406] = { id = "cac_12", status = "finish", special_function = SF.SetAchievementStatus },
    [104408] = { id = "cac_12", special_function = SF.SetAchievementComplete },
    [104409] = cac_12_disable,
    [103116] = cac_12_disable,

    [101614] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    local start_chance = 30 -- Normal
    if EHI:IsDifficulty("hard") then -- Hard
        start_chance = 33
    elseif EHI:IsDifficulty("very_hard") then -- Very Hard
        start_chance = 35
    elseif EHI:IsDifficultyOrAbove("overkill") then
        start_chance = 37
    end
    managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
end)

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(ExecuteAchievementIfInteractionExists, function(id, ...)
    if EHI:IsAchievementLocked("cac_12") and managers.ehi:InteractionExists("circuit_breaker_off") then
        EHI:CheckCondition(id)
    end
end)