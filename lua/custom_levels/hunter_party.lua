local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local escape_fly_in = 30 + 35 + 24
local fire_wait = { time = 20, id = "FireWait", icons = { "pd2_fire", "faster" } }
local triggers = {
    [100045] = { id = "hunter_party", status = "ok", icons = { "ehi_hunter_no_civie_kills" }, class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, special_function = SF.ShowAchievementFromStart },
    [100679] = { id = "hunter_party", special_function = SF.SetAchievementFailed },
    [100201] = { time = 99, id = "AmbushWait", icons = { "faster" } },
    [100218] = fire_wait,
    [100364] = fire_wait,
    [100417] = { time = 78 + 25 + escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, class = TT.Pausable },
    [100422] = { time = escape_fly_in, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
    [100423] = { time = escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable }
}
tweak_data.hud_icons.ehi_hunter_no_civie_kills = { texture = "textures/hunter_party", texture_rect = nil }

EHI:ParseTriggers(triggers)