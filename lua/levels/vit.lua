local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    -- Time before the tear gas is removed
    [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073 }
}
local triggers = {
    [102949] = { time = 17, id = "HeliDropWait", icons = { Icon.Wait } },
    [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance" } },
    [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), class = TT.Chance },
    -- Disabled in the mission script
    --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
    [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
    [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },
    [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning },

    [102335] = { time = 60, id = "Thermite", icons = { Icon.Fire } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
    [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position = Vector3(150, -1958, 133) } } -- 30s delay + 26s escape zone delay
}
if Network:is_client() then
    triggers[102073] = { time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103500] = { time = 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Escape, position = Vector3(150, -1958, 133) } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers({ mission = triggers })

local DisableWaypoints =
{
    -- levels/instances/unique/vit/vit_targeting_computer/001
    [EHI:GetInstanceElementID(100002, 10500)] = true, -- Defend
    [EHI:GetInstanceElementID(100003, 10500)] = true -- Fix
}
-- levels/instances/unique/vit/vit_wire_box
-- All 4 colors
for i = 4150, 4450, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100074, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100050, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

--[[local tbl =
{
    [EHI:GetInstanceElementID(100239, 12900)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100255, 12900) }
}
EHI:UpdateUnits(tbl)]]