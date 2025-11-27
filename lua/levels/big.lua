local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_from_element = 104326 }, hint = Hints.Thermite },

    [105197] = { time = 45, id = "PickUpAPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning, hint = Hints.PickUpPhone, remove_on_alarm = true },
    [105219] = { id = "PickUpAPhone", special_function = SF.RemoveTracker },

    [103050] = { time = 60, id = "PickUpManagersPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning, hint = Hints.PickUpPhone, remove_on_alarm = true },
    [105248] = { id = "PickUpManagersPhone", special_function = SF.RemoveTracker },

    [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [104532] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint_f = function(self, trigger)
        if managers.game_play_central:IsMissionUnitDisabled(101289) then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.PCHack,
                position = self._mission:GetUnitPositionOrDefault(104586)
            })
        elseif managers.game_play_central:IsMissionUnitDisabled(106835) then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.PCHack,
                position = self._mission:GetUnitPositionOrDefault(103158)
            })
        else
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.PCHack,
                position = self._mission:GetUnitPositionOrDefault(105258)
            })
        end
    end, hint = Hints.Hack },
    [103179] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103198 }, hint = Hints.Hack },
    [103259] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103177 }, hint = Hints.Hack },
    [103590] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103196 }, hint = Hints.Hack },
    [103620] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103293 }, hint = Hints.Hack },
    [103671] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103311 }, hint = Hints.Hack },
    [103734] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103313 }, hint = Hints.Hack },
    [103776] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103323 }, hint = Hints.Hack },
    [103815] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103328 }, hint = Hints.Hack },
    [103903] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103335 }, hint = Hints.Hack },
    [103920] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103356 }, hint = Hints.Hack },
    [103936] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103361 }, hint = Hints.Hack },
    [103956] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103376 }, hint = Hints.Hack },
    [103974] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103397 }, hint = Hints.Hack },
    [103988] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103418 }, hint = Hints.Hack },
    [104014] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103445 }, hint = Hints.Hack },
    [104029] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103463 }, hint = Hints.Hack },
    [104051] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_from_unit = 103504 }, hint = Hints.Hack },

    -- Heli escape
    [104126] = { time = 23 + 1, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape },

    [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" }, hint = Hints.big_Piggy },
    [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" }, hint = Hints.big_Piggy },
    [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" }, hint = Hints.big_Piggy },

    [104783] = { time = 8, id = "Bus", icons = { Icon.Wait }, hint = Hints.Wait }
}
if EHI.IsClient then
    triggers[101605] = EHI:ClientCopyTrigger(triggers[105842], { time = 16.7 * 17 })
    local doesnotexists = {
        [101817] = true,
        [101819] = true,
        [101825] = true,
        [101826] = true,
        [101828] = true,
        [101829] = true
    }
    local multiplier = 16
    for i = 101812, 101833, 1 do
        if not doesnotexists[i] then
            triggers[i] = EHI:ClientCopyTrigger(triggers[105842], { time = 16.7 * multiplier })
            multiplier = multiplier - 1
        end
    end
end

---@type ParseAchievementTable
local achievements =
{
    bigbank_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            [1] = { time = 720, class = TT.Achievement.Base },
            [2] = { special_function = SF.RemoveTrigger, data = { 100107, 106140, 106150 } }
        },
        load_sync = function(self)
            self._unlockable:AddTimedAchievementTracker("bigbank_4", 720)
        end,
        preparse_callback = function(data)
            local trigger = { special_function = SF.Trigger, data = { 1, 2 } }
            for _, id in ipairs({ 100107, 106140, 106150 }) do
                data.elements[id] = trigger
            end
        end
    },
    cac_22 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [106250] = { special_function = SF.SetAchievementFailed },
            [106247] = { special_function = SF.SetAchievementComplete }
        },
        alarm_callback = function(dropin)
            if dropin or not managers.preplanning:IsAssetBought(106594) then -- C4 Escape
                return
            end
            managers.ehi_unlockable:AddAchievementStatusTracker("cac_22")
        end
    }
}
if TheFixes then
    local Preventer = TheFixesPreventer or {}
    if not Preventer.achi_matrix_with_lasers and achievements.cac_22.difficulty_pass then -- Fixed
        achievements.cac_22.cleanup_callback = managers.ehi_unlockable:AddTFCallback("cac_22", "EHI_BigBank_TheFixes")
    end
end

local sidejob =
{
    daily_helicopter =
    {
        elements = {},
        alarm_callback = function(dropin)
            if dropin or not managers.preplanning:IsAssetBought(104305) then -- Default Heli escape (Loud)
                return
            end
            local offset = managers.loot:GetSecuredBagsAmount()
            managers.ehi_unlockable:AddSHDailyProgressTracker("daily_helicopter", 16)
            managers.ehi_loot:AddAchievementListener({
                achievement = "daily_helicopter",
                counter = {
                    f = function(loot)
                        local secured = loot:GetSecuredBagsAmount() - offset
                        managers.ehi_tracker:SetProgress("daily_helicopter", secured)
                        if secured >= 16 then
                            managers.ehi_loot:RemoveListener("daily_helicopter")
                        end
                end }
            }, 0)
        end
    }
}

local other =
{
    -- "Silent Alarm 30s delay" does not delay first assault
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3487502671137130788/
    [100109] = EHI:AddAssaultDelay({ control = 30, trigger_once = true })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_once = true, sniper_count = 3 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:IsLootCounterVisible() then
    other[106328] = EHI:AddLootCounter2(function()
        -- 11 bags of money + 4 bags of gold
        EHI:ShowLootCounterNoChecks({ max = 15, client_from_start = true })
    end, { element = { 100233, 100008, 100020, 104531, 104545, 103405 } }, function(self)
        self:Trigger()
        self._loot:IncreaseLootCounterProgressMax(tweak_data.ehi.functions.GetNumberOfLootInADepositBoxesInWall({
            102305, 102306, 102311, 102313, 102315, 102316, 102363
        }))
        self._loot:SyncSecuredLoot()
    end, true)
    ---@param max integer
    local function IncreaseMax(max)
        managers.ehi_loot:IncreaseLootCounterProgressMax(max)
    end
    -- Deposit boxes in the vault (the amount is predetermined after spawn)
    -- There is no need to check if the wall of deposit boxes is visible because this is controlled by the mission script
    -- The only thing that is hooked is the amount set (they won't run if the wall is hidden)
    other[102418] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102419] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102421] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102422] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102425] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102426] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102440] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102442] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102445] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102446] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102447] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102448] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102449] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102450] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102452] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102453] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102455] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102456] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
    other[102457] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 3 }
    other[102459] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 4 }
    other[102460] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 5 }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sidejob = sidejob
})
EHI:ShowAchievementLootCounter({
    achievement = "bigbank_3",
    max = 16,
    show_finish_after_reaching_target = true
})

local tbl =
{
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101457] = { icons = { Icon.Door } },
    [104671] = { icons = { Icon.Door } },

    --units/payday2/equipment/gen_interactable_lance_huge/gen_interactable_lance_huge
    [105318] = { remove_vanilla_waypoint = 103700 },
    [105319] = { remove_vanilla_waypoint = 103702 },
    [105320] = { remove_vanilla_waypoint = 103704 },
    [105321] = { remove_vanilla_waypoint = 103705 }
}
if EHI:GetWaypointOption("show_waypoints_mission") then
    --units/payday2/props/gen_prop_construction_crane/gen_prop_construction_crane_arm
    tbl[105111] = { f = function(id, unit_data, unit)
        local t = { unit = unit }
        EHI.Trigger:AddWaypointToTrigger(104091, t)
        EHI.Trigger:AddWaypointToTrigger(104261, t)
        EHI.Trigger:AddWaypointToTrigger(104069, t)
    end }
end
EHI.Unit:UpdateUnits(tbl)
EHI:SetMissionDoorData({
    -- Server Room
    [104582] = { w_id = 103457, restore = true },
    [104584] = { w_id = 103461, restore = true },
    [104585] = { w_id = 103465, restore = true },

    -- Roof
    [100311] = { w_id = 101306, restore = true },
    [103322] = { w_id = 106362, restore = true },
    [105317] = { w_id = 106372, restore = true },
    [106336] = { w_id = 106382, restore = true }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "correct_pc_hack" },
        { amount = 4000, name = "timelock_done" },
        { amount = 10000, name = "fs_secured_required_bags" },
        { escape = {
            { amount = 8000, stealth = true, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() },
            { amount = 8000, loud = true }
        }}
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    correct_pc_hack = { min_max = 1 },
                    timelock_done = { min_max = 1 },
                    fs_secured_required_bags = { min_max = 1 }
                },
                bonus_xp = { min_max = 8000 },
                loot_all = { min = 4, max = 25 }
            }
        }
    }
})