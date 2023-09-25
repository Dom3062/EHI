local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    -- Time before the tear gas is removed
    [102074] = { time = 3 + 2, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist, hook_element = 102073 }
}
local triggers = {
    [102949] = { time = 17, id = "HeliDropWait", icons = { Icon.Wait } },

    [102335] = { time = 60, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = EHI:GetInstanceElementID(100029, 16950) } }, -- units/pd2_dlc_vit/props/security_shutter/vit_prop_branch_security_shutter

    [100246] = { time = 31, id = "TearGasOffice", icons = { Icon.Teargas }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "TearGasOfficeChance" } },
    [101580] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, condition = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), class = TT.Chance },
    -- Disabled in the mission script
    --[101394] = { chance = 20, id = "TearGasOfficeChance", icons = { Icon.Teargas }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists }, -- It will not run on Hard and below
    [101377] = { amount = 20, id = "TearGasOfficeChance", special_function = SF.IncreaseChance },
    [101393] = { id = "TearGasOfficeChance", special_function = SF.RemoveTracker },

    [102544] = { time = 8.3, id = "HumveeWestWingCrash", icons = { Icon.Car, Icon.Fire }, class = TT.Warning },

    [101504] = { time = 12 + 11, id = "AirlockOpenInside", icons = { Icon.Door } },

    [102095] = { special_function = SF.Trigger, data = { 1020951, 1020952 } },
    [1020951] = { time = 26, id = "AirlockOpenOutside", icons = { Icon.Door }, condition_function = CF.IsStealth },
    [1020952] = { time = 26, id = "AirlockOpenOutsideEndlessAssault", icons = Icon.EndlessAssault, class = TT.Warning, condition_function = CF.IsLoud },

    [102104] = { time = 30 + 26, id = "LockeHeliEscape", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 101914 } } -- 30s delay + 26s escape zone delay
}
if EHI:IsClient() then
    triggers[102073] = { additional_time = 30 + 3 + 2, random_time = 10, id = "TearGasPEOC", icons = { Icon.Teargas }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103500] = EHI:ClientCopyTrigger(triggers[102104], { time = 26 })
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, "element")
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100314] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        if EHI:IsHost() and element:counter_value() ~= 0 then
            return
        end
        self._trackers:AddTracker({
            id = "Snipers",
            chance = 10,
            time = 20 + 10 + 25,
            on_fail_refresh_t = 25,
            on_success_refresh_t = 20 + 10 + 25,
            class = TT.Sniper.Loop
        })
    end) }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101324] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    -- Enemies killed via "ElementAIRemove" DOES NOT TRIGGER ElementEnemyDummyTrigger if "force_ragdoll" and "true_death" are set to "false" and "use_instigator" is set to "true"
    other[102596] = { id = "Snipers", special_function = SF.RemoveTracker }
end

EHI:ParseTriggers({ mission = triggers, other = other })

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
-- levels/instances/unique/vit/vit_peoc_workstation/001-006
for i = 30000, 31500, 300 do
    DisableWaypoints[EHI:GetInstanceElementID(100059, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

local tbl = {}
for i = 30000, 31500, 300 do
    tbl[EHI:GetInstanceUnitID(100045, i)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100058, i) }
end
EHI:UpdateUnits(tbl)

--[[local tbl =
{
    [EHI:GetInstanceUnitID(100239, 12900)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100255, 12900) }
}
for i = 14250, 15150, 300 do
    tbl[EHI:GetInstanceUnitID(100239, i)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100255, i) }
end
EHI:UpdateUnits(tbl)]]

--[[local tbl =
{
    [EHI:GetInstanceUnitID(100239, 12900)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100239_12900_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(unit_data.remove_vanilla_waypoint)
            end
        end)
        unit:timer_gui():RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
    end, remove_vanilla_waypoint = EHI:GetInstanceElementID(100255, 12900) }
}
for i = 30000, 31500, 300 do
    tbl[EHI:GetInstanceUnitID(100045, i)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100058, i) }
end
EHI:UpdateUnits(tbl)]]
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "twh_entered" },
                { amount = 2000, name = "twh_wireboxes_cut" },
                { amount = 2000, name = "twh_enter_west_wing" },
                { amount = 2000, name = "twh_enter_oval_office" },
                { amount = 8000, name = "twh_safe_open" },
                { amount = 4000, name = "twh_access_peoc" },
                { amount = 8000, name = "twh_mainframe_hacked" },
                { amount = 2000, name = "twh_pardons_stolen" },
                { amount = 2000, name = "twh_left_peoc" },
                { amount = 2000, name = "heli_arrival" }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "twh_entered" },
                { amount = 4000, name = "twh_wireboxes_hacked" },
                { amount = 2000, name = "twh_enter_west_wing" },
                { amount = 2000, name = "twh_found_thermite" },
                { amount = 1000, name = "thermite_done" },
                { amount = 2000, name = "twh_enter_oval_office" },
                { amount = 8000, name = "twh_safe_open" },
                { amount = 4000, name = "twh_access_peoc" },
                { amount = 8000, name = "twh_mainframe_hacked" },
                { amount = 2000, name = "twh_pardons_stolen" },
                { amount = 2000, name = "twh_left_peoc" },
                { amount = 4000, name = "twh_disable_aa" },
                { amount = 2000, name = "heli_arrival" }
            }
        }
    }
})