local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [100107] = { time = 420, id = "trophy_longfellow", icons = { Icon.Trophy }, class = TT.Warning, condition = EHI:IsDifficultyOrAbove("overkill") }
}

EHI:ParseTriggers(triggers)