local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in WankerCar
    [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = Icon.CarEscape },
    -- Wanker car
    [EHI:GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },

    [EHI:GetInstanceElementID(100358, 10130)] = { time = 1 + 210/30, id = "MayanDoorOpen", icons = { "pd2_door" } },

    [EHI:GetInstanceElementID(100016, 26980)] = { time = 180 + 2, id = "HeliEscape", icons = Icon.HeliEscape },

    [EHI:GetInstanceElementID(100007, 25580)] = { time = 6, id = "ThermiteWineCellarDoor1", icons = { Icon.Fire } },
    [EHI:GetInstanceElementID(100007, 25780)] = { time = 6, id = "ThermiteWineCellarDoor2", icons = { Icon.Fire } },

    [EHI:GetInstanceElementID(100026, 24580)] = { time = 26.5 + 5, id = "CarBurn", icons = { Icon.Car, Icon.Fire } },

    [EHI:GetInstanceElementID(100049, 5200)] = { time = 6, id = "ThermiteFrontGate", icons = { Icon.Fire } },

    [EHI:GetInstanceElementID(100016, 23480)] = { time = 45, id = "SafeHackStealth", icons = { Icon.Vault } }
}
if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100024, 26980)] = { time = 60 + 2, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100030, 26980)] = { time = 25 + 2, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100035, 26980)] = { time = 38 + 2, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100036, 26980)] = { time = 120 + 2, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTimeOrCreateTracker }
end
local DisableWaypoints =
{
    -- fex_saw_reinforced_door
    [EHI:GetInstanceElementID(100015, 27280)] = true, -- Defend
    [EHI:GetInstanceElementID(100068, 27280)] = true, -- Fix
    -- fex_safe
    [EHI:GetInstanceElementID(100029, 23480)] = true, -- Defend
    [EHI:GetInstanceElementID(100022, 23480)] = true -- Fix
}

---@type ParseAchievementTable
local achievements =
{
    fex_10 =
    {
        elements =
        {
            [100185] = { max = 21, class = TT.AchievementProgress, special_function = SF.AddAchievementToCounter }, -- Default spawn
            [102665] = { max = 21, class = TT.AchievementProgress, special_function = SF.AddAchievementToCounter }, -- Cave spawn
            [103553] = { special_function = SF.SetAchievementFailed }
        },
        load_sync = function(self)
            if EHI.ConditionFunctions.IsStealth() then
                EHI:ShowAchievementLootCounterNoCheck({
                    achievement = "fex_10",
                    max = 21
                })
                self._trackers:SetTrackerProgress("fex_10", managers.loot:GetSecuredBagsAmount())
            end
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 21 })
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "mex4_found_bulucs_office" },
                { amount = 1000, name = "mex4_found_inner_sanctum" },
                { amount = 1000, name = "mex4_discover_keycard_holder_mask_list" },
                { amount = 1000, name = "mex4_found_keycard" },
                { amount = 1000, name = "mex4_inner_sanctum_open" },
                { amount = 1000, name = "mex4_codex_room_open" },
                { amount = 10000, name = "mex4_bulucs_office_open" },
                { amount = 1000, name = "mex4_interacted_with_safe" },
                { amount = 2000, name = "mex4_contact_list_stolen" },
                { amount = 2000, name = "mex4_found_car_keys" },
                { amount = 2000, name = "mex4_car_escape" },
                { amount = 1000, name = "mex4_boat_escape" },
            },
            loot_all = { amount = 500, times = 21 }
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "mex4_found_bulucs_office" },
                { amount = 2000, name = "mex4_found_inner_sanctum" },
                { amount = 2000, name = "mex4_found_all_bomb_parts_hack_start" },
                { amount = 2000, name = "mex4_inner_sanctum_open_bomb" },
                { amount = 3000, name = "mex4_saw_placed" },
                { amount = 3000, name = "saw_done" },
                { amount = 4000, name = "mex4_bulucs_office_open" },
                { amount = 1000, name = "mex4_interacted_with_safe" },
                { amount = 1000, name = "mex4_contact_list_stolen_car_escape" },
                { amount = 1000, name = "mex4_turret_discovered_car_escape" },
                { amount = 3000, name = "mex4_turret_destroyed_car_escape" },
                { amount = 3000, name = "mex4_flare_lit_heli_escape" },
                { escape = 1000 }
            },
            loot_all = { amount = 500, times = 21 }
        }
    }
})