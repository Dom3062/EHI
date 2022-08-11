local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local chance = { id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance, special_function = SF.SetChanceFromElementWhenTrackerExists }
local triggers = {
    [103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, condition = very_hard_and_up, special_function = SF.SetTimeOrCreateTracker },
    [103367] = { chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance },
    [101001] = { time = 1200, id = "PresentDropChance50", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
    [101002] = { time = 600, id = "PresentDropChance40", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
    [101003] = { time = 600, id = "PresentDropChance30", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
    [101004] = { time = 600, id = "PresentDropChance20", icons = { "C_Vlad_H_XMas_Impossible", Icon.Wait }, class = TT.Warning },
    [101045] = { time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Heli, Icon.Wait } },
    [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry", "pd2_goto" }, special_function = SF.RemoveTriggerWhenExecuted },
    [105102] = { time = 30, id = "HeliLoot", icons = { Icon.Heli, Icon.Escape, Icon.LootDrop, "pd2_goto" }, special_function = SF.ExecuteIfElementIsEnabled },
    -- Hooked to 105072 instead of 105076 to track the take off accurately
    [105072] = { time = 82, id = "HeliLootTakeOff", icons = Icon.HeliWait, class = TT.Warning },

    [101005] = chance,
    [101006] = chance,
    [101007] = chance,
    [101008] = chance
}
local achievements = {}
if EHI:GetOption("show_achievement") and EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    achievements[104385] = { id = "uno_9", special_function = SF.IncreaseProgress }
    achievements[101471] = { max = 40, id = "uno_9", class = TT.AchievementProgress }
end

EHI:ParseTriggers(triggers, achievements)