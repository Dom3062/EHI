local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local escape_delay = 18
local CarLootDrop = { Icon.Car, Icon.LootDrop }
local triggers = {
    [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7, id = "CarPickupLoot", icons = CarLootDrop, hint = Hints.Loot },

    [101256] = { time = 3 + 28 + 10 + 135/30 + 0.5 + 210/30, id = "CarEscape", icons = Icon.CarEscapeNoLoot, hint = Hints.Escape },
    [101088] = { id = "CarEscape", special_function = SF.RemoveTracker },

    [101218] = { time = 60 + 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [101219] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [101221] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape }
}

-- Not possible to include Car location waypoint as this is selected randomly
-- See ´LootVehicleArrived´ MissionScriptElement 100658

if EHI:IsClient() then
    triggers[101307] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 })
    triggers[101308] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 })
    triggers[101309] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 })
    triggers[100944] = EHI:ClientCopyTrigger(triggers[102873], { time = 3 + 60 + 30 + 38 + 7 })
    triggers[101008] = EHI:ClientCopyTrigger(triggers[102873], { time = 60 + 30 + 38 + 7 })
    triggers[101072] = EHI:ClientCopyTrigger(triggers[102873], { time = 30 + 38 + 7 })
    triggers[101073] = EHI:ClientCopyTrigger(triggers[102873], { time = 38 + 7 })

    triggers[103300] = EHI:ClientCopyTrigger(triggers[101218], { time = 60 + 30 + 30 + escape_delay })
    triggers[103301] = EHI:ClientCopyTrigger(triggers[101218], { time = 30 + 30 + escape_delay })
    triggers[103302] = EHI:ClientCopyTrigger(triggers[101218], { time = 30 + escape_delay })
    triggers[101223] = EHI:ClientCopyTrigger(triggers[101218], { time = escape_delay })
end

---@type ParseAchievementTable
local achievements =
{
    hot_wheels =
    {
        elements =
        {
            [101137] = { status = "finish", class = TT.Achievement.Status },
            [102487] = { special_function = SF.SetAchievementFailed },
            [102470] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101244] = EHI:AddAssaultDelay({ time = 60 + 30 }),
    [101245] = EHI:AddAssaultDelay({ time = 45 + 30 }),
    [101249] = EHI:AddAssaultDelay({ time = 50 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local max = 8
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    max = 12
end
EHI:ShowLootCounter({ max = max })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "all_bags_secured" },
        { escape = 12000 },
        { amount = 2000, name = "heli_escape" }
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    escape = true
                }
            },
            max =
            {
                objectives = true
            }
        }
    }
})