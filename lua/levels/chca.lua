local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local escape_wp = { data_from_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100023, 11170) }
local vault_pickup_wp = { data_from_element_and_remove_vanilla_waypoint = 102690 }
---@type ParseTriggerTable
local triggers = {
    [103030] = { time = 19, id = "InsideManTalk", icons = { "pd2_talk" }, hint = Hints.Wait },

    -- Heli Extraction
    [101432] = { id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 101362, hint = Hints.Escape, waypoint = deep_clone(escape_wp) },

    [102571] = { additional_time = 10 + 15.25 + 0.5 + 0.2, random_time = 5, id = "WinchDrop", icons = Icon.HeliDropWinch, hint = Hints.brb_WinchDelivery },

    [102675] = { additional_time = 5 + 10 + 14, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.GetElementTimerAccurate, element = 102674, hint = Hints.Wait, waypoint = deep_clone(vault_pickup_wp) },

    [103269] = { time = 7 + 614/30, id = "BoatEscape", icons = Icon.BoatEscapeNoLoot, hint = Hints.Escape }
}
if EHI.Mission._SHOW_MISSION_TRACKERS_TYPE.cheaty then
    EHI:LoadTracker("EHICodesTracker")
    triggers[101073] = EHI:AddCustomCode(function(self)
        if self._cache.chca_C4Route or self._cache.chca_CodeUsed or self._cache.chca_CodeSeen then
            return
        end
        local paper_unit = managers.worlddefinition:get_unit(EHI:GetInstanceElementID(100000, 14470)) --[[@as UnitBase?]]
        if not paper_unit then
            return
        end
        local unit_damage = paper_unit:damage()
        local object = unit_damage and unit_damage._state and unit_damage._state.object
        if not object then
            return
        end
        local code = {}
        for i = 1, 4, 1 do
            local c = {}
            for j = 1, 10, 1 do
                c[j] = Idstring(string.format("g_%d_%d", i, j - 1)):key()
            end
            code[i] = c
        end
        self._trackers:AddTracker({
            id = "VaultCode",
            class = TT.Code
        })
        for i, code_body in ipairs(code) do
            for j, code_id in ipairs(code_body) do
                local body = object[code_id] or {}
                local visibility = body and body.set_visibility or {}
                if visibility[2] then -- If code is visible
                    self._trackers:CallFunction("VaultCode", "SetCodePart", i, tostring(j - 1), 4)
                    break
                end
            end
        end
        self._cache.chca_CodeSeen = true
    end, true) -- Spa first; Handprint second
    triggers[103761] = EHI:AddCustomCode(function(self)
        self._cache.chca_C4Route = true
        self._trackers:RemoveTracker("VaultCode")
    end)
    triggers[EHI:GetInstanceElementID(100023, 15470)] = EHI:AddCustomCode(function(self)
        self._cache.chca_CodeUsed = true
        self._trackers:RemoveTracker("VaultCode")
    end)
    triggers[100688] = triggers[101073] -- Handprint first; Spa second
end
if EHI.IsClient then
    local escape_wait_time = 90 -- Very Hard and below
    local vault_pickup_wait_time = 25 -- Normal and Hard
    if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.Mayhem) then -- Very Hard to Mayhem
        vault_pickup_wait_time = 40
    end
    if EHI:IsBetweenDifficulties(EHI.Difficulties.OVERKILL, EHI.Difficulties.Mayhem) then -- OVERKILL or Mayhem
        escape_wait_time = 120
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        escape_wait_time = 150
        vault_pickup_wait_time = 55
    end
    triggers[101432].client = { time = escape_wait_time, random_time = 30 }
    triggers[102675].client = { time = vault_pickup_wait_time, random_time = 15 }
    if ovk_and_up then -- OVK and up
        triggers[101456] = { time = 120, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape, waypoint = deep_clone(escape_wp) }
    end
    triggers[101366] = { time = 60, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape, waypoint = deep_clone(escape_wp) }
    triggers[101463] = { time = 45, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape, waypoint = deep_clone(escape_wp) }
    triggers[101367] = { time = 30, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape, waypoint = deep_clone(escape_wp) }
    triggers[101372] = { time = 15, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape, waypoint = deep_clone(escape_wp) }
    triggers[102678] = { time = 45, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate, hint = Hints.Wait, waypoint = deep_clone(vault_pickup_wp) }
    triggers[102679] = { time = 15, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate, hint = Hints.Wait, waypoint = deep_clone(vault_pickup_wp) }
end
EHI:AddEventListener("chca_Winch",
---@param self EHIMissionElementTrigger
---@param waypoint_id string
function(self, waypoint_id)
    local wp_defend = EHI:GetInstanceElementID(100070, 21220)
    self._waypoints:SetWaypointPosition(waypoint_id, self._mission:GetElementPositionOrDefault(wp_defend))
    managers.hud:SoftRemoveWaypoint2(wp_defend)
    managers.hud:SoftRemoveWaypoint2(wp_defend - 24) -- Interact (100046)
    self:RemoveEventListener("chca_Winch")
end)

local function chca_9_fail()
    managers.ehi_unlockable:SetAchievementFailed("chca_9")
    EHI:Unhook("chca_9_killed")
    EHI:Unhook("chca_9_killed_by_anyone")
end
---@type ParseAchievementTable
local achievements =
{
    chca_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            -- Players spawned
            [100264] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Guest Rooms (civilian mode)
            [102955] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Crew Deck
            [1] = { class = TT.Achievement.Status },
            [2] = { special_function = SF.CustomCode, f = function()
                local function check(_, data)
                    if data.variant ~= "melee" then
                        chca_9_fail()
                    end
                end
                Hooks:PostHook(StatisticsManager, "killed", "EHI_chca_9_killed", check)
                Hooks:PostHook(StatisticsManager, "killed_by_anyone", "EHI_chca_9_killed_by_anyone", check)
            end }
        },
        alarm_callback = chca_9_fail
    },
    chca_10 =
    {
        difficulty_pass = EHI:IsMayhemOrAbove(),
        elements =
        {
            [100264] = { max = 8, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, status_is_overridable = true }, -- Guest Rooms (civilian mode)
            [102955] = { max = 8, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, status_is_overridable = true }, -- Crew Deck
            [102944] = { special_function = SF.IncreaseProgress }, -- Bodybag thrown
            [103371] = { special_function = SF.SetAchievementFailed } -- Civie killed
        },
        failed_on_alarm = true
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 45 })
}
if EHI:CanShowAchievement("chca_12") and ovk_and_up then
    achievements.chca_12 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100041, 11770)] = { condition_function = EHI.ConditionFunctions.PlayingFromStart, class = TT.Achievement.Status },
            [103584] = { status = EHI.Const.Trackers.Achievement.Status.Finish, special_function = SF.SetAchievementStatus }
        }
    }
    local active_saws = 0
    local function chca_12(unit_id, unit_data, unit)
        unit:timer_gui():chca_12()
    end
    local function check(...)
        active_saws = active_saws + 1
        if active_saws > 1 then
            managers.ehi_unlockable:SetAchievementFailed("chca_12")
        end
    end
    local function saw_done()
        active_saws = active_saws - 1
    end
    function TimerGui:chca_12()
        Hooks:PostHook(self, "_start", string.format("EHI_saw_start_%s", self._ehi_key or self._unit:key()), check)
    end
    local tbl =
    {
        [100122] = { f = chca_12 },
        [100011] = { f = chca_12 },
        [100079] = { f = chca_12 },
        [100080] = { f = chca_12 }
    }
    EHI:UpdateInstanceUnitsNoCheck(tbl, 15470)
    local trigger = { special_function = SF.CustomCode, f = saw_done }
    other[EHI:GetInstanceElementID(100082, 15470)] = trigger
    other[EHI:GetInstanceElementID(100083, 15470)] = trigger
    other[EHI:GetInstanceElementID(100084, 15470)] = trigger
    other[EHI:GetInstanceElementID(100085, 15470)] = trigger
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 1,
        overkill_or_above = 2
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_once = true, single_sniper = sniper_count == 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101699] = { count = 0, id = "Snipers", special_function = SF.SetCounter }
end
if EHI:IsLootCounterVisible() then
    local units =
    {
        [EHI:GetInstanceElementID(100009, 15470)] = true
    }
    for i = 100017, 100020, 1 do
        units[EHI:GetInstanceUnitID(i, 15470)] = true
    end
    for i = 100028, 100030, 1 do
        units[EHI:GetInstanceUnitID(i, 15470)] = true
    end
    for i = 100034, 100041, 1 do
        units[EHI:GetInstanceUnitID(i, 15470)] = true
    end
    local LootLeftInVault = EHI.Trigger:RegisterCustomSF(function(self, ...)
        local destroyed = 0
        for unit_id, _ in pairs(units) do
            local unit = managers.worlddefinition:get_unit(unit_id) --[[@as UnitBase?]]
            if unit and unit.alive and unit:alive() then ---@diagnostic disable-line -- If the unit is alive, then players left it unbagged
                destroyed = destroyed + 1
            end
        end
        self._loot:DecreaseLootCounterProgressMax(destroyed)
    end)
    local C4Plan = EHI.Trigger:RegisterCustomSF(function(self, ...)
        local bags = 16
        if self._cache.chca_TeasetInMeetingRoom and not self._cache.chca_GlassDestroyed then
            bags = bags + 1
        end
        if not self._cache.chca_MinisafeMoneyBagFound then
            bags = bags + 1
        end
        self._loot:DecreaseLootCounterProgressMax(bags)
    end)
    other[100107] = EHI:AddLootCounter4(function(self, ...)
        EHI:ShowLootCounterNoChecks({
            max = 18, -- 16 money bags, teaset and 1 money bundle in a safe
            triggers =
            {
                [103761] = { special_function = C4Plan },
                [EHI:GetInstanceElementID(100065, 15470)] = { special_function = LootLeftInVault } -- Ink (Stealth) / Burn (Loud)
            },
            hook_triggers = true,
            client_from_start = true
        })
        if managers.game_play_central:IsMissionUnitEnabled(103818) then
            self._cache.chca_TeasetInMeetingRoom = true
        end
    end, nil, true)
    other[102751] = EHI:AddCustomCode(function(self)
        self._cache.chca_GlassDestroyed = true
    end)
    local MiniSafeMoneyBagFound = EHI:AddCustomCode(function(self)
        self._cache.chca_MinisafeMoneyBagFound = true
    end)
    other[101138] = MiniSafeMoneyBagFound
    other[101413] = MiniSafeMoneyBagFound
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local min_loot = EHI:GetValueBasedOnDifficulty({
    veryhard_or_below = 4,
    overkill = 8,
    mayhem = 8,
    deathwish_or_above = 12
})
local stealth_objectives =
{
    { amount = 2000, name = "china3_met_insider", additional_name = "china3_guest_entrance", optional = true },
    { amount = 2000, name = "ggc_gear_found", additional_name = "china3_guest_entrance", optional = true },
    { amount = 500, name = "china3_found_insider_info", additional_name = "china3_crew_deck_entrance", optional = true },
    { amount = 1000, name = "china3_found_lideng_or_xunkang" },
    { amount = 2000, name = "china3_found_lideng_safe" },
    { amount = 2000, name = "twh_safe_open" },
    { amount = 4000, name = "china3_found_xunkang", optional = true },
    { amount = 4000, name = "china3_bugged_meeting" },
    { amount = 2000, name = "china3_found_phone_number" },
    { amount = 2000, name = "china3_got_xunkang_hand" },
    { amount = 1000, name = "china3_guards_distracted" },
    { amount = 2000, name = "ggc_laser_disabled" },
    { amount = 1000, name = "vault_open" },
    { amount = 1000, name = "fs_secured_required_bags" },
    { amount = 2000, name = "china3_vault_empty" },
    { amount = 1000, name = "china3_lifeboat_lowered" },
    { escape_ghost_bonus_only = tweak_data.levels:GetLevelStealthBonus() }
}
local loud_objectives =
{
    { amount = 2000, name = "china3_met_insider", additional_name = "china3_guest_entrance", optional = true },
    { amount = 2000, name = "ggc_gear_found", additional_name = "china3_guest_entrance", optional = true },
    { amount = 500, name = "china3_found_insider_info", additional_name = "china3_crew_deck_entrance", optional = true },
    { amount = 2000, name = "china3_found_lideng_or_xunkang" },
    { amount = 500, name = "china3_found_lideng_safe" },
    { amount = 2000, name = "twh_safe_open" },
    { amount = 500, name = "china3_found_xunkang", optional = true },
    { amount = 500, name = "china3_glass_broken" },
    { amount = 500, name = "china3_glass_destroyed" },
    { amount = 4000, name = "china3_got_xunkang_hand" },
    { amount = 4000, name = "vault_found" },
    { amount = 500, name = "pc_hack" },
    { amount = 3000, name = "china3_firewall_disabled" },
    { amount = 3000, name = "rvd2_hacking_done" },
    { amount = 500, name = "vault_open" },
    { amount = 500, name = "fs_secured_required_bags" },
    { amount = 2000, name = "china3_vault_empty" },
    { amount = 500, name = "china3_signaled_heli" },
    { amount = 6000, name = "heli_arrival" }
}
local loud_c4_objectives =
{
    { amount = 2000, name = "china3_wall_exploded" },
    { amount = 9000, name = "saws_done" },
    { amount = 3000, name = "ggc_winch_set_up" },
    { amount = 6000, name = "china3_vault_out" },
    { amount = 5000, name = "china3_got_rid_of_police_heli" },
    { amount = 3000, name = "heli_arrival" },
    { amount = 1000, name = "china3_vault_secured" },
    { amount = 1000, name = "china3_boat_escape" }
}
local total_xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                china3_met_insider = { min = 0 },
                ggc_gear_found = { min = 0 },
                china3_found_insider_info = { max = 0 }
            },
            loot_all = { min = min_loot, max = 18 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        custom =
        {
            {
                name = "stealth",
                plan =
                {
                    objectives = stealth_objectives,
                    loot_all = 500,
                    total_xp_override = total_xp_override
                }
            },
            {
                name = "loud",
                plan =
                {
                    objectives = loud_objectives,
                    loot_all = 500,
                    total_xp_override = total_xp_override
                }
            },
            {
                name = "loud",
                additional_name = "china3_c4",
                plan =
                {
                    objectives = loud_c4_objectives,
                    loot_all = 500,
                    total_xp_override =
                    {
                        params =
                        {
                            min_max =
                            {
                                loot_all = { max = 1 }
                            }
                        }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "china3_most_xp",
                plan =
                {
                    objectives = loud_objectives,
                    loot_all = 500,
                    total_xp_override =
                    {
                        params =
                        {
                            min_max =
                            {
                                objectives =
                                {
                                    china3_met_insider = { min = 0 },
                                    ggc_gear_found = { min = 0 },
                                    china3_found_insider_info = { max = 0 }
                                },
                                loot_all = { max = 2 }
                            }
                        }
                    }
                },
                objectives_override =
                {
                    stop_at_inclusive_and_add_objectives =
                    {
                        stop_at = "rvd2_hacking_done",
                        add_objectives =
                        {
                            { amount = table.ehi_get_objectives_xp_amount(loud_c4_objectives), name = "china3_c4_route" }
                        }
                    }
                }
            }
        }
    }
})