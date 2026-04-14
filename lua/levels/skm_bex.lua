local EHI = EHI
local SF = EHI.SpecialFunctions

dofile(EHI.LuaPath .. "levels/skm_base.lua")

local other = {}
if EHI:GetLoadSniperTrackers() then
    other[100358] = { id = "Snipers", class = EHI.Trackers.Sniper.Count, sniper_count = 2 }
    other[100359] = { id = "Snipers", class = EHI.Trackers.Sniper.Count, sniper_count = 3 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100366] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    if EHI.IsClient then
        local sniper_count = EHI:IsDifficultyOrBelow(EHI.Difficulties.VeryHard) and 2 or 3
        managers.ehi_assault:AddAssaultNumberSyncCallback(function(assault_number, in_assault)
            if assault_number <= 1 then -- 2 assaults
                return
            end
            managers.ehi_tracker:AddTracker({
                id = "Snipers",
                count = EHISniperBase._alive_count,
                sniper_count = sniper_count,
                class = EHI.Trackers.Sniper.Count
            })
        end)
    end
end
EHI.TrackerUtils.Hudlist:AddAssaultCallbackForSniperItem(2, "start", "skm_bex")
EHI.Mission:ParseTriggers({
    other = other
})