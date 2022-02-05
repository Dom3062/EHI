local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local pc_hack = { time = 20, id = "PCHack", icons = { "wp_hack" } }
local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local hard_and_above = EHI:IsDifficultyOrAbove("hard")
local triggers = {
    [1] = { time = 720, id = "bigbank_4", class = TT.Achievement, condition = show_achievement and hard_and_above },
    [2] = { special_function = SF.RemoveTriggers, data = { 100107, 106140, 106150 } },
    [100107] = bigbank_4,
    [106140] = bigbank_4,
    [106150] = bigbank_4,
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire } },

    [100800] = { id = "cac_22", class = TT.AchievementNotification, condition = show_achievement and dw_and_above, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
    [106250] = { id = "cac_22", special_function = SF.SetAchievementFailed },
    [106247] = { id = "cac_22", special_function = SF.SetAchievementComplete },

    [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [104532] = pc_hack,
    [103179] = pc_hack,
    [103259] = pc_hack,
    [103590] = pc_hack,
    [103620] = pc_hack,
    [103671] = pc_hack,
    [103734] = pc_hack,
    [103776] = pc_hack,
    [103815] = pc_hack,
    [103903] = pc_hack,
    [103920] = pc_hack,
    [103936] = pc_hack,
    [103956] = pc_hack,
    [103974] = pc_hack,
    [103988] = pc_hack,
    [104014] = pc_hack,
    [104029] = pc_hack,
    [104051] = pc_hack,

    -- Heli escape
    [104126] = { time = 23 + 1, id = "HeliEscape", icons = Icon.HeliEscape },

    [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" } },
    [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" } },
    [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" } },

    [105623] = { time = 8, id = "Bus", icons = { Icon.Wait } }
}

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievement = "bigbank_3",
    max = 16,
    exclude_from_sync = true,
    remove_after_reaching_target = false
})