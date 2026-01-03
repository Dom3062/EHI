local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [101392] = { time = 120, id = "FireEvidence", icons = { Icon.Fire }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { data_from_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100024, 18900) }, hint = Hints.Fire },
    [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },

    [101460] = { time = 18, id = "DoorBreach", icons = { Icon.Door }, waypoint = { data_from_element_and_remove_vanilla_waypoint = 103837 }, hint = Hints.Wait },

    [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, Icon.Winch }, waypoint = { data_from_element_and_remove_vanilla_waypoint = 101391 }, hint = Hints.Escape }
}
if EHI.IsClient then
    triggers[100233] = EHI:ClientCopyTrigger(triggers[101389], { time = 20 + 4 })
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_once = true, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({ mission = triggers, other = other })
EHI:ShowAchievementLootCounter({ -- Loot
    achievement = "pex_10",
    job_pass = managers.job:current_job_id() == "pex",
    max = 6,
    show_loot_counter = true,
    triggers =
    {
        [100357] = { special_function = SF.SetAchievementFailed }
    },
    add_to_counter = true,
    waypoint_loot_counter = { element = { 100020, 103012 } }
})
EHI:ShowAchievementLootCounter({ -- Medals
    achievement = "pex_11",
    job_pass = managers.job:current_job_id() == "pex",
    max = 7,
    triggers =
    {
        [103735] = { special_function = SF.IncreaseProgress },
        [100357] = { special_function = SF.SetAchievementFailed }
    },
    load_sync = function(self)
        --[[
            There are total 12 places where medals can appears
            -- 11 places are on the first floor (6 randomly selected)
            -- last place is in the locker room (instance)
            Game sync all used places. When a medal is picked up, it is removed from the world
            and not synced to other drop-in players

            Can't use function "CountInteractionAvailable" because the medal in the locker room is not interactable first
            This is more accurate and reliable
            This sets remaining from the maximum
        ]]
        self._trackers:SetSyncData("pex_11", self._utils:CountUnitsAvailable("units/pd2_dlc_pex/props/pex_props_federali_chief_medal/pex_props_federali_chief_medal", 1) - 5, true)
    end
})
local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { max = 6 }
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
                { amount = 4000, name = "mex3_found_rfid_tag" },
                { amount = 3000, name = "mex3_found_cells" },
                { amount = 4000, name = "mex3_armory_opened" },
                { amount = 4000, name = "mex3_handcuffs_cut" },
                { amount = 5000, name = "mex3_hajrudin_found_his_car" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 5000, name = "mex3_evidence_opened" },
                { amount = 5000, name = "mex3_evidence_burned" },
                { amount = 4000, name = "mex3_armory_opened" },
                { amount = 5000, name = "mex3_hajrudin_found_his_car" },
                { amount = 4000, name = "heli_arrival" },
                { escape = 3000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})