local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local WinchCar = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue } }
local ElementTimer = 102059
local ElementTimerPickup = 102075
local WeaponsPickUp = { Icon.Heli, Icon.Interact }
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
if OVKorAbove then
    ElementTimer = 102063
    ElementTimerPickup = 102076
end
local FultonCatchAgain = { id = "FultonCatchAgain", icons = WeaponsPickUp, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootTimed }
local FultonCatchSuccess = { time = 6.8, id = "FultonCatchSuccess", icons = WeaponsPickUp, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
    if self._trackers:TrackerDoesNotExist("FultonCatch") or self._trackers:TrackerDoesNotExist("FultonCatchAgain") then
        self:CheckCondition(trigger)
    end
end), hint = Hints.LootTimed }
local FultonCatchIncreaseChance = { id = "FultonCatchChance", special_function = SF.IncreaseChanceFromElement }
local FultonRemoveCatch = { id = "FultonCatch", special_function = SF.RemoveTracker }

local sync_triggers =
{
    [EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgain,
}
---@type ParseTriggerTable
local triggers = {
    [EHI:GetInstanceElementID(100083, 12500)] = { time = 230/30, id = "CarPush1", icons = WinchCar, hint = Hints.hox_1_Car },
    [EHI:GetInstanceElementID(100084, 12500)] = { time = 230/30 + 1, id = "CarPush2", icons = WinchCar, hint = Hints.hox_1_Car },
    [EHI:GetInstanceElementID(100087, 12500)] = { time = 250/30, id = "CarWinchUsed", icons = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue }, Icon.Winch }, hint = Hints.Winch },

    -- Thermite
    [EHI:GetInstanceElementID(100012, 2850)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire }, hint = Hints.Thermite },
    [EHI:GetInstanceElementID(100012, 2950)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire }, hint = Hints.Thermite },

    -- C4
    [EHI:GetInstanceElementID(100044, 2850)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 }, hint = Hints.Explosion },
    [EHI:GetInstanceElementID(100044, 2950)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 }, hint = Hints.Explosion },

    -- Fulton (Preplanning asset)
    [102053] = { additional_time = 7, id = "FultonDropCage", icons = Icon.HeliDropBag, special_function = SF.GetElementTimerAccurate, element = ElementTimer, hint = Hints.peta2_LootZoneDelivery },
    [EHI:GetInstanceElementID(100053, 14950)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25500)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25650)] = FultonCatchSuccess,
    [102070] = { special_function = SF.Trigger, data = { 1020701, 1020702 } },
    [1020701] = { chance = 34, id = "FultonCatchChance", icons = { Icon.Heli }, class = TT.Chance, hint = Hints.ranc_Chance },
    [1020702] = { additional_time = 6.8, id = "FultonCatch", icons = WeaponsPickUp, special_function = SF.GetElementTimerAccurate, element = ElementTimerPickup, hint = Hints.LootTimed },
    [103988] = { id = "FultonCatchChance", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100055, 14950)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25500)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25650)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100056, 14950)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25500)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25650)] = FultonRemoveCatch
}

if EHI:IsClient() then
    triggers[102053].client = { time = OVKorAbove and 60 or 30, random_time = 5 }
    triggers[1020702].client = { time = OVKorAbove and 60 or 30, random_time = 5 }
    local FultonCatchAgainClient = { additional_time = 30, random_time = 30, id = "FultonCatchAgain", icons = FultonCatchAgain, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgainClient
    EHI:SetSyncTriggers(sync_triggers)
else
    EHI:AddHostTriggers(sync_triggers, "base")
end

--[[
    anim_ranc_arrive_01 -> 215/30 + 2-7 + 10 + 10 -> 29,1666-34,1666
    anim_ranc_arrive_02 -> 202/30 + 10-15 + 5 + 10 -> 31,7333-36,7333
    anim_ranc_arrive_03 -> 170/30 + 6.9 + 10-15 + 10 -> 32,5666-37,5666
    anim_ranc_arrive_04 -> 894/30 + 0-5 + 10 -> 39,8-44,8
    anim_ranc_arrive_05 -> 980/30 + 5 + 10 -> 47,6666
]]
local other =
{
    [100109] = EHI:AddAssaultDelay({ additional_time = 20 + 215/30 + 2 + 10 + 10 + 10 + 30, random_time = 5 + 10 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, other = other })
local ranc_10 = { special_function = SF.IncreaseProgress }
local ranc_10_triggers =
{
    [EHI:GetInstanceElementID(100015, 28400)] = ranc_10
}
for i = 28600, 29300, 50 do
    ranc_10_triggers[EHI:GetInstanceElementID(100015, i)] = ranc_10
end
EHI:ShowAchievementLootCounter({
    achievement = "ranc_10",
    max = 5,
    triggers = ranc_10_triggers,
    load_sync = function(self)
        self._trackers:SetTrackerProgress("ranc_10", 5 - self:CountInteractionAvailable("ranc_press_pickup_horseshoe"))
    end
})
EHI:ShowAchievementKillCounter({
    achievement = "ranc_9", -- "Caddyshacked" achievement
    achievement_stat = "ranc_9_stat", -- 100
    achievement_option = "show_achievements_vehicle",
    difficulty_pass = OVKorAbove
})
EHI:ShowAchievementKillCounter({
    achievement = "ranc_11", -- "Marshal Law" achievement
    achievement_stat = "ranc_11_stat", -- 4
    achievement_option = "show_achievements_weapon",
    difficulty_pass = OVKorAbove
})