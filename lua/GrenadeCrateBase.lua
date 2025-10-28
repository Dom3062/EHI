if EHI:CheckLoadHook("GrenadeCrateBase") then
    return
end

function GrenadeCrateBase:GetRealAmount()
    return self._grenade_amount or self._max_grenade_amount
end

if not EHI:GetEquipmentOption("show_equipment_grenadecases") then
    return
end

---@class GrenadeCrateBase
---@field _grenade_amount number
---@field _max_grenade_amount number
---@field _unit UnitGrenadeDeployable

local original =
{
    init = GrenadeCrateBase.init,
    _set_visual_stage = GrenadeCrateBase._set_visual_stage,
    _set_empty = GrenadeCrateBase._set_empty,
    destroy = GrenadeCrateBase.destroy,

    init_custom = CustomGrenadeCrateBase.init
}
function GrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    original.init(self, unit, ...)
    managers.ehi_deployable:OnDeployablePlaced(unit)
end

---@param amount number?
function GrenadeCrateBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), "grenade_crate", "GrenadeCases")
end

function GrenadeCrateBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        self:UpdateAmount()
    end
end

function GrenadeCrateBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
end

function GrenadeCrateBase:SetIgnoreChild()
    if self._parent_done then
        return
    end
    self:SetIgnore()
    self._ignore_set_by_parent = true
end

function GrenadeCrateBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    self:UpdateAmount()
end

function GrenadeCrateBase:_set_empty(...)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original._set_empty(self, ...)
end

function GrenadeCrateBase:destroy(...)
    self:UpdateAmount(0)
    managers.ehi_deployable:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end

function CustomGrenadeCrateBase:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    original.init_custom(self, unit, ...)
end