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
        local fixed_unit_id = EHI:GetInstanceElementID(unit_id, index)
        managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(unit)
            managers.ehi:AddTracker({
                id = tostring(fixed_unit_id),
                time = 30,
                icons = { "equipment_glasscutter" }
            })
        end)
    end
end