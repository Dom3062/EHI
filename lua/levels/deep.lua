local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers

local triggers =
{
    [103053] = { id = "FuelChecking", icons = { Icon.Wait }, class = TT.Pausable, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
        if not enabled then
            return
        end
        if managers.groupai then
            if managers.groupai:state():whisper_mode() then
                trigger.time = 40
            else
                trigger.time = 60
            end
            self:CheckCondition(trigger)
        end
    end) },
    [103055] = { id = "FuelChecking", special_function = SF.PauseTracker },
    [103070] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; loud
    [103071] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; stealth
    [103307] = { time = 5, id = "FuelCheckingExcellent", icons = { Icon.Wait }, special_function = SF.TriggerIfEnabled },

    [102454] = { id = "FuelTransferStealth", icons = { Icon.Water }, class = TT.Pausable, condition_function = CF.IsStealth, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 102438 },
    [102439] = { id = "FuelTransferStealth", special_function = SF.PauseTracker },
    [102656] = { id = "FuelTransferLoud", icons = { Icon.Water }, class = TT.Pausable, condition_function = CF.IsLoud, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101686 },
    [101684] = { id = "FuelTransferLoud", special_function = SF.PauseTracker }
}
if EHI:IsClient() then
    triggers[102454].additional_time = 60
    triggers[102454].random_time = 20
    triggers[102454].delay_only = true
    triggers[102454].special_function = SF.UnpauseTrackerIfExists
    triggers[102454].class = TT.InaccuratePausable
    triggers[102454].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(102454, triggers[102454])
    triggers[102656].additional_time = 100
    triggers[102656].random_time = 30
    triggers[102656].delay_only = true
    triggers[102656].special_function = SF.UnpauseTrackerIfExists
    triggers[102656].class = TT.InaccuratePausable
    triggers[102656].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(102656, triggers[102656])
    triggers[101685] = { time = 80, id = "FuelTransferLoud", icons = { Icon.Water }, special_function = SF.SetTrackerAccurate }
    triggers[104930] = { time = 20, id = "FuelTransferLoud", icons = { Icon.Water }, special_function = SF.SetTrackerAccurate }
end

---@type ParseAchievementTable
local achievements =
{
    deep_9 =
    {
        elements =
        {
            [104591] = { max = 10, class = TT.AchievementProgress }, -- Stealth approach (cannot be achieved in loud)
            [101704] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [104408] = { special_function = SF.IncreaseProgress },
            [104442] = { special_function = SF.IncreaseProgress },
            [104456] = { special_function = SF.IncreaseProgress }
        }
    },
    deep_11 =
    {
        elements =
        {
            [101084] = { max = 8, class = TT.AchievementProgress, special_function = SF.AddAchievementToCounter }
        }
    },
    deep_12 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [EHI:GetInstanceElementID(100267, 9840)] = { progress = 1, max = 3, set_color_bad_when_reached = true, class = TT.AchievementProgress },
            [EHI:GetInstanceElementID(100228, 9840)] = { special_function = SF.IncreaseProgress },
            [EHI:GetInstanceElementID(100229, 9840)] = { special_function = SF.IncreaseProgress },
            [EHI:GetInstanceElementID(100283, 9840)] = { special_function = SF.SetAchievementFailed }, -- 4th pump used
            [EHI:GetInstanceElementID(100467, 9840)] = { special_function = SF.SetAchievementComplete }
        }
    }
}
for i = 104410, 104428, 1 do
    achievements.deep_9.elements[i] = { special_function = SF.IncreaseProgress }
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

---@type MissionDoorTable
local MissionDoor =
{
    -- Arrival
    [Vector3(2308.08, 3258.11, 4092.94)] = 104170,

    -- Relax
    [Vector3(3712.11, 1893.92, 4090.94)] = 104171,

    -- Locker
    [Vector3(2358.11, 867.92, 4091.94)] = 104174
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)