local EHI = EHI
local SF = EHI.SpecialFunctions
local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [103712] = { time = 25, id = "HeliTrade", icons = Icon.HeliLootDrop, hint = EHI.Hints.Wait }
}

local other = {}
if EHI.TrackerUtils:IsLootCounterVisible({ element = 104450 }) then
    other[101705] = EHI:AddLootCounter(tweak_data.ehi.functions.ShowNumberOfLootbagsOnTheGround, { element = 104450 }, nil, nil, true)
end

if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104318] = { id = "Snipers", count = 2, chance_success = true, class = TT.Sniper.TimedChanceOnce }
    other[104319] = { id = "Snipers", count = 1, chance_success = true, class = TT.Sniper.TimedChanceOnce }
    other[104390] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    other = other
})
if EHI:IsEscapeChanceEnabled() then
    other[102557] = managers.ehi_escape:IncreaseChanceFromTrigger() -- +5%
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 24)
    end)
end
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 2000, stealth = true },
            { amount = 2000, loud = true, escape_chance = { start_chance = 24, kill_add_chance = 5 } }
        }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = 4, max = managers.job:get_memory("ehi_ff_saved_bags") or 9 },
                bonus_xp = { min_max = 2000 }
            }
        }
    }
})