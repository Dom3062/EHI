local EHI = EHI
if not EHI:GetOption("show_trade_delay") then
    return
end

local original =
{
    init = TradeManager.init,
    on_player_criminal_death = TradeManager.on_player_criminal_death,
    _set_auto_assault_ai_trade = TradeManager._set_auto_assault_ai_trade,
    sync_set_auto_assault_ai_trade = TradeManager.sync_set_auto_assault_ai_trade
}

local function OnPlayerCriminalDeath(peer_id, respawn_penalty)
    if managers.hud:TrackerExists("CustodyTime") then
        local tracker = managers.hud.ehi:GetTracker("CustodyTime")
        if tracker and not tracker:PeerExists(peer_id) then
            tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
        end
    else
        managers.hud:AddCustodyTimeTrackerAndAddPeerCustodyTime(peer_id, respawn_penalty)
    end
end

local function CreateTracker(peer_id, respawn_penalty)
    if respawn_penalty == tweak_data.player.damage.base_respawn_time_penalty then
        return
    end
    if EHI:GetOption("show_trade_delay_other_players_only") and peer_id == managers.network:session():local_peer():id() then
        return
    end
    OnPlayerCriminalDeath(peer_id, respawn_penalty)
end

local function SetTrackerPause(character_name)
    managers.hud.ehi:CallFunction("CustodyTime", "SetPaused", not character_name)
end

function TradeManager:init()
    original.init(self)
    EHI:Hook(self, "set_trade_countdown", function(s, enabled)
        local function f()
            managers.hud.ehi:CallFunction("CustodyTime", "SetPaused", not enabled)
        end
        EHI:DelayCall("CustodyTime", 1, f)
    end)
end

function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, hostages_killed, skip_netsend)
    local crim = original.on_player_criminal_death(self, criminal_name, respawn_penalty, hostages_killed, skip_netsend)
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
    if EHI:GetOption("show_trade_delay_option") == 2 then
        CreateTracker(peer_id, respawn_penalty)
    else
        local tracker = managers.hud.ehi:GetTracker("CustodyTime")
        if tracker and not tracker:PeerExists(peer_id) then
            tracker:AddPeerCustodyTime(peer_id, respawn_penalty)
        end
    end
    managers.hud.ehi:CallFunction("CustodyTime", "SetPeerInCustody", peer_id)
    return crim
end

function TradeManager:_set_auto_assault_ai_trade(character_name, time)
    if self._auto_assault_ai_trade_criminal_name ~= character_name then
        SetTrackerPause(character_name)
	end
    original._set_auto_assault_ai_trade(self, character_name, time)
end

function TradeManager:sync_set_auto_assault_ai_trade(character_name, time)
    original.sync_set_auto_assault_ai_trade(self, character_name, time)
    SetTrackerPause(character_name)
end