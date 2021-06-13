EHIVaultTemperatureTracker = EHIVaultTemperatureTracker or class(EHITracker)
EHIVaultTemperatureTracker._update = false
function EHIVaultTemperatureTracker:init(panel, params)
    params.time = 501 -- 500 + 1 second delay to launch countdown
    params.icons = { EHI.Icons.Vault }
    self._n_of_crowbars = 0
    EHIVaultTemperatureTracker.super.init(self, panel, params)
end

function EHIVaultTemperatureTracker:AddCrowbar()
    self._n_of_crowbars = self._n_of_crowbars + 1
    if self._n_of_crowbars == 1 then
        self:AddTrackerToUpdate()
        return
    elseif self._n_of_crowbars == 2 then
        self._time = self._time / 2
    else
        self._time = self._time / 2.5
        -- The number was already divided by 2; dividing by 5 would get the tracker inaccurate
    end
    self:AnimateBG()
end