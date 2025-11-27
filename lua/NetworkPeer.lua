local EHI = EHI
if EHI:CheckLoadHook("NetworkPeer") or EHI.IsHost then
    return
end

---@class NetworkPeer
---@field _id integer
---@field _unit UnitPlayer
---@field id fun(self: self): integer
---@field character fun(self: self): string
---@field name fun(self: self): string
---@field set_outfit_string fun(self: self, outfit_string: table)
---@field unit fun(self: self): UnitPlayer
---@field qos fun(self: self): NetworkQoS?

local load = NetworkPeer.load
function NetworkPeer:load(...)
    load(self, ...)
    if self == managers.network:session():local_peer() then
        EHI._cache.LocalPeerID = self._id
    end
end