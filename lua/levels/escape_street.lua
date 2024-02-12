local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [101961] = { time = 120, hint = Hints.LootEscape },
    [101962] = { time = 90, hint = Hints.LootEscape },

    [102065] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102675 }},
    [102080] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102674 }}
}

if EHI:IsClient() then
    triggers[101965] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[101966] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
end

---@type ParseAchievementTable
local achievements =
{
    bullet_dodger =
    {
        elements =
        {
            [101959] = { status = "finish", class = TT.Achievement.Status },
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
    other[102091] = EHI:AddLootCounter3(function(self, ...)
        if self._cache.CreateCounter then
            EHI:ShowLootCounterNoChecks()
            self._cache.CreateCounter = false
        end
        self._trackers:IncreaseLootCounterProgressMax()
    end)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102528] = { id = "Snipers", count_on_refresh = 2, snipers_spawned = true, class = TT.Sniper.TimedCount }
    other[102431] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[102428] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SetRespawnTime", arg = { 15 + 20 }}
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