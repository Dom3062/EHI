local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
---@type ParseTriggerTable
local triggers = {
    [101034] = { id = "MikeDefendTruck", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033, waypoint = { data_from_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100483, 1350) }, hint = Hints.Defend },
    [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
    [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

    [101535] = { id = "MikeDefendGarage", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532, waypoint = { data_from_element_and_remove_vanilla_waypoint = 101445 }, hint = Hints.Defend },
    [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
    [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker },

    [101048] = { time = 12, id = "ObjectiveDelay", icons = { Icon.Wait }, hint = Hints.Wait }
}
if EHI.IsClient then
    triggers[101034].client = { time = 80, random_time = 10, special_function = SF.UnpauseTrackerIfExists }
    triggers[101535].client = { time = 90, random_time = 30, special_function = SF.UnpauseTrackerIfExists }
end

---@type ParseAchievementTable
local achievements =
{
    born_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101048] = { status = Status.Objective, class = TT.Achievement.Status },
            [101001] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [101022] = { status = Status.Objective, special_function = SF.SetAchievementStatus },
            [100728] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Truck
            [101589] = { status = Status.Defend, special_function = SF.SetAchievementStatus }, -- Garage
            [101446] = { status = Status.Objective, special_function = SF.SetAchievementStatus }, -- Garage done
            [102777] = { special_function = SF.SetAchievementComplete },
            [102779] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetLoadSniperTrackers() then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill = 3,
        mayhem_or_above = 4
    })
    other[100015] = { chance = 20, time = 1 + 5 + 30, on_fail_refresh_t = 30, on_success_refresh_t = 20 + 5 + 30, id = "Snipers", class = TT.Sniper.Loop, sniper_count = sniper_count }
    other[100517] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 20%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +20%
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    if EHI.IsClient then
        managers.ehi_assault:AddAssaultNumberSyncCallback(function(assault_number, in_assault)
            if assault_number <= 0 or (assault_number == 1 and in_assault) then
                return
            end
            managers.ehi_tracker:AddTracker({
                id = "Snipers",
                from_sync = true,
                count = EHISniperBase._alive_count,
                on_fail_refresh_t = 30,
                on_success_refresh_t = 20 + 5 + 30,
                sniper_count = sniper_count,
                class = TT.Sniper.Loop
            })
        end)
    end
end
if EHI:GetHudlistAndListOption("right_list", "show_loot") then
    -- Disables crates inside the clubhouse as potentional loot
    local tbl = {}
    local f = { f = "IgnorePotentionalCarry" }
    for i = 1850, 4550, 300 do
        tbl[EHI:GetInstanceUnitID(100045, i)] = f
    end
    EHI.Unit:UpdateHudlistUnitsNoCheck(tbl)
end
EHI.TrackerUtils.Hudlist:AddAssaultCallbackForSniperItem(1, "end", "born")

managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")
EHI.Mission:ParseTriggers({ mission = triggers, achievement = achievements, other = other,
    assault =
    {
        diff_load_sync = function(self, assault_number, in_assault)
            if self.ConditionFunctions.IsStealth() then
                return
            elseif assault_number <= 0 or (assault_number == 1 and in_assault) then
                self._assault:SetDiff(0.5)
            else
                self._assault:SetDiff(0.75)
            end
        end
    } }, nil, { Icon.Defend })
EHI:ShowLootCounter({ max = 9 }, { element = EHI:GetInstanceElementID(100268, 1350), present_timer = 0 }) -- 4 weapons + 5 cocaine
EHI.Unit:UpdateUnits({
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small/001 (Bunker)
    [101086] = { remove_vanilla_waypoint = 101562, child_units = { 100776, 101226, 101469, 101472, 101473 } }
})
EHI.Unit:UpdateUnitsNoCheck({
    -- Inside the bunker
    -- Grenades
    [100776] = { f = "IgnoreChildDeployable" },
    [101226] = { f = "IgnoreChildDeployable" },
    [101469] = { f = "IgnoreChildDeployable" },
    -- Ammo
    [101472] = { f = "IgnoreChildDeployable" },
    [101473] = { f = "IgnoreChildDeployable" }
})
EHI:SetMissionDoorData({
    -- Workshop
    [101312] = 101580,

    -- Safe with a bike mask
    [EHI:GetInstanceUnitID(100026, 4850)] = EHI:GetInstanceElementID(100007, 4850),
    [EHI:GetInstanceUnitID(100026, 5350)] = EHI:GetInstanceElementID(100007, 5350)
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "biker_mike_in_the_trailer", times = 1 },
        {
            random =
            {
                seat =
                {
                    { amount = 6000, name = "biker_seat_collected" }
                },
                skull =
                {
                    { amount = 8000, name = "biker_skull_collected" }
                },
                exhaust_pipe =
                {
                    { amount = 2000, name = "biker_exhaust_pipe_collected" }
                },
                engine =
                {
                    { amount = 3000, name = "biker_engine_collected" }
                },
                tools =
                {
                    { amount = 2000, name = "biker_tools_collected" }
                },
                cola =
                {
                    { amount = 1000, name = "biker_cola_collected" },
                },
                garage =
                {
                    { amount = 3000, name = "biker_help_mike_garage" }
                }
            }
        },
        { amount = 3000, name = "biker_defend_mike" },
        { escape = 2500 }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    random =
                    {
                        min =
                        {
                            exhaust_pipe = true,
                            engine = true,
                            tools = true
                        },
                        max =
                        {
                            seat = true,
                            skull = true,
                            engine = true,
                            cola = true
                        }
                    },
                    biker_defend_mike = { min_max = 3 }
                },
                loot_all = { max = 9 }
            }
        }
    }
})