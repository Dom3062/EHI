EHIStoicTracker = EHIStoicTracker or class(EHIBuffTracker)
function EHIStoicTracker:Activate(t, pos)
    EHIStoicTracker.super.Activate(self, self._auto_shrug or t, pos)
end

function EHIStoicTracker:Extend(t)
    EHIStoicTracker.super.Extend(self, self._auto_shrug or t)
end

function EHIStoicTracker:SetAutoShrug(t)
    self._auto_shrug = t
end