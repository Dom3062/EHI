local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove("very_hard")
local heli_element_timer = 102292
local heli_delay = 60 -- Normal -> Very Hard
-- Bugged because of braindead use of ElementTimerTrigger...
--[[if EHI:IsDifficulty("overkill") then -- OVERKILL
    heli_element_timer = 102293
    heli_delay = 80
elseif EHI:IsDifficultyOrAbove("mayhem") then -- Mayhem+
    heli_element_timer = 102294
    heli_delay = 100
end]]
local triggers = {
    -- Loud Heli Escape
    [101539] = { time = 5, id = "EndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning },
    [102295] = { additional_time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = heli_element_timer },
    [102296] = { id = "HeliEscape", special_function = SF.PauseTracker },
    [102297] = { id = "HeliEscape", special_function = SF.UnpauseTracker },

    -- Window Cleaning Platform
    [EHI:GetInstanceElementID(100047, 9280)] = { time = 20, id = "PlatformLoweringDown", icons = { "faster" } },

    -- Elevator
    [101277] = { time = 12, id = "ElevatorDown", icons = { "faster" } },
    [102061] = { time = 900/30, id = "ElevatorUp", icons = { "faster" } },

    -- Elevator Generator
    [EHI:GetInstanceElementID(100066, 13930)] = { chance = 0, id = "GeneratorStartChance", icons = { "pd2_power" }, class = TT.Chance },
    [EHI:GetInstanceElementID(100018, 13930)] = { id = "GeneratorStartChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [EHI:GetInstanceElementID(100016, 13930)] = { id = "GeneratorStartChance", special_function = SF.RemoveTracker },

    -- Thermite
    [EHI:GetInstanceElementID(100035, 9930)] = { time = 22.5 * 3, id = "Thermite", icons = { Icon.Fire } },

    -- Car Platform
    [EHI:GetInstanceElementID(100133, 7830)] = { time = 1200/30, id = "CarRotate", icons = { Icon.Car, "faster" } },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 300/30, id = "CarLiftUp", icons = { Icon.Car, "faster" } },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 5, id = "CarSpeedUp", icons = { Icon.Car, "faster" } },

    -- Lobby PCs
    [EHI:GetInstanceElementID(100014, 8230)] = { time = 10 + 3, id = "PCHack1", icons = { "wp_hack" } },
    [EHI:GetInstanceElementID(100014, 13330)] = { time = 10 + 3, id = "PCHack2", icons = { "wp_hack" } },
    [EHI:GetInstanceElementID(100014, 14430)] = { time = 10 + 3, id = "PCHack3", icons = { "wp_hack" } },
    [EHI:GetInstanceElementID(100014, 17830)] = { time = 10 + 3, id = "PCHack4", icons = { "wp_hack" } }
}
if Network:is_client() then
    -- FOR THE LOVE OF GOD
    -- OVERKILL
    -- STOP. USING. F... RANDOM DELAY, it's not funny
    triggers[102295].time = heli_delay + triggers[102295].additional_time
    triggers[102295].random_time = 20
    triggers[102295].class = TT.InaccuratePausable
    triggers[102295].delay_only = true
    EHI:AddSyncTrigger(102295, triggers[102295])
    triggers[102303] = { time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    if EHI:IsDifficultyOrBelow("overkill") then
        triggers[103584] = { time = 70 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    else
        triggers[103585] = { time = 90 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    end

    -- Thermite
    triggers[EHI:GetInstanceElementID(100036, 9930)] = { time = 22.5 * 2, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
    -- 100037 has 0s delay for some reason...
    triggers[EHI:GetInstanceElementID(100038, 9930)] = { time = 22.5, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist }
end

local DisableWaypoints =
{
    -- pent_editing_room -> MissionDoor class

    -- pent_security_box
    [EHI:GetInstanceElementID(100081, 17930)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 17930)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 18330)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 18330)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 18830)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 18830)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 19230)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 19230)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 19630)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 19630)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 20030)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 20030)] = true, -- Fix
    [EHI:GetInstanceElementID(100081, 20430)] = true, -- Defend
    [EHI:GetInstanceElementID(100082, 20430)] = true -- Fix
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
if very_hard_and_up then
    EHI:AddOnAlarmCallback(function()
        EHI:ShowAchievementLootCounter({
            achievement = "pent_12",
            max = 1,
            remove_after_reaching_target = false,
            exclude_from_sync = true,
            counter =
            {
                check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                loot_type = "gnome"
            }
        })
    end)
end