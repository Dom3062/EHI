local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_anim = 35
local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local HeliWaterFill = { Icon.Heli, Icon.Water }
if EHI:GetOption("show_one_icon") then
    HeliWaterFill = { { icon = Icon.Heli, color = tweak_data.ehi.colors.WaterColor } }
end
local triggers = {
    [101499] = { time = 155 + 25, id = "HeliEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 101525 } },
    [101253] = heli_65,
    [101254] = heli_20,
    [101255] = heli_65,
    [101256] = heli_20,
    [101259] = heli_65,
    [101278] = heli_20,
    [101279] = heli_65,
    [101280] = heli_20,

    [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 100058 } },

    [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

    [102825] = { id = "WaterFill", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
    [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
    [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

    [1] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
    [2] = { id = "HeliWaterReset", icons = { Icon.Heli, Icon.Water, Icon.Loop }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

    -- Right
    [100283] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100647 } },
    [100284] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100648 } },
    [100288] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100653 } },

    -- Left
    [100285] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100651 } },
    [100286] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100652 } },
    [100560] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100220 } },

    -- Top
    [100282] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100646 } },
    [100287] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100653 } },
    [100558] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100655 } },
    [100559] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100656 } }
}
for _, index in ipairs({ 100, 150, 250, 300 }) do
    triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = HeliWaterFill, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
    triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
end

---@type ParseAchievementTable
local achievements =
{
    cow_3 =
    {
        elements =
        {
            [103461] = { time = 5, class = TT.Achievement.Base, trigger_times = 1 },
            [103458] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_4 =
    {
        elements =
        {
            [101031] = { status = "defend", class = TT.Achievement.Status, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
                if enabled then
                    self:CheckCondition(trigger)
                end
            end) },
            [103468] = { special_function = SF.SetAchievementFailed, trigger_times = 1 },
            [104357] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_5 =
    {
        elements =
        {
            [101041] = { status = "defend", class = TT.Achievement.Status },
            [104426] = { special_function = SF.SetAchievementComplete },
            [104364] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        }
    }
}

local other =
{
    [100475] = EHI:AddAssaultDelay({ time = 30, special_function = SF.AddTimeByPreplanning, data = { id = 101024, yes = 90, no = 60 } })
}
if EHI:IsLootCounterVisible() then
    local Trigger = { id = "LootCounter", special_function = SF.IncreaseProgressMax } -- Money spawned
    for _, index in ipairs({ 580, 830, 3120, 3370, 3620, 3870 }) do
        other[EHI:GetInstanceElementID(100197, index)] = Trigger
        other[EHI:GetInstanceElementID(100198, index)] = Trigger
        other[EHI:GetInstanceElementID(100201, index)] = Trigger
        other[EHI:GetInstanceElementID(100202, index)] = Trigger
    end
    other[101041] = { special_function = EHI:RegisterCustomSpecialFunction(function(...)
        EHI:ShowLootCounterNoChecks({
            -- 1 flipped wagon crate; guaranteed to have gold or 2x money; 15% chance to spawn 2x money, otherwise gold
            -- If second money bundle spawns, the maximum is increased in the Trigger above
            max = 5 -- 4 Bomb parts + 1
        })
    end)}
    -- 1 random loot in train wagon, 35% chance to spawn
    -- Wagons are selected randomly; sometimes 2 with possible loot spawns, sometimes 1
    local function DelayRejection(crate)
        EHI:DelayCall(tostring(crate), 2, function()
            managers.ehi_tracker:RandomLootDeclinedCheck(crate)
        end)
    end
    local IncreaseMaxRandomLoot = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
        local index = trigger.index
        local crate = EHI:GetInstanceUnitID(100000, index)
        local LootTrigger = {}
        local arg = { crate, true }
        local loot_trigger = { special_function = SF.CallTrackerManagerFunction, f = "RandomLootSpawnedCheck", arg = arg }
        LootTrigger[EHI:GetInstanceElementID(100009, index)] = loot_trigger
        LootTrigger[EHI:GetInstanceElementID(100010, index)] = loot_trigger
        managers.mission:add_runned_unit_sequence_trigger(crate, "interact", function(...)
            DelayRejection(crate)
        end)
        self:AddTriggers2(LootTrigger, nil, "LootCounter")
        self:HookElements(LootTrigger)
        self._trackers:IncreaseLootCounterMaxRandom()
    end)
    other[104274] = { special_function = IncreaseMaxRandomLoot, index = 500 }
    other[104275] = { special_function = IncreaseMaxRandomLoot, index = 520 }
    other[104276] = { special_function = IncreaseMaxRandomLoot, index = 1080 }
    other[104277] = { special_function = IncreaseMaxRandomLoot, index = 1100 }
    other[104278] = { special_function = IncreaseMaxRandomLoot, index = 1120 }
    other[104279] = { special_function = IncreaseMaxRandomLoot, index = 1140 }
    other[104280] = { special_function = IncreaseMaxRandomLoot, index = 1160 }
    other[104281] = { special_function = IncreaseMaxRandomLoot, index = 1300 }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    ---@class EHIcrojob3SnipersTracker : EHISniperLoopTracker
    ---@field super EHISniperLoopTracker
    EHIcrojob3SnipersTracker = class(EHISniperLoopTracker)
    EHIcrojob3SnipersTracker.super._refresh_on_delete = nil
    function EHIcrojob3SnipersTracker:pre_init(params)
        self._sniper_respawn = true
        self._initial_spawn = true
        self._refresh_on_delete = true
        EHIcrojob3SnipersTracker.super.pre_init(self, params)
    end
    function EHIcrojob3SnipersTracker:RequestRemoval()
        self._sniper_respawn = true -- To disable the respawn
        EHIcrojob3SnipersTracker.super.RequestRemoval(self)
    end
    function EHIcrojob3SnipersTracker:OnChanceSuccess()
        self:SetChance(10) -- ´set10´ ElementLogicChanceOperator 100749
        self:RemoveTrackerFromUpdate()
        self._sniper_respawn = false
    end
    function EHIcrojob3SnipersTracker:SniperKilled()
        if self._sniper_respawn then
            return
        end
        self._sniper_respawn = true
        self:OnChanceFail()
        self:AddTrackerToUpdate()
    end
    function EHIcrojob3SnipersTracker:Refresh()
        if self._initial_spawn then
            self:OnChanceSuccess()
            self._initial_spawn = nil
        end
    end
    other[100750] = { chance = 100, time = 120, on_fail_refresh_t = 40, id = "Snipers", class = "EHIcrojob3SnipersTracker" }
    other[100745] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100749] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" } -- 10%
    other[100518] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperKilled" }
    other[102928] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    other[100744] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100496] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100519] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100521] = { id = "Snipers", special_function = SF.IncreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "vault_found" },
        { amount = 12000, name = "the_bomb2_vault_filled" },
        { amount = 6000, name = "ggc_c4_taken" },
        { escape = 12000 }
    },
    loot_all = 1500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                -- Max = 2 money spawned instead of gold and all four train vagons have loot (very unprobable, but still...)
                loot_all = { min = 5, max = 10 }
            }
        }
    }
})