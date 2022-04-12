local original =
{
    init = EHIWaypointManager.init,
    AddWaypoint = EHIWaypointManager.AddWaypoint,
    SetWaypointIcon = EHIWaypointManager.SetWaypointIcon,
    update = EHIWaypointManager.update,
    Save = VoidUI.Save
}

function EHIWaypointManager:init()
    original.init(self)
    self:UpdateValues()
end

function EHIWaypointManager:UpdateValues()
    self._scale = VoidUI.options.waypoint_scale
    self._radius = VoidUI.options.waypoint_radius
    self._label_waypoint_offscreen = VoidUI.options.label_waypoint_offscreen
end

function EHIWaypointManager:AddWaypoint(id, params)
    original.AddWaypoint(self, id, params)
    if self._waypoints[id] then
        local scale = self._scale
        local bitmap = self._waypoints[id].bitmap
        local arrow = self._waypoints[id].arrow
        local distance = self._waypoints[id].distance
        local text = self._waypoints[id].text
        local timer = self._waypoints[id].timer_gui
        bitmap:set_size(bitmap:w() * scale, bitmap:h() * scale)
        arrow:set_size(arrow:w() * scale, arrow:h() * scale)
        text:set_font_size(text:font_size() * scale)
        text:set_size(text:w() * scale, text:h() * scale)
        self._waypoints[id].size = Vector3(bitmap:w(), bitmap:h(), 0)
        self._waypoints[id].radius = self._radius
        if params.distance then
            distance:set_font_size(distance:font_size() * scale)
            distance:set_size(distance:w() * scale, distance:h() * scale)
        end
        if params.timer then
            timer:set_size(timer:w() * scale, timer:h() * scale)
            timer:set_font_size(timer:font_size() * scale)
        end
    end
end

function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    original.SetWaypointIcon(self, id, new_icon)
    if self._waypoints[id] then
        local scale = self._scale
        local bitmap = self._waypoints[id].bitmap
        bitmap:set_size(bitmap:w() * scale, bitmap:h() * scale)
        self._waypoints[id].size = Vector3(bitmap:w(), bitmap:h(), 0)
    end
end

function EHIWaypointManager:update(t, dt, dt_actual)
    original.update(self, t, dt, dt_actual)
    local cam = managers.viewport:get_current_camera()
    if not cam then
        return
    end

    local wp_pos = Vector3()
    local wp_onscreen_direction = Vector3()

    for id, data in pairs(self._waypoints) do
        if data.state == "offscreen" then
                local panel = data.bitmap:parent()
                mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
                local show = self._label_waypoint_offscreen
                data.bitmap:set_visible(show)
                data.arrow:set_visible(show)
                data.text:set_visible(show)

                local direction = wp_onscreen_direction
                local panel_center_x, panel_center_y = panel:center()
                local scale = self._scale
                mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
                mvector3.normalize(direction)
                data.arrow:set_center(mvector3.x(data.current_position) + direction.x * (24 * scale), mvector3.y(data.current_position) + direction.y * (24 * scale))
        elseif data.state == "onscreen" and not self._label_waypoint_offscreen then
            data.bitmap:set_visible(true)
            data.text:set_visible(true)
        end
    end
end

function VoidUI:Save()
	original.Save(self)
    if managers.ehi_waypoint then
        managers.ehi_waypoint:UpdateValues()
    end
end