local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local start_delay = 1
local delay = 20 + math.rand(6.2, 7.5)
---@type ParseTriggerTable
local triggers = {
    [101931] = { time = 90 + delay, id = "CageDrop", icons = Icon.HeliDropBag, special_function = SF.SetTimeOrCreateTracker, hint = Hints.peta2_LootZoneDelivery },
    [101932] = { time = 120 + delay, id = "CageDrop", icons = Icon.HeliDropBag, special_function = SF.SetTimeOrCreateTracker, hint = Hints.peta2_LootZoneDelivery },
    [101933] = { time = 150 + delay, id = "CageDrop", icons = Icon.HeliDropBag, special_function = SF.SetTimeOrCreateTracker, hint = Hints.peta2_LootZoneDelivery },
    [101929] = { time = 30 + 150 + delay, id = "CageDrop", icons = Icon.HeliDropBag, class = TT.TimePreSync, hint = Hints.peta2_LootZoneDelivery },

    [102921] = { id = 101929, special_function = SF.RemoveTrigger }, ---@diagnostic disable-line

    [101959] = { time = 90 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },
    [101960] = { time = 120 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },
    [101961] = { time = 150 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },

    [102796] = { time = 10, id = "ObjectiveWait", icons = { Icon.Wait } },

    [102975] = { special_function = SF.Trigger, data = { 1029751, 1029752 } },
    [1029751] = { chance = 5, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance, hint = Hints.man_Code, remove_on_alarm = true },
    [1029752] = { time = 30, id = "GenSecArrivalWarning", icons = { Icon.Phone, Icon.ExclamationMark }, class = TT.Warning, hint = Hints.roberts_GenSecWarning, remove_on_alarm = true },
    [102986] = { special_function = SF.RemoveTracker, data = { "CorrectPaperChance", "GenSecArrivalWarning" } },
    [102985] = { id = "CorrectPaperChance", special_function = SF.IncreaseChanceFromElement }, -- +25%
    [102937] = { time = 30, id = "GenSecArrival", icons = { { icon = Icon.Car, color = Color.red } }, class = TT.Warning, trigger_once = true, hint = Hints.roberts_GenSec, remove_on_alarm = true },

    [102995] = { time = 30, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall, remove_on_alarm = true },
    [102996] = { time = 50, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall, remove_on_alarm = true },
    [102997] = { time = 60, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall, remove_on_alarm = true },
    [102940] = { time = 10, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning, hint = Hints.PickUpPhone, remove_on_alarm = true },
    [102945] = { id = "AnswerPhone", special_function = SF.RemoveTracker }
}
if EHI.IsClient then
    triggers[101934] = EHI:ClientCopyTrigger(triggers[101929], { time = delay })
end
tweak_data.ehi.functions.eng_X("eng_3", "eng_3_stats") -- "The one that survived" achievement

local sidejob =
{
    daily_rush =
    {
        elements =
        {
            [106579] = { time = 391, class = TT.SideJob.Base },
            [106580] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:IsLootCounterVisible() then
    other[103610] = EHI:AddLootCounter2(function()
        EHI:ShowLootCounterNoChecks({ max = tweak_data.ehi.functions.GetNumberOfDepositBoxesWithLoot(103625, 103684), client_from_start = true })
    end, nil, function(self)
        self:Trigger()
        self._loot:SyncSecuredLoot()
    end, true)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 15 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 15 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103060] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_from_element = 103444 } }
    other[103061] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_from_element = 103438 } }
    other[104809] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_from_element = 103443 } }
end
EHI.Mission:ParseTriggers({ mission = triggers, other = other, sidejob = sidejob })

EHI.Unit:UpdateUnits({
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [101570] = { remove_vanilla_waypoint = 102899 },
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101936] = { icons = { Icon.Vault }, remove_on_pause = true, remove_vanilla_waypoint = 102901 }
})
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { min = 1, max = 10 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "timelock_done" },
                { amount = 500, name = "phone_answered", times = 4 },
                { escape = 1000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 7000, name = "thermaldrill_done" },
                { amount = 3000, name = "cage_assembled" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})