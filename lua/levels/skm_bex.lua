local EHI = EHI
local SF = EHI.SpecialFunctions

dofile(EHI.LuaPath .. "levels/skm_base.lua")

local other = {}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { id = "Snipers", class = EHI.Trackers.Sniper.Count, sniper_count = 2 }
    other[100359] = { id = "Snipers", class = EHI.Trackers.Sniper.Count, sniper_count = 3 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100366] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
EHI.Mission:ParseTriggers({
    other = other
})