if EHI:CheckLoadHook("BodyBagsBagBase") then
    return
end

local original =
{
    init = BodyBagsBagBase.init,
    _set_empty = BodyBagsBagBase._set_empty,
    destroy = BodyBagsBagBase.destroy
}

local Deployables = EHI.TrackerUtils.Deployables
function BodyBagsBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = unit:key()
    Deployables:OnDeployablePlaced(unit)
end

function BodyBagsBagBase:GetRealAmount()
    return self._bodybag_amount or self._max_bodybag_amount
end

function BodyBagsBagBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
end

function BodyBagsBagBase:_set_empty(...)
    Deployables:OnDeployableConsumed(self._ehi_key)
    original._set_empty(self, ...)
end

function BodyBagsBagBase:destroy(...)
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end

if not EHI:GetEquipmentOption("show_equipment_bodybags") then
    return
end

BodyBagsBagBase.__ehi_id = "bodybags_bag"
BodyBagsBagBase.__ehi_tracker = "BodyBags"
---@param amount number?
function BodyBagsBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), self.__ehi_id, self.__ehi_tracker)
end

original._set_visual_stage = BodyBagsBagBase._set_visual_stage
function BodyBagsBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    self:UpdateAmount()
end