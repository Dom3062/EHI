local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local triggers =
{
    -- Time before escape vehicle arrives
    [300248] = { time = (EHI:IsDifficultyOrBelow("overkill") and 120 or 300) + 25, id = "EscapeHeli", icons = EHI.Icons.HeliEscapeNoLoot },
    -- 120: Base Delay on OVK or below
    -- 300: Base Delay on Mayhem or above
    -- 25: Escape zone activation delay

    [300043] = { id = "MallDestruction", class = TT.MallcrasherMoney, icons = { "C_Vlad_H_Mallcrasher_Shoot" } },
    [300852] = { amount = 40, id = "MallDestruction", special_function = SF.AddMoney },
    [300853] = { amount = 80, id = "MallDestruction", special_function = SF.AddMoney },
    [300854] = { amount = 250, id = "MallDestruction", special_function = SF.AddMoney },
    [300855] = { amount = 500, id = "MallDestruction", special_function = SF.AddMoney },
    [300856] = { amount = 800, id = "MallDestruction", special_function = SF.AddMoney },
    [300857] = { amount = 2000, id = "MallDestruction", special_function = SF.AddMoney },
    [300858] = { amount = 2800, id = "MallDestruction", special_function = SF.AddMoney },
    [300859] = { amount = 4000, id = "MallDestruction", special_function = SF.AddMoney },
    [300873] = { amount = 5600, id = "MallDestruction", special_function = SF.AddMoney },
    --[300863] = { amount = 5600, id = "MallDestruction", special_function = true },
    --[300867] = { amount = 5600, id = "MallDestruction", special_function = true },
    --[300869] = { amount = 5600, id = "MallDestruction", special_function = true },
    --[300870] = { amount = 5600, id = "MallDestruction", special_function = true },
    --[300830] = { amount = 8000, id = "MallDestruction", special_function = true },

    [301148] = { special_function = SF.Trigger, data = { 3011481, 3011482 } },
    [3011481] = { time = 50, to_secure = 1800000, id = "ameno_3", class = TT.AchievementTimedMoneyCounterTracker, condition = show_achievement and EHI:IsDifficulty("overkill"), exclude_from_sync = true },
    [3011482] = { time = 180, id = "uno_3", class = TT.Achievement, exclude_from_sync = true },
    [300241] = { id = "uno_3", special_function = SF.SetAchievementComplete },

    [301056] = { max = 171, id = "window_cleaner", flash_times = 1, class = TT.AchievementProgress },
    [300791] = { id = "window_cleaner", special_function = SF.IncreaseProgress }
}

EHI:ParseTriggers(triggers)