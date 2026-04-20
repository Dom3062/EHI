if EHI:CheckLoadHook("GrenadeCrateBase") then
    return
end

local original =
{
    init = GrenadeCrateBase.init,
    _set_empty = GrenadeCrateBase._set_empty,
    destroy = GrenadeCrateBase.destroy,

    init_custom = CustomGrenadeCrateBase.init
}
local Deployables = EHI.TrackerUtils.Deployables
---@param unit UnitGrenadeDeployable
function GrenadeCrateBase:init(unit, ...)
    self._ehi_key = unit:key()
    original.init(self, unit, ...)
    Deployables:OnDeployablePlaced(unit)
end

function GrenadeCrateBase:GetRealAmount()
    return self._grenade_amount or self._max_grenade_amount
end

function GrenadeCrateBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
end

function GrenadeCrateBase:SetIgnoreChild()
    if self._parent_done then
        return
    end
    self:SetIgnore()
    if EHITextFloatManager then
        EHITextFloatManager:IgnoreDeployable(self._ehi_key, true)
    end
    managers.ehi_hudlist:CallLeftListItemFunction("Deployable", "RemoveDeployable", self._ehi_key)
    self._ignore_set_by_parent = true
end

function GrenadeCrateBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    if self.UpdateAmount then
        self:UpdateAmount()
    end
    if EHITextFloatManager then
        EHITextFloatManager:_add_float(self._ehi_key, self._unit, true)
    end
    managers.ehi_hudlist:CallLeftListItemFunction("Deployable", "AddDeployableWithCurrentAmount", self._ehi_key, self._unit, self)
    Deployables:OnDeployablePlaced(self._unit)
end

function GrenadeCrateBase:_set_empty(...)
    Deployables:OnDeployableConsumed(self._ehi_key)
    original._set_empty(self, ...)
end

function GrenadeCrateBase:destroy(...)
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end

function CustomGrenadeCrateBase:init(unit, ...)
    self._ehi_key = unit:key()
    original.init_custom(self, unit, ...)
end

if not EHI:GetEquipmentOption("show_equipment_grenadecases") then
    return
end

---@class GrenadeCrateBase
---@field _grenade_amount number
---@field _max_grenade_amount number
---@field _unit UnitGrenadeDeployable

GrenadeCrateBase.__ehi_id = "grenade_crate"
GrenadeCrateBase.__ehi_tracker = "GrenadeCases"
---@param amount number?
function GrenadeCrateBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), self.__ehi_id, self.__ehi_tracker)
end

original._set_visual_stage = GrenadeCrateBase._set_visual_stage
function GrenadeCrateBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        self:UpdateAmount()
    end
end