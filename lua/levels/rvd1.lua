local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, Icon.Goto }
local triggers = {
    [100778] = { time = 10 + 17 + 13 + 15 + 17, id = "DefendWait", icons = { Icon.Wait }, hint = Hints.Wait },

    --310/30 anim_crash_04; Waypoint ID 100490
    [100010] = { time = 8 + 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car, hint = Hints.rvd_Pink },
    --260/30 anim_crash_02; Waypoint ID 101196
    [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },
    --201/30 anim_crash_05; Waypoint ID 101201
    [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },
    --284/30 anim_crash_03; Waypoint ID 101138
    [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },

    [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [100207] = { time = 260/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTrackerIfEnabled, hint = Hints.LootEscape },
    [100209] = { time = 250/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTrackerIfEnabled, hint = Hints.LootEscape }
}
if EHI.IsClient then
    triggers[100753] = EHI:ClientCopyTrigger(triggers[100778], { time = 17 + 13 + 15 + 17 })
    triggers[100756] = EHI:ClientCopyTrigger(triggers[100778], { time = 13 + 15 + 17 })
    triggers[100757] = EHI:ClientCopyTrigger(triggers[100778], { time = 15 + 17 })
    triggers[100761] = EHI:ClientCopyTrigger(triggers[100778], { time = 17 })
    triggers[100169] = EHI:ClientCopyTrigger(triggers[100010], { time = 17 + 1 + 310/30 })
    triggers[100731] = EHI:ClientCopyTrigger(triggers[100727], { time = 18 + 8.5 + 30 + 25 + 375/30 })
    triggers[100716] = EHI:ClientCopyTrigger(triggers[100727], { time = 8.5 + 30 + 25 + 375/30 })
    triggers[100286] = EHI:ClientCopyTrigger(triggers[100727], { time = 30 + 25 + 375/30 })
    triggers[101065] = EHI:ClientCopyTrigger(triggers[100727], { time = 25 + 375/30 })
end

---@type ParseAchievementTable
local achievements =
{
    rvd_9 =
    {
        elements =
        {
            [100107] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [100839] = { special_function = SF.SetAchievementFailed },
            [100869] = { special_function = SF.SetAchievementComplete },
        }
    },
    rvd_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [100057] = { time = 60, class = TT.Achievement.Base, condition_function = EHI.ConditionFunctions.PlayingFromStart },
            [100247] = { special_function = SF.SetAchievementComplete }
        }
    }
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    if EHI:CanShowAchievement2("rvd_8", "show_achievements_weapon") then -- United We Heist
        EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
            if job == "rvd" and self:EHIHasPrimaryWeaponTypeEquipped("assault_rifle") and from_beginning then
                managers.ehi_unlockable:AddAchievementStatusTracker("rvd_8")
                local achievement_success = true
                local function fail()
                    achievement_success = false
                    managers.ehi_unlockable:SetAchievementFailed("rvd_8")
                    Hooks:RemovePostHook("EHI_rvd_8_shot_fired")
                    Hooks:RemovePostHook("EHI_rvd_8_register_melee_hit")
                end
                Hooks:PostHook(StatisticsManager, "shot_fired", "EHI_rvd_8_shot_fired", function(sm, data)
                    local name_id = data.name_id or data.weapon_unit:base():get_name_id()
                    if tweak_data:get_raw_value("weapon", name_id, "categories", 1) ~= "assault_rifle" then
                        fail()
                    end
                end)
                Hooks:PostHook(StatisticsManager, "register_melee_hit", "EHI_rvd_8_register_melee_hit", fail)
                EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success) ---@param success boolean
                    if success and achievement_success then
                        managers.hud:custom_ingame_popup_text("SAVED", "Progress Saved", "C_Bain_H_ReservoirDogs_United")
                        managers.job:set_memory("ehi_rvd_8", true)
                    end
                end)
            end
        end)
    end
    if EHI:CanShowAchievement2("rvd_12", "show_achievements_melee") then -- "Close Shave" achievement
        EHI:AddOnSpawnedExtendedCallback(function(self, job, level, from_beginning)
            if job == "rvd" then
                self:EHIAddAchievementTrackerFromStat("rvd_12")
            end
        end)
    end
end


local other =
{
    [100179] = EHI:AddAssaultDelay({ control = 1 + 9.5 + 11 + 1 })
}
if EHI:IsLootCounterVisible() then
    other[100107] = EHI:AddLootCounter2(function()
        EHI:ShowLootCounterNoChecks({ max = 6, client_from_start = true })
    end, { element = { 101542, 100260, 100305, 100306 } })
    other[100037] = EHI:AddCustomCode(function(self)
        self._loot:SecuredMissionLoot() -- Secured diamonds at Mr. Blonde or in a Van
    end)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 3 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 2 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    -- Mr. Pink
    other[101105] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100490 } }
    other[101104] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101196 } }
    other[101106] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101201 } }
    other[101102] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101138 } }
    -- Escape
    local ShowWP = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, enabled)
        if enabled then
            self:_parse_vanilla_waypoint_trigger(trigger)
            managers.hud:add_waypoint("EscapeWP", trigger.data)
        end
    end)
    other[100207] = { special_function = ShowWP, data = { icon = Icon.Car, position_from_element = 101029 } } -- drive_in001
    other[100208] = { special_function = ShowWP, data = { icon = Icon.Car, position_from_element = 100276 } } -- drive_in003
    other[100209] = { special_function = ShowWP, data = { icon = Icon.Car, position_from_element = 100532 } } -- drive_in002
    other[101066] = { special_function = SF.CustomCode, f = function()
        managers.hud:remove_waypoint("EscapeWP") -- Removes EHI Escape WP once the van is ready, vanilla waypoints are dynamic based on how much secured loot you have
    end }
end
EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "rvd1_defended_warehouse" },
        { amount = 4000, name = "rvd1_escorted_pink" },
        { amount = 1500, name = "saw_done" }
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
                    saw_done = { max = 4 }
                },
                loot_all = { min = 1, max = 6 }
            }
        }
    }
})