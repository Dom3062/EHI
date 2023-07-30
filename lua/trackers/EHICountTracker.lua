---@class EHICountTracker : EHITracker
---@field super EHITracker
EHICountTracker = class(EHITracker)
EHICountTracker._update = false
function EHICountTracker:pre_init(params)
    self._count = 0
    self._anim_flash = params.flash ~= false
    self._flash_times = params.flash_times or 3
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
    if self._anim_flash then
        self:AnimateBG(self._flash_times)
    end
end

function EHICountTracker:ResetCount()
    self:SetCount(0)
end