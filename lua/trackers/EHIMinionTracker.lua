---@alias EHIMinionTracker.PeerData { label: Text, minions: table<userdata, boolean> }

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
    self._peers = {} ---@type table<integer, EHIMinionTracker.PeerData>
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
    for _, text in ipairs(self._bg_box:children()) do ---@cast text Text
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHIMinionTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        local peer_data = self._peers[i]
        if peer_data then
            self:AnimateTextPosition(self._default_bg_size_half * pos, self._default_bg_size_half, peer_data.label)
            pos = pos + 1
        end
    end
    if self._minion_health then
        self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], self._minion_health_second and self._minion_health[self._minion_health_second])
    end
end

---@param first_minion Text
---@param second_minion Text?
function EHIMinionTracker:AlignMinionTextOnHalfPos(first_minion, second_minion)
    if not first_minion then
        return
    end
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
        self:AnimateTextPosition(0, self._default_bg_size, peer_data.label, true)
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
            if self._minion_health then
                self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], self._minion_health_second and self._minion_health[self._minion_health_second])
            end
        end
    elseif addition then
        self:AnimateMovement(self._anim_params.PanelSizeIncreaseHalf)
        self:AlignTextOnHalfPos()
    else
        self:AnimateMovement(self._anim_params.PanelSizeDecreaseHalf)
        self:AlignTextOnHalfPos()
    end
end

---@param peer_id integer
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

---@param key userdata
function EHIMinionTracker:AddFirstLocalMinion(key)
    self._minion_health = {} ---@type table<userdata, Text>
    self._minion_health_first = key
    self:AnimateOrSetMovement(self._anim_params.PanelSizeIncrease, self._n_of_peers == 0) -- If first minion is local_peer, no need to animate
    local minion_text = self:CreateText({ text = "100%" })
    minion_text:set_w(self._default_bg_size)
    minion_text:set_right(self._bg_box:right() + (self._n_of_peers >= 2 and self._default_bg_size_half or 0) - self._bg_box:x())
    self:FitTheText(minion_text)
    self._minion_health[key] = minion_text
end

---@param key userdata
function EHIMinionTracker:AddSecondLocalMinion(key)
    self._minion_health_second = key
    local minion_text = self:CreateText({ text = "100%" })
    self:AlignMinionTextOnHalfPos(self._minion_health[self._minion_health_first], minion_text)
    self._minion_health[key] = minion_text
end

---@param key userdata
---@param peer_id integer
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

---@param key userdata
---@param unit UnitEnemy
function EHIMinionTracker:MinionDamaged(key, unit)
    local minion_text = self._minion_health and self._minion_health[key]
    if minion_text then
        local percent = unit:character_damage():health_ratio()
        minion_text:set_text(string.format("%d%%", math.ehi_round_chance(percent)))
        self:FitTheText(minion_text)
    end
end

---@param key userdata
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
                if self._minion_health_first == key then
                    self._minion_health_first = self._minion_health_second
                end
                self._minion_health_second = nil
                self._minion_health[key] = nil
                if table.ehi_size(self._minion_health) == 0 and self._n_of_peers > 1 then -- Skip shortening the tracker if the last peer is local
                    self._minion_health = nil
                    self._minion_health_first = nil
                    self:AnimateMovement(self._anim_params.PanelSizeDecrease)
                end
            end
            if table.size(data.minions) == 0 then
                self:RemovePeer(id)
            else
                self:FormatUnique(data)
                self:AnimateBG()
                if local_minion then -- Just check if the killed minion is local, but DO NOT USE IT because the text is already removed above (variable still holds old reference to (now dead) text)
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

---@param peer_id integer
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
EHIMinionHealthOnlyTracker.FormatUnique = function(...) end
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
    self._minion_health = {} ---@type table<userdata, Text>
    self._minion_health_first = key
    local minion_text = self:CreateText({ text = "100%" })
    self:AlignMinionTextOnHalfPos(minion_text)
    self._minion_health[key] = minion_text
    self._peers[peer_id] = peer_data
    self:SetIconColor()
end

function EHIMinionHealthOnlyTracker:RemovePeer(peer_id)
    self:delete()
end

function EHIMinionHealthOnlyTracker:UpdatePeerColor(peer_id, color)
    if peer_id ~= managers.network:session():local_peer():id() or not color then
        return
    end
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.label:set_color(color)
    end
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

---@param peer_id integer
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

function EHITotalMinionTracker:UpdatePeerColor(peer_id, color)
end