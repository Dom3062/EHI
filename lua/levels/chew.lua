local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {}
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

local achievements =
{
    [100595] = { time = 120, id = "born_5", class = TT.Achievement, difficulty_pass = ovk_and_up },
    [101170] = { id = "born_5", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers, achievements)
EHI:ShowLootCounter({
    max = 9,
    offset = Global.game_settings.gamemode ~= "crime_spree"
})
if EHI:GetOption("show_achievement") and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("born_5", 120)
    end)
end