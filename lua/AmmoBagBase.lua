if EHI:CheckLoadHook("AmmoBagBase") then
    return
end

AmmoBagBase._ehi_ignored_pos = {}
local original =
{
    init = AmmoBagBase.init,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

local Deployables = EHI.TrackerUtils.Deployables
---@param unit UnitAmmoDeployable
function AmmoBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = unit:key()
    self._offset = 0
    Deployables:OnDeployablePlaced(unit)
    if self._ehi_ignored_pos[tostring(unit:position())] then
        Deployables:_deployable_ignored(self._ehi_key, nil, self)
    end
end

function AmmoBagBase:GetRealAmount()
    return (self._ammo_amount or self._max_ammo_amount) - (self._offset or 0)
end

---@param offset number
function AmmoBagBase:SetOffset(offset)
    self._offset = offset
    if self._ehi_key and self._unit:interaction():active() and self.UpdateAmount and not self._ignore then
        self:UpdateAmount()
    end
end

function AmmoBagBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
end

function AmmoBagBase:SetIgnoreChild()
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

function AmmoBagBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    self:SetOffset(self._offset)
    if EHITextFloatManager then
        EHITextFloatManager:_add_float(self._ehi_key, self._unit, true)
    end
    managers.ehi_hudlist:CallLeftListItemFunction("Deployable", "AddDeployableWithCurrentAmount", self._ehi_key, self._unit, self)
    Deployables:OnDeployablePlaced(self._unit)
end

function AmmoBagBase:destroy(...)
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
    original.destroy(self, ...)
end

function CustomAmmoBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    if self.UpdateAmount then
        self:UpdateAmount(0)
    end
    Deployables:OnDeployableConsumed(self._ehi_key)
end

if not EHI:GetEquipmentOption("show_equipment_ammobag") then
    return
end

---@class AmmoBagBase
---@field _ammo_amount number
---@field _bullet_storm_level integer?
---@field _max_ammo_amount number
---@field _unit UnitAmmoDeployable

AmmoBagBase.__ehi_id = "ammo_bag"
AmmoBagBase.__ehi_tracker = "AmmoBags"
---@param amount number?
function AmmoBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), self.__ehi_id, self.__ehi_tracker)
end

original._set_visual_stage = AmmoBagBase._set_visual_stage
function AmmoBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        self:UpdateAmount()
    end
end