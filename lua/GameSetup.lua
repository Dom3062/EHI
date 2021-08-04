local EHI = EHI
if EHI._hooks.GameSetup then
	return
else
	EHI._hooks.GameSetup = true
end

local original =
{
    init_finalize = GameSetup.init_finalize,
    save = GameSetup.save,
    load = GameSetup.load
}

local add =
{
    arena = true, -- The Alesso Heist
    kosugi = true, -- Shadow Raid
    dark = true -- Murky Station
}

local broken_units =
{
    [tostring(Idstring("units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"))] = true,
    [tostring(Idstring("units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"))] = true,
    [tostring(Idstring("units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"))] = true
}

function GameSetup:init_finalize(...)
    original.init_finalize(self, ...)
    local level_id = Global.game_settings.level_id
    if add[level_id] then
        dofile(EHI.LuaPath .. "levels/" .. level_id .. ".lua")
    end
    EHI:InitElements()
    local units = World:find_units_quick("all", 1)
    for _, unit in pairs(units or {}) do
        if unit and unit:timer_gui() and broken_units[tostring(unit:name())] then
            unit:timer_gui():DisableOnSetVisible()
        end
    end
end

function GameSetup:save(data, ...)
    original.save(self, data, ...)
    managers.ehi:save(data)
end

function GameSetup:load(data, ...)
    managers.ehi:load(data)
    original.load(self, data, ...)
    managers.ehi:LoadSync()
    EHI:SyncLoad()
end