--[[
    Provides more accurate tracking of Enemy snipers
    None of these classes are referenced in Lua anywhere, however they are added to concerned units via Wren
    Tracking is enabled by default for majority of heists, however some scripts are having multiple sniper loops that need this tracking disabled
    and needs to track snipers manually via script
    This runs once when the unit is spawned and not every frame
    See file `ehi_units.xml` for more info

    This class is added as last extension, you are free to call other extensions without any delay needed
]]

---@class EHISniperBase
EHISniperBase = class()
EHISniperBase._alive_count = 0
EHISniperBase._enabled = false
EHISniperBase._spawned_listener = ListenerHolder:new()
---@param unit UnitEnemy
function EHISniperBase:init(unit)
    unit:set_extension_update_enabled(Idstring("ehi"), false)
    if self._enabled then
        self._alive_count = self._alive_count + 1
        unit:character_damage():add_listener("EHISniperBase", "death", self._die)
        self._spawned_listener:call()
        managers.ehi_tracker:IncreaseCount("Snipers")
    end
end

function EHISniperBase._die(...)
    EHISniperBase._alive_count = EHISniperBase._alive_count - 1
    managers.ehi_tracker:DecreaseCount("Snipers")
end

---@param self EHIMissionElementTrigger
---@param trigger ElementTrigger
---@param element MissionScriptElement
---@param enabled boolean
function EHISniperBase._trigger(self, trigger, element, enabled)
    local id = trigger.id
    if self._trackers:Exists(id) then
        if trigger.chance then
            self._trackers:SetChance(id, trigger.chance)
        end
        self._trackers:SetCount(id, EHISniperBase._alive_count)
        self._trackers:SetTimeNoAnim(id, trigger.time or 0)
        return
    end
    self:CreateTracking()
end

---@param key string
---@param f function
function EHISniperBase.register_spawn_listener(key, f)
    EHISniperBase._spawned_listener:add(key, f)
end

---@param key string
function EHISniperBase.unregister_spawn_listener(key)
    EHISniperBase._spawned_listener:remove(key)
end