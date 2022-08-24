local EHI = EHI
local Icon = EHI.Icons
local pc_ids = { 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }
for _, pc_id in pairs(pc_ids) do
    managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(pc_id),
            time = 13,
            icons = { Icon.Wait }
        })
    end)
end

local MissionDoorPositions =
{
    -- Security doors
    [1] = Vector3(-2357.87, -3621.42, 489.107),
    [2] = Vector3(1221.42, -2957.87, 489.107),
    [3] = Vector3(1342.13, -2621.42, 89.1069), --101867
    [4] = Vector3(-2830.08, 341.886, 492.443) --102199
}
local MissionDoorIndex =
{
    [1] = { w_id = 101899 },
    [2] = { w_id = 101834 },
    [3] = { w_id = 101782 },
    [4] = { w_id = 101783 }
}
EHI:SetMissionDoorPosAndIndex(MissionDoorPositions, MissionDoorIndex)