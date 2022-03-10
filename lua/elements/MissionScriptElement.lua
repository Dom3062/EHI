local EHI = EHI
if EHI._hooks.MissionScriptElement then -- Don't hook twice, pls
    return
else
    EHI._hooks.MissionScriptElement = true
end
local rotations =
{
    [1] = Rotation(0, 0, -0)
}