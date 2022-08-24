local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local van_delay = 47 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0), 31s before the timer gets activated; 10s before the timer is started; total 47s; Mayhem difficulty and above
local van_delay_ovk = 6 -- 1 second before setting up the timer and 5 seconds after the van leaves (base delay when timer is 0); OVERKILL difficulty and below
local heli_delay = 19
local anim_delay = 743/30 -- 743/30 is a animation duration; 3s is zone activation delay (never used when van is coming back)
local heli_delay_full = 13 + 19 -- 13 = Base Delay; 19 = anim delay
local heli_icon = { Icon.Heli, Icon.Methlab, Icon.Goto }
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [100494] = { id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, hook_element = 100724, set_time_when_tracker_exists = true }
}
local triggers = {
    [102318] = { time = 60 + 60 + 30 + 15 + anim_delay, id = "Van", icons = Icon.CarEscape },
    [102319] = { time = 60 + 60 + 60 + 30 + 15 + anim_delay, id = "Van", icons = Icon.CarEscape },
    [101001] = { special_function = SF.Trigger, data = { 1010011, 1010012 } },
    [1010011] = { special_function = SF.RemoveTrackers, data = { "CookChance", "VanStayDelay" } },
    [1010012] = { special_function = SF.RemoveTriggers, data = { 102220, 102219, 102229, 102235, 102236, 102237, 102238 } },

    [102383] = { time = 2 + 5, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1023831 } },
    [1023831] = { time = 2 + 20 + 4 + 3 + 3 + 3 + 5 + 30, id = "AssaultDelay", class = TT.AssaultDelay },
    [100721] = { time = 1, id = "CookDelay", icons = { Icon.Methlab, Icon.Wait }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1007211 } },
    [1007211] = { chance = 7, id = "CookChance", icons = { Icon.Methlab }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists },

    [100199] = { time = 5 + 1, id = "CookingDone", icons = { Icon.Methlab, Icon.Interact } },

    [102167] = { time = 60 + heli_delay, id = "HeliMeth", icons = heli_icon },
    [102168] = { time = 90 + heli_delay, id = "HeliMeth", icons = heli_icon },

    [102220] = { time = 60 + van_delay_ovk, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102219] = { time = 45 + van_delay, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102229] = { time = 90 + van_delay_ovk, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102235] = { time = 100 + van_delay_ovk, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102236] = { time = 50 + van_delay, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102237] = { time = 60 + van_delay_ovk, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },
    [102238] = { time = 70 + van_delay_ovk, id = "VanStayDelay", icons = Icon.CarWait, class = TT.Warning },

    [1] = { special_function = SF.RemoveTriggers, data = { 101972, 101973, 101974, 101975 } },
    [101972] = { time = 60 + 60 + 60 + 30 + 15 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101973] = { time = 60 + 60 + 30 + 15 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101974] = { time = 60 + 30 + 15 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },
    [101975] = { time = 30 + 15 + anim_delay, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1 } },

    [100954] = { time = 24 + 5 + 3, id = "HeliBulldozerSpawn", icons = { Icon.Heli, "heavy", Icon.Goto }, class = TT.Warning },

    [101982] = { special_function = SF.Trigger, data = { 1019821, 1019822 } },
    [1019821] = { time = 589/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1019822] = { id = 101281, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1133.0, 1264.0, 1289.0) } },

    [101128] = { id = 101454, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1374.0, -2388.0, 1135.0) } },

    [100723] = { amount = 15, id = "CookChance", special_function = SF.IncreaseChance }
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then
    triggers[102197] = { time = 180 + heli_delay_full, id = "HeliMeth", icons = heli_icon }
elseif EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    triggers[102197] = { time = 120 + heli_delay_full, id = "HeliMeth", icons = heli_icon }
end
if Network:is_client() then
    triggers[100724] = { time = 20, random_time = 5, id = "CookChanceDelay", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetTimeNoAnimOrCreateTrackerClient, delay_only = true }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    [101081] = { id = "halloween_1", status = "ready", class = TT.AchievementStatus },
    [101907] = { id = "halloween_1", status = "defend", special_function = SF.SetAchievementStatus },
    [101917] = { id = "halloween_1", special_function = SF.SetAchievementComplete },
    [101914] = { id = "halloween_1", special_function = SF.SetAchievementFailed },
    [101780] = { max = 25, id = "voff_5", class = TT.AchievementProgress, difficulty_pass = ovk_and_up },
    [101001] = { id = "voff_5", special_function = SF.SetAchievementFailed },
    [102611] = { id = "voff_5", special_function = SF.IncreaseProgress },
}

EHI:ParseTriggers(triggers, achievements, nil, "Van", Icon.CarEscape)
if EHI:GetOption("show_achievement") and ovk_and_up then
    EHI:ShowAchievementLootCounter({
        achievement = "halloween_2",
        max = 7,
        exclude_from_sync = true
    })
end