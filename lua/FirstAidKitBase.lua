local EHI = EHI
if EHI:CheckLoadHook("FirstAidKitBase") or not EHI:GetEquipmentOption("show_equipment_firstaidkit") then
    return
end

local original =
{
    init = FirstAidKitBase.init,
    destroy = FirstAidKitBase.destroy
}

---@class FirstAidKitBase
---@field _empty boolean
---@field _unit UnitFAKDeployable
---@field List { obj: UnitFAKDeployable, pos: Vector3, min_distance: number }[]

FirstAidKitBase._ehi_tracker = EHI:GetOption("show_equipment_aggregate_health") and not EHI:GetOption("show_equipment_aggregate_all") and "Health" or "FirstAidKits"
function FirstAidKitBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    managers.ehi_deployable:UpdateAmount(self._ehi_key, 1, "first_aid_kit", self._ehi_tracker)
end

function FirstAidKitBase:GetRealAmount()
    return self._empty and 0 or 1
end

function FirstAidKitBase:destroy(...)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, 0, "first_aid_kit", self._ehi_tracker)
    original.destroy(self, ...)
end