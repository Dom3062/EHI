local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local repair = { time = 90, id = "RepairWait", icons = { "pd2_fix" } }
local triggers = {
    [100132] = { special_function = SF.Trigger, data = { 1001321, 1001322 } },
    [1001321] = { max = 21, id = "hunter_loot", icons = { "ehi_hunter_departure_all_loot" }, class = TT.AchievementProgress, special_function = SF.ShowAchievementFromStart, condition = show_achievement and ovk_and_up },
    [1001322] = { special_function = SF.CustomCode, f = function ()
        if managers.ehi:TrackerDoesNotExist("hunter_loot") then
            EHI:ShowLootCounter(21)
            EHI:UnhookElement(100416)
        end
    end },
    [100416] = { id = "hunter_loot", special_function = SF.IncreaseProgress },
    [100030] = repair,
    [100065] = repair,
    [100080] = repair,
    [100123] = repair
}
tweak_data.hud_icons.ehi_hunter_departure_all_loot = { texture = "textures/hunter_loot", texture_rect = nil }

EHI:ParseTriggers(triggers)
EHI:AddLoadSyncFunction(function(self)
    EHI:ShowLootCounter(21)
    EHI:UnhookElement(100416)
    self:SetTrackerProgress("LootCounter", managers.loot:GetSecuredBagsAmount())
end)