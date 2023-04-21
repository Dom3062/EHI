local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    [100428] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 }, -- 20s
    [100430] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 } -- 30s
}
local triggers = {
    [100225] = { time = 5 + 5 + 22, id = Icon.Heli, icons = Icon.HeliEscape },
    -- 5 = Base Delay
    -- 5 = Delay when executed
    -- 22 = Heli door anim delay
    -- Total: 32 s
    [100224] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100926 } },
    [101858] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 101854 } },

    -- Bugged because of retarted use of ENABLED in ElementTimer and ElementTimerTrigger
    [101240] = { time = 540, id = "CokeTimer", icons = { { icon = Icon.Loot, color = Color.red } }, class = TT.Warning },
    [101282] = { id = "CokeTimer", special_function = SF.RemoveTracker }
}
local achievements =
{
    pig_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101228] = { time = 210, class = TT.Achievement },
            [100788] = { special_function = SF.SetAchievementComplete }
        }
    }
}
local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
if EHI:CanShowAchievement("pig_7") then
    achievements.pig_7 = { elements = {} }
    for _, index in ipairs(start_index) do
        achievements.pig_7.elements[EHI:GetInstanceElementID(100024, index)] = { time = 5, class = TT.Achievement }
        achievements.pig_7.elements[EHI:GetInstanceElementID(100016, index)] = { special_function = SF.SetAchievementFailed } -- Hostage blew out
        achievements.pig_7.elements[EHI:GetInstanceElementID(100027, index)] = { special_function = SF.SetAchievementComplete } -- Hostage saved
    end
else
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100024, index)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100016, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage blew out
        triggers[EHI:GetInstanceElementID(100027, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage saved
    end
end

if EHI:IsClient() then
    triggers[100426] = { id = "HeliDropDrill", icons = Icon.HeliDropDrill, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 44, 54 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local LootCounter = EHI:GetOption("show_loot_counter")
local MoneyBagsInVault = 1
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    MoneyBagsInVault = 2
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    MoneyBagsInVault = 3
end
local MoneyAroundHostage = 0
local HostageMoneyTaken = 0
local _HostageExploded = false
local function HostageMoneyInteracted(...)
    if _HostageExploded then
        return
    end
    HostageMoneyTaken = HostageMoneyTaken + 1
end
local function HostageExploded()
    _HostageExploded = true
    local count = MoneyAroundHostage - HostageMoneyTaken
    if count ~= 0 then
        managers.ehi:DecreaseTrackerProgressMax("LootCounter", count)
    end
end
local other =
{
    [100043] = EHI:AddLootCounter(function()
        local loot_triggers = {}
        MoneyAroundHostage = managers.ehi:CountInteractionAvailable("money_small")
        for _, index in ipairs(start_index) do
            if managers.game_play_central:GetMissionEnabledUnit(EHI:GetInstanceElementID(100000, index)) then -- Bomb guy is here
                for i = 100003, 100006, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(EHI:GetInstanceElementID(i, index), "interact", HostageMoneyInteracted )
                end
                loot_triggers[EHI:GetInstanceElementID(100029, index)] = { special_function = SF.CustomCode, f = HostageExploded }
                break
            end
        end
        EHI:ShowLootCounterNoCheck({
            max = 9,
            additional_loot = MoneyBagsInVault + MoneyAroundHostage,
            offset = true,
            triggers = loot_triggers,
            hook_triggers = true,
            client_from_start = true
        })
    end, LootCounter),

    [100520] = EHI:AddAssaultDelay({ time = 30 }) -- Diff is applied earlier
}
if LootCounter then
    -- coke, money, meth
    EHI:HookLootRemovalElement({ 101681, 101700, 101701 })
    local function CokeDestroyed()
        managers.ehi:DecreaseTrackerProgressMax("LootCounter")
    end
    local CokeDestroyedTrigger = { special_function = SF.CustomCode, f = CokeDestroyed }
    other[101264] = CokeDestroyedTrigger
    other[101271] = CokeDestroyedTrigger
    other[101272] = CokeDestroyedTrigger
    other[101274] = CokeDestroyedTrigger
    other[101276] = CokeDestroyedTrigger
    other[101278] = CokeDestroyedTrigger
    other[101279] = CokeDestroyedTrigger
    other[101280] = CokeDestroyedTrigger
    other[101281] = CokeDestroyedTrigger
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "hm2_enter_building" },
        { amount = 2000, name = "hm2_yellow_gate_open" },
        { amount = 2000, name = "hm2_magnetic_door_open" },
        { amount = 2000, name = "hm2_enter_apartment" },
        { amount = 2000, name = "vault_open" },
        { amount = 2000, name = "hm2_commissar_dead" },
        { escape = 2000 },
        { amount = 2000, name = "hm2_hostage_rescued", optional = true }
    },
    loot_all = { amount = 1000, times = 10 },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true -- Optional objective not counted
            },
            max =
            {
                objectives = true,
                loot_all = { times = 10 }
            }
        }
    }
})