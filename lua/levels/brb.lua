local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101136] = { special_function = SF.CustomCode, f = function()
        if EHI:IsDifficultyOrAbove("very_hard") then
            EHI:ShowAchievementLootCounter({
                achievement = "brb_8",
                max = 12,
                exclude_from_sync = true,
                remove_after_reaching_target = false,
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                    loot_type = "gold"
                }
            })
        end
    end },
    [100128] = { time = 38, id = "WinchDropTrainA", icons = { "equipment_winch_hook", "pd2_goto" } },
    [100164] = { time = 38, id = "WinchDropTrainB", icons = { "equipment_winch_hook", "pd2_goto" } },

    [100654] = { time = 120, id = "Winch", icons = { "equipment_winch_hook" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [100655] = { id = "Winch", special_function = SF.PauseTracker },
    [100656] = { id = "Winch", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100077, 2900)] = { time = 90, id = "Cutter", icons = { "equipment_glasscutter" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100078, 2900)] = { id = "Cutter", special_function = SF.PauseTracker },

    [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } },

    [100275] = { time = 20, id = "Van", icons = Icon.CarEscape }

    -- Will fix that later when OVK pulls out their head from their asses and fix the elements; won't probably happen anytime soon
    --[100837] = { time = 50, delay = 10, id = "VaultThermite", icons = { "pd2_fire" }, class = "EHIInaccurateTracker", trigger_at = 4, trigger_count = 0 }
}

EHI:ParseTriggers(triggers)