local tweak_data = tweak_data
local original =
{
    AddWaypoint = EHIWaypointManager.AddWaypoint
}

local prime_color = tweak_data.hud.prime_color
local menu_font = Idstring(tweak_data.menu.medium_font)
function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    end
    params.distance = true
    original.AddWaypoint(self, id, params)
    if not self._hud then
        return
    end
    local wp = self._waypoints[id]
    if wp.distance then
        wp.distance:set_color(prime_color)
        wp.distance:set_font(menu_font)
        wp.distance:set_font_size(32)
    end
    if wp.timer_gui then
        wp.timer_gui:set_font(menu_font)
        wp.timer_gui:set_font_size(20)
    end
end

-- Use Vanilla texture file because Restoration HUD does not have the icons
-- Reported here: https://modworkshop.net/mod/28118
-- Don't forget to remove it from VR too when it is fixed
tweak_data.hud_icons.pd2_car.texture = "guis/textures/pd2/pd2_waypoints"
tweak_data.hud_icons.pd2_water_tap.texture = "guis/textures/pd2/pd2_waypoints"