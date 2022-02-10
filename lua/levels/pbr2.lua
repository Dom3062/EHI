local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } }
local ring = { id = "voff_4", special_function = SF.IncreaseProgress }
local triggers = {
    [102504] = { id = "cac_33", status = "ready", class = TT.AchievementNotification, condition = show_achievement and dw_and_above, exclude_from_sync = true },
    [103486] = { id = "cac_33", status = "ok", special_function = SF.SetAchievementStatus },
    [103479] = { id = "cac_33", special_function = SF.SetAchievementComplete },
    [103475] = { id = "cac_33", special_function = SF.SetAchievementFailed },
    [103487] = { max = 200, id = "cac_33_kills", icons = { "pd2_kill" }, class = TT.Progress, flash_times = 1, condition = show_achievement and dw_and_above, special_function = SF.ShowAchievementCustom, data = "cac_33", exclude_from_sync = true },
    [103477] = { id = "cac_33_kills", special_function = SF.IncreaseProgress },
    [103481] = { id = "cac_33_kills", special_function = SF.RemoveTracker },
    [101897] = { time = 60, id = "LockeSecureHeli", icons = { Icon.Heli, "equipment_winch_hook" } }, -- Time before Locke arrives with heli to pickup the money
    [102452] = { id = "jerry_4", special_function = SF.SetAchievementComplete },
    [102453] = { special_function = SF.Trigger, data = { 1024531, 1024532 } },
    [1024531] = { id = "jerry_3", class = TT.AchievementNotification, condition = ovk_and_up and show_achievement },
    [1024532] = { time = 83, id = "jerry_4", class = TT.Achievement, condition = ovk_and_up and show_achievement },
    [102816] = { id = "jerry_3", special_function = SF.SetAchievementFailed },
    [101314] = { id = "jerry_3", special_function = SF.SetAchievementComplete },

    [103248] = ring,

    [101985] = thermite, -- First grate
    [101984] = thermite -- Second grate
}
for i = 103252, 103339, 3 do
    triggers[i] = ring
end

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievement = "voff_4",
    max = 9,
    exclude_from_sync = true,
    no_counting = true
})