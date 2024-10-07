local EHI = EHI
local SF = EHI.SpecialFunctions

local other =
{
    [100107] = EHI:IsHost() and EHI:AddAssaultDelay({ time = 15, trigger_once = true })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100234] = { chance = 20, time = 10 + 10, on_fail_refresh_t = 10, id = "Snipers", class = EHI.Trackers.Sniper.Loop, single_sniper = true }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 20%
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10% (Loop restart)
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15% (All snipers dead)
    other[100363] = { time = 20 + 10 + 10, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:SetTrackerTimeNoAnim("Snipers", trigger.time)
    end) }
    other[100260] = { special_function = EHI.Manager:RegisterCustomSF(function(self, ...)
        self._trackers:SetTrackerCount("Snipers", 1)
        self._trackers:CallFunction("Snipers", "AnnounceSniperSpawn")
    end) }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
EHI.Manager:ParseTriggers({
    other = other
})