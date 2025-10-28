if EHI:CheckLoadHook("BodyBagsBagBase") then
    return
end

function BodyBagsBagBase:GetRealAmount()
    return self._bodybag_amount or self._max_bodybag_amount
end

if not EHI:GetEquipmentOption("show_equipment_bodybags") then
    return
end

local original =
{
    init = BodyBagsBagBase.init,
    _set_visual_stage = BodyBagsBagBase._set_visual_stage,
    _set_empty = BodyBagsBagBase._set_empty,
    destroy = BodyBagsBagBase.destroy
}

function BodyBagsBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    managers.ehi_deployable:OnDeployablePlaced(unit)
end

function BodyBagsBagBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
end

---@param amount number?
function BodyBagsBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), "bodybags_bag", "BodyBags")
end

function BodyBagsBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    self:UpdateAmount()
end

function BodyBagsBagBase:_set_empty(...)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original._set_empty(self, ...)
end

function BodyBagsBagBase:destroy(...)
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end