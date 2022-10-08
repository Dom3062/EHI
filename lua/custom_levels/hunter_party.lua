local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local escape_fly_in = 30 + 35 + 24
local fire_wait = { time = 20, id = "FireWait", icons = { Icon.Fire, Icon.Wait } }
local triggers = {
    [100201] = { time = 99, id = "AmbushWait", icons = { Icon.Wait } },
    [100218] = fire_wait,
    [100364] = fire_wait,
    [100417] = { time = 78 + 25 + escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, class = TT.Pausable },
    [100422] = { time = escape_fly_in, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
    [100423] = { time = escape_fly_in, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable }
}

local achievements =
{
    [100045] = { id = "hunter_party", status = "ok", icons = { "ehi_hunter_party" }, class = TT.AchievementStatus, condition = EHI:IsBeardLibAchievementLocked("hunter_all", "hunter_party") and EHI:ShowMissionAchievements() and ovk_and_up, special_function = SF.ShowAchievementFromStart, beardlib = true },
    [100679] = { id = "hunter_party", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})