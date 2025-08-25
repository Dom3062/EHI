---@class EHIPlayerPingTracker : EHITracker
---@field super EHITracker
EHIPlayerPingTracker = class(EHITracker)
EHIPlayerPingTracker._needs_update = false
EHIPlayerPingTracker._forced_icons = { "ping" }
EHIPlayerPingTracker._forced_hint_text = "ping"
EHIPlayerPingTracker._ping_t_refresh = EHI:GetOption("show_ping_tracker_refresh_t") --[[@as number]]
function EHIPlayerPingTracker:post_init(params)
    self._hide_on_delete = true
    self._peers = {} ---@type table<number, { peer: NetworkPeer, label: Text }>
    self._n_of_peers = 0
    self._update_callback = callback(self, self, "update")
end

function EHIPlayerPingTracker:PlayerSpawned()
    EHIPlayerPingTracker.super.PlayerSpawned(self)
    local session = managers.network:session()
    self._local_peer_id = session:local_peer():id()
    for _, peer in pairs(session:peers()) do
        self:AddPeer(peer)
    end
    Hooks:PostHook(NetworkPeer, "init", "EHI_NetworkPeer_init", function(peer, ...)
        if not self._peers then
            self._peers = {}
        end
        self:AddPeer(peer)
    end)
    Hooks:PostHook(NetworkPeer, "destroy", "EHI_NetworkPeer_destroy", function(peer, ...)
        self:RemovePeer(peer:id())
    end)
end

---@param dt number
function EHIPlayerPingTracker:update(_, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        for _, peer_data in pairs(self._peers) do
            local qos = peer_data.peer:qos()
            if qos then
                if qos.packet_loss and qos.packet_loss > 0 then
                    peer_data.label:set_text(string.format("%d (%d)", math.ceil(qos.ping or 0), math.ehi_round_chance(qos.packet_loss)))
                else
                    peer_data.label:set_text(tostring(math.ceil(qos.ping or 0)))
                end
                self:FitTheText(peer_data.label)
            end
        end
        self._time = self._ping_t_refresh
    end
end

---@param peer NetworkPeer
function EHIPlayerPingTracker:AddPeer(peer)
    local id = peer:id()
    if id == self._local_peer_id or self._peers[id] then
        return
    end
    self._peers[id] = {
        peer = peer,
        label = self:CreateText({
            color = self._parent_class:GetPeerColorByPeerID(id)
        })
    }
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers == 1 then
        self._parent_class:RunTracker(self._id, nil, self._adjusted_pos)
        self:AddTrackerToUpdate()
    else
        self:Reorganize(true)
    end
end

---@param peer_id number
function EHIPlayerPingTracker:RemovePeer(peer_id)
    local peer = table.remove_key(self._peers, peer_id)
    if peer then
        peer.label:parent():remove(peer.label)
        self._n_of_peers = self._n_of_peers - 1
        if self._n_of_peers == 0 then
            self:RemoveTrackerFromUpdate()
            self:delete()
        else
            self:Reorganize()
        end
    end
end

---@param addition boolean?
function EHIPlayerPingTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        if addition then
            return
        end
        local _, peer_data = next(self._peers) ---@cast peer_data -?
        self:AnimateTextPosition(0, self._default_bg_size, peer_data.label, true)
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
        end
    elseif addition then
        self:AnimateMovement(self._anim_params.PanelSizeIncreaseHalf)
        self:AlignTextOnHalfPos()
    else
        self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
        self:AlignTextOnHalfPos()
    end
end

function EHIPlayerPingTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        local peer_data = self._peers[i]
        if peer_data then
            self:AnimateTextPosition(self._default_bg_size_half * pos, self._default_bg_size_half, peer_data.label, true)
            pos = pos + 1
        end
    end
end

function EHIPlayerPingTracker:AddTrackerToUpdate()
    managers.hud:add_updator(self._id, self._update_callback)
end

function EHIPlayerPingTracker:RemoveTrackerFromUpdate()
    managers.hud:remove_updator(self._id)
end

function EHIPlayerPingTracker:CleanupOnHide()
    self._time = self._ping_t_refresh
    self._peers = nil
end
EHIPlayerPingTracker.MissionEnd = EHIPlayerPingTracker.RemoveTrackerFromUpdate