local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local heli_delay = 26 + 6
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers =
{
    [103569] = { time = 25, id = "CFOFall", icons = { "hostage", Icon.Goto }, hook_element = 100438 }
}
local triggers = {
    [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, Icon.Goto } },

    [101343] = { time = 30, id = "KeypadReset", icons = { Icon.Loop }, waypoint = { position_by_element = EHI:GetInstanceElementID(100179, 9100) } },

    [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 100475 } },
    [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 103163 } }
}
if EHI:IsClient() then
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local other =
{
    [100479] = { time = 30 + 2 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = EHI:GetOption("show_assault_delay_tracker") }
}

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
if OVKorAbove then
    EHI:ShowAchievementLootCounter({
        achievement = "dah_8",
        max = 12,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "diamondheist_big_diamond"
        },
        triggers =
        {
            [102259] = { id = "dah_8", special_function = SF.SetAchievementComplete },
            [102261] = { id = "dah_8", special_function = SF.IncreaseProgress }
        },
        sync_only = true
    })
    EHI:AddOnAlarmCallback(function()
        managers.ehi:SetAchievementFailed("dah_8")
    end)
    EHI:AddLoadSyncFunction(function(self)
        if managers.game_play_central:GetMissionDisabledUnit(100950) then -- Red Diamond
            self:IncreaseTrackerProgressMax("LootCounter", 1)
        end
        self:SyncSecuredLoot()
    end)
end
local DisableWaypoints =
{
    [101368] = true -- Drill waypoint for vault with red diamond
}
if EHI:MissionTrackersAndWaypointEnabled() then
    DisableWaypoints[104882] = true -- Defend during loud escape
    DisableWaypoints[103163] = true -- Exclamation mark during loud escape
end
for i = 2500, 2700, 200 do
    DisableWaypoints[EHI:GetInstanceElementID(100011, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100036, i)] = true -- Fix
end
EHI:DisableWaypoints(DisableWaypoints)

EHI:ShowLootCounter({
    max = 8,
    triggers =
    {
        [101019] = { special_function = SF.IncreaseProgressMax } -- Red Diamond
    },
    -- Difficulties Very Hard or lower can load sync via EHI as the Red Diamond does not spawn on these difficulties
    no_sync_load = OVKorAbove
})