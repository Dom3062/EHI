local EHI = EHI
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
    [EHI:GetInstanceElementID(100103, 2900)] = { time = 5, id = "C4OfficeFloor", icons = { Icon.C4 } },

    [100124] = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire } },

    [100275] = { time = 20, id = "Van", icons = Icon.CarEscape },

    [100142] = { time = 5, id = "C4Vault", icons = { Icon.C4 } }

    -- Will fix that later when OVK pulls out their heads from their asses and fix the elements; won't probably happen anytime soon
    --[100837] = { time = 50, delay = 10, id = "VaultThermite", icons = { "pd2_fire" }, class = "EHIInaccurateTracker", trigger_at = 4, trigger_count = 0 }
}

local DisableWaypoints = {}
for _, index in ipairs({ 900, 1100, 1500, 3200 }) do -- brb/single_door + brb/single_door_large
    DisableWaypoints[EHI:GetInstanceElementID(100021, index)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, index)] = true -- Fix
end

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --levels/instances/unique/brb/brb_vault
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [EHI:GetInstanceElementID(100058, 1900)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100003, 1900) },
    [EHI:GetInstanceElementID(100058, 2400)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100003, 2400) }
}
EHI:UpdateUnits(tbl)