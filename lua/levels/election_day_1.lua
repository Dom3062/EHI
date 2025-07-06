local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
---@type ParseAchievementTable
local achievements =
{
    bob_8 =
    {
        elements =
        {
            [100012] = { class = TT.Achievement.Status },
            [101248] = { special_function = SF.SetAchievementComplete },
            [100469] = { special_function = SF.SetAchievementFailed }
        }
    },
    slakt_1 =
    {
        elements =
        {
            [100003] = { time = 60, class = TT.Achievement.Base },
            [104896] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100150] = EHI:AddAssaultDelay({}) -- Another first assault delay botched by phalanx spawn group -> see ´logic_link_065´ MissionScriptElement 104924
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104287] = { id = "Snipers", count = 2, class = TT.Sniper.LoopBuffer } -- Set count 2 so no negative number in the tracker
    local AddToRespawnFromDeath = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:CallFunction("Snipers", "AddToRespawnFromDeath", trigger.element, trigger.time)
    end)
    other[104258] = { special_function = AddToRespawnFromDeath, element = 103995, time = 45 }
    other[104259] = { special_function = AddToRespawnFromDeath, element = 103995, time = 60 }
    other[104260] = { special_function = AddToRespawnFromDeath, element = 103995, time = 75 }
    other[104267] = { special_function = AddToRespawnFromDeath, element = 103996, time = 45 }
    other[104268] = { special_function = AddToRespawnFromDeath, element = 103996, time = 60 }
    other[104269] = { special_function = AddToRespawnFromDeath, element = 103996, time = 75 }
    other[104275] = { special_function = AddToRespawnFromDeath, element = 104290, time = 45 }
    other[104276] = { special_function = AddToRespawnFromDeath, element = 104290, time = 60 }
    other[104277] = { special_function = AddToRespawnFromDeath, element = 104290, time = 75 }
    other[104283] = { special_function = AddToRespawnFromDeath, element = 104295, time = 45 }
    other[104284] = { special_function = AddToRespawnFromDeath, element = 104295, time = 60 }
    other[104285] = { special_function = AddToRespawnFromDeath, element = 104295, time = 75 }
end

EHI.Mission:ParseTriggers({
    achievement = achievements,
    other = other
})

local tbl =
{
    --units/payday2/props/off_prop_eday_shipping_computer/off_prop_eday_shipping_computer
    [101210] = { remove_vanilla_waypoint = 101887, ignore_visibility = true, restore_waypoint_on_done = true },
    [101289] = { remove_vanilla_waypoint = 101910, ignore_visibility = true, restore_waypoint_on_done = true },
    [101316] = { remove_vanilla_waypoint = 101913, ignore_visibility = true, restore_waypoint_on_done = true },
    [101317] = { remove_vanilla_waypoint = 101914, ignore_visibility = true, restore_waypoint_on_done = true },
    [101318] = { remove_vanilla_waypoint = 101922, ignore_visibility = true, restore_waypoint_on_done = true },
    [101320] = { remove_vanilla_waypoint = 101923, ignore_visibility = true, restore_waypoint_on_done = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 2000, name = "ed1_tag_right_truck", optional = true },
                { escape = 6000 }
            },
            total_xp_override = { params = { min_max = {} } }
        },
        loud =
        {
            objectives =
            {
                { amount = 12000, name = "ed1_hack_1" },
                { amount = 12000, name = "ed1_hack_2", optional = true }
            },
            total_xp_override = { params = { min_max = {} } }
        }
    }
})