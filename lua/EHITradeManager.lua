---@class EHITradeManager
local EHITradeManager = {}
EHITradeManager._id = "CustodyTime"
EHITradeManager._trade = {
    ai = false,
    normal = false
}
EHITradeManager._trade_delay = {} --[[@as table<number, { respawn_t: number, in_custody: boolean?, civilians_killed: number }>]]
---@param type string
---@param pause boolean
---@param t number
function EHITradeManager:SetTrade(type, pause, t)
    self._trade[type] = pause
    local f = type == "normal" and "SetTrade" or "SetAITrade"
    self:CallFunction(f, pause, t)
end

---@param anim_flash boolean?
function EHITradeManager:AddCustodyTimeTracker(anim_flash)
    managers.ehi_tracker:AddTrackerIfDoesNotExist({
        id = self._id,
        flash_bg = anim_flash ~= false,
        class = "EHITradeDelayTracker"
    })
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:AddCustodyTimeTrackerWithPeer(peer_id, time, civilians_killed, in_custody)
    self:AddCustodyTimeTracker()
    self:AddPeerCustodyTime(peer_id, time, civilians_killed, in_custody)
    if self._trade.normal or self._trade.ai then
        local f = self._trade.normal and "SetTrade" or "SetAITrade"
        self:CallFunction(f, true, managers.trade._trade_counter_tick, true)
    end
end

---@param peer_id number
---@param respawn_time_penalty number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:AddPeerCustodyTime(peer_id, respawn_time_penalty, civilians_killed, in_custody)
    self:CallFunction("AddPeerCustodyTime", peer_id, respawn_time_penalty, civilians_killed, in_custody)
end

---@param peer_id number
---@param respawn_penalty number
---@param civilians_killed number
function EHITradeManager:AddOrUpdateCachedPeer(peer_id, respawn_penalty, civilians_killed)
    if self:CachedPeerInCustodyExists(peer_id) then
        self:SetCachedPeerCustodyTime(peer_id, respawn_penalty, civilians_killed)
    else
        self:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed)
    end
end

---@param peer_id number
---@param delay number
---@param tweak_respawn_penalty number
function EHITradeManager:AddOrIncreaseCachedPeerCustodyTime(peer_id, delay, tweak_respawn_penalty)
    if self:CachedPeerInCustodyExists(peer_id) then
        self:IncreaseCachedPeerCustodyTime(peer_id, tweak_respawn_penalty)
    else
        self:AddToTradeDelayCache(peer_id, delay)
    end
end

---@param peer_id number
---@param respawn_penalty number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed, in_custody)
    if self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, respawn_penalty, civilians_killed, in_custody)
        return
    end
    self._trade_delay[peer_id] =
    {
        respawn_t = respawn_penalty,
        in_custody = in_custody,
        civilians_killed = civilians_killed or 1
    }
end

---@param peer_id number
function EHITradeManager:SetCachedPeerInCustody(peer_id)
    local data = self._trade_delay[peer_id]
    if not data then
        return
    elseif self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, data.respawn_t, data.civilians_killed, true)
        return
    end
    data.in_custody = true
end

---@param peer_id number
---@param time number
function EHITradeManager:IncreaseCachedPeerCustodyTime(peer_id, time)
    if not self._trade_delay[peer_id] then
        return
    end
    local data = self._trade_delay[peer_id]
    local new_t = data.respawn_t + time
    local new_civies = data.civilians_killed + 1
    if self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, new_t, new_civies)
        return
    end
    data.respawn_t = new_t
    data.civilians_killed = new_civies
end

---@param peer_id number
---@param time number
---@param civilians_killed number
function EHITradeManager:SetCachedPeerCustodyTime(peer_id, time, civilians_killed)
    local data = self._trade_delay[peer_id]
    if not data then
        return
    elseif self._trade_processed_after_alarm then
        self:PostPeerCustodyTime(peer_id, time, civilians_killed)
        return
    end
    data.respawn_t = time
    data.civilians_killed = civilians_killed or 1
end

---@param peer_id number
function EHITradeManager:CachedPeerInCustodyExists(peer_id)
    return self._trade_delay[peer_id] ~= nil
end

function EHITradeManager:LoadFromTradeDelayCache()
    if next(self._trade_delay) then
        -- The tracker may get created a frame before, only create it when the tracker does not exist
        self:AddCustodyTimeTracker(false)
        for peer_id, crim in pairs(self._trade_delay) do
            self:CallFunction("AddOrUpdatePeerCustodyTime", peer_id, crim.respawn_t, crim.civilians_killed, crim.in_custody)
        end
        self:CallFunction("SetAnimFlash", true)
        self._trade_delay = {}
    end
    self._trade_processed_after_alarm = true
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
---@param in_custody boolean?
function EHITradeManager:PostPeerCustodyTime(peer_id, time, civilians_killed, in_custody) -- In case the civilian is killed at the same time when alarm went off
    local tracker = self:GetTracker()
    if tracker then
        if tracker:PeerExists(peer_id) then
            tracker:IncreasePeerCustodyTime(peer_id, time)
            if in_custody then
                tracker:SetPeerInCustody(peer_id)
            end
        else
            tracker:AddPeerCustodyTime(peer_id, time, civilians_killed, in_custody)
        end
    else
        self:AddCustodyTimeTrackerWithPeer(peer_id, time, civilians_killed, in_custody)
    end
end

---@return EHITradeDelayTracker?
function EHITradeManager:GetTracker()
    return managers.ehi_tracker:GetTracker(self._id) --[[@as EHITradeDelayTracker?]]
end

---@param f string
---@param ... any
function EHITradeManager:CallFunction(f, ...)
    managers.ehi_tracker:CallFunction(self._id, f, ...)
end

if EHI.IsClient and CustomNameColor and CustomNameColor.ModID then
    managers.ehi_sync:AddReceiveHook(CustomNameColor.ModID, "EHI_EHITradeManager", function(data, sender)
        if data and data ~= "" then
            local col = NetworkHelper:StringToColour(data)
            EHITradeManager:CallFunction("UpdateTextPeerColor", sender, col)
        end
    end)
end

return EHITradeManager