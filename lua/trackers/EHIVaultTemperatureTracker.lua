EHIVaultTemperatureTracker = EHIVaultTemperatureTracker or class(EHITracker)
function EHIVaultTemperatureTracker:init(panel, params)
    params.time = 500
    params.icons = { EHI.Icons.Vault }
    self._synced_time = 0
    self._tick = 0.1
    EHIVaultTemperatureTracker.super.init(self, panel, params)
end

function EHIVaultTemperatureTracker:CheckTime(time)
    if self._synced_time == 0 then
        self._time = (50 - time) * 10
    else
        local new_tick = time - self._synced_time
        if new_tick ~= self._tick then
            self._time = ((50 - time) / (new_tick * 10)) * 10
            self._tick = new_tick
        end
    end
    self._synced_time = time
end