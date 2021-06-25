EHITotalXPTracker = EHITotalXPTracker or class(EHITracker)
EHITotalXPTracker._update = false
function EHITotalXPTracker:init(panel, params)
    params.icons = { "xp" }
    self._xp = 0
    EHITotalXPTracker.super.init(self, panel, params)
end

function EHITotalXPTracker:Format()
    return managers.experience:cash_string(self._xp, "+")
end

function EHITotalXPTracker:AddXP(amount)
    self._xp = self._xp + amount
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
end