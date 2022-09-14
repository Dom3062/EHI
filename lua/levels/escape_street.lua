local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101961] = { time = 120 },
    [101962] = { time = 90 },

    [102065] = { id = 102675, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = Vector3(858, -1525, 525) }},
    [102080] = { id = 102674, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = Vector3(-2512, -2344, 900) }}
}

local achievements =
{
    [101959] = { id = "bullet_dodger", class = TT.AchievementStatus },
    [101872] = { id = "bullet_dodger", special_function = SF.SetAchievementFailed },
    [101874] = { id = "bullet_dodger", special_function = SF.SetAchievementComplete },
}

EHI:ParseTriggers(triggers, achievements, nil, "Escape", Icon.HeliEscape)

if tweak_data.ehi.functions.IsBranchbankJobActive() then
    EHI:ShowAchievementBagValueCounter({
        achievement = "uno_1",
        value = tweak_data.achievement.complete_heist_achievements.uno_1.bag_loot_value,
        exclude_from_sync = true,
        remove_after_reaching_target = false,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfBags
        }
    })
--[[elseif managers.job:current_job_id() == "family" then -- Diamond Store
    EHI:ShowLootCounter({ max = 18 })]]
end