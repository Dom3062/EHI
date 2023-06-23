local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101961] = { time = 120 },
    [101962] = { time = 90 },

    [102065] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102675 }},
    [102080] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102674 }}
}

if EHI:IsClient() then
    triggers[101965] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101966] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist }
end

---@type ParseAchievementTable
local achievements =
{
    bullet_dodger =
    {
        elements =
        {
            [101959] = { status = "finish", class = TT.AchievementStatus },
            [101872] = { special_function = SF.SetAchievementFailed },
            [101874] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101959] = EHI:AddAssaultDelay({ time = 10 + 30 })
}
if EHI:IsLootCounterVisible() then
    local CreateCounter = true
    other[102091] = EHI:AddLootCounter3(function(self, ...)
        if CreateCounter then
            EHI:ShowLootCounterNoChecks()
            CreateCounter = false
        end
        self._trackers:IncreaseLootCounterProgressMax()
    end)
end

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.HeliEscape)

tweak_data.ehi.functions.uno_1(true)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 3000
    },
    no_total_xp = true
})