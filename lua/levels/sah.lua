local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [100643] = { time = 30, id = "CrowdAlert", icons = { Icon.Alarm }, class = TT.Warning, hint = Hints.Alarm },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

    -- Heli Escape is in CoreWorldInstanceManager
}

---@type ParseAchievementTable
local achievements =
{
    sah_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100107] = { time = 300, class = TT.Achievement.Base },
            [101878] = { special_function = SF.SetAchievementComplete },
            [101400] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 1 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local DisableWaypoints = {}
-- Hackboxes
-- 1-10
for i = 3900, 4800, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- 11-17
for i = 16950, 17550, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- Office
for i = 18200, 19400, 600 do
    -- Drill
    -- No defend icon, drill icon is disabled after drill unit has been placed
    DisableWaypoints[EHI:GetInstanceElementID(100320, i)] = true -- Fix
    -- Computer
    -- No defend icon, computer icon is disabled after computer unit has been interacted with
    DisableWaypoints[EHI:GetInstanceElementID(100087, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    -- Unused Grenade case
    [400178] = { f = "IgnoreDeployable" }
}
for i = 4900, 5100, 100 do
    --levels/instances/unique/sah/sah_vault_door
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    tbl[EHI:GetInstanceUnitID(100001, i)] = { icons = { Icon.Vault } }
end
for i = 18200, 19400, 600 do
    --levels/instances/unique/sah/sah_office
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    tbl[EHI:GetInstanceUnitID(100064, i)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100068, i) }
    --units/pd2_dlc_sah/props/sah_interactable_hack_computer/sah_interactable_hack_computer
    tbl[EHI:GetInstanceUnitID(100168, i)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100084, i) }
end
EHI:UpdateUnits(tbl)
local loot =
{
    black_tablet = 1000,
    mus_artifact = 1000
}
local xp_override =
{
    params =
    {
        min =
        {
            objectives = true,
            loot =
            {
                black_tablet = { times = 1 }
            }
        },
        no_max = true
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "vault_found" },
                { amount = 6000, name = "sah_entered_vault_code" },
                { amount = 4000, name = "sah_retrieved_tablet" },
                { escape = 1000 }
            },
            loot = loot,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 6000, name = "vault_found" },
                { amount = 10000, name = "sah_entered_vault_code" },
                { amount = 6000, name = "sah_retrieved_tablet" },
                { escape = 4000 }
            },
            loot = loot,
            total_xp_override = xp_override
        }
    }
})