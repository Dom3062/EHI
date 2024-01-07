local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local start_delay = 1
local delay = 20 + math.rand(6.2, 7.5)
local HeliDropLootZone = { Icon.Heli, Icon.LootDrop, Icon.Goto }
---@type ParseTriggerTable
local triggers = {
    [101931] = { time = 90 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker, hint = Hints.peta2_LootZoneDelivery },
    [101932] = { time = 120 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker, hint = Hints.peta2_LootZoneDelivery },
    [101929] = { time = 30 + 150 + delay, id = "CageDrop", icons = HeliDropLootZone, hint = Hints.peta2_LootZoneDelivery },

    [102921] = { id = 101929, special_function = SF.RemoveTrigger }, ---@diagnostic disable-line

    [103060] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103444 } },
    [103061] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103438 } },
    [104809] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103443 } },

    [101959] = { time = 90 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },
    [101960] = { time = 120 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },
    [101961] = { time = 150 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootTimed },

    [102796] = { time = 10, id = "ObjectiveWait", icons = { Icon.Wait } },

    [102975] = { special_function = SF.Trigger, data = { 1029751, 1029752 } },
    [1029751] = { chance = 5, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance, hint = Hints.man_Code },
    [1029752] = { time = 30, id = "GenSecArrivalWarning", icons = { Icon.Phone, "pd2_generic_look" }, class = TT.Warning, hint = Hints.roberts_GenSecWarning },
    [102986] = { special_function = SF.RemoveTracker, data = { "CorrectPaperChance", "GenSecArrivalWarning" } },
    [102985] = { id = "CorrectPaperChance", special_function = SF.IncreaseChanceFromElement }, -- +25%
    [102937] = { time = 30, id = "GenSecArrival", icons = { { icon = Icon.Car, color = Color.red } }, class = TT.Warning, trigger_times = 1, hint = Hints.roberts_GenSec },

    [102995] = { time = 30, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall },
    [102996] = { time = 50, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall },
    [102997] = { time = 60, id = "CallAgain", icons = { Icon.Phone, Icon.Loop }, hint = Hints.roberts_NextPhoneCall },
    [102940] = { time = 10, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning, hint = Hints.PickUpPhone },
    [102945] = { id = "AnswerPhone", special_function = SF.RemoveTracker },

    [100052] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._trackers:RemoveTracker("CorrectPaperChance")
        self._trackers:RemoveTracker("GenSecArrivalWarning")
        self._trackers:RemoveTracker("GenSecArrival")
        self._trackers:RemoveTracker("CallAgain")
        self._trackers:RemoveTracker("AnswerPhone")
    end)}
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}
if EHI:IsLootCounterVisible() then
    other[106579] = { special_function = EHI:RegisterCustomSF(function(...)
        local max = 0
        local wd = managers.worlddefinition
        for i = 103625, 103684, 1 do
            local unit = wd:get_unit(i) --[[@as UnitBase]]
            if unit and unit:damage() and unit:damage()._variables and unit:damage()._variables.var_random == 0 then -- Money will spawn here
                max = max + 1
            end
        end
        EHI:ShowLootCounterNoChecks({ max = max })
    end)}
    EHI:AddLoadSyncFunction(function(self)
        self:Trigger(106579)
        self._trackers:SyncSecuredLoot()
    end)
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

EHI:ParseTriggers({ mission = triggers, other = other })

local tbl =
{
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [101570] = { remove_vanilla_waypoint = 102899 },
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101936] = { icons = { Icon.Vault }, remove_on_pause = true, remove_vanilla_waypoint = 102901 }
}
EHI:UpdateUnits(tbl)
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
    tactic =
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