if EHI:CheckLoadHook("AmmoBagBase") then
    return
end

function AmmoBagBase:GetRealAmount()
    return (self._ammo_amount or self._max_ammo_amount) - (self._offset or 0)
end

---@param offset number
function AmmoBagBase:SetOffset(offset)
    self._offset = offset
    if self._ehi_key and self._unit:interaction():active() and not self._ignore then
        self:UpdateAmount()
    end
end

if not EHI:GetEquipmentOption("show_equipment_ammobag") then
    return
end

local original =
{
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

---@class AmmoBagBase
---@field _ammo_amount number
---@field _max_ammo_amount number
---@field _unit UnitAmmoDeployable

AmmoBagBase._ehi_ignored_pos = {}
function AmmoBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
    if next(self._ehi_ignored_pos) and self._ehi_ignored_pos[tostring(unit:position())] then
        self._ignore = true
    end
end

---@param amount number?
function AmmoBagBase:UpdateAmount(amount)
    managers.ehi_deployable:UpdateAmount(self._ehi_key, amount or self:GetRealAmount(), "ammo_bag", "AmmoBags")
end

function AmmoBagBase:SetIgnore()
    if self._ignore_set_by_parent then
        return
    end
    self._ignore = true
    self:UpdateAmount(0)
end

function AmmoBagBase:SetIgnoreChild()
    if self._parent_done then
        return
    end
    self:SetIgnore()
    self._ignore_set_by_parent = true
end

function AmmoBagBase:SetCountThisUnit()
    self._ignore = nil
    self._ignore_set_by_parent = nil
    self._parent_done = true
    self:SetOffset(self._offset)
end

function AmmoBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        self:UpdateAmount()
    end
end

function AmmoBagBase:destroy(...)
    self:UpdateAmount(0)
    original.destroy(self, ...)
end

function CustomAmmoBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    self:UpdateAmount(0)
end