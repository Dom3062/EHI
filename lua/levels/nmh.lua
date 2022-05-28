EHIElevatorTimerTracker = EHIElevatorTimerTracker or class(EHITracker)
function EHIElevatorTimerTracker:init(panel, params)
    self._floors = params.floors or 26
    params.icons = { "pd2_door" }
    params.time = self:GetElevatorTime()
    EHIElevatorTimerTracker.super.init(self, panel, params)
end

function EHIElevatorTimerTracker:GetElevatorTime()
    return self._floors * 8
end

function EHIElevatorTimerTracker:SetFloors(floors)
    self._floors = floors
    local new_time = self:GetElevatorTime()
    if math.abs(self._time - new_time) >= 1 then -- If the difference in the new time is higher than 1s, use the new time to stay accurate
        self._time = new_time
    end
end

function EHIElevatorTimerTracker:LowerFloor()
    self:SetFloors(self._floors - 1)
end

function EHIElevatorTimerTracker:SetPause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
    self:SetTextColor(pause and Color.red or Color.white)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local hard_and_above = EHI:IsDifficultyOrAbove("hard")
local LowerFloor = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [102460] = { time = 7, id = "Countdown", icons = { "pd2_generic_look" }, class = TT.Warning },
    [102606] = { id = "Countdown", special_function = SF.RemoveTracker },
    [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
    [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
    -- Looks like a bug, OVK thinks the timer resets but the achievement is already disabled... -> you have 1 shot before restart
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3048357185564293898/
    [103456] = { time = 5, id = "nmh_11", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievementFromStart, condition = hard_and_above and show_achievement, exclude_from_sync = true },
    [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
    [102619] = { id = "EscapeElevator", special_function = LowerFloor },

    [103460] = { id = "nmh_11", special_function = SF.SetAchievementComplete },

    [103443] = { id = "EscapeElevator", class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists },
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

for id, value in pairs(outcome) do
    for i = 2100, 2700, 100 do
        local element = EHI:GetInstanceElementID(id, i)
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
EHI:RegisterCustomSpecialFunction(LowerFloor, function(id, trigger, element, enabled)
    if enabled then
        managers.ehi:CallFunction(trigger.id, "LowerFloor")
    end
end)

--units/pd2_dlc_nmh/props/nmh_interactable_teddy_saw/nmh_interactable_teddy_saw
local tbl = { [101387] = { remove_vanilla_waypoint = true, waypoint_id = 104494 } }
EHI:UpdateUnits(tbl)