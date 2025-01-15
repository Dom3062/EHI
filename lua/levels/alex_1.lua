local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local anim_delay = 2 + 727/30 + 2 -- 2s is function delay; 727/30 is a animation duration; 2s is zone activation delay; total 28,23333
local assault_delay = 4 + 3 + 3 + 3 + 5 + 1
local assault_delay_methlab = 20 + assault_delay
local triggers = {
    [101970] = { time = (240 + 12) - 3, waypoint = { position_from_element = 101454 }, hint = Hints.LootEscape },
    [100199] = { time = 5 + 1, id = "CookingDone", icons = { Icon.Methlab, Icon.Interact }, waypoint = { data_from_element = 100485 }, hint = Hints.mia_1_MethDone, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        self:CreateTracker(trigger)
        self._cache.BagsCooked = (self._cache.BagsCooked or 0) + 1
        if self._cache.BagsCooked >= 7 then
            self._trackers:ForceRemoveTracker("CookingChance")
            self:UnhookTrigger(100721)
            self:UnhookTrigger(100724)
        end
    end) },

    [1] = { special_function = SF.RemoveTrigger, data = { 101974, 101975, 101970 } },
    [101974] = { special_function = SF.Trigger, data = { 1019741, 1 } },
    -- There is an issue in the script. Even if the van driver says 2 minutes, he arrives in a minute
    [1019741] = { time = (60 + 30 + anim_delay) - 58, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { position_from_element = 101454 }, hint = Hints.LootEscape },
    [101975] = { special_function = SF.Trigger, data = { 1019751, 1 } },
    [1019751] = { time = 30 + anim_delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { position_from_element = 101454 }, hint = Hints.LootEscape },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", Icon.Goto }, class = TT.Warning, hint = Hints.ScriptedBulldozer }
}
---@type ParseAchievementTable
local achievements =
{
    halloween_1 =
    {
        elements =
        {
            [101088] = { status = Status.Ready, class = TT.Achievement.Status },
            [101907] = { status = Status.Defend, special_function = SF.SetAchievementStatus },
            [101917] = { special_function = SF.SetAchievementComplete },
            [101914] = { special_function = SF.SetAchievementFailed },
            [101001] = { special_function = SF.SetAchievementFailed } -- Methlab exploded
        }
    }
}
local other =
{
    [100378] = EHI:AddAssaultDelay({ control = 42 + 50 + assault_delay }),
    [100380] = EHI:AddAssaultDelay({ control = 45 + 40 + assault_delay }),
    [100707] = EHI:AddAssaultDelay({ control = assault_delay_methlab, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:CallFunction2(trigger.id, "SetTimeIfLower", trigger.time) then
            self:CreateTracker(trigger)
        end
    end), trigger_once = true })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local SetRespawnTime = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        local t = trigger.time
        if self._trackers:CallFunction2(id, "SetRespawnTime", t) then
            self._trackers:AddTracker({
                id = id,
                time = t,
                count_on_refresh = 2,
                class = TT.Sniper.TimedCount
            })
        end
    end)
    other[101257] = { time = 90 + 140, id = "Snipers", count_on_refresh = 2, class = TT.Sniper.TimedCount, trigger_once = true, hint = Hints.EnemySnipers }
    other[101137] = { time = 60, id = "Snipers", special_function = SetRespawnTime }
    other[101138] = { time = 90, id = "Snipers", special_function = SetRespawnTime }
    other[101141] = { time = 140, id = "Snipers", special_function = SetRespawnTime }
    other[101134] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

if EHI.IsClient then
    local EM = managers.ehi_manager
    ---@param self LootManager
    local function SyncBagsCooked(self)
        EM._cache.BagsCooked = math.max(self:GetSecuredBagsAmount(), EM._cache.BagsCooked or 0)
        if EM._cache.BagsCooked >= 7 then
            EM._trackers:ForceRemoveTracker("CookChance")
            EM:UnhookTrigger(100721)
            EM:UnhookTrigger(100724)
            EM._loot:RemoveListener("alex_1")
        end
    end
    EM._loot:AddListener("alex_1", SyncBagsCooked)
    EM._loot:AddSyncListener(SyncBagsCooked)
end

local tracker_merge =
{
    CookingChance =
    {
        elements =
        {
            [101001] = { special_function = SF.RemoveTracker },
            [100721] = { time = 1, chance = 5, icons = { Icon.Methlab }, class = TT.Timed.Chance, special_function = SF.SetChanceWhenTrackerExists, start_opened = EHI:ShowTimedTrackerOpened(), hint = Hints.CookingChance, tracker_merge = {} },
            [100724] = { time = 25, icons = { Icon.Methlab, Icon.Loop }, waypoint = { position_from_element = 100212 }, special_function = SF.SetTimeOrCreateTracker, tracker_merge = {} },
            [100723] = { amount = 10, special_function = SF.IncreaseChance }
        }
    }
}

EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    tracker_merge = tracker_merge
}, "Van", Icon.CarEscape)
EHI:ShowAchievementLootCounter({
    achievement = "halloween_2",
    max = 7,
    triggers =
    {
        [101001] = { special_function = SF.SetAchievementFailed } -- Methlab exploded
    },
    add_to_counter = true,
    show_loot_counter = true,
    loot_counter_on_fail = true,
    difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
})
if EHI:IsEscapeChanceEnabled() then
    other[101863] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 25)
    end)
    EHI.Manager:AddLoadSyncFunction(function(self)
        if managers.environment_effects._mission_effects[101437] then
            self._escape:AddEscapeChanceTracker(false, 105)
            self:UnhookTrigger(101863)
        else
            self._escape:AddEscapeChanceTracker(false, 35)
            -- Disable increase when the cooks got killed by gangster in case the player dropins
            -- after Escape Chance is shown on screen and before they get killed by mission script
            self._escape:DisableIncreaseCivilianKilled()
        end
    end)
end
local obj1_xp = 12000
local min_xp =
{
    rats_lab_exploded = true
}
local lab_explode_increase_escape = 70
if EHI:IsMayhemOrAbove() then
    obj1_xp = 0
    min_xp =
    {
        rats_3_bags_cooked = true
    }
    lab_explode_increase_escape = nil ---@diagnostic disable-line
end
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = obj1_xp, name = "rats_lab_exploded", increase_escape_chance = lab_explode_increase_escape },
        { _or = true },
        { amount = 30000, name = "rats_3_bags_cooked" },
        { _or = true },
        { amount = 30000 + 40000, name = "rats_all_7_bags_cooked" }, -- Previous XP is counted too
        { escape = true, escape_chance = { start_chance = 35, no_expert_driver_asset = true } }
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = min_xp,
            },
            max =
            {
                objectives =
                {
                    rats_all_7_bags_cooked = true
                }
            }
        }
    }
})