EHIuno7Tracker = class(EHIAchievementTracker)
function EHIuno7Tracker:init(panel, params)
    EHIuno7Tracker.super.init(self, panel, params)
    self._obtainable = false
    self._blocked_warning = true
    self:SetTextColor()
end

function EHIuno7Tracker:SetObtainable()
    self._obtainable = true
    self._blocked_warning = false
    self:SetTextColor()
end

function EHIuno7Tracker:SetTextColor()
    if self._obtainable then
        self._text:set_color(Color.white)
        if self._time <= 10 then
            self:AnimateWarning(true)
        end
    else
        self._text:stop()
        self._text:set_color(Color.red)
    end
end

function EHIuno7Tracker:AnimateWarning(check_progress)
    if self._blocked_warning then
        return
    end
    EHITimerTracker.AnimateWarning(self, check_progress)
end

local EHI = EHI
EHI.AchievementTrackers.EHIuno7Tracker = true
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local mayhem_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem)
local element_sync_triggers =
{
    [100241] = { time = 662/30, id = "EscapeBoat", icons = Icon.BoatEscape, hook_element = 100216 },
}
local random_car = { time = 18, id = "RandomCar", icons = { Icon.Heli, Icon.Goto }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } }
local caddilac = { time = 18, id = "Caddilac", icons = { Icon.Heli, Icon.Goto } }
local triggers = {
    [100103] = { time = 15 + 5, random_time = 10, id = "BileArrival", icons = { Icon.Heli } },

    [100238] = random_car,
    [100249] = random_car,
    [100310] = random_car,
    [100313] = random_car,
    [100314] = random_car,

    [102231] = { time = 20, id = "BileDropCar", icons = { Icon.Heli, Icon.Car, Icon.Goto } },

    [100718] = caddilac,
    [100720] = caddilac,
    [100732] = caddilac,
    [100733] = caddilac,
    [100734] = caddilac,

    [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, { icon = Icon.Car, color = Color("FFFF00") }, Icon.Goto } },

    [100213] = { time = 450/30, id = "EscapeCar1", icons = Icon.CarEscape },
    [100214] = { time = 160/30, id = "EscapeCar2", icons = Icon.CarEscape },

    [102814] = { time = 180, id = "Safe", icons = { Icon.Winch }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
    [102815] = { id = "Safe", special_function = SF.PauseTracker }
}
if EHI:IsClient() then
    triggers[100216] = { time = 662/30, random_time = 10, id = "EscapeBoat", icons = Icon.BoatEscape, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    [100107] = { time = 901, id = "uno_7", class = "EHIuno7Tracker", difficulty_pass = mayhem_and_up },
    [102291] = { max = 2, id = "friend_5", class = TT.AchievementProgress },
    [102430] = { time = 780, id = "friend_6", class = TT.Achievement, difficulty_pass = mayhem_and_up },
    [102280] = { id = "friend_5", special_function = SF.IncreaseProgress }
}

local other =
{
    [100109] = { time = 30 + 1 + 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.RemoveTriggerWhenExecuted, condition = EHI:GetOption("show_assault_delay_tracker") },
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({ max = 16 })
if EHI:ShowMissionAchievements() and mayhem_and_up then
    EHI:AddOnAlarmCallback(function()
        managers.ehi:SetAchievementFailed("friend_6")
        managers.ehi:CallFunction("uno_7", "SetObtainable")
    end)
end