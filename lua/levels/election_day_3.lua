local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [103568] = { time = 60, id = "Hack", icons = { Icon.PCHack }, hint = Hints.Hack },
    [103585] = { id = "Hack", special_function = SF.RemoveTracker },

    [103478] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [103169] = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery, waypoint = { data_from_element_and_remove_vanilla_waypoint = 103185, restore_on_done = true } },
    [103179] = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery, waypoint = { data_from_element_and_remove_vanilla_waypoint = 101912, restore_on_done = true } },
    [103190] = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery, waypoint = { data_from_element_and_remove_vanilla_waypoint = 103183, restore_on_done = true } },
    [103195] = { time = 30, id = "DrillSpawnDelay", icons = { Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery, waypoint = { data_from_element_and_remove_vanilla_waypoint = 103184, restore_on_done = true } },

    [103535] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion }
}
local CrashIcons = EHI.TrackerUtils:GetTrackerIcons({ Icon.PCHack, Icon.Fix, "pd2_question" }, { Icon.Fix })
local tracker_merge =
{
    CrashChance =
    {
        start_timer = true,
        elements =
        {
            [101284] = { chance = 50, icons = { Icon.PCHack, Icon.Fix }, class = TT.Timed.Chance, hint = Hints.election_day_3_CrashChance, stop_timer_on_end = true },
            [103570] = { special_function = SF.DecreaseChanceFromElement }, -- -25%
            [100741] = { special_function = SF.RemoveTracker },
            [103572] = { time = 50, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime },
            [103573] = { time = 40, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime },
            [103574] = { time = 30, id = "CrashChanceTime", icons = CrashIcons, hint = Hints.election_day_3_CrashChanceTime },
        }
    }
}
local other =
{
    [102735] = EHI:AddAssaultDelay({ control = 5 }),
    [102736] = EHI:AddAssaultDelay({ control = 15 }),
    [102737] = EHI:AddAssaultDelay({ control = 25 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local refresh_t = EHI:GetValueBasedOnDifficulty({
        normal = 60,
        hard = 50,
        veryhard_or_above = 40
    })
    other[100356] = { time = refresh_t, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementFilter
        local t = trigger.time ---@cast t -?
        if element:_check_mode() then
            if self._cache.election_day_3_RefreshSniperTime then
                self._cache.election_day_3_RefreshSniperTime = nil
                self._trackers:CallFunction("Snipers", "UnpauseTimer", t)
            end
            if self._trackers:CallFunction2("Snipers", "SniperSpawnsSuccess", 2) then
                self._trackers:AddTracker({
                    id = "Snipers",
                    time = t,
                    refresh_t = t,
                    count = 2,
                    class = TT.Sniper.Timed
                })
            end
        else
            self._trackers:CallFunction("Snipers", "PauseTimer")
            self._cache.election_day_3_RefreshSniperTime = true
        end
    end) }
    other[100348] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100351] = { id = "Snipers", special_function = SF.DecreaseCounter }
    --other[100446] = EHI:AddSniperSpawnedPopup(true, true)
end
if EHI:IsLootCounterVisible() then
    other[103293] = EHI:AddLootCounter4(function(self, ...)
        local count = self._utils:CountInteractionAvailable("money_wrap")
        if count > 0 then
            EHI:ShowLootCounterNoChecks({ max = count, client_from_start = true })
        end
    end, { element = { 103525, 103532, 104721 } }, true)
end
EHI:SetMissionDoorData({
    -- Vault Doors
    [100342] = 104556, -- Left
    [100338] = 104611, -- Right

    -- Gate inside the vault
    [101581] = { w_id = 104645, restore = true }
})
EHI.Mission:ParseTriggers({ mission = triggers, other = other, tracker_merge = tracker_merge })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 20000
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 12 }
            }
        }
    }
})