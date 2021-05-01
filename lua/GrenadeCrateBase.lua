if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_grenadecases") then
    return
end

local level_id = Global.game_settings.level_id
local ignore = {}
if level_id == "sah" then -- Shacklethorne Auction
    ignore =
    {
        [400178] = true -- Unused Grenade case
    }
end

local _cache = {}

local function UpdateTracker(key, amount)
    if managers.hud.ehi and key and amount then
        if not managers.hud:TrackerExists("GrenadeCases") then
            managers.hud:AddTracker({
                id = "GrenadeCases",
                icons = { "frag_grenade" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.hud.ehi:CallFunction("GrenadeCases", "UpdateAmount", key, amount)
        for k, a in pairs(_cache) do
            managers.hud.ehi:CallFunction("GrenadeCases", "UpdateAmount", k, a or 0)
        end
        _cache = {}
    else
        if EHI and EHI._cache and EHI._cache.Deployables and EHI._cache.GrenadeCases and key then
            EHI._cache.Deployables.GrenadeCases[key] = amount
        elseif key then
            _cache[key] = amount
        end
    end
end

local original =
{
    init = GrenadeCrateBase.init,
    _set_visual_stage = GrenadeCrateBase._set_visual_stage,
    destroy = GrenadeCrateBase.destroy
}
function GrenadeCrateBase:init(unit)
    self._ehi_key = tostring(unit:key())
    self._ignore = ignore[unit:editor_id()] or false
    original.init(self, unit)
end

function GrenadeCrateBase:_set_visual_stage()
    original._set_visual_stage(self)
    if not self._ignore then
        UpdateTracker(self._ehi_key, self._grenade_amount)
    end
end

function GrenadeCrateBase:destroy()
    original.destroy(self)
    UpdateTracker(self._ehi_key, 0)
end

--[[function GrenadeCrateBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end
end

CustomGrenadeCrateBase = CustomGrenadeCrateBase or class(GrenadeCrateBase)

function CustomGrenadeCrateBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = self.is_attachable or false
	self._max_grenade_amount = self.max_grenade_amount or tweak_data.upgrades.grenade_crate_base

	self:setup()
end

function CustomGrenadeCrateBase:_set_empty()
	self._empty = true

	if alive(self._unit) then
		self._unit:interaction():set_active(false)
	end

	if self._unit:damage():has_sequence("empty") then
		self._unit:damage():run_sequence_simple("empty")
	end
end]]