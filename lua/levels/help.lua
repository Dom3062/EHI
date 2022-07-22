EHIorange5Tracker = class(EHIAchievementProgressTracker)
function EHIorange5Tracker:Finalize()
    if self._progress < self._max then
        self:SetFailed()
    end
end

local EHI = EHI
EHI.AchievementTrackers.EHIorange5Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local mayhem_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem)
local c4_wp = Vector3(0, 0, 50)
local vectors =
{ -- The rotation is taken directly from the game by Lua (it is not the same as in the decompiled mission script)
    [2300] = EHI:GetInstanceElementPosition(Vector3(-4339, -1118, 1887.84), c4_wp, Rotation(44.9999, 0, -0)),
    [5400] = EHI:GetInstanceElementPosition(Vector3(-3679, 1083, 1887.84), c4_wp, Rotation(0, 0, -0)),
    [10700] = EHI:GetInstanceElementPosition(Vector3(-3127, 3312, 1887.84), c4_wp, Rotation(0, 0, -0))
}
local triggers = {
    [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, id = "orange_4", class = TT.Achievement, difficulty_pass = mayhem_and_up, exclude_from_sync = true },
    [EHI:GetInstanceElementID(100461, 21700)] = { id = "orange_4", special_function = SF.SetAchievementComplete },

    [100279] = { max = 15, id = "orange_5", class = "EHIorange5Tracker", status_is_overridable = true, remove_after_reaching_target = false, difficulty_pass = mayhem_and_up, exclude_from_sync = true },
    [EHI:GetInstanceElementID(100471, 21700)] = { id = "orange_5", special_function = SF.SetAchievementFailed },
    [EHI:GetInstanceElementID(100474, 21700)] = { id = "orange_5", special_function = SF.IncreaseProgress },
    [EHI:GetInstanceElementID(100005, 12200)] = { id = "orange_5", special_function = SF.FinalizeAchievement },

    [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = Icon.HeliDropC4 },

    [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } }
}
for _, index in ipairs({ 2300, 5400, 10700 }) do
    triggers[EHI:GetInstanceElementID(100004, index)] = { id = EHI:GetInstanceElementID(100021, index), special_function = SF.ShowWaypoint, data = { icon = Icon.C4, position = vectors[index] } }
end

local DisableWaypoints = {}
for _, index in ipairs({ 900, 1200, 1500, 4800, 13200 }) do
    DisableWaypoints[EHI:GetInstanceElementID(100093, index)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100212, index)] = true -- Fix
end
EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
local LotteryWheel = { icons = { Icon.Wait }, icon_on_pause = { "restarter" } }

local tbl =
{
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [400003] = { ignore = true },

    --levels/instances/unique/help/door_switch
    --units/pd2_dlc_help/props/hlp_interactable_controlswitch/hlp_interactable_controlswitch
    [EHI:GetInstanceElementID(100072, 12400)] = { icons = { Icon.Wait }, warning = true },

    --levels/instances/unique/help/lottery_wheel (6 + 8)
    --units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer
    [EHI:GetInstanceElementID(100033, 4800)] = LotteryWheel,
    [EHI:GetInstanceElementID(100033, 13200)] = LotteryWheel
}
for i = 900, 1500, 300 do
    --levels/instances/unique/help/lottery_wheel (1, 4 + 5)
    --units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer
    tbl[EHI:GetInstanceElementID(100033, i)] = LotteryWheel
end
EHI:UpdateUnits(tbl)