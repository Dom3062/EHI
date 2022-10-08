local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local achievements = {
    -- 100244 is ´Players_spawned´
    [100244] = { special_function = SF.Trigger, data = { 1002441, 1002442, 1002443, 1002444 } },
    -- "fish_4" achievement is not in the Mission Script
    [1002441] = { time = 360, id = "fish_4", class = TT.Achievement, difficulty_pass = ovk_and_up },
    [1002442] = { id = "fish_5", class = TT.AchievementStatus },
    [1002443] = { id = "fish_6", class = TT.AchievementProgress, remove_after_reaching_target = false }, -- Maximum is set in the next trigger; difficulty dependant
    [1002444] = { special_function = SF.CustomCode, f = function()
        if managers.ehi:TrackerDoesNotExist("fish_6") then
            return
        end
        managers.ehi:SetTrackerProgressMax("fish_6", managers.enemy:GetNumberOfEnemies())
        CopDamage.register_listener("EHI_fish_6_listener", { "on_damage" }, function(damage_info)
            if damage_info.result.type == "death" then
                managers.ehi:IncreaseTrackerProgress("fish_6")
            end
        end)
    end},
    [100395] = { id = "fish_5", special_function = SF.SetAchievementFailed },
    [100842] = { id = "fish_5", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers({
    mission = {},
    achievement = achievements
})
if EHI:ShowMissionAchievements() and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("fish_4", 360)
    end)
end
EHI:ShowLootCounter({
    max = 8, -- Mission bags
    additional_loot = 7 -- Artifacts
})