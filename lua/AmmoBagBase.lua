local EHI = EHI
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
        [1] = Vector3(-225, -2300, -800), -- 2x Ammo shelves
		[2] = Vector3(-100, -1500, -400)
    }
end

local function CheckIgnore(unit_pos)
    local result = false
    for _, pos in pairs(ignore) do
        if pos == unit_pos then
            result = true
            break
        end
    end
    return result
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Deployables") and amount ~= 0 then
            managers.ehi:AddAggregatedDeployablesTracker()
        end
        managers.ehi:CallFunction("Deployables", "UpdateAmount", "ammo_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("AmmoBags") and amount ~= 0 then
            managers.ehi:AddTracker({
                id = "AmmoBags",
                format = "percent",
                icons = { "ammo_bag" },
                exclude_from_sync = true,
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("AmmoBags", "UpdateAmount", unit, key, amount)
    end
end

local original =
{
    init = AmmoBagBase.init,
    _set_visual_stage = AmmoBagBase._set_visual_stage,
    destroy = AmmoBagBase.destroy,

    custom_set_empty = CustomAmmoBagBase._set_empty
}

function AmmoBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
    self._ignore = CheckIgnore(unit:position())
end

function AmmoBagBase:GetEHIKey()
    return self._ehi_key
end

function AmmoBagBase:GetRealAmount()
    return (self._ammo_amount or self._max_ammo_amount) - self._offset
end

function AmmoBagBase:SetOffset(offset)
    self._offset = offset
    if not self._ignore and self._unit:interaction():active() then
        UpdateTracker(self._unit, self._ehi_key, self._ammo_amount - self._offset)
    end
end

function AmmoBagBase:SetIgnore()
    self._ignore = true
    UpdateTracker(self._unit, self._ehi_key, 0)
end

function AmmoBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    if not self._ignore then
        UpdateTracker(self._unit, self._ehi_key, self._ammo_amount - self._offset)
    end
end

function AmmoBagBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomAmmoBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    UpdateTracker(self._unit, self._ehi_key, 0)
end