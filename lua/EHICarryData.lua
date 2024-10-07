--[[
    Provides more accurate tracking of random loot spawned in safes
    None of these classes are referenced in Lua anywhere, however they are added to concerned units via Wren
    Tracking is disabled by default, to not mess up random loot counter when one of the units spawn, the tracking
    itself can be enabled via `EHI:ShowLootCounter()`; see `carry_data` in EHI docs for more info
    This runs once when the unit is spawned and not every time the bag is thrown around
    See file `ehi_units.xml` for more info
]]

---@class EHICarryData
EHICarryData = class()
EHICarryData._enabled = false
---@param unit UnitCarry
function EHICarryData:init(unit)
    unit:set_extension_update_enabled(Idstring("ehi"), false)
    if self._enabled then
        managers.ehi_loot:RandomLootSpawned()
    end
end

---@class EHINoCarryData
EHINoCarryData = class()
EHINoCarryData._enabled = false
---@param unit UnitCarry
function EHINoCarryData:init(unit)
    unit:set_extension_update_enabled(Idstring("ehi"), false)
    if self._enabled then
        managers.ehi_loot:RandomLootDeclined()
    end
end