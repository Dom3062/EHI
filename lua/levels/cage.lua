local EHI = EHI
local achievements = {
    [100107] = { time = 240, id = "fort_4", class = EHI.Trackers.Achievement }
}

EHI:ParseTriggers({}, achievements)
if EHI:GetOption("show_achievement") then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("fort_4", 240)
    end)
end