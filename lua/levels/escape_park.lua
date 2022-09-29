local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102449] = { time = 240 },
    [102450] = { time = 180 },
    [102451] = { time = 300 },

    [101285] = { id = 100786, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-2758, -3798, -50) } },
    [101286] = { id = 100783, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3583, -3882, -50) } },
    [101287] = { id = 100784, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(4023, 1027, -50) } },
    [101284] = { id = 100785, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3133, 1027, -50) } }
}

if EHI._cache.Client then
    triggers[100606] = { time = 240, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100593] = { time = 180, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100607] = { time = 120, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100601] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100602] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    [102444] = { id = "king_of_the_hill", class = TT.AchievementStatus },
    [101297] = { id = "king_of_the_hill", special_function = SF.SetAchievementFailed },
    [101343] = { id = "king_of_the_hill", special_function = SF.SetAchievementComplete },
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
    [102394] = { special_function = SF.CustomCode, f = BagsCheck },
    [102393] = { special_function = SF.CustomCode, f = BagsCheck },
    [102368] = { special_function = SF.CustomCode, f = BagsCheck }
}

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.CarEscape)

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