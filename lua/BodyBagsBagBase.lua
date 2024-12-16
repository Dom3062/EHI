local EHI = EHI
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

    custom_set_empty = CustomBodyBagsBagBase._set_empty
}

function BodyBagsBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

---@param amount number?
function BodyBagsBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), "bodybags_bag", "BodyBags")
end

function BodyBagsBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    self:UpdateAmount()
end

function CustomBodyBagsBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
	self:UpdateAmount(0)
end