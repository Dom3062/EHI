local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local VanCrashChance = { Icon.Car, Icon.Fire }
local assault_delay = 15 + 1 + 30
local triggers = {
    [104488] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker },
    [104489] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.AddTrackerIfDoesNotExist },

    [100342] = { chance = 25, id = "EscapeChance", icons = VanCrashChance, class = TT.Chance },

    -- Police ambush
    [104535] = { time = 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker }
}

EHI:ParseTriggers(triggers)
EHI:AddOnAlarmCallback(function(dropin)
    if dropin then
        return
    end
    managers.ehi:AddTracker({
        id = "AssaultDelay",
        time = 75 + 15 + 30,
        class = TT.AssaultDelay
    })
end)
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    if EHI._cache.Host or managers.ehi:GetStartedFromBeginning() then
        EHI:DelayCall("EHI_alex_2_Delay_LootCounter", 1, function()
            local spawned = managers.ehi:CountLootbagsOnTheGround()
            local additional_loot = math.max(0, spawned - 3)
            managers.ehi:ShowLootCounter(spawned, additional_loot, 0, true)
            EHI:HookLootCounter()
        end)
    end
end)

local function IncreaseLootCounterMax(...)
    managers.ehi:IncreaseTrackerProgressMax("LootCounter", 1)
end
local safes = { 103640, 103641, 101741, 101751, 103645, 103646, 103647, 103648, 103649, 103650, 103651, 103777, 103643, 101099, 101031, 101211 }
for _, safe in ipairs(safes) do
    managers.mission:add_runned_unit_sequence_trigger(safe, "spawn_loot_money", IncreaseLootCounterMax)
end