local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local hard_and_above = EHI:IsDifficultyOrAbove("hard")
local triggers = {
    [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
    [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
    [103456] = { time = 5, id = "nmh_11", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievementFromStart, condition = hard_and_above and show_achievement, exclude_from_sync = true },
    [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
    [102619] = { id = "EscapeElevator", special_function = SF.NMH_LowerFloor },

    [103460] = { id = "nmh_11", special_function = SF.SetAchievementComplete },

    [103443] = { id = "EscapeElevator", icons = { "pd2_door" }, class = "EHInmhElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists },
    [104072] = { id = "EscapeElevator", special_function = SF.UnpauseTracker },

    [102682] = { time = 20, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
    [102683] = { id = "AnswerPhone", special_function = SF.RemoveTracker },

    [103743] = { time = 25, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },
    [103744] = { time = 35, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },
    [103746] = { time = 15, id = "ExtraCivilianElevatorLeft", icons = { "pd2_door", "hostage" }, class = TT.Warning },

    [103745] = { time = 10, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },
    [103749] = { time = 19, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },
    [103750] = { time = 30, id = "ExtraCivilianElevatorRight", icons = { "pd2_door", "hostage" }, class = TT.Warning },

    [102992] = { chance = 1, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance },
    [103013] = { amount = 1, id = "CorrectPaperChance", special_function = SF.IncreaseChance },
    [103006] = { chance = 100, id = "CorrectPaperChance", special_function = SF.SetChanceWhenTrackerExists },
    [104752] = { id = "CorrectPaperChance", special_function = SF.RemoveTracker }
}
local outcome =
{
    [100013] = { time = 25 + 40/30 + 15, random_time = 5, id = "VialFail", icons = { "equipment_bloodvial", "restarter" } },
    [100017] = { time = 30, id = "VialSuccess", icons = { "equipment_bloodvialok" } }
}

local start_index_table =
{
    2100, 2200, 2300, 2400, 2500, 2600, 2700
}

for id, value in pairs(outcome) do
    for _, index in ipairs(start_index_table) do
        local element = EHI:GetInstanceElementID(id, index)
        triggers[element] = EHI:DeepClone(value)
        triggers[element].id = triggers[element].id .. tostring(element)
    end
end
EHI:AddOnAlarmCallback(function()
    local remove = {
        "AnswerPhone",
        "Patrol",
        "ExtraCivilianElevatorLeft",
        "ExtraCivilianElevatorRight",
        "CorrectPaperChance"
    }
    for _, tracker in pairs(remove) do
        managers.ehi:RemoveTracker(tracker)
    end
end)

EHI:ParseTriggers(triggers)