if EHI._hooks.SentryGunMovement then
	return
else
	EHI._hooks.SentryGunMovement = true
end

local original =
{
    init = SentryGunMovement.init,
    rearm = SentryGunMovement.rearm,
    repair = SentryGunMovement.repair,
    on_death = SentryGunMovement.on_death
}
function SentryGunMovement:init(unit)
    original.init(self, unit)
    local key = tostring(unit:key())
    self._ehi_key_reload = key .. "_reload"
    self._ehi_key_repair = key .. "_repair"
end

function SentryGunMovement:rearm()
    original.rearm(self)
    managers.ehi:AddTracker({
        id = self._ehi_key_reload,
        time = self._tweak.AUTO_RELOAD_DURATION,
        icons = { "wp_sentry", "reload" },
        class = "EHIWarningTracker"
    })
end

function SentryGunMovement:repair()
    original.repair(self)
    managers.ehi:RemoveTracker(self._ehi_key_reload)
    managers.ehi:AddTracker({
        id = self._ehi_key_repair,
        time = self._tweak.AUTO_REPAIR_DURATION,
        icons = { "wp_sentry", "pd2_fix" },
        class = "EHIWarningTracker"
    })
end

function SentryGunMovement:on_death()
    original.on_death(self)
    managers.ehi:RemoveTracker(self._ehi_key_reload)
    managers.ehi:RemoveTracker(self._ehi_key_repair)
end