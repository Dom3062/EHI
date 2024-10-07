---@alias EHIMinionTracker.PeerData { label: PanelText, minions: table<string, number> }

---@class EHIMinionTracker : EHITracker
---@field super EHITracker
EHIMinionTracker = class(EHITracker)
EHIMinionTracker._forced_hint_text = "converts"
EHIMinionTracker._forced_icons = { "minion" }
EHIMinionTracker._update = false
EHIMinionTracker._init_create_text = false
function EHIMinionTracker:post_init(...)
    self._n_of_peers = 0
    self._peers = {} ---@type table<number, EHIMinionTracker.PeerData>
    self._default_panel_w = self._panel:w()
    self._panel_half = self._bg_box:w() / 2
    self._panel_w = self._default_panel_w
end

function EHIMinionTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for i, peer in pairs(self._peers) do
        peer.label:set_color(tweak_data.chat_colors[i] or Color.white)
    end
end

function EHIMinionTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        self._icon1:set_color(Color.white)
    else
        local peer_id, _ = next(self._peers)
        self._icon1:set_color(tweak_data.chat_colors[peer_id] or Color.white)
    end
end

function EHIMinionTracker:RedrawPanel()
    for _, text in ipairs(self._bg_box:children()) do ---@cast text PanelText
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

---@param addition boolean?
function EHIMinionTracker:AnimateMovement(addition)
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconX(self._panel_w - self._icon_size_scaled)
    self:AnimateAdjustHintX(addition and self._panel_half or -self._panel_half)
end

function EHIMinionTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        local peer_data = self._peers[i]
        if peer_data then
            peer_data.label:set_w(self._panel_half)
            peer_data.label:set_x(self._panel_half * pos)
            pos = pos + 1
        end
    end
end

---@param addition boolean?
function EHIMinionTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        if addition then
            return
        end
        local _, peer_data = next(self._peers)
        peer_data.label:set_color(Color.white)
        peer_data.label:set_x(0)
        peer_data.label:set_w(self._bg_box:w())
        self:FitTheText(peer_data.label)
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self:AnimateMovement()
            self._bg_box:set_w(self._default_bg_size)
        end
    elseif addition then
        self._panel_w = self._panel_w + self._panel_half
        self:AnimateMovement(true)
        self:SetBGSize(self._panel_half, "add", true)
        self:AlignTextOnHalfPos()
    else
        self._panel_w = self._panel_w - self._panel_half
        self:AnimateMovement()
        self:SetBGSize(self._panel_half, "short", true)
        self:AlignTextOnHalfPos()
    end
end

---@param peer_id number
function EHIMinionTracker:RemovePeer(peer_id)
    if not self._peers[peer_id] then
        return
    end
    self._n_of_peers = self._n_of_peers - 1
    if self._n_of_peers == 0 then
        self:delete()
        return
    end
    local peer = table.remove_key(self._peers, peer_id)
    self._bg_box:remove(peer.label)
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

---@param peer_data EHIMinionTracker.PeerData
function EHIMinionTracker:FormatUnique(peer_data)
    peer_data.label:set_text(tostring(self:GetNumberOfMinions(peer_data.minions)))
    self:FitTheText(peer_data.label)
end

---@param minions table<string, number>
function EHIMinionTracker:GetNumberOfMinions(minions)
    local total = 0
    for _, value in pairs(minions) do
        if value > 0 then
            total = total + value
        end
    end
    return total
end

---@param key string
---@param amount number
---@param peer_id number
function EHIMinionTracker:AddMinion(key, amount, peer_id)
    if not key then
        return
    end
    if self._peers[peer_id] then
        local peer_data = self._peers[peer_id]
        peer_data.minions[key] = amount
        self:FormatUnique(peer_data)
        self:AnimateBG()
        return
    end
    local peer_data =
    {
        label = self:CreateText(),
        minions = { [key] = amount }
    }
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self._peers[peer_id] = peer_data
    self:FormatUnique(peer_data)
    self:Reorganize(true)
    self:SetIconColor()
    self:SetTextPeerColor()
end

---@param key string
function EHIMinionTracker:RemoveMinion(key)
    if not key then
        return
    end
    for id, data in pairs(self._peers) do
        if data.minions[key] then
            data.minions[key] = 0
            if self:GetNumberOfMinions(data.minions) == 0 then
                self:RemovePeer(id)
            else
                self:FormatUnique(data)
                self:AnimateBG()
            end
            break
        end
    end
end

---@param peer_id number
---@param color Color
function EHIMinionTracker:UpdatePeerColor(peer_id, color)
    if self._n_of_peers == 1 or not color then
        return
    end
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.label:set_color(color)
    end
end