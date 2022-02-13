local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local c4 = { time = 5, id = "C4", icons = { "pd2_c4" } }
local triggers = {
    [100484] = { time = 300, id = "farm_2", class = TT.AchievementUnlock },
    [100485] = { time = 30, id = "farm_4", class = TT.Achievement },
    [100915] = { time = 4640/30, id = "CraneMoveGas", icons = { "equipment_winch_hook", Icon.Fire, "pd2_goto" } },
    [100967] = { time = 3660/30, id = "CraneMoveGold", icons = { Icon.Escape } },
    [100319] = { id = "farm_2", special_function = SF.SetAchievementFailed },
    [102841] = { id = "farm_4", special_function = SF.SetAchievementComplete },
    [101553] = { id = "farm_3", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [103394] = { id = "farm_3", special_function = SF.SetAchievementFailed },
    [102880] = { id = "farm_3", special_function = SF.SetAchievementComplete },
    -- C4 (Doors)
    [100985] = c4,
    -- C4 (GenSec Truck)
    [100830] = c4,
    [100961] = c4
}

EHI:ParseTriggers(triggers)

if show_achievement then
    if ovk_and_up then
        EHI:ShowAchievementLootCounter({
            achievement = "farm_6",
            max = 1,
            exclude_from_sync = true,
            remove_after_reaching_target = false,
            counter =
            {
                check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                loot_type = "din_pig"
            }
        })
        if managers.ehi:TrackerExists("farm_6") then
            EHI:ShowLootCounter(10, 0, EHI.LootCounter.CheckType.OneTypeOfLoot, "gold")
        else
            EHI:ShowLootCounter(11)
        end
    else
        EHI:ShowLootCounter(10)
    end
else
    local max = 10
    if ovk_and_up then
        max = 11
    end
    EHI:ShowLootCounter(max)
end