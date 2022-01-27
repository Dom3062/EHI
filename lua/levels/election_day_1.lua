local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers =
{
    [100003] = { time = 60, id = "slakt_1", class = TT.Achievement },
    [100012] = { id = "bob_8", class = TT.AchievementNotification },
    [101248] = { id = "bob_8", special_function = SF.SetAchievementComplete },
    [100469] = { id = "bob_8", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers(triggers)