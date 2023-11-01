local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100322] = { time = 120, id = "Fuel", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { icon = Icon.Defend, position_by_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100038, 8075) }, hint = EHI.Hints.FuelTransfer },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker }
}

if EHI:IsClient() then
    triggers[100047] = EHI:ClientCopyTrigger(triggers[100322], { time = 60 })
    triggers[100049] = EHI:ClientCopyTrigger(triggers[100322], { time = 30 })
end

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

---@type ParseAchievementTable
local achievements =
{
    wwh_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100012] = { status = "defend", class = TT.Achievement.Status },
            [101250] = { special_function = SF.SetAchievementFailed },
            [100082] = { special_function = SF.SetAchievementComplete },
        }
    },
    wwh_10 =
    {
        elements =
        {
            [100946] = { max = 4, class = TT.Achievement.Progress },
            [101226] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other =
{
    [100946] = EHI:AddAssaultDelay({ time = 10 + 5 + 3 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 8 })
EHI._cache.diff = 1
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "alaskan_deal_crew_saved" },
        { amount = 5000, name = "alaskan_deal_captain_reached_boat" },
        { amount = 6000, name = "alaskan_deal_boat_fueled" },
        { escape = 1000 }
    },
    loot =
    {
        money = 400,
        weapon = 600
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    money = { max = 4 },
                    weapon = { max = 4 }
                }
            }
        }
    }
})