EHIXPTracker = EHIXPTracker or class(EHITracker)
function EHIXPTracker:init(panel, params)
    params.icons = { "xp" }
    self._xp = params.amount or 0
    EHIXPTracker.super.init(self, panel, params)
    self._time = 5
end

function EHIXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._xp, "+")
end

function EHIXPTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:delete()
    end
end

function EHIXPTracker:AddXP(amount)
    self._time = 5
    self._xp = self._xp + amount
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
end