---@alias EHIMinionTracker.PeerData { label: PanelText, minions: table<string, boolean> }

---@class EHIMinionTracker : EHITracker
---@field super EHITracker
EHIMinionTracker = class(EHITracker)
EHIMinionTracker._forced_hint_text = "converts"
EHIMinionTracker._forced_icons = { "minion" }
EHIMinionTracker._needs_update = false
EHIMinionTracker._init_create_text = false
EHIMinionTracker._SHOW_MINION_HEALTH = EHI:GetOption("show_minion_health") --[[@as boolean]]
function EHIMinionTracker:post_init(...)
    self._n_of_peers = 0
    self._peers = {} ---@type table<number, EHIMinionTracker.PeerData>
    self._default_panel_w = self._panel:w()
    self._panel_w = self._default_panel_w
end

function EHIMinionTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for i, peer in pairs(self._peers) do
        peer.label:set_color(self._parent_class:GetPeerColorByPeerID(i))
    end
end

function EHIMinionTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        EHIMinionTracker.super.SetIconColor(self, Color.white)
    else
        local peer_id, _ = next(self._peers)
        EHIMinionTracker.super.SetIconColor(self, self._parent_class:GetPeerColorByPeerID(peer_id))
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
---@param hint_move_size number?
function EHIMinionTracker:AnimateMovement(addition, hint_move_size)
    hint_move_size = hint_move_size or self._default_bg_size_half
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconsX()
    self:AnimateAdjustHintX(addition and hint_move_size or -hint_move_size)
end

function EHIMinionTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        local peer_data = self._peers[i]
        if peer_data then
            peer_data.label:set_w(self._default_bg_size_half)
            peer_data.label:set_x(self._default_bg_size_half * pos)
            pos = pos + 1
        end
    end
    if self._minion_health then
        self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], self._minion_health_second and self._minion_health[self._minion_health_second])
    end
end

---@param first_minion PanelText
---@param second_minion PanelText?
function EHIMinionTracker:AlignMinionTextOnHalfPos(first_minion, second_minion)
    local right = self._bg_box:right() - self._bg_box:x()
    if second_minion then
        second_minion:set_w(self._default_bg_size_half)
        second_minion:set_right(right - self._default_bg_size_half)
        self:FitTheText(second_minion)
        first_minion:set_w(self._default_bg_size_half)
    else
        first_minion:set_w(self._default_bg_size)
    end
    first_minion:set_right(right)
    self:FitTheText(first_minion)
end

---@param addition boolean?
function EHIMinionTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        if addition then
            return
        end
        local _, peer_data = next(self._peers) ---@cast peer_data -?
        peer_data.label:set_color(Color.white)
        peer_data.label:set_x(0)
        peer_data.label:set_w(self._bg_box:w() - (self._minion_health and self._default_bg_size or 0))
        self:FitTheText(peer_data.label)
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._bg_box:set_w(self._default_bg_size * (self._minion_health and 2 or 1))
            self:AnimateMovement()
            if self._minion_health then
                self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], self._minion_health_second and self._minion_health[self._minion_health_second])
            end
        end
    elseif addition then
        self._panel_w = self._panel_w + self._default_bg_size_half
        self:SetBGSize(self._default_bg_size_half, "add", true)
        self:AnimateMovement(true)
        self:AlignTextOnHalfPos()
    else
        self._panel_w = self._panel_w - self._default_bg_size_half
        self:SetBGSize(self._default_bg_size_half, "short", true)
        self:AnimateMovement()
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
    local peer = table.remove_key(self._peers, peer_id) ---@cast peer -?
    self._bg_box:remove(peer.label)
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

---@param peer_data EHIMinionTracker.PeerData
function EHIMinionTracker:FormatUnique(peer_data)
    peer_data.label:set_text(tostring(table.size(peer_data.minions)))
    self:FitTheText(peer_data.label)
end

---@param key string
function EHIMinionTracker:AddFirstLocalMinion(key)
    self._minion_health = {} ---@type table<string, PanelText>
    self._minion_health_first = key
    self._n_minion_health = 1
    self._default_panel_w = self._default_panel_w + self._default_bg_size
    self._panel_w = self._panel_w + self._default_bg_size
    self:SetBGSize(nil, "add", false, self._n_of_peers > 0)
    self:ChangeTrackerWidth(self._panel_w)
    if self._n_of_peers == 0 then -- First minion is for the local_peer; no need to animate
        if self._VERTICAL_ANIM_W_LEFT or self._HORIZONTAL_RIGHT_TO_LEFT then
            self._panel:set_x(self._panel:x() - self._default_bg_size)
        end
        if self._HORIZONTAL_LEFT_TO_RIGHT then
            if self._hint then
                self._hint:set_w(self._bg_box:w())
                self:FitTheText(self._hint, 18)
            end
        else
            self:AdjustHintX(self._VERTICAL_ANIM_W_LEFT and -self._default_bg_size or self._default_bg_size)
            if self._HORIZONTAL_RIGHT_TO_LEFT then
                self:AnimateAdjustHintX(0, false)
            end
        end
    else
        self:AnimateMovement(true, self._default_bg_size)
    end
    local minion_text = self:CreateText({ text = "100%" })
    minion_text:set_w(self._default_bg_size)
    minion_text:set_right(self._bg_box:right() + (self._n_of_peers >= 2 and self._default_bg_size_half or 0) - self._bg_box:x())
    self:FitTheText(minion_text)
    self._minion_health[key] = minion_text
end

---@param key string
function EHIMinionTracker:AddSecondLocalMinion(key)
    self._n_minion_health = 2
    self._minion_health_second = key
    local minion_text = self:CreateText({ text = "100%" })
    self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], minion_text)
    self._minion_health[key] = minion_text
end

---@param key string
---@param peer_id number
---@param local_peer boolean
function EHIMinionTracker:AddMinion(key, peer_id, local_peer)
    if not key then
        return
    end
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.minions[key] = true
        self:FormatUnique(peer_data)
        self:AnimateBG()
        if local_peer and self._SHOW_MINION_HEALTH then
            self:AddSecondLocalMinion(key)
        end
        return
    end
    peer_data =
    {
        label = self:CreateText(),
        minions = { [key] = true }
    }
    if local_peer and self._SHOW_MINION_HEALTH then
        self:AddFirstLocalMinion(key)
    end
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
---@param unit UnitEnemy
function EHIMinionTracker:MinionDamaged(key, unit)
    local minion_text = self._minion_health[key]
    if minion_text then
        local percent = unit:character_damage():health_ratio()
        minion_text:set_text(string.format("%d%%", self._parent_class:RoundChanceNumber(percent)))
        self:FitTheText(minion_text)
    end
end

---@param key string
function EHIMinionTracker:RemoveMinion(key)
    if not key then
        return
    end
    for id, data in pairs(self._peers) do
        if data.minions[key] then
            data.minions[key] = nil
            local local_minion = self._minion_health and self._minion_health[key]
            if local_minion then
                local_minion:parent():remove(local_minion)
                self._n_minion_health = self._n_minion_health - 1
                if self._minion_health_first == key then
                    self._minion_health_first = self._minion_health_second
                end
                self._minion_health_second = nil
                self._minion_health[key] = nil
                if self._n_minion_health == 0 and self._n_of_peers > 1 then -- Skip shortening the tracker if the last peer is local
                    self._minion_health = nil
                    self._minion_health_first = nil
                    self:SetBGSize(self._default_bg_size, "short")
                    self._panel_w = self._panel_w - self._default_bg_size
                    self._default_panel_w = self._default_panel_w - self._default_bg_size
                    self:ChangeTrackerWidth()
                    self:AdjustHintX(self._VERTICAL_ANIM_W_LEFT and self._default_bg_size or -self._default_bg_size)
                end
            end
            if table.size(data.minions) == 0 then
                self:RemovePeer(id)
            else
                self:FormatUnique(data)
                self:AnimateBG()
                if local_minion then
                    local other_minion = self._minion_health and self._minion_health_first and self._minion_health[self._minion_health_first]
                    if other_minion then
                        self:AlignMinionTextOnHalfPos(other_minion)
                    end
                end
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

---@class EHIMinionHealthOnlyTracker : EHIMinionTracker
---@field super EHIMinionTracker
EHIMinionHealthOnlyTracker = class(EHIMinionTracker)
function EHIMinionHealthOnlyTracker:AddMinion(key, peer_id, local_peer)
    if not key then
        return
    end
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.minions[key] = true
        self:AnimateBG()
        self:AddSecondLocalMinion(key)
        return
    end
    peer_data =
    {
        minions = { [key] = true }
    }
    self._minion_health = {} ---@type table<string, PanelText>
    self._minion_health_first = key
    self._n_minion_health = 1
    local minion_text = self:CreateText({ text = "100%" })
    self:AlignMinionTextOnHalfPos(minion_text)
    self._minion_health[key] = minion_text
    self._peers[peer_id] = peer_data
    self:SetIconColor()
end

function EHIMinionHealthOnlyTracker:RemovePeer(peer_id)
    self:delete()
end

function EHIMinionHealthOnlyTracker:FormatUnique(peer_data)
end

---@class EHITotalMinionTracker : EHIMinionTracker
---@field super EHIMinionTracker
EHITotalMinionTracker = class(EHIMinionTracker)
EHITotalMinionTracker._init_create_text = true
function EHITotalMinionTracker:AddMinion(key, peer_id, local_peer)
    if not key then
        return
    end
    self._n_of_minions = (self._n_of_minions or 0) + 1
    self._text:set_text(tostring(self._n_of_minions))
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.minions[key] = true
        self:AnimateBG()
        if local_peer and self._SHOW_MINION_HEALTH then
            self:AddSecondLocalMinion(key)
        end
        return
    end
    peer_data =
    {
        minions = { [key] = true }
    }
    if local_peer and self._SHOW_MINION_HEALTH then
        self:AddFirstLocalMinion(key)
    end
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self._peers[peer_id] = peer_data
end

---@param peer_id number
function EHITotalMinionTracker:RemovePeer(peer_id)
    if not self._peers[peer_id] then
        return
    end
    self._n_of_peers = self._n_of_peers - 1
    if self._n_of_peers == 0 then
        self:delete()
        return
    end
    self._peers[peer_id] = nil
    self:FormatUnique()
    self:AnimateBG()
end

function EHITotalMinionTracker:FormatUnique(peer_data)
    self._n_of_minions = self._n_of_minions - 1
    self._text:set_text(tostring(self._n_of_minions))
end