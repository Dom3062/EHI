if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.CoreMissionScriptElement_ElementDelay then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.CoreMissionScriptElement_ElementDelay = true
end

core:module("CoreMissionScriptElement")

local level_id = Global.game_settings.level_id
local triggers = {}
local trigger_id_all = "Trigger"
local trigger_icon_all = nil
local SF = EHI.SpecialFunctions
local Icon = EHI:GetIcons()
local TT = -- Tracker Type
{
    MallcrasherMoney = "EHIMoneyCounterTracker",
    Warning = "EHIWarningTracker",
    Pausable = "EHIPausableTracker"
}
local _cache = {}
if level_id == "vit" then -- The White House
    triggers = {
        -- Time before the tear gas is removed
        [102074] = { time = 5, id = "TearGasPEOC", icons = { Icon.Teargas } }
    }
elseif level_id == "mia_2" then -- Hotline Miami Day 2
    triggers = {
        [100428] = { time = 24, id = "PickUpThermalDrill", icons = { Icon.Interact, "pd2_drill" } },
        [100430] = { time = 24, id = "PickUpThermalDrill", icons = { Icon.Interact, "pd2_drill" } }
    }
elseif level_id == "mia_1" then -- Hotline Miami Day 1
    triggers = {
        -- Cooking restart
        [EHI:GetInstanceElementID(100120, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100120, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100120, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100121, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100121, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100121, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100122, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100122, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100122, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },

        -- Cooking continuation
        [EHI:GetInstanceElementID(100169, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100169, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100169, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100170, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100170, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100170, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100171, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100171, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100171, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100172, 7800)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100172, 8200)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } },
        [EHI:GetInstanceElementID(100172, 8600)] = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } }
    }
elseif level_id == "dah" then -- Diamond Heist
    triggers = { -- 100438, ElementInstanceOutputEvent, check if enabled
        [103569] = { time = 25, id = "CFOFall", icons = { "hostage", "pd2_goto" } }
    }
elseif level_id == "chas" then -- Dragon Heist
    triggers = {
        [100209] = { time = 5, id = "LoudEscape", icons = { Icon.Car, Icon.Escape, Icon.LootDrop }, client_on_executed = SF.RemoveTriggerWhenExecuted },
        [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = { Icon.Heli, "pd2_drill", "pd2_goto" } }
    }
elseif level_id == "pal" then -- Counterfeit
    triggers = {
        [102887] = { time = 1800/30, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop } }
    }
elseif level_id == "mex_cooking" then -- Border Crystals
    triggers = {
        [103575] = { id = "CookingStartDelay", icons = { "pd2_methlab", "faster" } },
        [103576] = { id = "CookingStartDelay", icons = { "pd2_methlab", "faster" } },

        [EHI:GetInstanceElementID(100078, 55850)] = { id = "NextIngredient", icons = { "pd2_methlab", "restarter" } },
        [EHI:GetInstanceElementID(100078, 56850)] = { id = "NextIngredient", icons = { "pd2_methlab", "restarter" } },
        [EHI:GetInstanceElementID(100157, 55850)] = { id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" } },
        [EHI:GetInstanceElementID(100157, 56850)] = { id = "MethReady", icons = { "pd2_methlab", "pd2_generic_interact" } }
    }
elseif level_id == "crojob2" then -- The Bomb: Dockyard
    local interact = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } }
    local start_index = { 1100, 1400, 1700, 2000, 2300, 2600, 2900, 3500, 3800, 4100, 4400, 4700 }
    for _, index in pairs(start_index) do
        triggers[EHI:GetInstanceElementID(100169, index)] = interact
        triggers[EHI:GetInstanceElementID(100170, index)] = interact
        triggers[EHI:GetInstanceElementID(100171, index)] = interact
        triggers[EHI:GetInstanceElementID(100172, index)] = interact
    end
elseif level_id == "rvd2" then -- Reservoir Dogs Heist Day 1
    triggers = {
        [101374] = { id = "VaultTeargas", icons = { Icon.Teargas } }
    }
elseif level_id == "bex" then -- San Martín Bank
    triggers = {
        [102290] = { id = "VaultGas", icons = { Icon.Teargas } }
    }
else
    return
end

if Network:is_server() then
    EHI:Log("CoreMissionScriptElement_ElementDelay: AddTriggers")
    EHI:AddTriggers(triggers)
else
    EHI:SetSyncTriggers(triggers)
end

local _f_calc_element_delay = MissionScriptElement._calc_element_delay
function MissionScriptElement:_calc_element_delay(params)
    local delay = _f_calc_element_delay(self, params)
    if triggers[params.id] then
        EHI:AddTrackerAndSync(params.id, delay)
    end
    return delay
end