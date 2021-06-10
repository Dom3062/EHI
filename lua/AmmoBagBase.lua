if EHI._hooks.AmmoBagBase then
    return
else
    EHI._hooks.AmmoBagBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_ammobag") then
    return
end

local level_id = Global.game_settings.level_id
local ignore = {}
if level_id == "chill_combat" then -- Safehouse Raid
    ignore =
    {
        [100751] = true, -- 2x Ammo shelves
		[101242] = true
    }
end

local correction =
{
    [tostring(Idstring("units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"))] = 1,	--CustomAmmoBagBase / shelf 1
	[tostring(Idstring("units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"))] = 1,	--CustomAmmoBagBase / shelf 2
}

local function UpdateTracker(unit, key, amount)
    if managers.ehi:TrackerDoesNotExist("AmmoBags") then
        managers.ehi:AddTracker({
            id = "AmmoBags",
            format = "percent",
            icons = { "ammo_bag" },
            class = "EHIEquipmentTracker"
        })
    end
    managers.ehi:CallFunction("AmmoBags", "UpdateAmount", unit, key, amount)
end

local original =
{
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

function AmmoBagBase:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
    self._offset = correction[tostring(unit:name())] or 0
    self._ignore = ignore[unit:editor_id()] or false
end

function AmmoBagBase:GetEHIKey()
    return self._ehi_key
end

function AmmoBagBase:GetRealAmount()
    return (self._ammo_amount or self._max_ammo_amount) - self._offset
end

function AmmoBagBase:_set_visual_stage()
    original._set_visual_stage(self)
    if not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self._ammo_amount - self._offset)
    end
end

function AmmoBagBase:destroy()
    original.destroy(self)
    UpdateTracker(self._unit, self._ehi_key, 0)
end

function CustomAmmoBagBase:_set_empty()
    original.custom_set_empty(self)
    UpdateTracker(self._unit, self._ehi_key, 0)
end