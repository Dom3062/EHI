local add =
{
    ["arena"] = true,
    ["kosugi"] = true,
    ["dark"] = true
}

local _f_init_finalize = GameSetup.init_finalize
function GameSetup:init_finalize()
    _f_init_finalize(self)
    local level_id = Global.game_settings.level_id
    if add[level_id] then
        dofile(EHI.LuaPath .. "levels/" .. level_id .. ".lua")
    end
end