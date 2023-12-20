local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local heli_element_timer = 102292
local heli_delay = 60 -- Normal -> Very Hard
-- Bugged because of braindead use of ElementTimerTrigger...
--[[if EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    heli_element_timer = 102293
    heli_delay = 80
elseif EHI:IsMayhemOrAbove() then
    heli_element_timer = 102294
    heli_delay = 100
end]]
---@type ParseTriggerTable
local triggers = {
    -- Loud Heli Escape
    [101539] = { time = 5, id = "EndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning, hint = Hints.EndlessAssault },
    [102295] = { additional_time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = heli_element_timer, hint = Hints.LootEscape },
    [102296] = { id = "HeliEscape", special_function = SF.PauseTracker },
    [102297] = { id = "HeliEscape", special_function = SF.UnpauseTracker },

    -- Window Cleaning Platform
    [EHI:GetInstanceElementID(100047, 9280)] = { time = 20, id = "PlatformLoweringDown", icons = { Icon.Wait }, hint = Hints.Wait },

    -- Elevator
    [101277] = { time = 12, id = "ElevatorDown", icons = { Icon.Wait }, hint = Hints.Wait },
    [102061] = { time = 900/30, id = "ElevatorUp", icons = { Icon.Wait }, hint = Hints.Wait },

    -- Elevator Generator
    [EHI:GetInstanceElementID(100066, 13930)] = { id = "GeneratorStartChance", icons = { Icon.Power }, class = TT.Chance, hint = Hints.pent_Chance },
    [EHI:GetInstanceElementID(100018, 13930)] = { id = "GeneratorStartChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [EHI:GetInstanceElementID(100016, 13930)] = { id = "GeneratorStartChance", special_function = SF.RemoveTracker },

    -- Thermite
    [EHI:GetInstanceElementID(100035, 9930)] = { time = 22.5 * 3, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite },

    -- Car Platform
    [EHI:GetInstanceElementID(100133, 7830)] = { time = 1200/30, id = "CarRotate", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 300/30, id = "CarLiftUp", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait },
    [EHI:GetInstanceElementID(100002, 7830)] = { time = 5, id = "CarSpeedUp", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait },

    -- Lobby PCs
    [EHI:GetInstanceElementID(100014, 8230)] = { time = 10 + 3, id = "PCHack1", icons = { Icon.PCHack }, hint = Hints.Hack },
    [EHI:GetInstanceElementID(100014, 13330)] = { time = 10 + 3, id = "PCHack2", icons = { Icon.PCHack }, hint = Hints.Hack },
    [EHI:GetInstanceElementID(100014, 14430)] = { time = 10 + 3, id = "PCHack3", icons = { Icon.PCHack }, hint = Hints.Hack },
    [EHI:GetInstanceElementID(100014, 17830)] = { time = 10 + 3, id = "PCHack4", icons = { Icon.PCHack }, hint = Hints.Hack }
}
if EHI:IsClient() then
    -- FOR THE LOVE OF GOD
    -- OVERKILL
    -- STOP. USING. F... RANDOM DELAY, it's not funny
    triggers[102295].client = { time = heli_delay, random_time = 20 }
    triggers[102303] = { time = 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
    if EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL) then
        triggers[103584] = { time = 70 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
    else
        triggers[103585] = { time = 90 + 40, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
    end

    -- Thermite
    triggers[EHI:GetInstanceElementID(100036, 9930)] = { time = 22.5 * 2, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Thermite }
    -- 100037 has 0s delay for some reason...
    triggers[EHI:GetInstanceElementID(100038, 9930)] = { time = 22.5, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Thermite }
end

local DisableWaypoints = {}

-- pent_editing_room
for i = 11680, 12680, 500 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100093, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100044, i)] = true -- Fix
    DisableWaypoints[EHI:GetInstanceElementID(100107, i)] = true -- Fix
end

-- pent_security_box
for _, index in ipairs({ 17930, 18330, 18830, 19230, 19630, 20030, 20430 }) do
    DisableWaypoints[EHI:GetInstanceElementID(100081, index)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100082, index)] = true -- Fix
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 50 + 30, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local time_for_prefereds = self:IsMissionElementEnabled(104439) and 5 or 0
        self._trackers:AddTracker({
            id = trigger.id,
            time = trigger.time + time_for_prefereds,
            class = trigger.class
        }, trigger.pos)
    end)})
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:DisableWaypoints(DisableWaypoints)
local loot_triggers = {}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    if EHI:CanShowAchievement("pent_12") then
        EHI:AddOnAlarmCallback(function()
            EHI:ShowAchievementLootCounterNoCheck({
                achievement = "pent_12",
                max = 1,
                show_finish_after_reaching_target = true,
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
                    loot_type = "gnome"
                }
            })
        end)
    end
    loot_triggers[103616] = { special_function = SF.IncreaseProgressMax }
    loot_triggers[103617] = { special_function = SF.IncreaseProgressMax }
end

local max = 8
EHI:ShowLootCounter({
    max = max,
    triggers = loot_triggers
})

function DigitalGui:pent_10()
    local key = self._ehi_key or tostring(self._unit:key())
    local hook_key = "EHI_pent_10_" .. key
    if EHI:GetUnlockableOption("show_achievement_started_popup") then
        local function AchievementStarted(...)
            managers.hud:ShowAchievementStartedPopup("pent_10")
        end
        if self.TimerStartCountDown then
            EHI:HookWithID(self, "TimerStartCountDown", hook_key .. "_start", AchievementStarted)
        else
            EHI:HookWithID(self, "timer_start_count_down", hook_key .. "_start", AchievementStarted)
        end
    end
    if EHI:GetUnlockableOption("show_achievement_failed_popup") then
        EHI:HookWithID(self, "_timer_stop", hook_key .. "_end", function(...)
            managers.hud:ShowAchievementFailedPopup("pent_10")
        end)
    end
end

local tbl =
{
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [102452] = { f = function(unit_id, unit_data, unit)
        unit:digital_gui():SetRemoveOnPause(true)
        unit:digital_gui():SetWarning(true)
        if EHI:CanShowAchievement("pent_10") then
            unit:digital_gui():SetIcons(EHI:GetAchievementIcon("pent_10"))
            unit:digital_gui():pent_10()
        else
            unit:digital_gui():SetIcons({ EHI.Icons.Trophy })
        end
    end },
    [103872] = { ignore = true }
}
EHI:UpdateUnits(tbl)