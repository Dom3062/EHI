local EHI = EHI

local start_index =
{
    8750, 17750, 33525, 36525
}

for _, index in pairs(start_index) do
    local unit_index = EHI:GetInstanceUnitID(100334, index)
    managers.mission:add_runned_unit_sequence_trigger(unit_index, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_index),
            time = 10,
            icons = { "pd2_fire" }
        })
    end)
end