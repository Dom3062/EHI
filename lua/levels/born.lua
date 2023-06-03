local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local trigger_icon_all = { Icon.Defend }
local triggers = {
    [101034] = { id = "MikeDefendTruck", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101033, waypoint = { position_by_element = EHI:GetInstanceElementID(100483, 1350), remove_vanilla_waypoint = EHI:GetInstanceElementID(100483, 1350) } },
    [101038] = { id = "MikeDefendTruck", special_function = SF.PauseTracker },
    [101070] = { id = "MikeDefendTruck", special_function = SF.UnpauseTracker },

    [101535] = { id = "MikeDefendGarage", class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101532, waypoint = { position_by_element = 101445, remove_vanilla_waypoint = 101445 } },
    [101534] = { id = "MikeDefendGarage", special_function = SF.UnpauseTracker },
    [101533] = { id = "MikeDefendGarage", special_function = SF.PauseTracker },

    [101048] = { time = 12, id = "ObjectiveDelay", icons = { Icon.Wait } }
}
if EHI:IsClient() then
    triggers[101034].additional_time = 80
    triggers[101034].random_time = 10
    triggers[101034].special_function = SF.UnpauseTrackerIfExists
    triggers[101034].icons = trigger_icon_all
    triggers[101034].delay_only = true
    triggers[101034].class = TT.InaccuratePausable
    triggers[101034].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(101034, triggers[101034])
    triggers[101535].additional_time = 90
    triggers[101535].random_time = 30
    triggers[101535].special_function = SF.UnpauseTrackerIfExists
    triggers[101535].icons = trigger_icon_all
    triggers[101535].delay_only = true
    triggers[101535].class = TT.InaccuratePausable
    triggers[101535].synced = { class = TT.Pausable }
    EHI:AddSyncTrigger(101535, triggers[101535])
end

---@type ParseAchievementTable
local achievements =
{
    born_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101048] = { status = "objective", class = TT.AchievementStatus },
            [101001] = { status = "finish", special_function = SF.SetAchievementStatus },
            [101022] = { status = "objective", special_function = SF.SetAchievementStatus },
            [100728] = { status = "defend", special_function = SF.SetAchievementStatus }, -- Truck
            [101589] = { status = "defend", special_function = SF.SetAchievementStatus }, -- Garage
            [101446] = { status = "objective", special_function = SF.SetAchievementStatus }, -- Garage done
            [102777] = { special_function = SF.SetAchievementComplete },
            [102779] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, nil, trigger_icon_all)
EHI:ShowLootCounter({ max = 9 })

local tbl =
{
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small/001 (Bunker)
    [101086] = { remove_vanilla_waypoint = 101562, child_units = { 100776, 101226, 101469, 101472, 101473 } },

    -- Inside the bunker
    -- Grenades
    [100776] = { f = "IgnoreChildDeployable" },
    [101226] = { f = "IgnoreChildDeployable" },
    [101469] = { f = "IgnoreChildDeployable" },
    -- Ammo
    [101472] = { f = "IgnoreChildDeployable" },
    [101473] = { f = "IgnoreChildDeployable" }
}
EHI:UpdateUnits(tbl)

---@type MissionDoorTable
local MissionDoor =
{
    -- Workshop
    [Vector3(-3798.92, -1094.9, -6.52779)] = 101580,

    -- Safe with a bike mask
    [Vector3(1570.02, -419.693, 185.724)] = EHI:GetInstanceElementID(100007, 4850),
    [Vector3(1570.02, -419.693, 585.724)] = EHI:GetInstanceElementID(100007, 5350)
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)
EHI:AddXPBreakdown({
    objective =
    {
        biker_mike_in_the_trailer = { amount = 3000, times = 1 },
        biker_seat_collected = 6000,
        biker_skull_collected = 8000,
        biker_exhaust_pipe_collected = 2000,
        biker_engine_collected = 3000,
        biker_tools_collected = 2000,
        biker_cola_collected = 1000,
        biker_help_mike_garage = 3000,
        biker_defend_mike = { amount = 3000, times = 3 },
        escape = 2500
    },
    loot_all = 500
})