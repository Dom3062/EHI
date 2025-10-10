if EHI:CheckLoadHook("DoctorBagBase") then
    return
end

function DoctorBagBase:GetRealAmount()
    return (self._amount or self._max_amount) - (self._offset or 0)
end

---@param offset number
function DoctorBagBase:SetOffset(offset)
    self._offset = offset
    if self._ehi_key and self._unit:interaction():active() and not self._ignore then
        self:UpdateAmount()
    end
end

if not EHI:GetEquipmentOption("show_equipment_doctorbag") then
    return
end

local original =
{
    init = DoctorBagBase.init,
    _set_visual_stage = DoctorBagBase._set_visual_stage,
    destroy = DoctorBagBase.destroy,

    custom_set_empty = CustomDoctorBagBase._set_empty
}

DoctorBagBase.__ehi_tracker = EHI:GetOption("show_equipment_aggregate_health") and not EHI:GetOption("show_equipment_aggregate_all") and "Health" or "DoctorBags"
function DoctorBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
    managers.ehi_deployable:OnDeployablePlaced(unit)
end

function DoctorBagBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
end

---@param amount number?
function DoctorBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), "doctor_bag", self.__ehi_tracker)
end

function DoctorBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        self:UpdateAmount()
    end
end

function DoctorBagBase:destroy(...)
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end

function CustomDoctorBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
end