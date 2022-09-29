local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100247] = { time = 180 },
    [100248] = { time = 120 },

    [100154] = { id = 100318, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3900, -2200, 650) } },
    [100157] = { id = 100314, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(2800, 2750, 623) } },
    [100156] = { id = 100367, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1450, -3850, 650) } }
}

local achievements =
{
    [100287] = { time = 30, id = "frappucino_to_go_please", class = TT.Achievement },
    [101379] = { id = "frappucino_to_go_please", special_function = SF.SetAchievementComplete }
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
    [100968] = { special_function = SF.CustomCode, f = BagsCheck },
    [100969] = { special_function = SF.CustomCode, f = BagsCheck },
    [100970] = { special_function = SF.CustomCode, f = BagsCheck }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape", Icon.CarEscape)

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