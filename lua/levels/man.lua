local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local deal = { "pd2_car", "pd2_goto" }
local delay = 4 + 356/30
local start_chance = 15 -- Normal
if EHI:IsBetweenDifficulties("hard", "very_hard") then
    -- Hard + Very Hard
    start_chance = 10
elseif ovk_and_up then
    -- OVERKILL+
    start_chance = 5
end
local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, "wp_hack" }, flash_times = 1, class = TT.Chance }
local triggers = {
    [100698] = { special_function = SF.Trigger, data = { 1006981, 1006982 } },
    [1006981] = { id = "man_2", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, special_function = SF.RemoveTriggerAndShowAchievement },
    [1006982] = { id = "man_3", class = TT.AchievementNotification, special_function = SF.RemoveTriggerAndShowAchievement },
    [101587] = { time = 30 + delay, id = "DealGoingDown", icons = deal },
    [101588] = { time = 40 + delay, id = "DealGoingDown", icons = deal },
    [101589] = { time = 50 + delay, id = "DealGoingDown", icons = deal },
    [101590] = { time = 60 + delay, id = "DealGoingDown", icons = deal },
    [101591] = { time = 70 + delay, id = "DealGoingDown", icons = deal },

    [102891] = { id = "CodeChance", special_function = SF.RemoveTracker },

    [101825] = CodeChance, -- First hack
    [102016] = CodeChance, -- Second and Third Hack
    [102121] = { time = 10, id = "Escape", icons = { Icon.Escape } },

    [103163] = { time = 1.5 + 25, random_time = 10, id = "Faint", icons = { "hostage", "faster" }, class = TT.Inaccurate },

    [102866] = { time = 5, id = "GotCode", icons = { "faster" } },

    [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance },

    [103989] = { id = "man_4", special_function = SF.IncreaseProgress },

    [103963] = { id = "man_2", special_function = SF.SetAchievementFailed },
    [103957] = { id = "man_3", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievement = "man_4",
    max = 10,
    exclude_from_sync = true,
    no_counting = true
})
EHI:AddLoadSyncFunction(function(self)
    -- Achievement count used planks on windows, vents, ...
    -- There are total 49 positions and 10 planks
    self:SetTrackerProgressRemaining("man_4", 49 - self:CountInteractionAvailable("stash_planks"))
    if EHI.ConditionFunctions.IsStealth() then
        self:AddAchievementNotificationTracker("man_3")
    end
end)

local function man_WP(instance, unit_id, unit_data, unit)
    if unit_id == 102034 then
        unit:timer_gui():RemoveVanillaWaypoint(102303)
    elseif unit_id == 102035 then
        unit:timer_gui():RemoveVanillaWaypoint(102301)
    elseif unit_id == 102040 then
        unit:timer_gui():RemoveVanillaWaypoint(101837)
    else -- 102041
        unit:timer_gui():RemoveVanillaWaypoint(101992)
    end
end

local tbl =
{
    -- Saws
    [102034] = { f = man_WP },
    [102035] = { f = man_WP },
    [102040] = { f = man_WP },
    [102041] = { f = man_WP }
}

EHI:UpdateUnits(tbl)