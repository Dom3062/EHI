local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102444] = { id = "king_of_the_hill", class = TT.AchievementNotification },
    [101297] = { id = "king_of_the_hill", special_function = SF.SetAchievementFailed },
    [101343] = { id = "king_of_the_hill", special_function = SF.SetAchievementComplete },
    [102449] = { time = 240 },
    [102450] = { time = 180 },
    [102451] = { time = 300 },

    [101285] = { id = 100786, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-2758, -3798, -50) } },
    [101286] = { id = 100783, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3583, -3882, -50) } },
    [101287] = { id = 100784, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(4023, 1027, -50) } },
    [101284] = { id = 100785, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3133, 1027, -50) } }
}

if EHI._cache.Client then
    triggers[100606] = { time = 240, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100593] = { time = 180, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100607] = { time = 120, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100601] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100602] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers, "Escape", Icon.CarEscape)