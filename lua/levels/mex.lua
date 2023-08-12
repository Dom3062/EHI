local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local function SetAssaultTrackerBlock(block)
    managers.hud:SetAssaultTrackerManualBlock(block)
end
---@type ParseTriggerTable
local triggers = {
    [102685] = { id = "Refueling", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.SetTimeIfLoudOrStealth, data = { loud = 121, stealth = 91 }, trigger_times = 1 },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker },
    [101983] = { time = 15, id = "C4Trap", icons = { Icon.C4 }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker }
}
---@type ParseAchievementTable
local achievements =
{
    mex_9 =
    {
        elements =
        {
            [100107] = { max = 4, class = TT.Achievement.Progress }
        }
    }
}
for i = 101502, 101509, 1 do
    achievements.mex_9.elements[i] = { special_function = SF.IncreaseProgress }
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 }), -- Arizona (When alarm is raised in Mexico (for the first time), run this trigger instead)
    [100697] = EHI:AddAssaultDelay({ additional_time = 30 + 30, random_time = 10, condition_function = EHI.ConditionFunctions.IsLoud }), -- Mexico (ElementDifficulty already exists)

    [100880] = { special_function = SF.CustomCode, f = SetAssaultTrackerBlock, arg = true }, -- Entered the tunnel
    [103212] = { special_function = SF.CustomCode, f = SetAssaultTrackerBlock, arg = false } -- Entered in Mexico
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102495] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102485] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102480] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    --levels/instances/unique/mex/mex_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100003, 26850)] = { icons = { Icon.Vault }, remove_on_pause = true }
}
for i = 7950, 8550, 300 do
    --levels/instances/unique/mex/mex_explosives
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceUnitID(100032, i)] = { icons = { Icon.C4 } }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_red_door_found" },
                { amount = 2000, name = "mex1_tunnel_found" },
                { amount = 2000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 8000, name = "mex1_secured_mandatory_bags" },
                { amount = 2000, name = "mex1_started_fueling" },
                { amount = 3000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_tunnel_found" },
                { amount = 3000, name = "mex1_explosives_found" },
                { amount = 3000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 6000, name = "mex1_secured_mandatory_bags" },
                { amount = 1000, name = "mex1_started_fueling" },
                { amount = 2000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000
        }
    }
})