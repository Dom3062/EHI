local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101148] = { id = "you_shall_not_pass", class = TT.AchievementNotification },
    [102471] = { id = "you_shall_not_pass", special_function = SF.SetAchievementFailed },
    [100426] = { id = "you_shall_not_pass", special_function = SF.SetAchievementComplete },
    [101145] = { time = 180, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101158] = { time = 240, special_function = SF.GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop } },
    [101977] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
    [101978] = { special_function = SF.AddToCache, data = { icon = Icon.Heli } }, -- Heli
    [101979] = { special_function = SF.AddToCache, data = { icon = Icon.Car } }, -- Van
}

EHI:ParseTriggers(triggers, "Escape")