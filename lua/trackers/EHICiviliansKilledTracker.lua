EHICiviliansKilledTracker = EHICiviliansKilledTracker or class(EHITracker)
EHICiviliansKilledTracker._update = false
function EHICiviliansKilledTracker:init(panel, params)
    self._n_of_peers_in_custody = 0
    self._panel_size = 2
    self._peer_text = {}
    self._peer_custody_time = {}
    self._peer_in_custody = {}
    self._peer_pos = {}
    self._tick = 0
    EHICiviliansKilledTracker.super.init(self, panel, params)
    self._time_bg_box:remove(self._text)
end

function EHICiviliansKilledTracker:SetTextPeerColor()
    if self._n_of_peers_in_custody == 1 then
        return
    end
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            local color = tweak_data.chat_colors[i] or Color.white
            self._time_bg_box:child("text" .. i):set_color(color)
        end
    end
end

function EHICiviliansKilledTracker:SetIconColor()
    if self._n_of_peers_in_custody >= 2 then
        self._icon1:set_color(Color.white)
    else
        local peer_id = self._peer_pos[1]
        local color = tweak_data.chat_colors[peer_id] or Color.white
        self._icon1:set_color(color)
    end
end

function EHICiviliansKilledTracker:SetTextSize()
    if self._n_of_peers_in_custody == 1 then
        return
    end
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_w(32 * self._scale)
            self:FitTheTextUnique(i)
        end
    end
    if self._n_of_peers_in_custody % 2 == 0 then
        return
    end
    for i = HUDManager.PLAYER_PANEL, 1, -1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_font_size(self._panel:h())
            self._time_bg_box:child("text" .. i):set_w(self._time_bg_box:w())
            self:FitTheTextUnique(i)
            break
        end
    end
end

function EHICiviliansKilledTracker:AddPeerCustodyTime(peer_id, time)
    self._peer_custody_time[peer_id] = time
    self._peer_pos[#self._peer_pos + 1] = peer_id
    self._peer_in_custody[peer_id] = false
    self._time_bg_box:text({
        name = "text" .. peer_id,
        text = "",
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h(),
        color = Color.white
    })
    self._n_of_peers_in_custody = self._n_of_peers_in_custody + 1
    if self._n_of_peers_in_custody > 1 then
        self:AnimateBG()
    end
    self:SetTextSize()
    self:FormatUnique(time, peer_id)
    self:FitTheTextUnique(peer_id)
    self:Reorganize()
    self:SetIconColor()
    self:SetTextPeerColor()
end

function EHICiviliansKilledTracker:Reorganize()
    if self._n_of_peers_in_custody == 1 then
        return
    end
    if self._n_of_peers_in_custody > self._panel_size then
        self._panel_size = self._panel_size * 2
        self._panel:set_w(self._panel:w() * 2)
        self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    end
    if self._n_of_peers_in_custody < self._panel_size and self._n_of_peers_in_custody % 2 == 0 then
        self._panel_size = self._panel_size / 2
        self._panel:set_w(self._panel:w() / 2)
        self._time_bg_box:set_w(self._time_bg_box:w() / 2)
    end
    self._icon1:set_x(self._time_bg_box:w() + (5 * self._scale))
    local half = self._time_bg_box:w() / self._panel_size
    local pos = 1
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if self._time_bg_box:child("text" .. i) then
            self._time_bg_box:child("text" .. i):set_x(half * (pos - 1))
            pos = pos + 1
        end
    end
end

function EHICiviliansKilledTracker:SetPeerCustodyTime(peer_id, time)
    self._peer_custody_time[peer_id] = time
    self:FormatUnique(time, peer_id)
    self:FitTheTextUnique(peer_id)
    self:AnimateBG()
end

function EHICiviliansKilledTracker:IncreasePeerCustodyTime(peer_id, time)
    local t = self._peer_custody_time[peer_id] or 0
    self:SetPeerCustodyTime(peer_id, t + time)
end

function EHICiviliansKilledTracker:SetTick(t)
    --[[
        This function makes Trade Delay accurate because of the braindead use of the "update" loop in TradeManager
        Why is OVK is using another variable to "count down" the remaining time ? As shown below:
        "self._trade_counter_tick = self._trade_counter_tick - dt" (which later subtracts 1s from the delay when self._trade_counter_tick <= 0)
        when they could just simply do:
        "crim.respawn_penalty - dt"
        Much faster and cleaner imo

        But why bother ?
        1. This time correction actually makes the tracker accurate
        2. To not confuse players why the tracker is blinking after a teammate is taken to custody
    ]]
    self._tick = t
end

function EHICiviliansKilledTracker:RemovePeerFromCustody(peer_id)
    if not self._peer_custody_time[peer_id] then
        return
    end
    self._n_of_peers_in_custody = self._n_of_peers_in_custody - 1
    if self._n_of_peers_in_custody == 0 then
        self:delete()
        return
    end
    self._peer_custody_time[peer_id] = nil
    self._peer_in_custody[peer_id] = nil
    for i = 1, #self._peer_pos, 1 do
        if self._peer_pos[i] == peer_id then
            table.remove(self._peer_pos, i)
            break
        end
    end
    self._time_bg_box:remove(self._time_bg_box:child("text" .. peer_id))
    if self._n_of_peers_in_custody == 1 then
        for i = 1, HUDManager.PLAYER_PANEL, 1 do
            if self._time_bg_box:child("text" .. i) then
                self._time_bg_box:child("text" .. i):set_font_size(self._panel:h())
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
    if self._n_of_peers_in_custody > 0 then
        self:AnimateBG()
    end
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

function EHICiviliansKilledTracker:SetPeerInCustody(peer_id)
    if not self:PeerExists(peer_id) then
        return
    end
    self._peer_in_custody[peer_id] = true
end

function EHICiviliansKilledTracker:PeerExists(peer_id)
    return self._peer_custody_time[peer_id] ~= nil
end

function EHICiviliansKilledTracker:FitTheTextUnique(i)
    local text = self._time_bg_box:child("text" .. i)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

local function SecondsOnly(self, time, peer_id)
    local t = math.floor(time * 10) / 10
    local text = self._time_bg_box:child("text" .. peer_id)
    local s
	if t < 0 then
		s = string.format("%d", 0)
    elseif t < 1 then
        s = string.format("%.2f", time)
	elseif t < 10 then
		s = string.format("%.1f", t)
	else
		s = string.format("%d", t)
	end
    text:set_text(s)
end

local function MinutesAndSeconds(self, time, peer_id)
    local t = math.floor(time * 10) / 10
    local text = self._time_bg_box:child("text" .. peer_id)
    local s
	if t < 0 then
		s = string.format("%d", 0)
    elseif t < 1 then
        s = string.format("%.2f", time)
	elseif t < 10 then
		s = string.format("%.1f", t)
	elseif t < 60 then
		s = string.format("%d", t)
	else
		s = string.format("%d:%02d", t / 60, t % 60)
	end
    text:set_text(s)
end

if EHI:GetOption("time_format") == 1 then
    EHICiviliansKilledTracker.FormatUnique = SecondsOnly
else
    EHICiviliansKilledTracker.FormatUnique = MinutesAndSeconds
end

function EHICiviliansKilledTracker:update(t, dt)
    if self._tick > 0 then
        self._tick = self._tick - dt
        return
    end
    for peer_id, time in pairs(self._peer_custody_time) do
        if self._peer_in_custody[peer_id] then
            time = time - dt
            if time <= 0 then
                self:RemovePeerFromCustody(peer_id)
            else
                self._peer_custody_time[peer_id] = time
                self:FormatUnique(time, peer_id)
            end
        end
    end
end

function EHICiviliansKilledTracker:SetPause(pause, t_correction)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:SetTick(t_correction)
        self:AddTrackerToUpdate()
    end
end

function EHICiviliansKilledTracker:Sync(new_time) -- Don't re-sync time
end