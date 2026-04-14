local EHI = EHI
local SF = EHI.SpecialFunctions

dofile(EHI.LuaPath .. "levels/skm_base.lua")

local other = {}
if EHI:GetLoadSniperTrackers() then
    other[100359] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = EHI.Trackers.Sniper.Loop, sniper_count = 3 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    if EHI.IsClient then
        managers.ehi_assault:AddAssaultNumberSyncCallback(function(assault_number, in_assault)
            if assault_number <= 1 then
                return
            end
            managers.ehi_tracker:AddTracker({
                id = "Snipers",
                from_sync = true,
                count = EHISniperBase._alive_count,
                on_fail_refresh_t = 25,
                on_success_refresh_t = 20 + 10 + 25,
                sniper_count = 3,
                class = EHI.Trackers.Sniper.Loop
            })
        end)
    end
end
EHI.TrackerUtils.Hudlist:AddAssaultCallbackForSniperItem(2, "start", "skm_big2")
EHI.Mission:ParseTriggers({
    other = other
})