local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@param self EHIMissionElementTrigger
---@param block boolean
local function SetAssaultTrackerBlock(self, block)
    self._assault:SetAssaultBlock(block)
end
---@type ParseTriggerTable
local triggers = {
    [102685] = { id = "Refueling", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.SetTimeIfLoudOrStealth, data = { loud = 121, stealth = 91 }, trigger_once = true, hint = Hints.FuelTransfer },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker },
    [101983] = { time = 15, id = "C4Trap", icons = { Icon.C4 }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Explosion },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker }
}
---@type ParseAchievementTable
local achievements =
{
    mex_9 =
    {
        elements =
        {
            [100107] = { max = 4, class = TT.Achievement.Progress }
        },
        preparse_callback = function(data)
            local trigger = { special_function = SF.IncreaseProgress }
            for i = 101502, 101509, 1 do
                data.elements[i] = trigger
            end
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 }), -- Arizona (When alarm is raised in Mexico (for the first time), run this trigger instead)
    [100697] = EHI:AddAssaultDelay({ control_additional_time = 30, random_time = 10, condition_function = EHI.ConditionFunctions.IsLoud }), -- Mexico (ElementDifficulty already exists)

    [100880] = { special_function = SF.CustomCode2, f = SetAssaultTrackerBlock, arg = true }, -- Entered the tunnel
    [103212] = { special_function = SF.CustomCode2, f = SetAssaultTrackerBlock, arg = false } -- Arrived in Mexico
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102495] = { id = "Snipers", class = TT.Sniper.Count, trigger_once = true, single_sniper = EHI:IsDifficulty(EHI.Difficulties.Normal) }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102473] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[102485] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102480] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:IsLootCounterVisible() then
    local arizona_meth = 4
    other[100108] = EHI:AddLootCounter2(function()
        EHI:ShowLootCounterNoChecks({
            -- 41 extra loot in Mexico (final loot count determined when spawned in Mexico)
            -- 4 meth bags in Arizona
            max = 45,
            max_random = 4, -- Achievement armor
            client_from_start = true,
            triggers =
            {
                [100109] = EHI:AddCustomCode(function(self)
                    self._loot:RandomLootDeclined(4) -- Alarm
                end)
            },
            hook_triggers = true
        })
    end, { element = { EHI:GetInstanceElementID(100017, 24850), EHI:GetInstanceElementID(100017, 25850) }})
    other[101740] = EHI:AddCustomCode(function(self)
        if arizona_meth > 0 then
            self._loot:DecreaseLootCounterProgressMax(arizona_meth)
            arizona_meth = 0 -- Set the number to zero to avoid subtracting it again after players left the Arizona
        end
    end, true) -- Explosion
    other[102815] = other[101740] -- Left Arizona
    for _, meth in ipairs({ 102023, 102054, 103556, 103557 }) do
        managers.mission:add_runned_unit_sequence_trigger(meth, "interact", function(unit)
            arizona_meth = arizona_meth - 1
        end)
    end
    other[EHI:GetInstanceElementID(100022, 26850)] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawned(4)
    end) -- Vault opened
    local function LootDespawned()
        managers.ehi_loot:DecreaseLootCounterProgressMax()
    end
    for _, i in ipairs({
        -- Money
        100654, 100655, 100656, 100681, 100696, 100653, 100720, 100758, 100759, 100820, 100827, 100828, 100829, 100841,

        -- Weapons
        100919, 100920, 100930, 100938, 100943, 100947, 100950, 100951, 100952, 100961, 100964, 100968, 100971, 100973,

        -- Cocaine
        100982, 100984, 100990, 100994, 101001, 101003, 101089, 101260, 101261, 101262, 101265, 101266, 101267
    }) do
        other[i] = { special_function = SF.CustomCodeIfEnabled, f = LootDespawned, trigger_once = true }
    end
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local MinBags = EHI:GetValueBasedOnDifficulty({
    normal = 4,
    hard = 6,
    veryhard = 6,
    overkill = 8,
    mayhem_or_above = 12
})
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_red_door_found" },
                { amount = 2000, name = "mex1_tunnel_found" },
                { amount = 2000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 8000, name = "mex1_secured_mandatory_bags" },
                { amount = 2000, name = "mex1_started_fueling" },
                { amount = 3000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = MinBags, max = 43 }
                    }
                }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_tunnel_found" },
                { amount = 3000, name = "mex1_explosives_found" },
                { amount = 3000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 6000, name = "mex1_secured_mandatory_bags" },
                { amount = 1000, name = "mex1_started_fueling" },
                { amount = 2000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = MinBags, max = 35 }
                    }
                }
            }
        }
    }
})