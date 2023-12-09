local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints

if EHI:GetOption("show_mission_trackers") then
    for _, unit_id in ipairs({ 100067, 100093, 100094 }) do
        for _, index in ipairs({ 4500, 5400, 5800, 6000, 6200, 6600 }) do
            local fixed_unit_id = EHI:GetInstanceUnitID(unit_id, index)
            managers.mission:add_runned_unit_sequence_trigger(fixed_unit_id, "interact", function(unit)
                managers.ehi_tracker:AddTracker({
                    id = tostring(fixed_unit_id),
                    time = 30,
                    icons = { Icon.Glasscutter },
                    hint = Hints.Cutter
                })
            end)
        end
    end
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100241] = { time = 19, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape },

    [EHI:GetInstanceElementID(100166, 4900)] = { time = 5, id = "WaitTime", icons = { Icon.Wait }, hint = Hints.Wait },

    [EHI:GetInstanceElementID(100128, 4900)] = { time = 10, id = "PressSequence", icons = { Icon.Interact }, class = TT.Warning },
    [EHI:GetInstanceElementID(100069, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100090, 4900)] = { id = "PressSequence", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100116, 4900)] = { max = 3, id = "C4Progress", icons = { Icon.C4 }, class = TT.Progress },
    [EHI:GetInstanceElementID(100177, 4900)] = { id = "C4Progress", special_function = SF.IncreaseProgress }
}

---@type ParseAchievementTable
local achievements =
{
    live_2 =
    {
        elements =
        {
            [100693] = { class = TT.Achievement.Status },
            [102704] = { special_function = SF.SetAchievementFailed },
            [100246] = { special_function = SF.SetAchievementComplete }
        }
    },
    live_3 =
    {
        elements =
        {
            [100304] = { time = 5, class = TT.Achievement.Unlock }
        }
    },
    live_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102785] = { class = TT.Achievement.Status },
            [100249] = { special_function = SF.SetAchievementComplete },
            [102694] = { special_function = SF.SetAchievementFailed },
        }
    },
    live_5 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100116, 4900)] = { class = TT.Achievement.Status },
            [102702] = { special_function = SF.SetAchievementFailed },
            [100265] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100050, 4700)] = true -- PC
}
EHI:DisableWaypoints(DisableWaypoints)

local max = 6
local required_bags = 3
local closets = 2
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    max = 12
    required_bags = 6
    closets = 3
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    max = 18
    if EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
        required_bags = 9
    else
        required_bags = 12
    end
    closets = 5
end
EHI:ShowLootCounter({ max = max })
local xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                alesso_find_c4 = { min_max = closets },
                loot_secured = { min = required_bags, max = max }
            }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "alesso_find_c4" },
                { amount = 2000, name = "c4_set_up" },
                { amount = 3000, times = 3, name = "alesso_pyro_set" },
                { amount = 1200, name = "loot_secured" }
            },
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 10000, name = "pc_hack" },
                { amount = 1000, name = "alesso_find_c4" },
                { amount = 2000, name = "c4_set_up" },
                { amount = 3000, times = 3, name = "alesso_pyro_set" },
                { amount = 1500, name = "loot_secured" }
            },
            total_xp_override = xp_override
        }
    }
})