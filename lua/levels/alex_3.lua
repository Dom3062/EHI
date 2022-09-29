local EHI = EHI
local SF = EHI.SpecialFunctions
local delay = 2
local triggers = {
    [1] = { special_function = SF.RemoveTriggers, data = { 100668, 100669, 100670 } },
    [100668] = { time = 240 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [100669] = { time = 180 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [100670] = { time = 120 + delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } }
}

EHI:ParseTriggers({ mission = triggers }, "HeliLootDrop", EHI.Icons.HeliLootDrop)
EHI:ShowLootCounter({
    max = 14,
    offset = true
})