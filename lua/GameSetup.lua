if EHI._hooks.GameSetup then
	return
else
	EHI._hooks.GameSetup = true
end

local original =
{
    init_finalize = GameSetup.init_finalize,
    load = GameSetup.load
}

local add =
{
    ["arena"] = true,
    ["kosugi"] = true,
    ["dark"] = true
}

function GameSetup:init_finalize()
    original.init_finalize(self)
    local level_id = Global.game_settings.level_id
    if add[level_id] then
        dofile(EHI.LuaPath .. "levels/" .. level_id .. ".lua")
    end
end

function GameSetup:load(data)
    original.load(self, data)
    managers.ehi:load()
end