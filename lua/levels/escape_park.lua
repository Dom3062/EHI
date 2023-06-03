local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102449] = { time = 240 },
    [102450] = { time = 180 },
    [102451] = { time = 300 },

    [101285] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100786 } },
    [101286] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100783 } },
    [101287] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100784 } },
    [101284] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100785 } }
}

if EHI:IsClient() then
    triggers[100606] = { time = 240, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100593] = { time = 180, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100607] = { time = 120, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100601] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100602] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist }
end

---@type ParseAchievementTable
local achievements =
{
    king_of_the_hill =
    {
        elements =
        {
            [102444] = { status = "defend", class = TT.AchievementStatus },
            [101297] = { special_function = SF.SetAchievementFailed },
            [101343] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [102444] = EHI:AddAssaultDelay({ time = 25 + 30 })
}
if EHI:GetOption("show_loot_counter") then
    local CreateCounter = true
    local UpdateLootCounter = EHI:GetFreeCustomSpecialFunctionID()
    other[102293] = { special_function = UpdateLootCounter }
    EHI:RegisterCustomSpecialFunction(UpdateLootCounter, function(self, ...)
        if CreateCounter then
            EHI:ShowLootCounterNoCheck({})
            CreateCounter = false
        end
        self._trackers:IncreaseTrackerProgressMax("LootCounter")
    end)
end

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.CarEscape)

tweak_data.ehi.functions.uno_1(true)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    no_total_xp = true
})