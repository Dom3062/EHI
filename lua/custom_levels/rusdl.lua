local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local triggers = {
    [100114] = { time = 17 * 18, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite, waypoint = { position_from_element = 100119 } },
    [100138] = { time = 20, id = "ObjectiveWait", icons = { Icon.Wait }, hint = Hints.Wait }
}

EHI.Manager:ParseTriggers({ mission = triggers })
EHI:ShowLootCounter({ max = 20 }, { element = { 100166, 100178 } })