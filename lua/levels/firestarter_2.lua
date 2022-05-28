local pc_ids = { 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }
for _, pc_id in pairs(pc_ids) do
    managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(pc_id),
            time = 13,
            icons = { "faster" }
        })
    end)
end