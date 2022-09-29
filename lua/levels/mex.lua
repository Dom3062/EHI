local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102685] = { special_function = SF.Trigger, data = { 1026851, 1026852 } },
    [1026851] = { id = "Refueling", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeIfLoudOrStealth, data = { yes = 121, no = 91 } },
    [1026852] = { special_function = SF.RemoveTriggers, data = { 102685 } },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker }
}
local achievements =
{
    [100107] = { max = 4, id = "mex_9", class = TT.AchievementProgress },
    [101983] = { time = 15, id = "C4Trap", icons = { Icon.C4 }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker },
}
for i = 101502, 101509, 1 do
    achievements[i] = { id = "mex_9", special_function = SF.IncreaseProgress }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})

local tbl =
{
    --levels/instances/unique/mex/mex_vault
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceElementID(100003, 26850)] = { icons = { Icon.Vault }, remove_on_pause = true }
}
for i = 7950, 8550, 300 do
    --levels/instances/unique/mex/mex_explosives
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    tbl[EHI:GetInstanceElementID(100032, i)] = { icons = { Icon.C4 } }
end
EHI:UpdateUnits(tbl)