local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [108538] = { time = 60, id = "Gas", icons = { Icon.Teargas } },

    [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

    [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 100451 } },
    -- 60s delay after flare has been placed
    -- 25s to land
    -- 3s to open the heli doors

    [102593] = { time = 30, id = "ChemSetReset", icons = { Icon.Methlab, Icon.Loop } },
    [101217] = { time = 30, id = "ChemSetInterrupted", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
    [102595] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab } },

    [102009] = { time = 60, id = "Crane", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101702] = { id = "Crane", special_function = SF.PauseTracker },

    [100729] = { chance = 20, id = "HackChance", icons = { Icon.PCHack }, class = TT.Timer.Chance },
    [108694] = { id = "HackChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [101485] = { id = "HackChance", special_function = SF.RemoveTracker }
}
if EHI:IsClient() then
    triggers[100564] = EHI:ClientCopyTrigger(triggers[100423], { time = 25 + 3 })
    -- Not worth adding the 3s delay here
end
EHI:FilterOutNotLoadedTrackers(triggers, "show_timers")

---@type ParseAchievementTable
local achievements =
{
    des_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = "push", class = TT.AchievementStatus },
            [102480] = { special_function = SF.Trigger, data = { 1024801, 1024802 } },
            [1024801] = { status = "finish", special_function = SF.SetAchievementStatus },
            ---@diagnostic disable-next-line
            [1024802] = { id = 102486, special_function = SF.RemoveTrigger },
            [102710] = { special_function = SF.SetAchievementComplete },
            [102486] = { special_function = SF.SetAchievementFailed }
        }
    },
    des_11 =
    {
        elements =
        {
            [103025] = { time = 3, class = TT.Achievement, trigger_times = 1 },
            [102822] = { special_function = SF.SetAchievementComplete }
        }
    },
    uno_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100296] = { max = 2, class = TT.AchievementProgress },
            [103391] = { special_function = SF.IncreaseProgress },
            [103395] = { special_function = SF.SetAchievementFailed },
        }
    }
}

local other =
{
    [102065] = EHI:AddAssaultDelay({ time = 2 + 30 + 2 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 30 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100297] = { chance = 25, recheck_t = 30, id = "SnipersBlackhawk", class = TT.Sniper.HeliTimedChance }
    other[101295] = { id = "SnipersBlackhawk", special_function = SF.IncreaseChanceFromElement }
    other[101293] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess", arg = { 25 } }
    other[EHI:GetInstanceElementID(100023, 7500)] = { id = "SnipersBlackhawk", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100007, 7500)] = { id = "SnipersBlackhawk", special_function = SF.DecreaseCounter }
    other[EHI:GetInstanceElementID(100025, 7500)] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SnipersKilled", arg = { 23 } }
    other[EHI:GetInstanceElementID(100023, 8000)] = { id = "SnipersBlackhawk", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100007, 8000)] = { id = "SnipersBlackhawk", special_function = SF.DecreaseCounter }
    other[EHI:GetInstanceElementID(100025, 8000)] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SnipersKilled", arg = { 23 } }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    --units/pd2_dlc_des/props/des_prop_inter_hack_computer/des_inter_hack_computer
    [103009] = { icons = { Icon.Power } },

    --units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit
    [101323] = { remove_on_power_off = true },
    [101324] = { remove_on_power_off = true },

    --levels/instances/unique/des/des_drill
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [EHI:GetInstanceUnitID(100030, 21000)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100009, 21000) }
}

local DisableWaypoints =
{
    -- Hackboxes at the start
    [EHI:GetInstanceElementID(100007, 11000)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11000)] = true, -- Fix
    [EHI:GetInstanceElementID(100007, 11500)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11500)] = true, -- Fix

    -- Archaeology
    [EHI:GetInstanceElementID(100008, 21000)] = true, -- Defend
    -- Interact is disabled in CoreWorldInstanceManager.lua

    -- Turret charging computer
    [101122] = true, -- Defend
    [103191] = true, -- Fix

    -- Outside hack turret box
    [102901] = true, -- Defend
    [102902] = true, -- Fix
    [102926] = true, -- Defend
    [102927] = true -- Fix
}

-- levels/instances/unique/des/des_computer/001-004
for i = 3000, 4500, 500 do
    tbl[EHI:GetInstanceUnitID(100051, i)] = { tracker_merge_id = "HackChance" }
    DisableWaypoints[EHI:GetInstanceElementID(100025, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100026, i)] = true -- Fix
end

-- levels/instances/unique/des/des_computer/012
tbl[EHI:GetInstanceUnitID(100051, 8500)] = { tracker_merge_id = "HackChance" }
DisableWaypoints[EHI:GetInstanceElementID(100025, 8500)] = true -- Defend
DisableWaypoints[EHI:GetInstanceElementID(100026, 8500)] = true -- Fix

-- levels/instances/unique/des/des_computer_001/001
-- levels/instances/unique/des/des_computer_002/001
for i = 6000, 6500, 500 do
    tbl[EHI:GetInstanceUnitID(i == 6000 and 100000 or 100051, i)] = { tracker_merge_id = "HackChance" }
    DisableWaypoints[EHI:GetInstanceElementID(100025, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100026, i)] = true -- Fix
end

-- levels/instances/unique/des/des_computer_002/002
tbl[EHI:GetInstanceUnitID(100051, 29550)] = { tracker_merge_id = "HackChance" }
DisableWaypoints[EHI:GetInstanceElementID(100025, 29550)] = true -- Defend
DisableWaypoints[EHI:GetInstanceElementID(100026, 29550)] = true -- Fix

EHI:UpdateUnits(tbl)
EHI:DisableWaypoints(DisableWaypoints)

EHI:ShowLootCounter({
    max = 8, -- 2 main loot; 6 artifacts in crates, one in Archaeology room -> 400511
    triggers =
    {
        [102491] = { special_function = SF.IncreaseProgressMax } -- Archaeology, one more bag next to the objective
    },
    load_sync = function(self)
        if self:IsMissionElementDisabled(101506) then
            self._trackers:IncreaseLootCounterProgressMax()
        end
        self._trackers:SyncSecuredLoot()
    end
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "diamond_heist_boxes_hack" },
        { amount = 2000, name = "ed1_hack_1" },
        { amount = 2000, name = "henrys_rock_first_mission_bag_on_belt" },
        {
            random =
            {
                max = 2,
                archaelogy =
                {
                    { amount = 6000, name = "henrys_rock_drilled_archaelogy_door" },
                    { amount = 2000, name = "henrys_rock_archaelogy_chest_open" }
                },
                biolab =
                {
                    { amount = 6000, name = "henrys_rock_made_concoction" }
                },
                weapon_lab =
                {
                    { amount = 4000, name = "henrys_rock_weapon_fired", times = 2 }
                },
                computer_lab =
                {
                    { amount = 2000, name = "pc_hack" },
                    { amount = 2000, name = "henrys_rock_crane" }
                }
            }
        },
        { amount = 4000, name = "twh_disable_aa" },
        { escape = 6000 }
    },
    loot =
    {
        mus_artifact = 2000
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    diamond_heist_boxes_hack = true,
                    ed1_hack_1 = true,
                    henrys_rock_first_mission_bag_on_belt = true,
                    random =
                    {
                        biolab = true,
                        computer_lab = true
                    },
                    twh_disable_aa = true,
                    escape = true
                }
            },
            max =
            {
                objectives =
                {
                    diamond_heist_boxes_hack = true,
                    ed1_hack_1 = true,
                    henrys_rock_first_mission_bag_on_belt = true,
                    random =
                    {
                        archaelogy = true,
                        computer_lab =
                        {
                            { times = 4 },
                            true
                        }
                    },
                    twh_disable_aa = true,
                    escape = true
                },
                loot =
                {
                    mus_artifact = { times = 7 }
                }
            }
        }
    }
})