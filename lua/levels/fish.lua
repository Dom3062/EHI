local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    -- 100244 is ´Players_spawned´
    [100244] = { special_function = SF.Trigger, data = { 1002441, 1002442 } },
    -- "fish_4" achievement is not in the Mission Script
    [1002441] = { time = 360, id = "fish_4", class = TT.Achievement, condition = show_achievement and ovk_and_up },
    [1002442] = { id = "fish_5", class = TT.AchievementNotification, exclude_from_sync = true },
    [100395] = { id = "fish_5", special_function = SF.SetAchievementFailed },
    [100842] = { id = "fish_5", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers)
if show_achievement and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("fish_4", 360)
    end)
end