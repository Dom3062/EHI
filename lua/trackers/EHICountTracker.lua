EHICountTracker = EHICountTracker or class(EHITracker)
EHICountTracker._update = false
function EHICountTracker:init(panel, params)
    params.icons = params.icons or { "enemy" }
    self._count = 0
    EHICountTracker.super.init(self, panel, params)
end

function EHICountTracker:Format()
    return tostring(self._count)
end

function EHICountTracker:IncreaseCount()
    self:SetCount(self._count + 1)
end

function EHICountTracker:DecreaseCount()
    self:SetCount(self._count - 1)
end

function EHICountTracker:SetCount(count)
    self._count = count
    self._text:set_text(self:Format())
end