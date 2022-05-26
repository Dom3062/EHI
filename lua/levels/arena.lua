local EHI = EHI

local start_index =
{
    4500, 5400, 5800, 6000, 6200, 6600
}

local unit_ids =
{
    100067, 100093, 100094
}

for _, unit_id in ipairs(unit_ids) do
    for _, index in ipairs(start_index) do
        local fixed_unit_id = EHI:GetInstanceUnitID(unit_id, index)
        managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(unit)
            managers.ehi:AddTracker({
                id = tostring(fixed_unit_id),
                time = 30,
                icons = { "equipment_glasscutter" }
            })
        end)
    end
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [100693] = { id = "live_2", class = TT.AchievementNotification },
    [102704] = { id = "live_2", special_function = SF.SetAchievementFailed },
    [100246] = { id = "live_2", special_function = SF.SetAchievementComplete },
    [102785] = { id = "live_4", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [100249] = { id = "live_4", special_function = SF.SetAchievementComplete },
    [102694] = { id = "live_4", special_function = SF.SetAchievementFailed },

    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape },
    [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100116, 4900)] = { special_function = SF.Trigger, data = { 1, 2 } },
    [1] = { id = "live_5", class = TT.AchievementNotification },
    [102702] = { id = "live_5", special_function = SF.SetAchievementFailed },
    [100265] = { id = "live_5", special_function = SF.SetAchievementComplete },
    [2] = { max = 3, id = "C4Progress", icons = { Icon.C4 }, class = TT.Progress },
    [EHI:GetInstanceElementID(100177, 4900)] = { id = "C4Progress", special_function = SF.IncreaseProgress },
    [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { "faster" } },
    [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { "pd2_generic_interact" }, class = TT.Warning },

    [100304] = { time = 5, id = "live_3", class = TT.AchievementUnlock }
}

EHI:ParseTriggers(triggers)

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100050, 4700)] = true -- PC
}
EHI:DisableWaypoints(DisableWaypoints)