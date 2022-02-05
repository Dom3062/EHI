if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = EHI
if EHI._hooks.MissionScriptElement then -- Don't hook twice, pls
    return
else
    EHI._hooks.MissionScriptElement = true
end
local level_id = Global.game_settings.level_id
local rotations =
{
    [1] = Rotation(0, 0, -0)
}
if level_id == "" then -- Fourth and last heist in City of Gold campaign
end