if EHI._hooks.GrenadeCrateBase then
	return
else
	EHI._hooks.GrenadeCrateBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_grenadecases") then
    return
end

local level_id = Global.game_settings.level_id
local ignore = {}
if level_id == "sah" then -- Shacklethorne Auction
    ignore =
    {
        [400178] = true -- Unused Grenade case
    }
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Deployables") then
            managers.ehi:AddAggregatedDeployablesTracker()
        end
        managers.ehi:CallFunction("Deployables", "UpdateAmount", "grenade_crate", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("GrenadeCases") then
            managers.ehi:AddTracker({
                id = "GrenadeCases",
                icons = { "frag_grenade" },
                exclude_from_sync = true,
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("GrenadeCases", "UpdateAmount", unit, key, amount)
    end
end

local original =
{
    init = GrenadeCrateBase.init,
    _set_visual_stage = GrenadeCrateBase._set_visual_stage,
    destroy = GrenadeCrateBase.destroy,

    init_custom = CustomGrenadeCrateBase.init,
    _set_empty_custom = CustomGrenadeCrateBase._set_empty
}
function GrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ignore = ignore[unit:editor_id()] or false
    original.init(self, unit, ...)
end

function GrenadeCrateBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self._grenade_amount)
    end
end

function GrenadeCrateBase:GetEHIKey()
    return self._ehi_key
end

function GrenadeCrateBase:GetRealAmount()
    return self._grenade_amount or self._max_grenade_amount
end

function GrenadeCrateBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomGrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ignore = ignore[unit:editor_id()] or false
    original.init_custom(self, unit, ...)
end

function CustomGrenadeCrateBase:_set_empty(...)
    original._set_empty_custom(self, ...)
    UpdateTracker(self._unit, self._ehi_key, 0)
end