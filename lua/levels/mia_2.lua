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

    -- Bugged because of retarded use of ENABLED in ElementTimer and ElementTimerTrigger
    [101240] = { time = 540, id = "CokeTimer", icons = { { icon = Icon.Loot, color = Color.red } }, class = TT.Warning },
    [101282] = { id = "CokeTimer", special_function = SF.RemoveTracker }
}
---@type ParseAchievementTable
local achievements =
{
    pig_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101228] = { time = 210, class = TT.Achievement.Base },
            [100788] = { special_function = SF.SetAchievementComplete }
        }
    }
}
local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
if EHI:CanShowAchievement("pig_7") then
    achievements.pig_7 = { elements = {} }
    for _, index in ipairs(start_index) do
        achievements.pig_7.elements[EHI:GetInstanceElementID(100024, index)] = { time = 5, class = TT.Achievement.Base }
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
    triggers[100426] = { id = "HeliDropDrill", icons = Icon.HeliDropDrill, special_function = SF.SetRandomTime, data = { 44, 54 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, "element")
end

local other =
{
    --[100520] = EHI:AddAssaultDelay({ time = 30 }) -- Diff is applied earlier
}
if EHI:IsLootCounterVisible() then
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
            managers.ehi_tracker:DecreaseLootCounterProgressMax(count)
        end
    end
    other[100043] = EHI:AddLootCounter3(function(self, ...)
        local loot_triggers = {}
        MoneyAroundHostage = self:CountInteractionAvailable("money_small")
        for _, index in ipairs(start_index) do
            if managers.game_play_central:GetMissionEnabledUnit(EHI:GetInstanceElementID(100000, index)) then -- Bomb guy is here
                for i = 100003, 100006, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(EHI:GetInstanceElementID(i, index), "interact", HostageMoneyInteracted )
                end
                loot_triggers[EHI:GetInstanceElementID(100029, index)] = { special_function = SF.CustomCode, f = HostageExploded }
                break
            end
        end
        EHI:ShowLootCounterNoChecks({
            max = 9 + MoneyBagsInVault + MoneyAroundHostage,
            offset = true,
            triggers = loot_triggers,
            hook_triggers = true,
            client_from_start = true
        })
    end)
    -- coke, money, meth
    EHI:HookLootRemovalElement({ 101681, 101700, 101701 })
    local CokeDestroyedTrigger = { special_function = SF.CallTrackerManagerFunction, f = "DecreaseLootCounterProgressMax" }
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
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    ---@class EHImia2SnipersTracker : EHISniperLoopTracker
    ---@field super EHISniperLoopTracker
    EHImia2SnipersTracker = class(EHISniperLoopTracker)
    function EHImia2SnipersTracker:post_init(params)
        EHImia2SnipersTracker.super.post_init(self, params)
        self._sniper_respawn = true
        if params.chance_success then
            self:OnChanceSuccess()
        end
    end
    function EHImia2SnipersTracker:OnChanceSuccess()
        self:RemoveTrackerFromUpdate()
        self._sniper_respawn = false
    end
    function EHImia2SnipersTracker:DecreaseCount()
        EHImia2SnipersTracker.super.DecreaseCount(self)
        self:SniperLoopStart()
    end
    function EHImia2SnipersTracker:SniperLoopStart()
        if self._sniper_respawn then
            return
        end
        self._sniper_respawn = true
        self._time = 36 -- 1 + 35
        self:AddTrackerToUpdate()
    end
    local ChanceSuccess = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        local id = trigger.id
        if self._trackers:TrackerExists(id) then
            self._trackers:SetChance(id, element._values.chance) -- 10%/15%
            self._trackers:CallFunction(id, "OnChanceSuccess")
        else
            self._trackers:AddTracker({
                id = id,
                chance = element._values.chance,
                on_fail_refresh_t = 0.5 + 35,
                chance_success = true,
                class = "EHImia2SnipersTracker"
            })
        end
    end)
    other[100667] = { chance = 100, time = 35, on_fail_refresh_t = 0.5 + 35, id = "Snipers", class = "EHImia2SnipersTracker" }
    other[100682] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100683] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100685] = { id = "Snipers", special_function = ChanceSuccess }
    other[100686] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[100687] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100512] = { chance = 100, times = 35, on_fail_refresh_t = 0.5 + 35, id = "Snipers2", class = "EHImia2SnipersTracker" }
    other[101202] = { id = "Snipers2", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[101197] = { id = "Snipers2", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[101208] = { id = "Snipers2", special_function = ChanceSuccess }
    other[101266] = { id = "Snipers2", special_function = SF.DecreaseCounter }
    other[101267] = { id = "Snipers2", special_function = SF.IncreaseCounter }
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
        { amount = 2000, name = "hm2_hostage_rescued", optional = true },
        { amount = 2000, name = "hm2_magnetic_door_open" },
        { amount = 2000, name = "hm2_enter_apartment" },
        { amount = 2000, name = "vault_open" },
        { amount = 2000, name = "hm2_commissar_dead" },
        { escape = 2000 }
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