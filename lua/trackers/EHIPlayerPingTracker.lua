---@class EHIPlayerPingTracker : EHITracker
---@field super EHITracker
EHIPlayerPingTracker = class(EHITracker)
EHIPlayerPingTracker._needs_update = false
EHIPlayerPingTracker._init_create_text = false
EHIPlayerPingTracker._forced_icons = { "ping" }
EHIPlayerPingTracker._forced_hint_text = "ping"
EHIPlayerPingTracker._ping_t_refresh = EHI:GetOption("show_ping_tracker_refresh_t") --[[@as number]]
function EHIPlayerPingTracker:post_init(params)
    self._hide_on_delete = true
    self._peers = {} ---@type table<integer, { peer: NetworkPeer, label: Text }>
    self._n_of_peers = 0
    self._update_callback = callback(self, self, "update")
    self:SetMovement(self._anim_params.PanelSizeIncreaseHalf)
    self._default_bg_size = self._bg_box:w()
    self._default_bg_size_half = self._default_bg_size / 2
end

function EHIPlayerPingTracker:PlayerSpawned()
    EHIPlayerPingTracker.super.PlayerSpawned(self)
    local session = managers.network:session()
    self._local_peer_id = session:local_peer():id()
    for _, peer in pairs(session:peers()) do
        self:AddPeer(peer)
    end
    Hooks:PostHook(NetworkPeer, "init", "EHI_NetworkPeer_init", function(peer, ...)
        self._peers = self._peers or {}
        self:AddPeer(peer)
    end)
    Hooks:PostHook(NetworkPeer, "destroy", "EHI_NetworkPeer_destroy", function(peer, ...)
        if self._peers then
            self:RemovePeer(peer:id())
        end
    end)
    EHI:AddEndGameCallback(function()
        self:MissionEnd()
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
        local pos, assault_exists, drama_exists = 0, managers.ehi_assault:Exists(), self._parent_class:Exists("Drama")
        if assault_exists and drama_exists then
            pos = 2
        elseif assault_exists or drama_exists then
            pos = 1
        end
        self._parent_class:RunTracker(self._id, nil, pos)
        self:AddTrackerToUpdate()
    else
        self:Reorganize(true)
    end
end

---@param peer_id integer
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

function EHIPlayerPingTracker:MissionEnd()
    self:RemoveTrackerFromUpdate()
    Hooks:RemovePostHook("EHI_NetworkPeer_init")
    Hooks:RemovePostHook("EHI_NetworkPeer_destroy") -- Remove this PostHook as it may cause a crash when a peer is removed and panel is no longer valid
end