local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [100073] = { id = "ameno_7", status = "loud", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [100624] = { id = "ameno_7", special_function = SF.SetAchievementFailed },
    [100634] = { id = "ameno_7", special_function = SF.SetAchievementComplete },
    [101541] = { time = 2, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [101558] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [101601] = { time = 7, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [103172] = { time = 45 + 830/30, id = "Van", icons = Icon.CarEscape },
    [103183] = { id = 103194, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(1602.0, 5635.0, 140.0) } },
    [103182] = { special_function = SF.Trigger, data = { 1031821, 1031822 } },
    [1031821] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031822] = { id = 103193, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3776.0, 1766.0, 156.0) } },
    [103181] = { special_function = SF.Trigger, data = { 1031811, 1031812 } },
    [1031811] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031812] = { id = 103192, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3280.0, 2200.0, 152.133) } },
    [101770] = { special_function = SF.Trigger, data = { 1017701, 1017702 } },
    [1017701] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1017702] = { id = 101776, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-2324.0, 4444.0, 150.0) } },

    [101433] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    local start_chance = 25 -- Normal
    if EHI:IsDifficulty("hard") then -- Hard
        start_chance = 27
    elseif EHI:IsDifficulty("very_hard") then -- Very Hard
        start_chance = 32
    elseif EHI:IsDifficultyOrAbove("overkill") then
        start_chance = 36
    end
    managers.ehi:AddEscapeChanceTracker(dropin, start_chance)
end)

EHI:ParseTriggers(triggers)