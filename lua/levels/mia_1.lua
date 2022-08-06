local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Methlab = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" } }
local element_sync_triggers = {}
local start_index = { 7800, 8200, 8600 }
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local very_hard_and_below = EHI:IsDifficultyOrBelow(EHI.Difficulties.VeryHard)
local client = Network:is_client()
for _, index in ipairs(start_index) do
    -- Cooking restart
    for i = 100120, 100122, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = EHI:DeepClone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100119, index)
    end
    -- Cooking continuation
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = EHI:DeepClone(Methlab)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
    end
end
local delay = 1.5
local AddTimeByPreplanning = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [102177] = { time = (ovk_and_up and (3 + 60 + 23 + 5) or (30 + 23 + 5)), id = "Heli", icons = Icon.HeliDropBag }, -- Time before Bile arrives
    --,[105967] = { time = 60 + 23 + 5 }
    --,[103808] = { time = 30 + 23 + 5 }

    [106013] = { time = (very_hard_and_below and 40 or 60), id = "Truck", icons = { Icon.Car }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [106017] = { id = "Truck", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100038, 1300)] = { time = 90 + delay, id = "reader", icons = { "wp_hack" }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100039, 1300)] = { time = 120 + delay, id = "reader", icons = { "wp_hack" }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100040, 1300)] = { time = 180 + delay, id = "reader", icons = { "wp_hack" }, class = TT.Pausable },
    [EHI:GetInstanceElementID(100045, 1300)] = { id = "reader", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100051, 1300)] = { id = "reader", special_function = SF.UnpauseTracker },

    -- +30s anticipation
    --[101937] = { time = 10 + 1 + 40 + 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = AddTimeByPreplanning, data = { id = 100191, yes = 75, no = 45 } },

    [104299] = { time = 5, id = "C4GasStation", icons = { Icon.C4 } },

    -- Calls with Commissar
    [101388] = { time = 8.5 + 6, id = "FirstCall", icons = { Icon.Phone } },
    [101389] = { time = 10.5 + 8, id = "SecondCall", icons = { Icon.Phone } },
    [103385] = { time = 8.5 + 5, id = "LastCall", icons = { Icon.Phone } }
}
local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, "restarter" }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
for _, index in ipairs(start_index) do
    triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethPickUp", icons = { Icon.Methlab, "pd2_generic_interact" } }
    if client then
        triggers[EHI:GetInstanceElementID(100149, index)] = random_time
        triggers[EHI:GetInstanceElementID(100150, index)] = random_time
        triggers[EHI:GetInstanceElementID(100184, index)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
    end
end
if client then
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(AddTimeByPreplanning, function(id, trigger, element, enabled)
    local t = 0
    if managers.preplanning:IsAssetBought(trigger.data.id) then
        t = trigger.data.yes
    else
        t = trigger.data.no
    end
    trigger.time = trigger.time + t
    EHI:CheckCondition(id)
end)