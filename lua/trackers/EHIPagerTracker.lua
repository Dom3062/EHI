EHIPagerTracker = EHIPagerTracker or class(EHIWarningTracker)
function EHIPagerTracker:init(panel, params)
    params.time = 12
    params.icons = { "pager_icon" }
    EHIPagerTracker.super.init(self, panel, params)
end

function EHIPagerTracker:update(t, dt)
    if self._answered then
        return
    end
    EHIPagerTracker.super.update(self, t, dt)
end

function EHIPagerTracker:SetAnswered()
    self._answered = true
    self._text:stop()
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIPagerTracker:delete()
    self._parent_class:RemovePager(self._id)
    EHIPagerTracker.super.delete(self)
end