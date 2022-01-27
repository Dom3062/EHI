local unit_ids =
{
    100098, 102897, 102899, 102900
}

for _, unit_id in pairs(unit_ids) do
    managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(unit)
        managers.ehi:AddTracker({
            id = tostring(unit_id),
            time = 10,
            icons = { "pd2_fire" }
        })
    end)
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local trigger = { special_function = SF.Trigger, data = { 1, 2 } }
local triggers = {
    [1] = { time = 300, id = "Blackhawk", icons = { Icon.Heli, "pd2_goto" } },
    [2] = { special_function = SF.RemoveTriggers, data = { 101131, 100900 } },
    [101131] = trigger,
    [100900] = trigger,

    [100955] = { time = 10, id = "KeycardLeft", icons = { Icon.Keycard }, class = TT.Warning, special_function = SF.KOSUGI_DisableTriggerAndExecute, data = { id = 100957 } },
    [100957] = { time = 10, id = "KeycardRight", icons = { Icon.Keycard  }, class = TT.Warning, special_function = SF.KOSUGI_DisableTriggerAndExecute, data = { id = 100955 } },
    [100967] = { special_function = SF.RemoveTrackers, data = { "KeycardLeft", "KeycardRight" } }
}

EHI:ParseTriggers(triggers)