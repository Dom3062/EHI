local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local LootDropWP = Vector3(0, -341, 253)
local triggers = {
    [100107] = { time = 300, id = "sah_9", class = TT.Achievement, condition = ovk_and_up and show_achievement, exclude_from_sync = true },
    [101878] = { id = "sah_9", special_function = SF.SetAchievementComplete },

    [100643] = { time = 30, id = "CrowdAlert", icons = { Icon.Alarm }, class = TT.Warning },
    [100645] = { id = "CrowdAlert", special_function = SF.RemoveTracker },

    [101725] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape }, -- West
    [101845] = { time = 120 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape }, -- East

    [EHI:GetInstanceElementID(100004, 6200)] = { id = EHI:GetInstanceElementID(100013, 6200), special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = EHI:GetInstanceElementPosition(Vector3(-2950, 1750, 499.835), LootDropWP, Rotation(-180, -4.09812e-005, 3.58268e-012)) } }, -- West
    [EHI:GetInstanceElementID(100015, 6100)] = { id = EHI:GetInstanceElementID(100013, 6100), special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = EHI:GetInstanceElementPosition(Vector3(2950, 2400, 499.838), LootDropWP, Rotation(0, 0, -0)) } } -- East
}

if Network:is_client() then
    triggers[EHI:GetInstanceElementID(100030, 6100)] = { time = 113 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100033, 6100)] = { time = 107 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100034, 6100)] = { time = 47 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100035, 6100)] = { time = 17 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100030, 6200)] = { time = 113 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100033, 6200)] = { time = 107 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100034, 6200)] = { time = 47 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100035, 6200)] = { time = 17 + 24 + 5 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers(triggers)
EHI:AddOnAlarmCallback(function()
    managers.ehi:SetAchievementFailed("sah_9")
end)

local DisableWaypoints = {}
-- Hackboxes
-- 1-10
for i = 3900, 4800, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- 11-17
for i = 16950, 17550, 100 do
    DisableWaypoints[EHI:GetInstanceElementID(100016, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100042, i)] = true -- Fix
end
-- Office
for i = 18200, 19400, 600 do
    -- Drill
    -- No defend icon, drill icon is disabled after drill unit has been placed
    DisableWaypoints[EHI:GetInstanceElementID(100320, i)] = true -- Fix
    -- Computer
    -- No defend icon, computer icon is disabled after computer unit has been interacted with
    DisableWaypoints[EHI:GetInstanceElementID(100087, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)