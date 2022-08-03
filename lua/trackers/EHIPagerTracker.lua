EHIPagerTracker = class(EHIWarningTracker)
function EHIPagerTracker:init(panel, params)
    params.time = 12
    params.icons = { "pager_icon" }
    EHIPagerTracker.super.init(self, panel, params)
end

function EHIPagerTracker:SetAnswered()
    self:RemoveTrackerFromUpdate()
    self._text:stop()
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIPagerTracker:delete()
    self._parent_class:RemovePager(self._id)
    EHIPagerTracker.super.delete(self)
end