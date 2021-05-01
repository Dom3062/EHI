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

local function UpdateTracker(key, amount)
    if managers.hud.ehi then
        if not managers.hud:TrackerExists("AmmoBags") then
            managers.hud:AddTracker({
                id = "AmmoBags",
                format = "percent",
                icons = { "ammo_bag" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.hud.ehi:CallFunction("AmmoBags", "UpdateAmount", key, amount)
    elseif EHI._cache.Deployables.AmmoBags then
        EHI._cache.Deployables.AmmoBags[key] = amount
    end
end

local original =
{
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy
}

function AmmoBagBase:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
    self._offset = correction[tostring(unit:name())] or 0
    self._ignore = ignore[unit:editor_id()] or false
end

function AmmoBagBase:_set_visual_stage()
    original._set_visual_stage(self)
    if not self._ignore then
        UpdateTracker(self._ehi_key, self._ammo_amount - self._offset)
    end
end

function AmmoBagBase:destroy()
    original.destroy(self)
    UpdateTracker(self._ehi_key, 0)
end