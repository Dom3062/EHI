local EHI = EHI
local SF = EHI.SpecialFunctions

local other =
{
    [101326] = EHI.IsHost and EHI:AddAssaultDelay({ time = 15 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100203] = { chance = 90, time = 10 + 1 + 10, recheck_t = 20 + 10, id = "Snipers", class = EHI.Trackers.Sniper.TimedChance, single_sniper = true, trigger_once = true }
    other[102224] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 25%
    other[102423] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10% (Loop restart)
    other[101840] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101841] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102082] = { time = 30 + 10, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementCounterFilter
        if EHI.IsHost and not element:_values_ok() then
            return
        elseif self._trackers:CallFunction2("Snipers", "SnipersKilled", trigger.time) then
            self._trackers:AddTracker({
                id = "Snipers",
                chance = 25,
                time = trigger.time,
                recheck_t = 20 + 10,
                single_sniper = true,
                no_logic_annoucement = true,
                class = EHI.Trackers.Sniper.TimedChance
            })
        end
    end) }
    other[101322] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
end
EHI.Manager:ParseTriggers({
    other = other
})