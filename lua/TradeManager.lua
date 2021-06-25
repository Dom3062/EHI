local EHI = EHI
if EHI._hooks.TradeManager then
    return
else
    EHI._hooks.TradeManager = true
end

if not EHI:GetOption("show_trade_delay") then
    return
end

local show_trade_for_other_players = EHI:GetOption("show_trade_delay_other_players_only")
local on_death_show = EHI:GetOption("show_trade_delay_option") == 2

local original =
{
    init = TradeManager.init,
    on_player_criminal_death = TradeManager.on_player_criminal_death,
    _set_auto_assault_ai_trade = TradeManager._set_auto_assault_ai_trade,
    sync_set_auto_assault_ai_trade = TradeManager.sync_set_auto_assault_ai_trade
}

local TrackerID = "CustodyTime"

local function OnPlayerCriminalDeath(peer_id, respawn_penalty)
    if managers.ehi:TrackerExists(TrackerID) then
        local tracker = managers.ehi:GetTracker(TrackerID)
        if tracker and not tracker:PeerExists(peer_id) then
            tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
        end
    else
        managers.ehi:AddCustodyTimeTrackerAndAddPeerCustodyTime(peer_id, respawn_penalty)
    end
end

local function CreateTracker(peer_id, respawn_penalty)
    if respawn_penalty == tweak_data.player.damage.base_respawn_time_penalty then
        return
    end
    if show_trade_for_other_players and peer_id == managers.network:session():local_peer():id() then
        return
    end
    OnPlayerCriminalDeath(peer_id, respawn_penalty)
end

local function SetTrackerPause(character_name, t)
    managers.ehi:SetTrade("ai", character_name ~= nil, t)
end

function TradeManager:init(...)
    original.init(self, ...)
    EHI:Hook(self, "set_trade_countdown", function(s, enabled)
        managers.ehi:SetTrade("normal", enabled, self._trade_counter_tick)
    end)
end

function TradeManager:GetTradeCounterTick()
    return self._trade_counter_tick
end

function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, ...)
    local crim = original.on_player_criminal_death(self, criminal_name, respawn_penalty, ...)
    if crim and type(crim) == "table" then -- Apparently OVK sometimes send empty criminal, not sure why; Probably mods
        local peer_id = crim.peer_id
        if not peer_id then
            for id, peer in pairs(managers.network:session():peers()) do
                if peer:character() == criminal_name then
                    peer_id = id
                    break
                end
            end
            if not peer_id then -- If peer_id is still nil, return the value and GTFO
                return crim
            end
        end
        if on_death_show then
            CreateTracker(peer_id, respawn_penalty)
        elseif respawn_penalty ~= tweak_data.player.damage.base_respawn_time_penalty then
            local tracker = managers.ehi:GetTracker(TrackerID)
            if tracker then
                if tracker:PeerExists(peer_id) then
                    tracker:UpdatePeerCustodyTime(peer_id, respawn_penalty)
                else
                    tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
                end
            end
        end
        managers.ehi:CallFunction(TrackerID, "SetPeerInCustody", peer_id)
    end
    return crim
end

function TradeManager:_set_auto_assault_ai_trade(character_name, ...)
    if self._auto_assault_ai_trade_criminal_name ~= character_name then
        SetTrackerPause(character_name, self._trade_counter_tick)
	end
    original._set_auto_assault_ai_trade(self, character_name, ...)
end

function TradeManager:sync_set_auto_assault_ai_trade(character_name, ...)
    original.sync_set_auto_assault_ai_trade(self, character_name, ...)
    SetTrackerPause(character_name, self._trade_counter_tick)
end