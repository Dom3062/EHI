local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [100931] = { time = 23 },
    [104910] = { time = 24 },
    [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning }
}

local other =
{
    [100355] = EHI:AddAssaultDelay({ time = 35 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", Icon.HeliEscapeNoLoot)
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 300, name = "ff3_item_deployed" },
                { amount = 1000, name = "ff3_cocaine_placed" },
                { amount = 1000, name = "ff3_gold_secured" },
                { escape = 2000 }
            },
            total_xp_override =
            {
                objectives =
                {
                    ff3_item_deployed = { times = 5 },
                    ff3_cocaine_placed = { times = 8 },
                    ff3_gold_secured = { times = 8 }
                }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 8000, name = "pc_found" },
                { amount = 8000, name = "pc_hack" },
                { escape = 8000 }
            }
        }
    }
})