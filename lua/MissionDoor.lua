local EHI = EHI
if EHI:CheckLoadHook("MissionDoor") or not (EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission")) then
    return
end

if EHI:GetTrackerOrWaypointOption("show_timers", "show_waypoints_timers") then
    local mission_door_cache = {} ---@type table<integer, Vector3|Vector3[]>
    local mission_door = 1
    Hooks:PostHook(MissionDoor, "init", "EHI_MissionDoor_init", function(self, ...)
        if self.tweak_data and tweak_data.mission_door[self.tweak_data] then
            local devices_data = tweak_data.mission_door[self.tweak_data].devices or {}
            local drill_data = devices_data.drill
            if not drill_data then
                return
            end
            local tbl = {} ---@type Vector3[]
            for i, data in ipairs(drill_data) do
                local object = self._unit:get_object(Idstring(data.align))
                tbl[i] = object and object:position() or Vector3() -- Sometimes the align object does not exist in the unit; example: units/pd2_dlc_vit/architecture/vit_int/vit_int_peoc_doors/vit_int_peoc_doors/001 (6634, 4425, -1525)
            end
            if EHI.IsHost then
                call_on_next_update(function()
                    local editor_id = self._unit:editor_id()
                    if editor_id == -1 then
                        return
                    end
                    EHI:_SetMissionDoorData(editor_id, tbl)
                end)
            else
                self.__ehi_use_me = mission_door
                mission_door_cache[mission_door] = tbl
                mission_door = mission_door + 1
            end
        end
    end)
    if EHI.IsClient then
        Hooks:PostHook(MissionDoor, "load", "EHI_MissionDoor_load", function(self, ...)
            if self.__ehi_use_me then
                local editor_id = self._unit:editor_id()
                if editor_id == -1 then
                    return
                end
                EHI:_SetMissionDoorData(editor_id, mission_door_cache[self.__ehi_use_me])
                mission_door_cache[self.__ehi_use_me] = nil
            end
        end)
    end
end

if EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission") then
    local C4 = EHI.Icons.C4
    local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_mission_trackers", "show_waypoints_mission")
    ---@param unit Unit
    local function StartC4Sequence(unit)
        local key = tostring(unit:key())
        if show_tracker then
            managers.ehi_tracker:AddTracker({
                id = key,
                time = 5,
                icons = { C4 },
                hint = EHI.Hints.Explosion
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(key, {
                time = 5,
                icon = C4,
                position = unit:position()
            })
        end
    end
    if EHI.IsHost then
        local initiate_c4_sequence = MissionDoor._initiate_c4_sequence
        function MissionDoor:_initiate_c4_sequence(...)
            initiate_c4_sequence(self, ...)
            StartC4Sequence(self._unit)
        end
    else
        local run_mission_door_device_sequence = MissionDoor.run_mission_door_device_sequence
        function MissionDoor.run_mission_door_device_sequence(unit, sequence_name, ...)
            if sequence_name == "activate_explode_sequence" and unit:damage():has_sequence(sequence_name) then
                StartC4Sequence(unit)
            end
            run_mission_door_device_sequence(unit, sequence_name, ...)
        end
    end
end