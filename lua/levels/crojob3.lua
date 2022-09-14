local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_anim = 35
local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
local thermite_right = { time = 86, id = "Thermite", icons = { Icon.Fire } }
local thermite_left_top = { time = 90, id = "Thermite", icons = { Icon.Fire } }
local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled }
local HeliWaterFill = { Icon.Heli, Icon.Water }
if EHI:GetOption("show_one_icon") then
    HeliWaterFill = { { icon = Icon.Heli, color = Color("D4F1F9") } }
end
local cow_4 = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101499] = { time = 155 + 25, id = "EscapeHeli", icons = Icon.HeliEscape },
    [101253] = heli_65,
    [101254] = heli_20,
    [101255] = heli_65,
    [101256] = heli_20,
    [101259] = heli_65,
    [101278] = heli_20,
    [101279] = heli_65,
    [101280] = heli_20,

    [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = Icon.HeliEscape },

    [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },

    [102825] = { id = "WaterFill", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 } },
    [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
    [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

    [1] = { id = "HeliWaterFill", special_function = SF.PauseTracker },
    [2] = { id = "HeliWaterReset", icons = { Icon.Heli, Icon.Water, Icon.Loop }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full } },

    -- Right
    [100283] = thermite_right,
    [100284] = thermite_right,
    [100288] = thermite_right,

    -- Left
    [100285] = thermite_left_top,
    [100286] = thermite_left_top,
    [100560] = thermite_left_top,

    -- Top
    [100282] = thermite_left_top,
    [100287] = thermite_left_top,
    [100558] = thermite_left_top,
    [100559] = thermite_left_top
}
for _, index in ipairs({ 100, 150, 250, 300 }) do
    triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = HeliWaterFill, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
    triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
end

local achievements =
{
    [103461] = { time = 5, id = "cow_3", class = TT.Achievement, special_function = SF.RemoveTriggerAndShowAchievement },
    [103458] = { id = "cow_3", special_function = SF.SetAchievementComplete },

    [101031] = { id = "cow_4", status = "defend", class = TT.AchievementStatus, special_function = cow_4 },
    [103468] = { id = "cow_4", special_function = SF.SetAchievementFailed },
    [104357] = { id = "cow_4", special_function = SF.SetAchievementComplete }
}

local other =
{
    --[[[101041] = { special_function = SF.CustomCode, f = function()
        local LootTrigger = {}
        local function DelayRejection(unit, ...) -- This will get very wonky with desync...
            local id = unit:editor_id()
            EHI:DelayCall(tostring(id), 2, function()
                managers.ehi:CallFunction("LootCounter", "RandomLootDeclined2", id)
            end)
        end
        for _, index in ipairs({500, 520, 1080, 1100, 1120, 1140, 1160, 1300}) do
            local crate = EHI:GetInstanceUnitID(100000, index)
            local function LootSpawned()
                managers.ehi:CallFunction("LootCounter", "RandomLootSpawned2", crate)
            end
            LootTrigger[EHI:GetInstanceElementID(100009, index)] = { special_function = SF.CustomCode, f = LootSpawned }
            LootTrigger[EHI:GetInstanceElementID(100010, index)] = { special_function = SF.CustomCode, f = LootSpawned }
            managers.mission:add_runned_unit_sequence_trigger(crate, "interact", DelayRejection)
        end
        EHI:ShowLootCounter({
            max = 4,
            -- 1 flipped wagon crate; guaranteed to have 1 bag of loot and C4
            additional_loot = 1,
            -- 4 regular wagon crates; random loot, 35% chance to spawn
            max_random = 4,
            triggers = LootTrigger
        })
    end},]]
    [101018] = { time = 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.AddTimeByPreplanning, data = { id = 101024, yes = 90, no = 60 }, condition = EHI:GetOption("show_assault_delay_tracker") }
}

EHI:ParseTriggers(triggers, achievements, other)
EHI:RegisterCustomSpecialFunction(cow_4, function(id, trigger, element, enabled)
    if enabled then
        EHI:CheckCondition(id)
    end
end)