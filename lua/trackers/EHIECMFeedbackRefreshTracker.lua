---@class EHIECMFeedbackRefreshTracker : EHIGroupTracker
---@field super EHIGroupTracker
EHIECMFeedbackRefreshTracker = class(EHIGroupTracker)
EHIECMFeedbackRefreshTracker._count_f = function(item, key)
    return item > 0
end
function EHIECMFeedbackRefreshTracker:post_init(params)
    self._peers = {}
    self._peers_n = 0
    EHIECMFeedbackRefreshTracker.super.post_init(self, params)
end

function EHIECMFeedbackRefreshTracker:UpdatePeerCount()
    self._peers_n = table.count(self._peers, self._count_f)
    self:SetIconColor()
    self:SetTextColor()
end

function EHIECMFeedbackRefreshTracker:Run(params)
    EHIECMFeedbackRefreshTracker.super.Run(self, params)
    self._timers[self._timers_n].peer_id = params.peer_id
    self._peers[params.peer_id] = (self._peers[params.peer_id] or 0) + 1
    self:UpdatePeerCount()
end

function EHIECMFeedbackRefreshTracker:Remove(i)
    if self._timers_n <= 1 then
        self:delete()
        return
    end
    local peer_id = self._timers[i].peer_id
    if self._peers[peer_id] == 1 then
        self._peers[peer_id] = nil
    else
        self._peers[peer_id] = self._peers[peer_id] - 1
    end
    EHIECMFeedbackRefreshTracker.super.Remove(self, i)
    self:UpdatePeerCount()
end

function EHIECMFeedbackRefreshTracker:SetIconColor()
    if self._peers_n <= 1 then
        local peer_id, _ = next(self._peers)
        EHIECMFeedbackRefreshTracker.super.SetIconColor(self, self._parent_class:GetPeerColorByPeerID(peer_id))
    else
        EHIECMFeedbackRefreshTracker.super.SetIconColor(self, Color.white)
    end
end

function EHIECMFeedbackRefreshTracker:SetTextColor()
    if self._timers_n <= 1 then
        local _, timer = next(self._timers) ---@cast timer -?
        EHIECMFeedbackRefreshTracker.super.SetTextColor(self, Color.white, timer.label)
    elseif self._peers_n <= 1 then
        for _, timer in ipairs(self._timers) do
            EHIECMFeedbackRefreshTracker.super.SetTextColor(self, Color.white, timer.label)
        end
    else
        for _, timer in ipairs(self._timers) do
            EHIECMFeedbackRefreshTracker.super.SetTextColor(self, self._parent_class:GetPeerColorByPeerID(timer.peer_id), timer.label)
        end
    end
end