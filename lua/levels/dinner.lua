local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local c4 = { time = 5, id = "C4", icons = { Icon.C4 } }
---@type Vector3?
local EscapePos = nil
---@type ParseTriggerTable
local triggers = {
    [100915] = { time = 4640/30, id = "CraneMoveGas", icons = { Icon.Winch, Icon.Fire, Icon.Goto }, waypoint = { position_by_element = 100836 } },
    [100967] = { time = 3660/30, id = "CraneMoveGold", icons = { Icon.Escape }, waypoint_f = function(self, trigger)
        if EscapePos then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.Interact,
                position = EscapePos
            })
            return
        end
        self._trackers:AddTrackerIfDoesNotExist(trigger, trigger.pos)
    end },
    -- C4 (Doors)
    [100985] = c4,
    -- C4 (GenSec Truck)
    [100830] = c4,
    [100961] = c4
}
local function CacheEscapePos(index)
    EscapePos = EHI:GetElementPosition(EHI:GetInstanceElementID(100034, index))
end
for i = 2850, 3050, 100 do
    triggers[EHI:GetInstanceElementID(100028, i)] = { special_function = SF.CustomCode, f = CacheEscapePos, arg = i }
end

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseAchievementTable
local achievements =
{
    farm_2 =
    {
        elements =
        {
            [100484] = { time = 300, class = TT.AchievementUnlock },
            [100319] = { special_function = SF.SetAchievementFailed }
        }
    },
    farm_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101179] = { class = TT.AchievementStatus }, --101553
            [103394] = { special_function = SF.SetAchievementFailed },
            [102880] = { special_function = SF.SetAchievementComplete }
        }
    },
    farm_4 =
    {
        elements =
        {
            [100485] = { time = 30, class = TT.Achievement },
            [102841] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101346] = EHI:AddAssaultDelay({ time = 45 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[101179] = { chance = 15, id = "Snipers", class = TT.Sniper.Chance, flash_times = 1 }
    other[101227] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101228] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[101233] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
        if EHI:IsHost() and not element:_values_ok() then
            return
        end
        self._trackers:CallFunction("Snipers", "SnipersKilled")
    end)}
    other[101956] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[101957] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
        if self._trackers:TrackerExists("Snipers") then
            self._trackers:SetChance("Snipers", element._values.chance) -- 0%
            self._trackers:CallFunction("Snipers", "SniperSpawnsSuccess")
        else
            self._trackers:AddTracker({
                id = "Snipers",
                flash_times = 1,
                chance_success = true,
                class = TT.Sniper.Chance
            })
        end
    end) }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local pig = 0
if ovk_and_up then
    pig = 1
    EHI:ShowAchievementLootCounter({
        achievement = "farm_6",
        max = 1,
        show_finish_after_reaching_target = true,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "din_pig"
        }
    })
    if EHI:CanShowAchievement("farm_1") then
        local farm_1 = EHI:GetAchievementIcon("farm_1")
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            if mode == "phalanx" then
                managers.ehi_tracker:AddTracker({
                    id = "farm_1",
                    status = "finish",
                    icons = farm_1,
                    class = EHI.Trackers.AchievementStatus,
                })
            else
                managers.ehi_tracker:SetAchievementFailed("farm_1")
            end
        end)
        EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
            if success then
                managers.ehi_tracker:SetAchievementComplete("farm_1")
            end
        end)
    end
end

EHI:ShowLootCounter({ max = 10 + pig })

local tbl =
{
    -- Drills
    [100035] = { remove_vanilla_waypoint = 103175 },
    [100949] = { remove_vanilla_waypoint = 103174 }
}
EHI:UpdateUnits(tbl)
local required_bags = 2 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    required_bags = 4
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    required_bags = 6
elseif EHI:IsMayhemOrAbove() then
    required_bags = 8
end
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "slaughterhouse_entered" },
        { amount = 6000, name = "vault_drill_done" },
        { amount = 6000, name = "slaughterhouse_tires_burn" },
        { amount = 6000, name = "slaughterhouse_trap_lifted" },
        { amount = 6000, name = "slaughterhouse_gold_lifted" },
        { escape = 6000 }
    },
    loot =
    {
        gold = ovk_and_up and 800 or 1000
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    gold = { min = required_bags, max = 10 }
                }
            }
        }
    }
})