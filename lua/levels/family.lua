local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local triggers = {
    [102611] = { time = 1, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102612] = { time = 3, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102613] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [100750] = { time = 120 + 80, id = "Van", icons = Icon.CarEscape },
    [101568] = { time = 20, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101569] = { time = 40, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101572] = { time = 60, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101573] = { time = 80, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 10)
end)

local achievements =
{
    [100108] = { id = "uno_2", status = "secure", class = TT.AchievementStatus, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) },
    [100022] = { id = "uno_2", status = "defend", special_function = SF.SetAchievementStatus }, -- Alarm has been raised, defend the hostages until the escape vehicle arrives
    [101492] = { id = "uno_2", status = "secure", special_function = SF.SetAchievementStatus }, -- Escape vehicle is here, secure the remaining bags
    [102206] = { id = "uno_2", special_function = SF.SetAchievementFailed },
    [102207] = { id = "uno_2", special_function = SF.SetAchievementComplete }
}

local other =
{
    [102622] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
    [100107] = { special_function = SF.CustomCode, f = function()
        local SafeTriggers =
        {
            loot =
            {
                "spawn_loot_money"
            },
            no_loot =
            {
                "spawn_loot_value_c",
                "spawn_loot_value_d",
                "spawn_loot_value_e",
                "spawn_loot_crap_c"
            }
        }
        EHI:ShowLootCounter({
            max = 18,
            max_random = 2,
            sequence_triggers =
            {
                -- units/payday2/equipment/gen_interactable_sec_safe_05x05_titan/gen_interactable_sec_safe_05x05_titan
                [101239] = SafeTriggers,
                [101541] = SafeTriggers,
                [101543] = SafeTriggers,
                [101544] = SafeTriggers
            }
        })
    end}
}

EHI:ParseTriggers(triggers, achievements, other)