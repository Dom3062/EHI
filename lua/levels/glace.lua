local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333, hint = Hints.Defend },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732, hint = Hints.Escape },
    [102324] = EHI:AddEndlessAssault(3)
}
if EHI:IsClient() then
    triggers[102368].client = { time = 120, random_time = 10 }
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    triggers[102370].client = { time = 35, random_time = 10 }
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
end

---@type ParseAchievementTable
local achievements =
{
    glace_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101732] = { status = Status.Find, class = TT.Achievement.Status },
            [105758] = { special_function = SF.SetAchievementFailed },
            [105756] = { status = Status.Ok, special_function = SF.SetAchievementStatus },
            [105759] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    },
    glace_10 =
    {
        elements =
        {
            [101732] = { max = 6, class = TT.Achievement.Progress },
            [105761] = { special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
            [105721] = { special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
        },
        sync_params = { from_start = true }
    },
    uno_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100765] = { status = Status.Destroy, class = TT.Achievement.Status },
            [103397] = { special_function = SF.SetAchievementComplete },
            [102323] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [101132] = EHI:AddAssaultDelay({ control = 59 }),
    [100487] = EHI:AddAssaultDelay({ special_function = SF.SetTimeOrCreateTracker }) -- 30s
}
if EHI:IsLootCounterVisible() then
    other[101732] = { special_function = SF.CustomCode, f = function()
        EHI:ShowLootCounterNoChecks({
            max_random = 9,
            carry_data =
            {
                at_loot = true,
                no_at_loot = true
            },
            client_from_start = true
        })
        managers.ehi_loot:SetCountOfArmoredTransports(1)
    end }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104045] = { id = "SniperHeliSaw", refresh_t = 23 + 2, class = TT.Sniper.Heli }
    local sniper_respawn_saw = { id = "SniperHeliSaw", special_function = SF.CallCustomFunction, f = "SniperRespawn" }
    local sniper_killed_saw = { id = "SniperHeliSaw", special_function = SF.CallCustomFunction, f = "SniperKilledUpdateCount" }
    for i = 2150, 3050, 150 do
        other[EHI:GetInstanceElementID(100020, i)] = sniper_respawn_saw
        other[EHI:GetInstanceElementID(100007, i)] = sniper_killed_saw
    end
    other[104046] = { id = "SniperHeliSaw", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    other[102379] = { id = "SniperHeliConstruction", refresh_t = 23 + 2, class = TT.Sniper.Heli }
    local sniper_respawn_construction = { id = "SniperHeliConstruction", special_function = SF.CallCustomFunction, f = "SniperRespawn" }
    local sniper_killed_construction = { id = "SniperHeliConstruction", special_function = SF.CallCustomFunction, f = "SniperKilledUpdateCount" }
    for i = 3200, 3650, 150 do
        other[EHI:GetInstanceElementID(100020, i)] = sniper_respawn_construction
        other[EHI:GetInstanceElementID(100007, i)] = sniper_killed_construction
    end
    other[100508] = { id = "SniperHeliConstruction", special_function = SF.CallCustomFunction, f = "NormalSniperSpawned" }
    other[100512] = sniper_killed_construction
    other[104048] = { id = "SniperHeliConstruction", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    other[104049] = { id = "SniperHeliEscape", time = 23 + 2, refresh_t = 23 + 2, class = TT.Sniper.Heli }
    local sniper_respawn_escape = { id = "SniperHeliEscape", special_function = SF.CallCustomFunction, f = "SniperRespawn" }
    local sniper_killed_escape = { id = "SniperHeliEscape", special_function = SF.CallCustomFunction, f = "SniperKilledUpdateCount" }
    for i = 3800, 4400, 150 do
        other[EHI:GetInstanceElementID(100020, i)] = sniper_respawn_escape
        other[EHI:GetInstanceElementID(100007, i)] = sniper_killed_escape
    end
end

EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "green_bridge_prisoner_found" },
        { amount = 6000, name = "green_bridge_prisoner_escorted" },
        { amount = 6000, name = "green_bridge_prisoner_defended" },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 4 }
            }
        }
    }
})