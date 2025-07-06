--[[
    Provides more accurate tracking of Enemy snipers
    None of these classes are referenced in Lua anywhere, however they are added to concerned units via Wren
    Tracking is disabled by default, to not mess up enemy sniper counter when one of the units spawn, the tracking
    itself can be enabled via `EHISniperBase._enabled`
    This runs once when the unit is spawned and not every frame
    See file `ehi_units.xml` for more info

    This class is added as last extension, you are free to call other extensions without any delay needed
]]

---@class EHISniperBase
EHISniperBase = class()
EHISniperBase._enabled = false
---@param unit UnitEnemy
function EHISniperBase:init(unit)
    unit:set_extension_update_enabled(Idstring("ehi"), false)
    if self._enabled then
        unit:character_damage():add_listener("EHISniperBase", "death", callback(self, self, "die"))
        managers.ehi_tracker:IncreaseCount("Snipers")
    end
end

function EHISniperBase:die(unit, damage_info)
    managers.ehi_tracker:DecreaseCount("Snipers")
end