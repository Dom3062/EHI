local EHI = EHI
local Icon = EHI.Icons

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
                icons = { Icon.Glasscutter }
            })
        end)
    end
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape },
    [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100116, 4900)] = { max = 3, id = "C4Progress", icons = { Icon.C4 }, class = TT.Progress },
    [EHI:GetInstanceElementID(100177, 4900)] = { id = "C4Progress", special_function = SF.IncreaseProgress },
    [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { Icon.Wait } },
    [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { Icon.Interact }, class = TT.Warning }
}

local achievements =
{
    [100693] = { id = "live_2", class = TT.AchievementStatus },
    [102704] = { id = "live_2", special_function = SF.SetAchievementFailed },
    [100246] = { id = "live_2", special_function = SF.SetAchievementComplete },
    [100304] = { time = 5, id = "live_3", class = TT.AchievementUnlock },
    [102785] = { id = "live_4", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [100249] = { id = "live_4", special_function = SF.SetAchievementComplete },
    [102694] = { id = "live_4", special_function = SF.SetAchievementFailed },
    [EHI:GetInstanceElementID(100116, 4900)] = { id = "live_5", class = TT.AchievementStatus },
    [102702] = { id = "live_5", special_function = SF.SetAchievementFailed },
    [100265] = { id = "live_5", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers, achievements)

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100050, 4700)] = true -- PC
}
EHI:DisableWaypoints(DisableWaypoints)

local max = 6
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    max = 12
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    max = 18
end
EHI:ShowLootCounter({ max = max })