EHIECMTracker = EHIECMTracker or class(EHIWarningTracker)
function EHIECMTracker:SetTime(time)
    self._text:stop()
    self._time_warning = false
    self:SetTextColor(Color.white)
    EHIECMTracker.super.SetTime(self, time)
end

function EHIECMTracker:SetTimeIfLower(time, owner_id)
    if self._time >= time then
        return
    end
    self:SetTime(time)
    self:SetIconColor(EHI:GetPeerColorByPeerID(owner_id))
end