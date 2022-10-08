local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:ShowMissionAchievements()
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local repair = { time = 90, id = "RepairWait", icons = { EHI.Icons.Fix } }
local triggers = {
    [100030] = repair,
    [100065] = repair,
    [100080] = repair,
    [100123] = repair
}

local achievements =
{
    [100132] = { special_function = SF.Trigger, data = { 1001321, 1001322 } },
    [1001321] = { max = 21, id = "hunter_loot", icons = { "ehi_hunter_loot" }, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart, condition = EHI:IsBeardLibAchievementLocked("hunter_all", "hunter_loot") and show_achievement and ovk_and_up, beardlib = true },
    [1001322] = { special_function = SF.CustomCode, f = function ()
        if managers.ehi:TrackerDoesNotExist("hunter_loot") then
            EHI:ShowLootCounter({ max = 21 })
            EHI:UnhookElement(100416)
        end
    end },
    [100416] = { id = "hunter_loot", special_function = SF.IncreaseProgress }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddLoadSyncFunction(function(self)
    EHI:ShowLootCounter({ max = 21 })
    EHI:UnhookElement(100416)
    self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
end)