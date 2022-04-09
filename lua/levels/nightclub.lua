local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    -- Time before escape is available
    [102808] = { time = 65 },
    [102811] = { time = 80 },
    [103591] = { time = 126 },
    [102813] = { time = 186 },
    [100797] = { time = 240 },
    [100832] = { time = 270 },

    -- Fire
    [101412] = { time = 300, id = "fire1", icons = { Icon.Fire }, class = TT.Warning },
    [101453] = { time = 300, id = "fire2", icons = { Icon.Fire }, class = TT.Warning },

    -- Asset
    [103094] = { time = 20 + (40/3), id = "AssetLootDropOff", icons = { Icon.Car, Icon.LootDrop } },
    -- 20: Base Delay
    -- 40/3: Animation finish delay
    -- Total 33.33 s

    [104285] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(false, 25) -- Civilian kills do not count towards escape chance -> https://steamcommunity.com/app/218620/discussions/14/5487063042655462839/
end)

EHI:ParseTriggers(triggers, "Escape", Icon.CarEscape)