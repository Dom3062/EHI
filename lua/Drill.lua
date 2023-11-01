local EHI = EHI
if EHI:CheckLoadHook("Drill") then
    return
end
local highest_id = 0
for _, id in pairs(Drill.EVENT_IDS) do
    if id > highest_id then
        highest_id = id
    end
end
local HasAutorepair = highest_id + 1
local NoAutorepair = highest_id + 2

local original = {}

local function SetAutorepair(unit_key, autorepair)
    managers.ehi_manager:Call(unit_key, "SetAutorepair", autorepair)
end

if EHI:IsHost() then
    original.set_autorepair = Drill.set_autorepair
    function Drill:set_autorepair(...)
        original.set_autorepair(self, ...)
        if self._autorepair == nil then
            return
        end
        SetAutorepair(tostring(self._unit:key()), self._autorepair)
        managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", self._autorepair and HasAutorepair or NoAutorepair)
    end
else
    original.on_autorepair = Drill.on_autorepair
    function Drill:on_autorepair(...)
        original.on_autorepair(self, ...)
        SetAutorepair(tostring(self._unit:key()), true)
    end

    original.sync_net_event = Drill.sync_net_event
    function Drill:sync_net_event(event_id, ...)
        if event_id == HasAutorepair then
            self._autorepair_client = true
            SetAutorepair(tostring(self._unit:key()), true)
        elseif event_id == NoAutorepair then
            self._autorepair_client = nil
            SetAutorepair(tostring(self._unit:key()), false)
        end
        original.sync_net_event(self, event_id, ...)
    end
end