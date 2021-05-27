local unit_ids =
{
    100098, 102897, 102899, 102900
}

for _, unit_id in pairs(unit_ids) do
    managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_id),
            time = 10,
            icons = { "pd2_fire" }
        })
    end)
end