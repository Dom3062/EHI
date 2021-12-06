if EHI._hooks.QuickCsGrenade then
	return
else
	EHI._hooks.QuickCsGrenade = true
end

local _f_detonate = QuickCsGrenade.detonate
function QuickCsGrenade:detonate(...)
    _f_detonate(self, ...)
    local key = tostring(self._unit:key())
    managers.ehi:AddTracker({
        id = key,
        time = self._duration,
        icons = { "wp_sentry", "teargas" }
    })
    managers.ehi_waypoint:AddWaypoint(key, {
        time = self._duration,
        texture = "guis/dlcs/drm/textures/pd2/crime_spree/modifiers_atlas_2",
        text_rect = {128, 256, 128, 128},
        unit = self._unit
    })
end