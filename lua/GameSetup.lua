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

local levels =
{
    arena = true, -- The Alesso Heist
    kosugi = true, -- Shadow Raid
    dark = true, -- Murky Station,
    firestarter_1 = true, -- Firestarter Day 1

    fex = true, -- Buluc's Mansion
    chas = true, -- Dragon Heist
    sand = true, -- Ukrainian Prisoner Heist
    chca = true, -- Black Cat Heist
    Fourth_and_last_heist_in_City_of_Gold_campaign = true
}

local custom_levels =
{

}

function GameSetup:init_finalize(...)
    original.init_finalize(self, ...)
    local level_id = Global.game_settings.level_id
    if levels[level_id] then
        dofile(EHI.LuaPath .. "levels/" .. level_id .. ".lua")
    end
    if custom_levels[level_id] then
        dofile(EHI.LuaPath .. "custom_levels/" .. level_id .. ".lua")
    end
    EHI:InitElements()
    EHI:DisableWaypointsOnInit()
end

function GameSetup:save(data, ...)
    original.save(self, data, ...)
    managers.ehi:save(data)
end

function GameSetup:load(data, ...)
    EHI:FinalizeUnitsClient()
    managers.ehi:load(data)
    original.load(self, data, ...)
    managers.ehi:LoadSync()
    EHI:SyncLoad()
end