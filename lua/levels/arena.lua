local EHI = EHI

local start_index =
{
    4500, 5400, 5800, 6000, 6200, 6600
}

local unit_ids =
{
    100067, 100093, 100094
}

for _, unit_id in pairs(unit_ids) do
    for _, index in pairs(start_index) do
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
local triggers = {
    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape },
    [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { "faster" } },
    [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { "pd2_generic_interact" }, class = TT.Warning },

    [100304] = { time = 5, id = "live_3", icons = { "C_Bain_H_Arena_Even" }, class = TT.AchievementUnlock }
}

EHI:ParseTriggers(triggers)