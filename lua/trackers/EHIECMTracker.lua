---@class EHIECMTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIECMTracker = class(EHIWarningTracker)
function EHIECMTracker:post_init(params)
    self._unit = params.unit
end

function EHIECMTracker:SetTime(...)
    EHIECMTracker.super.SetTime(self, ...)
    self:SetTextColor(Color.white)
end

---@param time number
---@param owner_id number
---@param unit UnitECM
function EHIECMTracker:SetTimeIfLower(time, owner_id, unit)
    if self._time >= time then
        return
    end
    self:SetTime(time)
    self:SetIconColor(self._parent_class:GetPeerColorByPeerID(owner_id))
    self._unit = unit
end

---@param owner_id number
---@param unit UnitECM
function EHIECMTracker:UpdateOwnerID(owner_id, unit)
    if self._unit == unit then
        self:SetIconColor(self._parent_class:GetPeerColorByPeerID(owner_id))
    end
end

---@param unit UnitECM
function EHIECMTracker:Destroyed(unit)
    if self._unit == unit then
        self:delete()
    end
end