local EHI = EHI

dofile(EHI.LuaPath .. "levels/skm_base.lua")

local other =
{
    [100953] = EHI:AddSniperSpawnedPopup(true),
    [100954] = EHI:AddSniperSpawnedPopup(true),
    [100956] = EHI:AddSniperSpawnedPopup(true)
}
EHI.Manager:ParseTriggers({
    other = other
})