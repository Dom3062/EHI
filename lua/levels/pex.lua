local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local WT = EHI.Waypoints
local triggers = {
    [101392] = { time = 120, id = "FireEvidence", icons = { Icon.Fire }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },

    [101460] = { time = 18, id = "DoorBreach", icons = { "pd2_door" } },

    [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, Icon.Winch } }
}
for _, index in ipairs({ 5300, 6300, 7300 }) do
    triggers[EHI:GetInstanceElementID(100025, index)] = { time = 120, id = "ArmoryHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists --[[, waypoint = { position_by_element = EHI:GetInstanceElementID(100055, index), icon = Icon.PCHack, class = WT.Pausable } ]] }
    triggers[EHI:GetInstanceElementID(100026, index)] = { id = "ArmoryHack", special_function = SF.PauseTracker }
end
if EHI:IsClient() then
    triggers[100233] = { time = 20 + 4, id = "HeliEscape", icons = { Icon.Heli, Icon.Winch }, special_function = SF.AddTrackerIfDoesNotExist }
end
local DisableWaypoints =
{
    -- pex_evidence_room_1
    [EHI:GetInstanceElementID(100080, 13300)] = true, -- Defend
    [EHI:GetInstanceElementID(100084, 13300)] = true, -- Fix
    -- pex_evidence_room_2
    [EHI:GetInstanceElementID(100072, 14300)] = true, -- Defend
    [EHI:GetInstanceElementID(100079, 14300)] = true -- Fix
    -- Why they use 2 instances for one objective ???
}
--[[if EHI:MissionTrackersAndWaypointEnabled() then
    for _, index in ipairs({ 5300, 6300, 7300 }) do
        DisableWaypoints[EHI:GetInstanceElementID(100055, index)] = true -- Defend
        DisableWaypoints[EHI:GetInstanceElementID(100056, index)] = true -- Fix
    end
end]]

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowAchievementLootCounter({ -- Loot
    achievement = "pex_10",
    max = 6,
    show_loot_counter = true
})
EHI:ShowAchievementLootCounter({ -- Medals
    achievement = "pex_11",
    max = 7,
    triggers =
    {
        [103735] = { special_function = SF.IncreaseProgress }
    },
    load_sync = function(self)
        --[[
            There are total 12 places where medals can appears
            -- 11 places are on the first floor (6 randomly selected)
            -- last place is in the locker room (instance)
            Game sync all used places. When a medal is picked up, it is removed from the world
            and not synced to other drop-in players

            Can't use function "CountInteractionAvailable" because the medal in the locker room is not interactable first
            This is more accurate and reliable
        ]]
        self:SetTrackerProgressRemaining("pex_11", self:CountUnitAvailable("units/pd2_dlc_pex/props/pex_props_federali_chief_medal/pex_props_federali_chief_medal", 1) - 5)
    end
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "mex3_found_rfid_tag", stealth = true },
        { amount = 3000, name = "mex3_found_cells", stealth = true },
        { amount = 4000, name = "mex3_armory_opened", stealth = true },
        { amount = 4000, name = "mex3_handcuffs_cut", stealth = true },
        { amount = 5000, name = "mex3_hajrudin_found_his_car", stealth = true },
        { amount = 2000, name = "stealth_escape" },
        { amount = 5000, name = "mex3_evidence_opened", loud = true },
        { amount = 5000, name = "mex3_evidence_burned", loud = true },
        { amount = 4000, name = "mex3_armory_opened", loud = true },
        { amount = 5000, name = "mex3_hajrudin_found_his_car", loud = true },
        { amount = 4000, name = "heli_arrival", loud = true },
        { amount = 3000, name = "loud_escape" }
    },
    loot_all = 1000
})