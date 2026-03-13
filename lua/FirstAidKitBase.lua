if EHI:CheckLoadHook("FirstAidKitBase") then
    return
end

function FirstAidKitBase:GetRealAmount()
    return self._empty and 0 or 1
end

local original =
{
    init = FirstAidKitBase.init,
    destroy = FirstAidKitBase.destroy
}

---@class FirstAidKitBase
---@field _empty boolean
---@field _damage_reduction_upgrade boolean
---@field _min_distance number
---@field _unit UnitFAKDeployable
---@field List { obj: UnitFAKDeployable, pos: Vector3, min_distance: number }[]

local Deployables = EHI.TrackerUtils.Deployables
FirstAidKitBase.__ehi_id = "first_aid_kit"
FirstAidKitBase.__ehi_tracker = EHI:GetOption("show_equipment_aggregate_health") and not EHI:GetOption("show_equipment_aggregate_all") and "Health" or "FirstAidKits"
FirstAidKitBase.__ehi_update_equipment_amount = EHI:GetEquipmentOption("show_equipment_firstaidkit")
function FirstAidKitBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = unit:key()
    if not self._ignore then
        Deployables:OnDeployablePlaced(unit)
        if self.__ehi_update_equipment_amount then
            managers.ehi_deployable:UpdateAmount(self._ehi_key, 1, self.__ehi_id, self.__ehi_tracker)
        end
    end
end

function FirstAidKitBase:SetIgnore()
    if self._ignore_set_by_parent then ---@diagnostic disable-line
        return
    end
    self._ignore = true
    if self.__ehi_update_equipment_amount then
        managers.ehi_deployable:UpdateAmount(self._ehi_key, 0, self.__ehi_id, self.__ehi_tracker)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
end

function FirstAidKitBase:destroy(...)
    if self.__ehi_update_equipment_amount then
        managers.ehi_deployable:UpdateAmount(self._ehi_key, 0, self.__ehi_id, self.__ehi_tracker)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end