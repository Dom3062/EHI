if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
local level_id = Global.game_settings.level_id
if level_id ~= "mex_cooking" then
    return
end