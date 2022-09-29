local EHI = EHI
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { "faster" } }
local triggers = {
    [100271] = ObjectiveWait,
    [100269] = ObjectiveWait
}
tweak_data.hud_icons.ehi_rc_6mins = { texture = "guis/achievements/rc_6mins", texture_rect = nil }

local achievements =
{
    --[100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.Achievement, condition = show_achievement and ovk_and_up }
    --[100756] = { id = "RC_Achieve_speedrun", special_function = SF.SetAchievementComplete },
    -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
    [100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.AchievementUnlock, difficulty_pass = ovk_and_up }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
if EHI:ShowMissionAchievements() and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        local t = 360 - self._t
        if t <= 0 then
            return
        end
        self:AddTracker({
            id = "RC_Achieve_speedrun",
            time = t,
            icons = { "ehi_rc_6mins" },
            class = EHI.Trackers.AchievementUnlock
        })
    end)
end