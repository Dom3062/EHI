local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [100107] = { time = 300, id = "sah_9", class = TT.Achievement, condition = ovk_and_up and show_achievement, exclude_from_sync = true },

    [100643] = { time = 30, id = "CrowdAlert", icons = { "enemy" }, class = TT.Warning },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

    [101725] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape }, -- West
    [101845] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape } -- East
}

EHI:ParseTriggers(triggers)