local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100077] = { time = 62, id = "hunter_fall", icons = { "ehi_hunter_fall_60s" }, class = TT.Achievement, special_function = SF.ShowAchievementFromStart }
}
tweak_data.hud_icons.ehi_hunter_fall_60s = { texture = "textures/hunter_speedrun", texture_rect = nil }

EHI:ParseTriggers(triggers)