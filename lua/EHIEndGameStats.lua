local EHI = EHI

---@class EHIEndGameStats
EHIEndGameStats = {}
function EHIEndGameStats:new()
    self._icons = { Skull = 57364, Ghost = 57363, LC=139, RC=155 }
    for k, v in pairs(self._icons) do
        self._icons[k] = utf8.char(v) ---@diagnostic disable-line
    end
    self._end_stats_format = ""
    if EHI:GetOption("show_end_game_stats_kills") > 1 then -- Kills
        if EHI:GetOption("show_end_game_stats_kills") == 2 then -- All kills only
            self._end_stats_format = "$kills;" .. self._icons.Skull
        elseif EHI:GetOption("show_end_game_stats_kills") == 3 then -- Special kills only
            self._end_stats_format = "$s_kills Sp"
        elseif EHI:GetOption("show_end_game_stats_kills") == 4 then -- All kills + Special kills
            self._end_stats_format = "$kills;" .. self._icons.Skull .. "$s_kills_format;"
        else -- Special kills + All kills
            self._end_stats_format = "$s_kills_format;$kills;" .. self._icons.Skull
            EHIEndGamePeerStats._SP_KILLS_POSTFIX = true
        end
    end
    if EHI:GetOption("show_end_game_stats_headshots") then
        if self._end_stats_format == "" then
            self._end_stats_format = "$headshots; Hs"
        else
            self._end_stats_format = self._end_stats_format .. "$headshots_format;"
        end
    end
    if EHI:GetOption("show_end_game_stats_dps") then
        if self._end_stats_format == "" then
            self._end_stats_format = "$dps;"
        else
            self._end_stats_format = self._end_stats_format .. " | $dps;"
        end
    end
    if EHI:GetOption("show_end_game_stats_kpm") then
        if self._end_stats_format == "" then
            self._end_stats_format = "$kpm;"
        else
            self._end_stats_format = self._end_stats_format .. " | $kpm;"
        end
    end
    if EHI:GetOption("show_end_game_stats_acc") then
        if self._end_stats_format == "" then
            self._end_stats_format = "$acc;"
        else
            self._end_stats_format = self._end_stats_format .. " | $acc;"
        end
    end
    if EHI:GetOption("show_end_game_stats_downs") then
        if self._end_stats_format == "" then
            self._end_stats_format = "$downs;"
        else
            self._end_stats_format = self._end_stats_format .. " $downs;"
        end
    end
    if self._end_stats_format == "" then -- No stats visible, user is an idiot, hook nothing and return
        return
    end
    self._special_units_id = StatisticsManager and StatisticsManager.special_unit_ids or {}
    self._peers = {} ---@type EHIEndGamePeerStats[]
    self._my_peer_id = EHI.IsHost and 1 or EHI._cache.LocalPeerID
    for i = 0, HUDManager.PLAYER_PANEL, 1 do
        self._peers[i] = EHIEndGamePeerStats:new(i)
    end
    Hooks:PostHook(MissionEndState, "at_enter", "EHI_EndGameKillStats_MissionEndState_at_enter", function(...)
        local total_kills = 0
        for _, peer in pairs(self._peers) do
            total_kills = total_kills + peer._kills
        end
        if total_kills <= 0 then
            return -- Don't print anything if all peers have 0 kills. This can happen as a client when you drop-in to a heist that already ended or playing a heist where kills did not happen -> Safehouse
        end
        -- There is some fuckery going where delaying end game stats actually works
        -- If it is not delayed, stats will still get printed, however the chat won't be visible
        -- Setting the delay to 0.25-1s is enough
        -- This needs to be investigated
        -- Note to future me:
        -- --call_on_next_update() does not work
        -- --ChatManager.GLOBAL does not work (without a delay)
        local heist_time = managers.hud._hud_heist_timer and managers.hud._hud_heist_timer._timer_text and managers.hud._hud_heist_timer._timer_text:text() or ""
        local t = managers.game_play_central:get_heist_timer() - (managers.statistics:is_dropin() and (self.__dropin_offset_t or 0) or 0)
        DelayedCalls:Add("EHI_EndGameStats", 1, function()
            local session = managers.network and managers.network:session() -- Host can leave the game before you fully load
            local local_peer = session and session.local_peer and session:local_peer()
            managers.chat:_receive_message(ChatManager.GAME, heist_time, string.format("%sCrew Kills: %d", self._icons.Skull, total_kills), tweak_data.chat_colors[local_peer and local_peer:id() or 0] or Color.white)
            for i = 0, HUDManager.PLAYER_PANEL, 1 do
                local peer = self._peers[i]
                if peer:IsValid() then
                    managers.chat:_receive_message(ChatManager.GAME, string.format("%s%s%s", self._icons.LC, peer:PeerName(), self._icons.RC), managers.localization:_text_macroize(self._end_stats_format, {
                        kills = peer._kills,
                        s_kills = peer._specials,
                        s_kills_format = peer:FormatSpecialKills(),
                        headshots = peer._headshots,
                        headshots_format = peer:FormatHeadshots(),
                        dps = peer:DPS(t),
                        kpm = peer:KPM(t),
                        acc = peer:ACC(),
                        downs = peer:Downs(self._icons.Ghost --[[@as string]])
                    }), Color.white)
                end
            end
        end)
    end)
    Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHIEndGameStats", function(peer, peer_id, reason)
        self._peers[peer_id]:Disconnected()
    end)
    if EHI:GetOption("show_end_game_stats_kills") > 1 or EHI:GetOption("show_end_game_stats_headshots") or EHI:GetOption("show_end_game_stats_dps") or EHI:GetOption("show_end_game_stats_kpm") then
        Hooks:PostHook(CopDamage, "_on_damage_received", "EHI_EndGameKillStats", callback(self, self, "damage_callback"))
    end
    if EHI:GetOption("show_end_game_stats_downs") then
        managers.player:add_listener("EHIEndGameStats_bleed_out", "bleed_out", function()
            self._peers[managers.network:session():local_peer():id()]:Downed()
        end)
        managers.player:add_listener("EHIEndGameStats_incapacitated", "incapacitated", function()
            self._peers[managers.network:session():local_peer():id()]:DownedIncapacitated()
        end)
        Hooks:PostHook(HuskPlayerMovement, "_sync_movement_state_bleed_out", "EHI_EndGameStats_HuskPlayerMovement_sync_bleed_out", function(movement, ...)
            self._peers[self:_pid(movement._unit)]:Downed()
        end)
        Hooks:PostHook(HuskPlayerMovement, "_sync_movement_state_incapacitated", "EHI_EndGameStats_HuskPlayerMovement_sync_incapacitated", function(movement, ...)
            self._peers[self:_pid(movement._unit)]:DownedIncapacitated()
        end)
    end
    if EHI:GetOption("show_end_game_stats_acc") then
        Hooks:PreHook(HUDTeammate, "set_ammo_amount_by_type", "EHI_EndGameStats_HUDTeammate_set_ammo_amount_by_type", function(hud, type, max_clip, current_clip, current_left, ...)
            local clip = "__last_clip_" .. type
            local cc = hud[clip] or 0
            if current_clip < cc then
                self._peers[hud._peer_id or self._my_peer_id or 0]:ShotMade(cc - current_clip)
            end
            hud[clip] = current_clip
        end)
        Hooks:PostHook(HUDTeammate, "remove_panel", "EHI_EndGameStats_HUDTeammate_remove_panel", function(hud, ...)
            hud["__last_clip_primary"] = 0
            hud["__last_clip_secondary"] = 0
        end)
    end
    if EHI.IsClient then
        Hooks:PostHook(GamePlayCentralManager, "load", "EHI_EndGameStats_GamePlayCentralManager_load", function(gpcm, ...)
            self.__dropin_offset_t = gpcm._heist_timer.offset_time
        end)
    end
end

---@param c_dmg CopDamage
---@param damage_info CopDamage.AttackData
function EHIEndGameStats:damage_callback(c_dmg, damage_info)
    local realAttacker = damage_info.attacker_unit
    if alive(realAttacker) then
        local base = realAttacker:base()
        if base then
            if base.thrower_unit then
                realAttacker = base.thrower_unit
            elseif base.sentry_gun then
                realAttacker = base:get_owner()
            end
        end
    end
    local damage = damage_info.damage
    if type(damage) ~= 'number'  -- Dragon's breath crash
        or damage_info.variant == 'stun'	-- Stun a convert crash with concussion grenade
        or damage == 0			-- Stun a shield crash with concussion grenade
        or type(realAttacker) == "function"
    then
        return
    end
    local pid = self:_pid(realAttacker)
    local peer_stats = self._peers[pid]
    local rDamage = damage >= 0 and damage or -damage
    if damage < 0 and c_dmg._HEALTH_INIT then
        rDamage = math.min(c_dmg._HEALTH_INIT * rDamage / 100, c_dmg._health)
    end
    peer_stats:DamageDealt(rDamage)
    if damage_info.variant == "bullet" or damage_info.variant == "fire" or damage_info.variant == "explosion" or damage_info.variant == "melee" then
        peer_stats:HitMade()
    end
    if c_dmg._dead then
        peer_stats:KillConfirmed(damage_info.headshot)
        local unit = c_dmg._unit
        if unit then
            local base = alive(unit) and unit:base() ---@cast base -false
            local unitTweak = base and base._tweak_table
            local statsTweak = unitTweak and base._stats_name or ""
            if unitTweak and base.has_tag and base:has_tag("special") or self._special_units_id[statsTweak] then
                peer_stats:SpecialKillConfirmed()
            end
        end
    end
end

---@param something UnitPlayer|UnitEnemy|UnitTeamAI
function EHIEndGameStats:_pid(something)
    local network = alive(something) and something:network()
    local peer = network and network:peer()
    return peer and peer:id() or 0
end

---@class EHIEndGamePeerStats
---@field new fun(self: self, peer_id: number): self
EHIEndGamePeerStats = class()
---@param peer_id number
function EHIEndGamePeerStats:init(peer_id)
    self._peer_id = peer_id
    self._damage = 0
    self._kills = 0
    self._specials = 0
    self._headshots = 0
    self._downs = 0
    self._downs_incapacitated = 0
    self._hits = 0
    self._shots = 0
end

function EHIEndGamePeerStats:Disconnected()
    self:init(self._peer_id)
end

---@param damage number
function EHIEndGamePeerStats:DamageDealt(damage)
    self._damage = self._damage + damage
end

---@param headshot boolean
function EHIEndGamePeerStats:KillConfirmed(headshot)
    self._kills = self._kills + 1
    self._headshots = self._headshots + (headshot and 1 or 0)
end

function EHIEndGamePeerStats:SpecialKillConfirmed()
    self._specials = self._specials + 1
end

function EHIEndGamePeerStats:Downed()
    self._downs = self._downs + 1
end

function EHIEndGamePeerStats:DownedIncapacitated()
    self._downs_incapacitated = self._downs_incapacitated + 1
end

function EHIEndGamePeerStats:HitMade()
    self._hits = self._hits + 1
end

---@param shots number
function EHIEndGamePeerStats:ShotMade(shots)
    self._shots = self._shots + shots
end

function EHIEndGamePeerStats:IsValid()
    return self._kills > 0
end

function EHIEndGamePeerStats:PeerName()
    local session = managers.network:session()
    local peer = session and session:peer(self._peer_id)
    return peer and peer:name() or "Someone"
    --local name = peer and peer:name() or "Someone"
    --[[name = name:gsub('{','['):gsub('}',']')
    local hDot,fDot
    local truncated = name:gsub('^%b[]',''):gsub('^%b==',''):gsub('^%s*(.-)%s*$','%1')
    if O:get('game','truncateTags') and utf8.len(truncated) > 0 and name ~= truncated then
        name = truncated
        hDot = true
    end
    local tLen = O:get('game','truncateNames')
    if tLen > 1 then
        tLen = (tLen - 1) * 3
        if tLen < utf8.len(name) then
            name = utf8.sub(name,1,tLen)
            fDot = true
        end
    end
    return (hDot and Icon.Dot or '')..name..(fDot and Icon.Dot or '')]]
end

function EHIEndGamePeerStats:FormatSpecialKills()
    if self._specials > 0 then
        return string.format("%s%d Sp%s", not self._SP_KILLS_POSTFIX and ", " or "", self._specials, self._SP_KILLS_POSTFIX and "" or ", ")
    end
    return ""
end

function EHIEndGamePeerStats:FormatHeadshots()
    if self._headshots > 0 then
        return string.format("%d Hs", self._headshots)
    end
    return ""
end

---@param t number
function EHIEndGamePeerStats:DPS(t)
    local result = t > 0 and (self._damage / t * 10) or 0
    result = result < 10 and math.ehi_round(result, 0.1) or math.floor(result)
    return string.format("DPS:%g", result)
end

---@param t number
function EHIEndGamePeerStats:KPM(t)
    local result = t > 0 and (60 * self._kills / t) or 0
    result = result < 10 and math.ehi_round(result, 0.1) or math.floor(result)
    return string.format("KPM:%g", result)
end

function EHIEndGamePeerStats:ACC()
    if self._peer_id == 0 then
        return "Acc:N/A"
    elseif self._shots <= 0 then
        return "Acc:0%"
    end
    return string.format("Acc:%d%%", self._hits / self._shots * 100)
end

---@param ghost string
function EHIEndGamePeerStats:Downs(ghost)
    if self._downs > 0 or self._downs_incapacitated > 0 then
        return string.format("%d|%d%s", self._downs, self._downs_incapacitated, ghost)
    end
    return ""
end