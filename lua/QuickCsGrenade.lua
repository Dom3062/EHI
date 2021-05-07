local _f_detonate = QuickCsGrenade.detonate
function QuickCsGrenade:detonate()
    _f_detonate(self)
    managers.ehi:AddTracker({
        id = tostring(self._unit:key()),
        time = self._duration,
        icons = { "wp_sentry", "teargas" }
    })
end