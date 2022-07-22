local EHI = EHI
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { "faster" } }
local triggers = {
    --[100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.Achievement, condition = show_achievement and ovk_and_up }
    --[100756] = { id = "RC_Achieve_speedrun", special_function = SF.SetAchievementComplete },
    -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
    [100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.AchievementUnlock, condition = show_achievement and ovk_and_up },
    [100271] = ObjectiveWait,
    [100269] = ObjectiveWait
}
tweak_data.hud_icons.ehi_rc_6mins = { texture = "guis/achievements/rc_6mins", texture_rect = nil }

EHI:ParseTriggers(triggers)