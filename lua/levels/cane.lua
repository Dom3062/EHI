local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local fire_recharge = { time = 180, id = "FireRecharge", icons = { "pd2_fire", "restarter" } }
local fire_t = { time = 60, id = "Fire", icons = { "pd2_fire" }, class = TT.Warning }
local triggers = {
    [100647] = { time = 240 + 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop } },
    [EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = { Icon.Escape, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = { Icon.Escape, Icon.LootDrop, "faster" }, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" } },
    [EHI:GetInstanceElementID(100135, 11300)] = { time = 12, id = "SafeEvent", icons = { Icon.Heli, "pd2_goto" } },
    [101167] = { time = 1800, id = "cane_2", class = TT.AchievementUnlock, condition = show_achievement and ovk_and_up },
    [101176] = { id = "cane_2", special_function = SF.SetAchievementFailed }
}
for _, index in pairs({0, 120, 240, 360, 480}) do
    local recharge = EHI:DeepClone(fire_recharge)
    recharge.id = recharge.id .. index
    triggers[EHI:GetInstanceElementID(100024, index)] = recharge
    local fire = EHI:DeepClone(fire_t)
    fire.id = fire.id .. index
    triggers[EHI:GetInstanceElementID(100022, index)] = fire
end

EHI:ParseTriggers(triggers)
if show_achievement and ovk_and_up then
    EHI:ShowAchievementLootCounter({
        achievement = "cane_3",
        max = 100,
        exclude_from_sync = true,
        remove_after_reaching_target = false
    })
end