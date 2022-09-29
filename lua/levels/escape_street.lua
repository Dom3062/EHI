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

local function BagsCheck()
    local max = managers.ehi:CountLootbagsOnTheGround()
    if max == 0 then
        return
    end
    EHI:ShowLootCounter({ max = max })
end
local other =
{
    [102031] = { special_function = SF.CustomCode, f = BagsCheck },
    [102030] = { special_function = SF.CustomCode, f = BagsCheck }
}

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.HeliEscape)

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
end