local EHI = EHI
if EHI._hooks.SentryGunMovement then
	return
else
	EHI._hooks.SentryGunMovement = true
end

local show_waypoints = EHI:GetOption("show_waypoints_enemy_turret")

local original =
{
    init = SentryGunMovement.init,
    rearm = SentryGunMovement.rearm,
    repair = SentryGunMovement.repair,
    on_death = SentryGunMovement.on_death,
    pre_destroy = SentryGunMovement.pre_destroy
}

function SentryGunMovement:init(unit, ...)
    original.init(self, unit, ...)
    local key = tostring(unit:key())
    self._ehi_key_reload = key .. "_reload"
    self._ehi_key_repair = key .. "_repair"
end

function SentryGunMovement:rearm(...)
    original.rearm(self, ...)
    managers.ehi:AddTracker({
        id = self._ehi_key_reload,
        time = self._tweak.AUTO_RELOAD_DURATION,
        icons = { "wp_sentry", "reload" },
        class = "EHIWarningTracker"
    })
    if show_waypoints then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_reload, {
            time = self._tweak.AUTO_RELOAD_DURATION,
            texture = "guis/textures/pd2/skilltree/icons_atlas",
            text_rect = {0, 576, 64, 64},
            warning = true,
            unit = self._unit
        })
    end
end

function SentryGunMovement:repair(...)
    original.repair(self, ...)
    managers.ehi:RemoveTracker(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    managers.ehi:AddTracker({
        id = self._ehi_key_repair,
        time = self._tweak.AUTO_REPAIR_DURATION,
        icons = { "wp_sentry", "pd2_fix" },
        class = "EHIWarningTracker"
    })
    if show_waypoints then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_repair, {
            time = self._tweak.AUTO_REPAIR_DURATION,
            icon = "pd2_fix",
            warning = true,
            unit = self._unit
        })
    end
end

function SentryGunMovement:on_death(...)
    original.on_death(self, ...)
    managers.ehi:RemoveTracker(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    managers.ehi:RemoveTracker(self._ehi_key_repair)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_repair)
end

function SentryGunMovement:pre_destroy(...)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_reload)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_repair)
    original.pre_destroy(self, ...)
end