---@class EHITimePreSyncTracker : EHITracker
---@field super EHITracker
EHITimePreSyncTracker = class(EHITracker)
EHITimePreSyncTracker._text_color = Color(0, 1, 1)
function EHITimePreSyncTracker:SetTimeNoAnim(...)
    self:SetTextColor(EHITimePreSyncTracker.super._text_color)
    EHITimePreSyncTracker.super.SetTimeNoAnim(self, ...)
end

function EHITimePreSyncTracker:SetTime(...)
    if self._synced then
        self:SetTimeNoAnim(...)
    else
        EHITimePreSyncTracker.super.SetTime(self, ...)
        self._synced = true
    end
end