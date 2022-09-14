local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    [100428] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 }, -- 20s
    [100430] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427 } -- 30s
}
local triggers = {
    [100225] = { time = 5 + 5 + 22, id = Icon.Heli, icons = Icon.HeliEscape },
    -- 5 = Base Delay
    -- 5 = Delay when executed
    -- 22 = Heli door anim delay
    -- Total: 32 s
    [100224] = { id = 100926, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100926 } },
    [101858] = { id = 101854, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 101854 } },

    -- Bugged because of retarted use of ENABLED and ElementTimerTrigger
    [101240] = { time = 540, id = "CokeTimer", icons = { { icon = Icon.Loot, color = Color.red } }, class = TT.Warning },
    [101282] = { id = "CokeTimer", special_function = SF.RemoveTracker }
}
local achievements =
{
    [101228] = { time = 210, id = "pig_2", class = TT.Achievement, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) },
    [100788] = { id = "pig_2", special_function = SF.SetAchievementComplete }
}
local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
if EHI:GetOption("show_achievement") and EHI:IsAchievementLocked("pig_7") then
    for _, index in ipairs(start_index) do
        achievements[EHI:GetInstanceElementID(100024, index)] = { time = 5, id = "pig_7", class = TT.Achievement }
        achievements[EHI:GetInstanceElementID(100039, index)] = { id = "pig_7", special_function = SF.SetAchievementFailed } -- Hostage blew out
        achievements[EHI:GetInstanceElementID(100027, index)] = { id = "pig_7", special_function = SF.SetAchievementComplete } -- Hostage saved
    end
else
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100024, index)] = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning }
        triggers[EHI:GetInstanceElementID(100039, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage blew out
        triggers[EHI:GetInstanceElementID(100027, index)] = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage saved
    end
end

if Network:is_client() then
    triggers[100426] = { id = "HeliDropDrill", icons = Icon.HeliDropDrill, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 44, 54 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers, achievements)