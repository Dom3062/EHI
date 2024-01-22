local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers =
{
    [100975] = { time = 5, id = "C4Pipeline", icons = { Icon.C4 }, hint = Hints.Explosion },

    [102011] = { time = 5, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite },

    [101098] = { time = 5 + 7 + 2, id = "WalkieTalkie", icons = { Icon.Door }, hint = Hints.Wait },
    [100109] = { id = "WalkieTalkie", special_function = SF.RemoveTracker },

    [EHI:GetInstanceElementID(100209, 10450)] = { time = 3, id = "KeygenHack", icons = { Icon.Tablet }, hint = Hints.Hack },

    [103130] = { time = 10, id = "LocomotiveRefuel", icons = { Icon.Oil }, hint = Hints.FuelTransfer }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 50 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

local required_bags = 6
local bag_multiplier = 2
if EHI:IsMayhemOrAbove() then
    required_bags = 9
    bag_multiplier = 3
end
EHI:ShowLootCounter({
    max = required_bags + ((6 * bag_multiplier) + 8) -- (4 secondary wagons with 2 money bags); total 5 wagons, one is disabled
})