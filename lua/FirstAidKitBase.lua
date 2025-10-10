if EHI:CheckLoadHook("FirstAidKitBase") then
    return
end

function FirstAidKitBase:GetRealAmount()
    return self._empty and 0 or 1
end

if not EHI:GetEquipmentOption("show_equipment_firstaidkit") then
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

FirstAidKitBase.__ehi_tracker = EHI:GetOption("show_equipment_aggregate_health") and not EHI:GetOption("show_equipment_aggregate_all") and "Health" or "FirstAidKits"
function FirstAidKitBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    if not self._ignore then
        managers.ehi_deployable:OnDeployablePlaced(unit)
        managers.ehi_deployable:UpdateAmount(self._ehi_key, 1, "first_aid_kit", self.__ehi_tracker)
    end
end

function FirstAidKitBase:SetIgnore()
    if self._ignore_set_by_parent then ---@diagnostic disable-line
        return
    end
    self._ignore = true
    managers.ehi_deployable:UpdateAmount(self._ehi_key, 0, "first_aid_kit", self.__ehi_tracker)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
end

function FirstAidKitBase:destroy(...)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, 0, "first_aid_kit", self.__ehi_tracker)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end