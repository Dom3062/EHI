---@alias EHIMinionTracker.PeerData { label: PanelText, minions: table<string, boolean> }
---@alias EHIMinionTracker.LocalMinion { key: string, text: PanelText }

---@class EHIMinionTracker : EHITracker
---@field super EHITracker
EHIMinionTracker = class(EHITracker)
EHIMinionTracker._forced_hint_text = "converts"
EHIMinionTracker._forced_icons = { "minion" }
EHIMinionTracker._update = false
EHIMinionTracker._init_create_text = false
EHIMinionTracker._SHOW_MINION_HEALTH = EHI:GetOption("show_minion_health")
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
        peer.label:set_color(tweak_data.chat_colors[i] or Color.white)
    end
end

function EHIMinionTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        EHIMinionTracker.super.SetIconColor(self, Color.white)
    else
        local peer_id, _ = next(self._peers)
        EHIMinionTracker.super.SetIconColor(self, tweak_data.chat_colors[peer_id] or Color.white)
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
    self:AlignMinionTextOnHalfPos()
end

function EHIMinionTracker:AlignMinionTextOnHalfPos()
    if self._minion_health then
        if self._n_minion_health > 1 then
            local m_pos = 0
            for _, value in ipairs(self._minion_health) do
                value.text:set_w(self._default_bg_size_half)
                value.text:set_right(self._bg_box:right() - (self._default_bg_size_half * m_pos))
                self:FitTheText(value.text)
                m_pos = m_pos + 1
            end
        else
            local _, value = next(self._minion_health)
            value.text:set_right(self._bg_box:right())
            self:FitTheText(value.text)
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
        peer_data.label:set_w(self._bg_box:w() - (self._minion_health and self._default_bg_size or 0))
        self:FitTheText(peer_data.label)
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._bg_box:set_w(self._default_bg_size * (self._minion_health and 2 or 1))
            self:AnimateMovement()
            self:AlignMinionTextOnHalfPos()
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
    local peer = table.remove_key(self._peers, peer_id)
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
            self._n_minion_health = self._n_minion_health + 1
            local minion_text = self:CreateText({ text = "100%" })
            table.insert(self._minion_health, {
                key = key,
                text = minion_text
            })
            self._minion_text_cache[key] = minion_text
            self:AlignMinionTextOnHalfPos()
        end
        return
    end
    peer_data =
    {
        label = self:CreateText(),
        minions = { [key] = true }
    }
    if local_peer and self._SHOW_MINION_HEALTH then
        self._minion_health = {} ---@type EHIMinionTracker.LocalMinion[]
        self._minion_text_cache = {}
        self._n_minion_health = 1
        self._default_panel_w = self._default_panel_w + self._default_bg_size
        self._panel_w = self._panel_w + self._default_bg_size
        self:SetBGSize()
        self:ChangeTrackerWidth(self._panel_w)
        self:SetIconsX()
        self:AdjustHintX(self._default_bg_size)
        local minion_text = self:CreateText({ text = "100%" })
        minion_text:set_w(self._default_bg_size)
        minion_text:set_right(self._bg_box:right() + (self._n_of_peers >= 2 and self._default_bg_size_half or 0))
        self:FitTheText(minion_text)
        table.insert(self._minion_health, {
            key = key,
            text = minion_text
        })
        self._minion_text_cache[key] = minion_text
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
    local minion_text = self._minion_text_cache[key]
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
            local local_peer, local_minion
            if self._minion_health then
                for i, value in ipairs(self._minion_health) do
                    if value.key == key then
                        local_minion = value
                        local_peer = true
                        table.remove(self._minion_health, i)
                        self._n_minion_health = self._n_minion_health - 1
                        break
                    end
                end
                if table.size(self._minion_health) == 0 and self._n_of_peers > 1 then -- Skip shortening the tracker if the last peer is local
                    self._minion_health = nil
                    self:SetBGSize(self._default_bg_size, "short")
                    self:SetIconsX()
                    self._panel_w = self._panel_w - self._default_bg_size
                    self._default_panel_w = self._default_panel_w - self._default_bg_size
                    self:ChangeTrackerWidth()
                    self:AdjustHintX(-self._default_bg_size)
                end
            end
            if local_minion then
                local text = local_minion.text
                text:parent():remove(text)
                self._minion_text_cache[key] = nil
            end
            if table.size(data.minions) == 0 then
                self:RemovePeer(id)
            else
                self:FormatUnique(data)
                self:AnimateBG()
                if local_peer then
                    local _, other_minion = next(self._minion_health)
                    other_minion.text:set_w(self._default_bg_size)
                    other_minion.text:set_right(self._bg_box:right())
                    self:FitTheText(other_minion.text)
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
        peer_data.minions[key] = amount
        self:AnimateBG()
        self._n_minion_health = self._n_minion_health + 1
        local minion_text = self:CreateText({ text = "100%" })
        table.insert(self._minion_health, {
            key = key,
            text = minion_text
        })
        self._minion_text_cache[key] = minion_text
        self:AlignMinionTextOnHalfPos()
        return
    end
    peer_data =
    {
        minions = { [key] = amount }
    }
    self._minion_health = {} ---@type EHIMinionTracker.LocalMinion[]
    self._minion_text_cache = {}
    self._n_minion_health = 1
    local minion_text = self:CreateText({ text = "100%" })
    minion_text:set_w(self._default_bg_size)
    minion_text:set_right(self._bg_box:right())
    self:FitTheText(minion_text)
    table.insert(self._minion_health, {
        key = key,
        text = minion_text
    })
    self._minion_text_cache[key] = minion_text
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
            self._n_minion_health = self._n_minion_health + 1
            local minion_text = self:CreateText({ text = "100%" })
            table.insert(self._minion_health, {
                key = key,
                text = minion_text
            })
            self._minion_text_cache[key] = minion_text
            self:AlignMinionTextOnHalfPos()
        end
        return
    end
    peer_data =
    {
        minions = { [key] = true }
    }
    if local_peer and self._SHOW_MINION_HEALTH then
        self._minion_health = {} ---@type EHIMinionTracker.LocalMinion[]
        self._minion_text_cache = {}
        self._n_minion_health = 1
        self._default_panel_w = self._default_panel_w + self._default_bg_size
        self._panel_w = self._panel_w + self._default_bg_size
        self:SetBGSize()
        self:ChangeTrackerWidth(self._panel_w)
        if self._n_of_minions == 1 then -- First minion is for the local_peer; no need to animate
            self:SetIconsX()
            self:AdjustHintX(self._default_bg_size)
        else
            self:AnimateMovement(true, self._default_bg_size)
        end
        local minion_text = self:CreateText({ text = "100%" })
        minion_text:set_w(self._default_bg_size)
        minion_text:set_right(self._bg_box:right())
        self:FitTheText(minion_text)
        table.insert(self._minion_health, {
            key = key,
            text = minion_text
        })
        self._minion_text_cache[key] = minion_text
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