---@class BaseNetworkSession
---@field amount_of_alive_players fun(self: self): number
---@field amount_of_players fun(self: self): number
---@field local_peer fun(self: self): NetworkPeer
---@field peer fun(self: self, peer_id: number): NetworkPeer
---@field peer_by_unit fun(self: self, unit: UnitPlayer): NetworkPeer
---@field peers fun(self: self): table<number, NetworkPeer>
---@field send_to_peers_synched fun(self: self, func_name: string, ...: any)

local EHI = EHI
if EHI:CheckLoadHook("BaseNetworkSession") then
    return
end

local on_network_stopped = BaseNetworkSession.on_network_stopped
function BaseNetworkSession:on_network_stopped(...)
    EHI:RunEndGameCallback(EHI.Const.GameEnd.End)
    on_network_stopped(self, ...)
end