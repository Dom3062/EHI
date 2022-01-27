if EHI:ShouldDisableWaypoints() then
    local door_ids = { 101671, 102199, 101855, 101867 }
    local waypoint_ids = { 101899, 101834, 101783, 101782 }
    for _, door_id in pairs(door_ids) do
        managers.mission:add_runned_unit_sequence_trigger(door_id, "drill_placed", function(unit)
            for _, waypoint_id in pairs(waypoint_ids) do
                managers.hud:SoftRemoveWaypoint(waypoint_id)
                EHI._cache.IgnoreWaypoints[waypoint_id] = true
            end
        end)
    end
    -- MissionDoor class; figure out a solution
    --[[if Network:is_client() then
        for _, waypoint_id in pairs(waypoint_ids) do
            EHI._cache.IgnoreWaypoints[waypoint_id] = true
        end
    end]]
end

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