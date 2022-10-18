EHIMinionTracker = class(EHITracker)
EHIMinionTracker._forced_icons = { "minion" }
EHIMinionTracker._update = false
function EHIMinionTracker:init(panel, params)
    self._n_of_peers = 0
    self._panel_size = 2
    self._icon_remove = 0
    self._peers = {}
    EHIMinionTracker.super.init(self, panel, params)
    self._default_panel_w = self._panel:w()
    self._panel_w = self._default_panel_w
    self._time_bg_box:remove(self._text)
end

function EHIMinionTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._time_bg_box:child("text" .. i):set_color(color)
        end
    end
end

function EHIMinionTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        self._icon1:set_color(Color.white)
    else
        for i = 0, HUDManager.PLAYER_PANEL, 1 do
            if self._time_bg_box:child("text" .. i) then
                local color = tweak_data.chat_colors[i] or Color.white
                self._icon1:set_color(color)
                break
            end
        end
    end
end

function EHIMinionTracker:SetTextSize()
    if self._n_of_peers == 1 then
        return
    end
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_w(self._icon_size_scaled)
            self:FitTheTextUnique(i)
        end
    end
    if self._n_of_peers % 2 == 0 then
        return
    end
    for i = HUDManager.PLAYER_PANEL, 0, -1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_font_size(self._panel:h() * self._text_scale)
            self._time_bg_box:child("text" .. i):set_w(self._time_bg_box:w())
            self:FitTheTextUnique(i)
            break
        end
    end
end

function EHIMinionTracker:Reorganize()
    if self._n_of_peers == 1 then
        return
    end
    local old_panel_size = self._panel_size
    if self._n_of_peers > self._panel_size then
        self._panel_size = self._panel_size * 2
        self._panel_w = self._panel_w * 3 -- Fixes text being cut off after animation
        self:SetPanelW(self._panel_w)
        self._time_bg_box:set_w(self._time_bg_box:w() * 2)
        self._icon_remove = self._icon_remove + 1
    end
    if self._n_of_peers < self._panel_size and self._n_of_peers % 2 == 0 then
        self._panel_size = self._panel_size / 2
        self._panel_w = self._panel_w / 3 -- Fixes text being cut off after animation
        self:SetPanelW(self._panel_w)
        self._time_bg_box:set_w(self._time_bg_box:w() / 2)
        self._icon_remove = self._icon_remove - 1
    end
    local bg_w = self._time_bg_box:w()
    if old_panel_size ~= self._panel_size then
        self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
        self:SetIconX(bg_w + self._gap_scaled)
    end
    local half = bg_w / self._panel_size
    local pos = 0
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_x(half * pos)
            pos = pos + 1
        end
    end
    if old_panel_size > self._panel_size then
        for i = HUDManager.PLAYER_PANEL, 0, -1 do
            if self._time_bg_box:child("text" .. i) then
                self._time_bg_box:child("text" .. i):set_w(self._icon_size_scaled)
                self:FitTheTextUnique(i)
                break
            end
        end
    elseif old_panel_size == self._panel_size and self._n_of_peers % 2 ~= 0 then
        for i = HUDManager.PLAYER_PANEL, 0, -1 do
            if self._time_bg_box:child("text" .. i) then
                self._time_bg_box:child("text" .. i):set_font_size(self._panel:h() * self._text_scale)
                self._time_bg_box:child("text" .. i):set_w(half + half)
                self:FitTheTextUnique(i)
                break
            end
        end
    end
end

function EHIMinionTracker:GetPanelSize()
    return (self._default_panel_w * (self._panel_size / 2)) - (self._icon_gap_size_scaled * self._icon_remove) -- 32 + 5 (gap)
end

function EHIMinionTracker:RemovePeer(peer_id)
    if not self._peers[peer_id] then
        return
    end
    self._n_of_peers = self._n_of_peers - 1
    if self._n_of_peers == 0 then
        self:delete()
        return
    end
    self._peers[peer_id] = nil
    self._time_bg_box:remove(self._time_bg_box:child("text" .. peer_id))
    if self._n_of_peers == 1 then
        for i = 0, HUDManager.PLAYER_PANEL, 1 do
            if self._time_bg_box:child("text" .. i) then
                self._time_bg_box:child("text" .. i):set_font_size(self._panel:h() * self._text_scale)
                self._time_bg_box:child("text" .. i):set_color(Color.white)
                self._time_bg_box:child("text" .. i):set_x(0)
                self._time_bg_box:child("text" .. i):set_w(self._time_bg_box:w())
                self:FitTheTextUnique(i)
                break
            end
        end
    else
        --self:SetTextSize()
    end
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

function EHIMinionTracker:FitTheTextUnique(i)
    local text = self._time_bg_box:child("text" .. i)
    text:set_font_size(self._panel:h() * self._text_scale)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

function EHIMinionTracker:FormatUnique(peer_id)
    self._time_bg_box:child("text" .. peer_id):set_text(tostring(self:GetNumberOfMinions(peer_id)))
end

function EHIMinionTracker:GetNumberOfMinions(peer_id)
    local total = 0
    for _, value in pairs(self._peers[peer_id] or {}) do
        if value > 0 then
            total = total + value
        end
    end
    return total
end

function EHIMinionTracker:AddMinion(unit, key, amount, peer_id)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount, peer_id)
        return
    end
    if self._peers[peer_id] then
        self._peers[peer_id][key] = amount
        self:FormatUnique(peer_id)
        self:FitTheTextUnique(peer_id)
        self:AnimateBG()
        return
    end
    self._peers[peer_id] = { [key] = amount }
    self._time_bg_box:text({
        name = "text" .. peer_id,
        text = "",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = Color.white
    })
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self:SetTextSize()
    self:FormatUnique(peer_id)
    self:FitTheTextUnique(peer_id)
    self:Reorganize()
    self:SetIconColor()
    self:SetTextPeerColor()
end

function EHIMinionTracker:RemoveMinion(key)
    if not key then
        return
    end
    for peer, tbl in pairs(self._peers) do
        if tbl[key] then
            self._peers[peer][key] = 0
            if self:GetNumberOfMinions(peer) == 0 then
                self:RemovePeer(peer)
            else
                self:FormatUnique(peer)
                self:AnimateBG()
            end
            break
        end
    end
end

function EHIMinionTracker:UpdatePeerColors()
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._time_bg_box:child("text" .. i):set_color(color)
        end
    end
end