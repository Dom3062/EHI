local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101959] = { id = "bullet_dodger", class = TT.AchievementNotification },
    [101872] = { id = "bullet_dodger", special_function = SF.SetAchievementFailed },
    [101874] = { id = "bullet_dodger", special_function = SF.SetAchievementComplete },
    [101961] = { time = 120 },
    [101962] = { time = 90 },

    [102065] = { id = 102675, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = Vector3(858, -1525, 525) }},
    [102080] = { id = 102674, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = Vector3(-2512, -2344, 900) }}
}

EHI:ParseTriggers(triggers, "Escape", Icon.HeliEscape)