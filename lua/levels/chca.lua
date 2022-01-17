local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local mayhem_and_up = EHI:IsDifficultyOrAbove("mayhem")
local HeliEscape = { Icon.Heli, Icon.Escape, Icon.LootDrop }

local vault_reset_time = 5 -- Normal
if EHI:IsBetweenDifficulties("hard", "very_hard") then -- Hard + Very Hard
    vault_reset_time = 15
elseif EHI:IsDifficulty("overkill") then -- OVERKILL
    vault_reset_time = 20
elseif EHI:IsBetweenDifficulties("mayhem", "death_wish") then -- Mayhem + Death Wish
    vault_reset_time = 30
elseif EHI:IsDifficulty("death_sentence") then
    vault_reset_time = 40
end
local triggers = {
    -- Players spawned
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
    [1001071] = { id = "chca_9", status = "ok", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [1001072] = { special_function = SF.CustomCode, f = function()
        if EHI:IsAchievementLocked("chca_9") and show_achievement and ovk_and_up then
            local function check(self, data)
                if data.variant ~= "melee" then
                    managers.ehi:SetAchievementFailed("chca_9")
                end
            end
            EHI:HookWithID(StatisticsManager, "killed", "EHI_chca_9_killed", check)
            EHI:HookWithID(StatisticsManager, "killed_by_anyone", "EHI_chca_9_killed_by_anyone", check)
            EHI:AddOnAlarmCallback(function()
                managers.ehi:SetAchievementFailed("chca_9")
                EHI:Unhook("chca_9_killed")
                EHI:Unhook("chca_9_killed_by_anyone")
            end)
        end
    end },
    [1001073] = { max = 8, id = "chca_10", class = TT.AchievementProgress, remove_after_reaching_target = false, condition = show_achievement and mayhem_and_up },
    [102944] = { id = "chca_10", special_function = SF.IncreaseProgress }, -- Bodybag thrown
    [103371] = { id = "chca_10", special_function = SF.SetAchievementFailed }, -- Civie killed

    -- C4 in the meeting room
    [EHI:GetInstanceElementID(100025, 20420)] = { time = 5, id = "C4MeetingRoom", icons = { "pd2_c4" } },

    -- C4 in the vault room
    [EHI:GetInstanceElementID(100022, 11770)] = { time = 5, id = "C4VaultWall", icons = { "pd2_c4" } },

    -- Chandelier swing
    [EHI:GetInstanceElementID(100137, 20420)] = { time = 10 + 1 + 52/30, id = "Swing", icons = { "faster" } },

    -- Heli Extraction
    [101432] = { id = "HeliEscape", icons = HeliEscape, special_function = SF.GetElementTimerAccurate, element = 101362 },

    [EHI:GetInstanceElementID(100210, 14670)] = { time = 3 + vault_reset_time, id = "KeypadReset", icons = { "faster" } },
    [EHI:GetInstanceElementID(100176, 14670)] = { time = 30, id = "KeypadResetECMJammer", icons = { "faster" } },

    [102571] = { time = 10 + 15.25 + 0.5 + 0.2, random_time = 5, id = "WinchDrop", icons = { Icon.Heli, Icon.Winch, "pd2_goto" } },

    -- Winch (the element is actually in instance "chas_heli_drop")
    [EHI:GetInstanceElementID(100097, 21420)] = { time = 150, id = "Winch", icons = { Icon.Winch }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100104, 21420)] = { id = "Winch", special_function = SF.UnpauseTracker },
    [EHI:GetInstanceElementID(100105, 21420)] = { id = "Winch", special_function = SF.PauseTracker },
    -- DON'T REMOVE THIS, because OVK's scripting skills suck
    -- They pause the timer when it reaches zero for no reason. But the timer is already stopped via Lua...
    [EHI:GetInstanceElementID(100101, 21420)] = { id = "Winch", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100096, 21420)] = { time = 5 + 15, id = "HeliRaise", icons = { Icon.Heli, "faster" } },

    [102675] = { additional_time = 5 + 10 + 14, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.GetElementTimerAccurate, element = 102674 },

    [103269] = { time = 7 + 614/30, id = "BoatEscape", icons = { Icon.Boat, Icon.Escape } },
}
if client then
    local wait_time = 90 -- Very Hard and below
    local pickup_wait_time = 25 -- Normal and Hard
    if EHI:IsBetweenDifficulties("very_hard", "mayhem") then -- Very Hard to Mayhem
        pickup_wait_time = 40
    end
    if EHI:IsBetweenDifficulties("overkill", "mayhem") then
        -- OVERKILL or Mayhem
        wait_time = 120
    elseif dw_and_above then
        wait_time = 150
        pickup_wait_time = 55
    end
    triggers[101432].time = wait_time
    triggers[101432].random_time = 30
    triggers[101432].delay_only = true
    EHI:AddSyncTrigger(101432, triggers[101432])
    triggers[102675].time = pickup_wait_time + triggers[102675].additional_time
    triggers[102675].random_time = 15
    triggers[102675].delay_only = true
    EHI:AddSyncTrigger(102675, triggers[102675])
    if ovk_and_up then -- OVK and up
        triggers[101456] = { time = 120, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTrackerAccurate }
    end
    triggers[101366] = { time = 60, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101463] = { time = 45, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101367] = { time = 30, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[101372] = { time = 15, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTrackerAccurate }
    triggers[102678] = { time = 45, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate }
    triggers[102679] = { time = 15, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate }
    -- "pulling_timer_trigger_120sec" but the time is set to 80s...
    triggers[EHI:GetInstanceElementID(100099, 21420)] = { time = 80, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100100, 21420)] = { time = 90, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100060, 21420)] = { time = 20, id = "Winch", icons = { Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers)