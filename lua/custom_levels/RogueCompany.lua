local EHI = EHI
local TT = EHI.Trackers
local ObjectiveWait = { time = 90, id = "ObjectiveWait", icons = { EHI.Icons.Wait } }
local triggers = {
    [100271] = ObjectiveWait,
    [100269] = ObjectiveWait
}

local achievements =
{
    RC_Achieve_speedrun =
    {
        beardlib = true,
        package = "Rogue_Company",
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            --[100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_rc_6mins" }, class = TT.Achievement, condition = show_achievement and ovk_and_up }
            --[100756] = { id = "RC_Achieve_speedrun", special_function = SF.SetAchievementComplete },
            -- Apparently there is a bug in the mission script which causes to unlock this achievement even when the time runs out
            [100824] = { time = 360, id = "RC_Achieve_speedrun", icons = { "ehi_RC_Achieve_speedrun" }, class = TT.AchievementUnlock }
        },
        load_sync = function(self)
            local t = 360 - self._t
            if t <= 0 then
                return
            end
            self:AddTracker({
                id = "RC_Achieve_speedrun",
                time = t,
                icons = { "ehi_RC_Achieve_speedrun" },
                class = TT.AchievementUnlock
            })
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})