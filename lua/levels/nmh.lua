EHIElevatorTimerTracker = class(EHIPausableTracker)
EHIElevatorTimerTracker._forced_icons = { "pd2_door" }
function EHIElevatorTimerTracker:init(panel, params)
    self._floors = params.floors or 26
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

EHIElevatorTimerWaypoint = class(EHIPausableWaypoint)
EHIElevatorTimerWaypoint.GetElevatorTime = EHIElevatorTimerTracker.GetElevatorTime
EHIElevatorTimerWaypoint.SetFloors = EHIElevatorTimerTracker.SetFloors
EHIElevatorTimerWaypoint.LowerFloor = EHIElevatorTimerTracker.LowerFloor
function EHIElevatorTimerWaypoint:init(panel, params, parent_class)
    self._floors = params.floors or 26
    params.time = self:GetElevatorTime()
    EHIElevatorTimerWaypoint.super.init(self, panel, params, parent_class)
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102460] = { time = 7, id = "Countdown", icons = { Icon.Alarm }, class = TT.Warning },
    [102606] = { id = "Countdown", special_function = SF.RemoveTracker },
    [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning },
    [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },

    [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
    [102619] = { id = "EscapeElevator", special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
        if enabled then
            self:Call(trigger.id, "LowerFloor")
        end
    end) },

    [103443] = { id = "EscapeElevator", class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists, waypoint = { icon = EHIElevatorTimerTracker._forced_icons[1], position_by_unit = 102296, class = "EHIElevatorTimerWaypoint" } },
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
    [104752] = { id = "CorrectPaperChance", special_function = SF.RemoveTracker },

    [104721] = { special_function = SF.CustomCode, f = function()
        if managers.hud.SetAssaultTrackerManualBlock then
            managers.hud:SetAssaultTrackerManualBlock(true)
        end
    end}
}
local outcome =
{
    [100013] = { additional_time = 15 + 15 + 10 + 40/30, random_time = 5, id = "VialFail", icons = { "equipment_bloodvial", Icon.Loop } },
    [100017] = { time = 30, id = "VialSuccess", icons = { "equipment_bloodvialok" } },
    [100014] = { time = 15 + 10 + 40/30, id = "VialFail", icons = { "equipment_bloodvial", Icon.Loop }, special_function = SF.SetTrackerAccurate }
}

for id, value in pairs(outcome) do
    for i = 2100, 2700, 100 do
        local element = EHI:GetInstanceElementID(id, i)
        triggers[element] = deep_clone(value)
        triggers[element].id = triggers[element].id .. tostring(i)
        triggers[element].waypoint = { position_by_unit = EHI:GetInstanceUnitID(100008, i) }
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
    for _, tracker in ipairs(remove) do
        managers.ehi_tracker:RemoveTracker(tracker)
    end
end)

---@type ParseAchievementTable
local achievements =
{
    nmh_11 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            -- Looks like a bug, OVK thinks the timer resets but the achievement is already disabled... -> you have 1 shot before mission restart
            -- Reported in:
            -- https://steamcommunity.com/app/218620/discussions/14/3048357185564293898/
            [103456] = { time = 5, class = TT.Achievement, special_function = SF.ShowAchievementFromStart, trigger_times = 1 },
            [103460] = { special_function = SF.SetAchievementComplete }
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddLoadSyncFunction(function(self)
    local elevator_counter = managers.worlddefinition:get_unit(102296)
    if elevator_counter then
        local o = elevator_counter:digital_gui()
        if o and o._timer and o._timer ~= 30 then
            self:Trigger(103443)
            self:Call("EscapeElevator", "SetFloors", o._timer - 4)
            if self:InteractionExists("circuit_breaker") or self:InteractionExists("press_call_elevator") then
                self:Pause("EscapeElevator")
            end
        end
    end
end)

--units/pd2_dlc_nmh/props/nmh_interactable_teddy_saw/nmh_interactable_teddy_saw
EHI:UpdateUnits({ [101387] = { remove_vanilla_waypoint = 104494 } })
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 2000, name = "nmh_cameras_taken_out" },
                { amount = 7000, name = "nmh_keep_hostages_down" },
                { amount = 2000, name = "nmh_found_patients_file" },
                { amount = 1000, name = "nmh_set_up_fake_sentries" },
                { amount = 3000, name = "nmh_found_correct_patient" },
                { amount = 3000, name = "nmh_valid_sample" },
                { amount = 8000, name = "nmh_elevator_arrived" },
                { amount = 2000, name = "nmh_exit_elevator" }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 2000, name = "nmh_cameras_taken_out", optional = true },
                { amount = 7000, name = "nmh_icu_open" },
                { amount = 3000, name = "nmh_saw_patient_room" },
                { amount = 3000, name = "nmh_valid_sample" },
                { amount = 8000, name = "nmh_elevator_arrived" },
                { amount = 2000, name = "nmh_exit_elevator" }
            },
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        min =
                        {
                            nmh_cameras_taken_out = { times = 0 }
                        },
                        max =
                        {
                            nmh_saw_patient_room = { times = 3 }
                        }
                    }
                }
            }
        }
    }
})