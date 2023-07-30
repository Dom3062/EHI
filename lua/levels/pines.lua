local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local chance = { id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance, special_function = SF.SetChanceFromElementWhenTrackerExists }
local PresentDropTimer = { "C_Vlad_H_XMas_Impossible", Icon.Wait }
local preload =
{
    { id = "HeliLootTakeOff", icons = Icon.HeliWait, class = TT.Warning, hide_on_delete = true }
}
---@type ParseTriggerTable
local triggers = {
    [100109] = { time = 25, id = "EndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning },
    [100021] = { time = 180, id = "EndlessAssault2", icons = Icon.EndlessAssault, class = TT.Warning },
    [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up, special_function = SF.SetTimeOrCreateTracker },
    [103367] = { chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance },
    [101001] = { time = 1200, id = "PresentDropChance50", icons = PresentDropTimer, class = TT.Warning },
    [101002] = { time = 600, id = "PresentDropChance40", icons = PresentDropTimer, class = TT.Warning },
    [101003] = { time = 600, id = "PresentDropChance30", icons = PresentDropTimer, class = TT.Warning },
    [101004] = { time = 600, id = "PresentDropChance20", icons = PresentDropTimer, class = TT.Warning },
    [101045] = { additional_time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Heli, Icon.Wait } },
    [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry" }, trigger_times = 1 },
    [105102] = { time = 30, id = "HeliLoot", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
    -- Hooked to 105072 instead of 105076 to track the take off accurately
    [105072] = { id = "HeliLootTakeOff", run = { time = 82 } },

    [101005] = chance,
    [101006] = chance,
    [101007] = chance,
    [101008] = chance
}
---@type ParseAchievementTable
local achievements =
{
    uno_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101471] = { max = 40, class = TT.AchievementProgress },
            [104385] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other = {}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    preload = preload
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    loot_all = 2000
})