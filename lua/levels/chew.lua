local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100595] = { time = 120, id = "born_5", class = TT.Achievement, condition = ovk_and_up and show_achievement },
    [101170] = { id = "born_5", special_function = SF.SetAchievementComplete }
}
local sync_triggers =
{
    [100558] = { id = "BileReturn", icons = Icon.HeliEscape }
}
if Network:is_client() then
    triggers[100558] = { time = 5, random_time = 5, id = "BileReturn", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(sync_triggers)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
end

EHI:ParseTriggers(triggers)
EHI:ShowLootCounter({
    max = 9,
    offset = true
})
if show_achievement and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("born_5", 120)
    end)
end