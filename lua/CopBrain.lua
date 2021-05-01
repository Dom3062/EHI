if true then
    return
end

local _f_begin_alarm_pager = CopBrain.begin_alarm_pager
function CopBrain:begin_alarm_pager(reset)
    if not reset and self._alarm_pager_has_run then
		return
	end
    managers.hud:AddTracker({
        id = "pager_" .. tostring(self._unit:key()),
        time = 12,
        icons = { "pagers_used" },
        class = "EHIWarningTracker"
    })
    _f_begin_alarm_pager(self, reset)
end