local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local deal = { Icon.Car, Icon.Goto }
local delay = 4 + 356/30
local start_chance = 15 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    -- Hard + Very Hard
    start_chance = 10
elseif ovk_and_up then
    -- OVERKILL+
    start_chance = 5
end
local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, Icon.PCHack }, flash_times = 1, class = TT.Chance }
local triggers = {
    [101587] = { time = 30 + delay, id = "DealGoingDown", icons = deal },
    [101588] = { time = 40 + delay, id = "DealGoingDown", icons = deal },
    [101589] = { time = 50 + delay, id = "DealGoingDown", icons = deal },
    [101590] = { time = 60 + delay, id = "DealGoingDown", icons = deal },
    [101591] = { time = 70 + delay, id = "DealGoingDown", icons = deal },

    [102891] = { id = "CodeChance", special_function = SF.RemoveTracker },

    [101825] = CodeChance, -- First hack
    [102016] = CodeChance, -- Second and Third Hack
    [102121] = { time = 10, id = "Escape", icons = { Icon.Escape } },

    [103163] = { time = 1.5 + 25, random_time = 10, id = "Faint", icons = { "hostage", Icon.Wait } },

    [102866] = { time = 5, id = "GotCode", icons = { Icon.Wait } },

    [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance }
}

local achievements =
{
    [100698] = { special_function = SF.Trigger, data = { 1006981, 1006982 } },
    [1006981] = { id = "man_2", class = TT.AchievementStatus, difficulty_pass = ovk_and_up, special_function = SF.RemoveTriggerAndShowAchievement },
    [1006982] = { id = "man_3", class = TT.AchievementStatus, special_function = SF.RemoveTriggerAndShowAchievement },

    [103963] = { id = "man_2", special_function = SF.SetAchievementFailed },
    [103957] = { id = "man_3", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers(triggers, achievements)
EHI:ShowAchievementLootCounter({
    achievement = "man_4",
    max = 10,
    exclude_from_sync = true,
    triggers =
    {
        [103989] = { special_function = SF.IncreaseProgress }
    }
})
if EHI:GetOption("show_achievement") then
    EHI:AddLoadSyncFunction(function(self)
        if EHI.ConditionFunctions.IsStealth() then
            self:AddAchievementStatusTracker("man_3")
        end
        -- Achievement count used planks on windows, vents, ...
        -- There are total 49 positions and 10 planks
        self:SetTrackerProgress("man_4", 49 - self:CountInteractionAvailable("stash_planks"))
    end)
end

local tbl =
{
    -- Saws
    [102034] = { remove_vanilla_waypoint = true, waypoint_id = 102303 },
    [102035] = { remove_vanilla_waypoint = true, waypoint_id = 102301 },
    [102040] = { remove_vanilla_waypoint = true, waypoint_id = 101837 },
    [102041] = { remove_vanilla_waypoint = true, waypoint_id = 101992 }
}

EHI:UpdateUnits(tbl)