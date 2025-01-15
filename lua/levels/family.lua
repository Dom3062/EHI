local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local VanDelay = 475/30
local triggers = {
    [102611] = { time = 1, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [102612] = { time = 3, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [102613] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },

    [100750] = { time = 120 + 80 + VanDelay, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [101568] = { time = 20 + VanDelay, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101569] = { time = 40 + VanDelay, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101572] = { time = 60 + VanDelay, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101573] = { time = 80 + VanDelay, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape },

    ---units/payday2/vehicles/str_vehicle_van_family_jewels_4/str_vehicle_van_family_jewels_4/escape1_van
    [100752] = { time = 336/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_3/str_vehicle_van_family_jewels_3/escape2_van
    [100753] = { time = VanDelay, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape },
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_2/str_vehicle_van_family_jewels_2/escape3_van
    [100754] = { time = 375/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_5/str_vehicle_van_family_jewels_5/escape4_van
    [100755] = { time = 437/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    uno_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100108] = { status = Status.Secure, class = TT.Achievement.Status },
            [100022] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Alarm has been raised, defend the hostages until the escape vehicle arrives
            [101095] = { status = Status.Secure, special_function = SF.SetAchievementStatus }, -- Escape vehicle is here, secure the remaining bags
            [102206] = { special_function = SF.SetAchievementFailed },
            [102207] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local sidejob =
{
    daily_mortage =
    {
        elements =
        {
            [100108] = { special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
                local trophy = tweak_data.achievement.loot_cash_achievements.daily_mortage.secured
                self._trackers:AddTracker({
                    id = trigger.id,
                    max = trophy.total_amount,
                    icons = { EHI.Icons.Trophy },
                    class = TT.SideJob.Progress
                })
                self._loot:AddListener(trigger.id, function(loot)
                    local progress = loot:GetSecuredBagsTypeAmount(trophy.carry_id)
                    self._trackers:SetTrackerProgress(trigger.id, progress)
                    if progress >= trophy.total_amount then
                        self._loot:RemoveListener(trigger.id)
                    end
                end)
            end) }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetWaypointOption("show_waypoints_escape") then
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_4/str_vehicle_van_family_jewels_4/escape1_van
    other[101350] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101119 } }
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_3/str_vehicle_van_family_jewels_3/escape2_van
    other[101351] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101284 } }
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_2/str_vehicle_van_family_jewels_2/escape3_van
    other[101352] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101285 } }
    ---units/payday2/vehicles/str_vehicle_van_family_jewels_5/str_vehicle_van_family_jewels_5/escape4_van
    other[101353] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101286 } }
end
if EHI:IsLootCounterVisible() then
    other[100107] = EHI:AddLootCounter2(function()
        EHI:ShowLootCounterNoChecks({
            max = 18,
            max_random = 2,
            carry_data =
            {
                loot = true,
                no_loot = true
            },
            client_from_start = true
        })
    end)
end
if EHI:IsEscapeChanceEnabled() then
    other[102622] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 10)
    end)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 20, time = 1 + 30 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 30 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_once = true, sniper_count = 2 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

local min_bags = EHI:GetValueBasedOnDifficulty({
    normal = 4,
    hard = 6,
    veryhard = 10,
    overkill_or_above = 14
})
EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sidejob = sidejob
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 2000, stealth = true, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() },
            { amount = 2000, loud = true, escape_chance = { start_chance = 10, kill_add_chance = 5 } }
        }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = min_bags, max = 20 }, -- 18 diamonds + 2 money (random)
                bonus_xp = { min_max = 2000 } -- Escape
            }
        }
    }
})