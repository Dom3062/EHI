local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local overkill = EHI:IsDifficulty("overkill")
local AddMoney = EHI:GetFreeCustomSpecialFunctionID()
local MoneyTrigger = { id = "MallDestruction", special_function = AddMoney }
local OverkillOrBelow = EHI:IsDifficultyOrBelow("overkill")
local triggers =
{
    -- Time before escape vehicle arrives
    [300248] = { time = (OverkillOrBelow and 120 or 300) + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot },
    -- 120: Base Delay on OVK or below
    -- 300: Base Delay on Mayhem or above
    -- 25: Escape zone activation delay

    [300043] = { id = "MallDestruction", class = TT.MallcrasherMoney, icons = { "C_Vlad_H_Mallcrasher_Shoot" } },
    [300843] = MoneyTrigger, -- +40
    [300844] = MoneyTrigger, -- +80
    [300845] = MoneyTrigger, -- +250
    [300846] = MoneyTrigger, -- +500
    [300847] = MoneyTrigger, -- +800
    [300848] = MoneyTrigger, -- +2000
    [300850] = MoneyTrigger, -- +2800
    [300849] = MoneyTrigger, -- +4000
    [300872] = MoneyTrigger, -- +5600
    [300851] = MoneyTrigger, -- +8000, appears to be unused

    [301148] = { special_function = SF.Trigger, data = { 3011481, 3011482, 3011483 } },
    [3011481] = { time = 50, to_secure = 1800000, id = "ameno_3", class = TT.AchievementTimedMoneyCounterTracker, condition = show_achievement and overkill, exclude_from_sync = true },
    [3011482] = { time = 180, id = "uno_3", class = TT.Achievement, exclude_from_sync = true },
    [3011483] = { special_function = SF.CustomCode, f = function()
        if managers.ehi:TrackerDoesNotExist("ameno_3") then
            return
        end
        EHI:AddAchievementToCounter({
            achievement = "ameno_3",
            counter =
            {
                check_type = EHI.LootCounter.CheckType.ValueOfSmallLoot
            }
        })
    end },
    [300241] = { id = "uno_3", special_function = SF.SetAchievementComplete },

    [301056] = { max = 171, id = "window_cleaner", flash_times = 1, class = TT.AchievementProgress },
    [300791] = { id = "window_cleaner", special_function = SF.IncreaseProgress }
}

if EHI._cache.Client then
    triggers[302287] = { time = (OverkillOrBelow and 115 or 120) + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[300223] = { time = 60 + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[302289] = { time = 30 + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[300246] = { time = 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(AddMoney, function(id, trigger, element, enabled)
    managers.ehi:AddMoneyToTracker(trigger.id, element._values.amount)
end)
if show_achievement and overkill and EHI:IsAchievementLocked("ameno_3") then
    EHI:AddLoadSyncFunction(function(self)
        if self._t <= 50 then
            self:AddTracker({
                time = 50 - self._t,
                id = "ameno_3",
                to_secure = 1800000,
                icons = EHI:GetAchievementIcon("ameno_3"),
                class = "EHIAchievementTimedMoneyCounterTracker"
            })
            self:SetTrackerProgress("ameno_3", managers.loot:get_real_total_small_loot_value())
            EHI:AddAchievementToCounter({
                achievement = "ameno_3",
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.ValueOfSmallLoot
                }
            })
        end
    end)
end