EHIStoicTracker = class(EHIBuffTracker)
function EHIStoicTracker:Activate(t, pos)
    EHIStoicTracker.super.Activate(self, self._auto_shrug or t, pos)
end

function EHIStoicTracker:Extend(t)
    EHIStoicTracker.super.Extend(self, self._auto_shrug or t)
end

function EHIStoicTracker:SetAutoShrug(t)
    self._auto_shrug = t
end

EHIHackerTemporaryDodgeTracker = class(EHIBuffTracker)
function EHIHackerTemporaryDodgeTracker:Activate(...)
    EHIHackerTemporaryDodgeTracker.super.Activate(self, ...)
    self._parent_class:CallBuffFunction("DodgeChance", "ForceUpdate")
end

function EHIHackerTemporaryDodgeTracker:Deactivate(...)
    EHIHackerTemporaryDodgeTracker.super.Deactivate(self, ...)
    self._parent_class:CallBuffFunction("DodgeChance", "ForceUpdate")
end

EHIUnseenStrikeTracker = class(EHIBuffTracker)
function EHIUnseenStrikeTracker:Activate(...)
    EHIUnseenStrikeTracker.super.Activate(self, ...)
    self._parent_class:CallBuffFunction("CritChance", "ForceUpdate")
end

function EHIUnseenStrikeTracker:Deactivate(...)
    EHIUnseenStrikeTracker.super.Deactivate(self, ...)
    self._parent_class:CallBuffFunction("CritChance", "ForceUpdate")
end