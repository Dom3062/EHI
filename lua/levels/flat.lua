local EHI = EHI
local Icon = EHI.Icons
---@class EHIHeliTracker : EHIWarningTracker
local EHIHeliTracker = class(EHIWarningTracker)
EHIHeliTracker._forced_icons = { Icon.Heli }
EHIHeliTracker._show_completion_color = true

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local kills = 7 -- Normal + Hard
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    kills = 10
elseif EHI:IsMayhemOrAbove() then
    kills = 15
end
---@type ParseTriggerTable
local triggers = {
    [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 }, hint = Hints.C4Delivery },

    [100068] = { max = kills, id = "SniperDeath", icons = { "sniper" }, class = TT.Progress, waypoint = { position_from_element_and_remove_vanilla_waypoint = 100294, restore_on_done = true }, hint = Hints.Kills },
    [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

    [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },

    [102001] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [100082] = { time = 30 + 10, id = "HeliComesWithMagnet", icons = { Icon.Heli, Icon.Winch }, hint = Hints.Winch },

    --- Add 0.2 delay here so the tracker does not hide first before this gets executed again; players won't notice 0.2 delay here
    [100147] = { time = 18.2 + 0.2, id = "HeliMagnetLoop", icons = { Icon.Heli, Icon.Winch, Icon.Loop }, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, enabled)
        if enabled and self._trackers:CallFunction2(trigger.id, "SetTimeNoAnim", trigger.time) then
            self:CreateTracker()
        end
    end), hint = Hints.Wait },
    [102181] = { id = "HeliMagnetLoop", special_function = SF.RemoveTracker },

    [100206] = { time = 30, id = "LoweringTheMagnet", icons = Icon.HeliDropWinch, waypoint = { data_from_element = 101016 }, hint = Hints.Winch },

    [103869] = { time = 600, id = "PanicRoomTakeoff", class_table = EHIHeliTracker, hint = Hints.Defend },
    [100405] = { time = 15, id = "HeliTakeoff", icons = { Icon.Heli, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1004051 }, hint = Hints.Wait },
    [1004051] = { id = "PanicRoomTakeoff", special_function = SF.RemoveTracker }
}

---@type ParseAchievementTable
local achievements =
{
    flat_2 =
    {
        elements =
        {
            [100049] = { time = 20, class = TT.Achievement.Base },
            [104859] = { special_function = SF.SetAchievementComplete }
        }
    },
    cac_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100809] = { time = 60, class = TT.Achievement.Base, trigger_once = true, condition_function = EHI.ConditionFunctions.PlayingFromStart },
            [100805] = { special_function = SF.SetAchievementComplete },
        }
    }
}

local other =
{
    [100290] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:IsLootCounterVisible() then
    other[102741] = EHI:AddLootCounter4(function(self, ...)
        local max = self._utils:CountInteractionAvailable("gen_pku_cocaine")
        EHI:ShowLootCounterNoChecks({ max = max + 1, client_from_start = true })
    end, { element = { 104303, 104306 }, present_timer = 0 })
end

--´drill defend waypoint001´ ElementWaypoint 101734
EHI.Waypoint:DisableTimerWaypoints({ [101734] = true })

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "panic_room_found" },
        { amount = 8000, name = "saws_done" },
        { amount = 3000, name = "panic_room_killed_all_snipers" },
        { amount = 2000, name = "c4_set_up" },
        { amount = 4000, name = "panic_room_roof_secured" },
        { amount = 1000, name = "panic_room_magnet_attached" },
        { amount = 3000, name = "panic_room_defended_heli" },
        { escape = 2000 }
    },
    loot =
    {
        coke = 500,
        toothbrush = 1000
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            max =
            {
                objectives = true,
                loot =
                {
                    coke = { times = 10 },
                    toothbrush = { times = 1 }
                }
            }
        }
    }
})