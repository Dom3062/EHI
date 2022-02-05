local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local very_hard_and_up = EHI:IsDifficultyOrAbove("very_hard")
local element_sync_triggers =
{
    -- Time before the tear gas is removed
    [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073 }
}
local triggers = {
    [102949] = { time = 17, id = "HeliDropWait", icons = { "faster" } },
    [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance", trigger = 100808 } },
    [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = very_hard_and_up, class = TT.Chance },
    -- Disabled in the mission script
    --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
    [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
    [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },
    [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning },

    [102335] = { time = 60, id = "Thermite", icons = { "pd2_fire" } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter
    [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot } -- 30s delay + 26s escape zone delay
}
if Network:is_client() then
    triggers[102073] = { time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)