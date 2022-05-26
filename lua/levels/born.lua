local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local trigger_icon_all = { "pd2_defend" }
local triggers = {
    [101034] = { id = "MikeDefendTruck", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033 },
    [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
    [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

    [101535] = { id = "MikeDefendGarage", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532 },
    [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
    [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker }
}
if Network:is_client() then
    triggers[101034].time = 80
    triggers[101034].random_time = 10
    triggers[101034].special_function = SF.UnpauseTrackerIfExists
    triggers[101034].icons = trigger_icon_all
    triggers[101034].delay_only = true
    triggers[101034].class = "EHIInaccuratePausableTracker"
    triggers[101034].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(101034, triggers[101034])
    triggers[101535].time = 90
    triggers[101535].random_time = 30
    triggers[101535].special_function = SF.UnpauseTrackerIfExists
    triggers[101535].icons = trigger_icon_all
    triggers[101535].delay_only = true
    triggers[101535].class = "EHIInaccuratePausableTracker"
    triggers[101535].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(101535, triggers[101535])
end

EHI:ParseTriggers(triggers, nil, trigger_icon_all)
EHI:ShowLootCounter(9)