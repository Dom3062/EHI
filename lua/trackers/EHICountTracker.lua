---@class EHICountTracker : EHITracker
---@field super EHITracker
EHICountTracker = class(EHITracker)
EHICountTracker._update = false
function EHICountTracker:pre_init(params)
    self._count = params.count or 0
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
    self:AnimateBG()
end

function EHICountTracker:ResetCount()
    self:SetCount(0)
end