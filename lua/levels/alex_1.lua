local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local anim_delay = 2 + 727/30 + 2 -- 2s is function delay; 727/30 is a animation duration; 2s is zone activation delay; total 28,23333
local assault_delay_methlab = 20 + 4 + 3 + 3 + 3 + 5 + 1 + 30
local assault_delay = 4 + 3 + 3 + 3 + 5 + 1 + 30
local SetTimeIfMoreThanOrCreateTracker = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101088] = { id = "halloween_1", status = "ready", class = TT.AchievementNotification },
    [101907] = { id = "halloween_1", status = "ok", special_function = SF.SetAchievementStatus },
    [101917] = { id = "halloween_1", special_function = SF.SetAchievementComplete },
    [101914] = { id = "halloween_1", special_function = SF.SetAchievementFailed },
    [100378] = { time = 42 + 50 + assault_delay, id = "AssaultDelay", class = TT.AssaultDelay },
    [100380] = { time = 45 + 40 + assault_delay, id = "AssaultDelay", class = TT.AssaultDelay },
    [101001] = { special_function = SF.Trigger, data = { 1010011, 1010012 } },
    [1010011] = { id = "CookChance", special_function = SF.RemoveTracker },
    [1010012] = { id = "halloween_2", special_function = SF.SetAchievementFailed },
    [101970] = { time = (240 + 12) - 3, id = "Van", icons = Icon.CarEscape },
    [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
    [1007211] = { chance = 5, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },
    [100724] = { time = 25, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetTimeOrCreateTracker },
    [100199] = { time = 5 + 1, id = "CookingDone", icons = { Icon.Methlab, "pd2_generic_interact" } },

    [1] = { special_function = SF.RemoveTriggers, data = { 101974, 101975 } },
    [101974] = { special_function = SF.Trigger, data = { 1019741, 1 } },
    -- There is an issue in the script. Even if the van driver says 2 minutes, he arrives in a minute
    [1019741] = { time = (60 + 30 + anim_delay) - 58, special_function = SF.AddTrackerIfDoesNotExist },
    [101975] = { special_function = SF.Trigger, data = { 1019751, 1 } },
    [1019751] = { time = 30 + anim_delay, special_function = SF.AddTrackerIfDoesNotExist },

    [100707] = { time = assault_delay_methlab, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SetTimeIfMoreThanOrCreateTracker },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", "pd2_goto" }, class = TT.Warning },

    [100723] = { amount = 10, id = "CookChance", special_function = SF.IncreaseChance },

    [101863] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 25)
end)

EHI:ParseTriggers(triggers, "Van", Icon.CarEscape)
if EHI:GetOption("show_achievement") and EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    EHI:ShowAchievementLootCounter({
        achievement = "halloween_2",
        max = 7,
        exclude_from_sync = true
    })
else
    EHI:ShowLootCounter(7)
end
EHI:RegisterCustomSpecialFunction(SetTimeIfMoreThanOrCreateTracker, function(id, trigger, ...)
    if managers.ehi:TrackerExists(trigger.id) then
        local tracker = managers.ehi:GetTracker(trigger.id)
        if tracker then
            if tracker._time >= trigger.time then
                managers.ehi:SetTrackerTime(trigger.id, trigger.time)
            end
        else
            EHI:CheckCondition(id)
        end
    else
        EHI:CheckCondition(id)
    end
    EHI:UnhookTrigger(id)
end)
EHI:AddLoadSyncFunction(function(self)
    if managers.environment_effects._mission_effects[101437] then
        self:AddEscapeChanceTracker(false, 105)
        EHI:UnhookElement(101863)
    else
        self:AddEscapeChanceTracker(false, 35)
        -- Disable increase when the cooks got killed by gangster in case the player dropins
        -- after Escape Chance is shown on screen and before they get killed by mission script
        self.IncreaseCivilianKilled = function(...)
        end
    end
end)