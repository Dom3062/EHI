local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100247] = { time = 180 },
    [100248] = { time = 120 },
    [100287] = { time = 30, id = "frappucino_to_go_please", class = TT.Achievement },
    [101379] = { id = "frappucino_to_go_please", special_function = SF.SetAchievementComplete },

    [100154] = { id = 100318, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3900, -2200, 650) } },
    [100157] = { id = 100314, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(2800, 2750, 623) } },
    [100156] = { id = 100367, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1450, -3850, 650) } }
}

EHI:ParseTriggers(triggers, "Escape", Icon.CarEscape)

local function IsBranchbankJobActive()
    local jobs = tweak_data.achievement.complete_heist_achievements.uno_1.jobs
    for _, job in ipairs(jobs) do
        if managers.job:current_job_id() == job then
            return true
        end
    end
    return false
end

if IsBranchbankJobActive() then
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