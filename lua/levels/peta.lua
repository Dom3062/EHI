local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = Icon.CarEscape },
    [101706] = { time = 1283/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101727] = { time = 895/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait } },
    [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait } },
    [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait } },
    [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait } },
    [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, id = "peta_2", class = TT.Achievement },
    [EHI:GetInstanceElementID(100080, 2900)] = { id = "peta_2", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers)