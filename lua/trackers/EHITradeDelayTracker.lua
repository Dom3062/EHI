---@class EHITradeDelayTracker : EHITracker
---@field super EHITracker
EHITradeDelayTracker = class(EHITracker)
EHITradeDelayTracker._update = false
EHITradeDelayTracker._forced_icons = { "mugshot_in_custody" }
function EHITradeDelayTracker:init(panel, params)
    self._pause_t = 0
    self._n_of_peers = 0
    self._peers = {}
    self._tick = 0
    EHITradeDelayTracker.super.init(self, panel, params)
    self._default_panel_w = self._panel:w()
    self._default_bg_box_w = self._time_bg_box:w()
    self._panel_half = self._default_bg_box_w / 2
    self._panel_w = self._default_panel_w
    self._time_bg_box:remove(self._text)
end

function EHITradeDelayTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._time_bg_box:child("text" .. i):set_color(color)
        end
    end
end

function EHITradeDelayTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        self._icon1:set_color(Color.white)
    else
        local peer_id, _ = next(self._peers)
        local color = tweak_data.chat_colors[peer_id] or Color.white
        self._icon1:set_color(color)
    end
end

function EHITradeDelayTracker:Refresh()
    for _, text in ipairs(self._time_bg_box:children()) do
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHITradeDelayTracker:AnimateMovement()
    self:SetPanelWAndRefresh(self._panel_w)
    self._parent_class:ChangeTrackerWidth(self._id, self._panel_w)
    self:SetIconX(self._panel_w - self._icon_size_scaled)
end

function EHITradeDelayTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        local text = self._time_bg_box:child("text" .. i)
        if text then
            text:set_w(self._panel_half)
            text:set_x(self._panel_half * pos)
            self:FitTheText(text)
            pos = pos + 1
        end
    end
end

function EHITradeDelayTracker:AddPeerCustodyTime(peer_id, time, civilians_killed)
    local kills = civilians_killed or 1
    self._peers[peer_id] =
    {
        t = time,
        in_custody = false,
        civilians_killed = kills
    }
    self._time_bg_box:text({
        name = "text" .. peer_id,
        text = "",
        align = "center",
        vertical = "center",
        w = self._default_bg_box_w,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = Color.white
    })
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self:FormatUnique(time, peer_id, kills)
    self:Reorganize(true)
    self:SetIconColor()
    self:SetTextPeerColor()
end

function EHITradeDelayTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        return
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._time_bg_box:set_w(self._default_bg_box_w)
            self:AnimateMovement()
        end
    elseif addition then
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w + self._panel_half
        self._time_bg_box:set_w(self._time_bg_box:w() + self._panel_half)
        self:AnimateMovement()
    else
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w - self._panel_half
        self._time_bg_box:set_w(self._time_bg_box:w() - self._panel_half)
        self:AnimateMovement()
    end
end

function EHITradeDelayTracker:SetPeerCustodyTime(peer_id, time, civilians_killed, anim)
    self._peers[peer_id].t = time
    local killed = self._peers[peer_id].civilians_killed
    killed = civilians_killed or (killed + 1)
    self._peers[peer_id].civilians_killed = killed
    self:FormatUnique(time, peer_id, killed)
    self:FitTheTextUnique(peer_id)
    if anim then
        self:AnimateBG()
    end
end

function EHITradeDelayTracker:IncreasePeerCustodyTime(peer_id, time)
    local t = self:GetPeerData(peer_id, "t", 0)
    self:SetPeerCustodyTime(peer_id, t + time, nil, true)
end

function EHITradeDelayTracker:UpdatePeerCustodyTime(peer_id, time, civilians_killed)
    local t = self:GetPeerData(peer_id, "t", 0)
    if t == time then -- Don't blink on the player, son
        return
    end
    self:SetPeerCustodyTime(peer_id, time, civilians_killed)
end

function EHITradeDelayTracker:AddOrUpdatePeerCustodyTime(peer_id, time, civilians_killed, in_custody)
    if self:PeerExists(peer_id) then
        self:UpdatePeerCustodyTime(peer_id, time, civilians_killed)
    else
        self:AddPeerCustodyTime(peer_id, time, civilians_killed)
    end
    if in_custody then
        self:SetPeerInCustody(peer_id)
    end
end

function EHITradeDelayTracker:SetTick(t)
    --[[
        This function makes Trade Delay accurate because of the braindead use of the "update" loop in TradeManager
        Why is OVK using another variable to "count down" the remaining time ? As shown below:
        "self._trade_counter_tick = self._trade_counter_tick - dt" (which later subtracts 1s from the delay when self._trade_counter_tick <= 0)
        when they could just simply do:
        "crim.respawn_penalty - dt"
        Much faster and cleaner imo

        But why bother ?
        1. This time correction actually makes the tracker accurate
        2. To not confuse players why the tracker is blinking after a teammate is taken to custody or during count down
        Eg.:
        2:35 -> 2:36
    ]]
    self._tick = t
end

function EHITradeDelayTracker:SetTradePause(t)
    self._pause_t = t
end

function EHITradeDelayTracker:RemovePeerFromCustody(peer_id)
    if not self:PeerExists(peer_id) then
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
        for i = 1, HUDManager.PLAYER_PANEL, 1 do
            local text = self._time_bg_box:child("text" .. i)
            if text then
                text:set_font_size(self._panel:h() * self._text_scale)
                text:set_color(Color.white)
                text:set_x(0)
                text:set_w(self._time_bg_box:w())
                self:FitTheText(text)
                break
            end
        end
    end
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

function EHITradeDelayTracker:SetPeerInCustody(peer_id)
    if not self:PeerExists(peer_id) then
        return
    end
    self._peers[peer_id].in_custody = true
end

function EHITradeDelayTracker:PeerExists(peer_id)
    return self._peers[peer_id] ~= nil
end

function EHITradeDelayTracker:GetPeerData(peer_id, field_name, default_value)
    if self:PeerExists(peer_id) then
        return self._peers[peer_id][field_name] or default_value
    end
    return default_value
end

function EHITradeDelayTracker:FitTheTextUnique(i)
    self:FitTheText(self._time_bg_box:child("text" .. i))
end

if EHI:GetOption("show_trade_delay_amount_of_killed_civilians") then
    local math_floor = math.floor
    local string_format = string.format
    if EHI:GetOption("time_format") == 1 then
        EHITradeDelayTracker.FormatUnique = function(self, time, peer_id, civilians_killed)
            local t = math_floor(time * 10) / 10
            local text = self._time_bg_box:child("text" .. peer_id)
            local s
            if t < 0 then
                s = string_format("%d (%d)", 0, civilians_killed)
            elseif t < 10 then
                s = string_format("%.1f (%d)", t, civilians_killed)
            else
                s = string_format("%d (%d)", t, civilians_killed)
            end
            text:set_text(s)
        end
    else
        EHITradeDelayTracker.FormatUnique = function(self, time, peer_id, civilians_killed)
            local t = math_floor(time * 10) / 10
            local text = self._time_bg_box:child("text" .. peer_id)
            local s
            if t < 0 then
                s = string_format("%d (%d)", 0, civilians_killed)
            elseif t < 10 then
                s = string_format("%.1f (%d)", t, civilians_killed)
            elseif t < 60 then
                s = string_format("%d (%d)", t, civilians_killed)
            else
                s = string_format("%d:%02d (%d)", t / 60, t % 60, civilians_killed)
            end
            text:set_text(s)
        end
    end
else
    local math_floor = math.floor
    local string_format = string.format
    if EHI:GetOption("time_format") == 1 then
        EHITradeDelayTracker.FormatUnique = function(self, time, peer_id, civilians_killed)
            local t = math_floor(time * 10) / 10
            local text = self._time_bg_box:child("text" .. peer_id)
            local s
            if t < 0 then
                s = string_format("%d", 0)
            elseif t < 10 then
                s = string_format("%.1f", t)
            else
                s = string_format("%d", t)
            end
            text:set_text(s)
        end
    else
        EHITradeDelayTracker.FormatUnique = function(self, time, peer_id, civilians_killed)
            local t = math_floor(time * 10) / 10
            local text = self._time_bg_box:child("text" .. peer_id)
            local s
            if t < 0 then
                s = string_format("%d", 0)
            elseif t < 10 then
                s = string_format("%.1f", t)
            elseif t < 60 then
                s = string_format("%d", t)
            else
                s = string_format("%d:%02d", t / 60, t % 60)
            end
            text:set_text(s)
        end
    end
end

function EHITradeDelayTracker:update(t, dt)
    if self._tick > 0 then
        self._tick = self._tick - dt
        return
    end
    if self._pause_t > 0 then
        self._pause_t = self._pause_t - dt
        return
    end
    for peer_id, data in pairs(self._peers) do
        if data.in_custody then
            local time = data.t - dt
            if time <= 0 then
                self:RemovePeerFromCustody(peer_id)
            else
                data.t = time
                self:FormatUnique(time, peer_id, data.civilians_killed)
                self:FitTheTextUnique(peer_id)
            end
        end
    end
end

function EHITradeDelayTracker:SetAITrade(trade, t, force_t)
    if trade then
        if not self._trade then
            self:SetTick(t)
            self:AddTrackerToUpdate()
        end
        if force_t then
            self:SetTick(t)
        end
        self._ai_trade = true
    else
        if not self._trade then
            self:RemoveTrackerFromUpdate()
        end
        self._ai_trade = false
    end
end

function EHITradeDelayTracker:SetTrade(trade, t, force_t)
    if trade then
        if not self._ai_trade then
            self:SetTick(t)
            self:AddTrackerToUpdate()
        end
        if force_t then
            self:SetTick(t)
        end
        self._trade = true
    else
        if not self._ai_trade then
            self:RemoveTrackerFromUpdate()
        end
        self._trade = false
    end
end