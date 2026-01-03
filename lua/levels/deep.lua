---@class EHIFuelCheckingTracker : EHIPausableTracker
local EHIFuelCheckingTracker = class(EHIPausableTracker)
---@param delay number
function EHIFuelCheckingTracker:AddDelay(delay)
    self:SetTime(self._time + delay)
end

---@class EHIFuelCheckingWaypoint : EHIPausableWaypoint
local EHIFuelCheckingWaypoint = class(EHIPausableWaypoint)
EHIFuelCheckingWaypoint.AddDelay = EHIFuelCheckingTracker.AddDelay

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@param self EHIMissionElementTrigger
---@param trigger ElementTrigger
local function TransferWP(self, trigger)
    local index = managers.game_play_central:IsMissionUnitDisabled(EHI:GetInstanceUnitID(100087, 9340)) and 9590 or 9340
    local vanilla_wp = EHI:GetInstanceElementID(100019, index)
    self._cache.TransferPosition = self._cache.TransferPosition or self._mission:GetElementPositionOrDefault(vanilla_wp)
    self._waypoints:AddWaypoint(trigger.id, {
        time = trigger.time,
        icon = trigger.element == 102438 and Icon.Wait or Icon.Defend,
        position = self._cache.TransferPosition,
        class = self._mission._TrackerToWaypoint[trigger.class or ""],
        remove_vanilla_waypoint = vanilla_wp
    })
end

---@type ParseTriggerTable
local triggers =
{
    [103053] = { id = "FuelChecking", icons = { Icon.Wait }, class_table = EHIFuelCheckingTracker, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, enabled)
        if not enabled then
            return
        end
        if self._tracking:Exists(trigger.id) then
            self._tracking:Unpause(trigger.id)
            return
        --[[elseif self:IsMissionElementDisabled(trigger.fix_wp) or self:IsMissionElementEnabled(trigger.success_sequence) then
            trigger.time = 5]] -- Broken for some reason
        elseif CF.IsStealth() then
            trigger.time = 40
        else
            trigger.time = 60
        end
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
        self:CreateTracking()
    end), fix_wp = EHI:GetInstanceElementID(100068, 4650), success_sequence = EHI:GetInstanceElementID(100016, 4650), waypoint = { class_table = EHIFuelCheckingWaypoint, data_from_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100067, 4650) }, hint = Hints.Wait },
    [103055] = { id = "FuelChecking", special_function = SF.PauseTracker },
    [103070] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; loud
    [103071] = { id = "FuelChecking", special_function = SF.RemoveTracker }, -- Checking done; stealth

    [102454] = { id = "FuelTransferStealth", icons = { Icon.Oil }, class = TT.Pausable, condition_function = CF.IsStealth, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 102438, waypoint_f = TransferWP, hint = Hints.FuelTransfer },
    [102439] = { id = "FuelTransferStealth", special_function = SF.PauseTracker },
    [102656] = { id = "FuelTransferLoud", icons = { Icon.Oil }, class = TT.Pausable, condition_function = CF.IsLoud, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 101686, waypoint_f = TransferWP, hint = Hints.FuelTransfer },
    [101684] = { id = "FuelTransferLoud", special_function = SF.PauseTracker },

    [101050] = { special_function = EHI.Trigger:RegisterCustomSF(function(self, ...)
        self._tracking:Call("FuelChecking", "AddDelay", 20) -- Add 20s because stealth trigger is now disabled
        self._tracking:Remove("FuelTransferStealth") -- ElementTimer won't proceed because alarm has been raised, remove it from the screen
        self:UpdateWaypointTriggerIcon(103053, Icon.Defend) -- Cops can turn off the checking device, change the waypoint icon to reflect this
    end), trigger_once = true } -- Alarm
}
if EHI.IsClient then
    triggers[102454].client = { time = 60, random_time = 20, special_function = SF.UnpauseTrackerIfExists }
    triggers[102656].client = { time = 100, random_time = 30, special_function = SF.UnpauseTrackerIfExists }
    triggers[101685] = { time = 80, id = "FuelTransferLoud", icons = { Icon.Oil }, special_function = SF.SetTrackerAccurate, waypoint_f = TransferWP, hint = Hints.FuelTransfer }
    triggers[104930] = { time = 20, id = "FuelTransferLoud", icons = { Icon.Oil }, special_function = SF.SetTrackerAccurate, waypoint_f = TransferWP, hint = Hints.FuelTransfer }
end

---@type ParseAchievementTable
local achievements =
{
    deep_9 =
    {
        elements =
        {
            [104591] = { max = 10, class = TT.Achievement.Progress }, -- Stealth approach (cannot be achieved in loud)
            [101704] = { special_function = SF.SetAchievementFailed }, -- Alarm
            [104408] = { special_function = SF.IncreaseProgress },
            [104442] = { special_function = SF.IncreaseProgress },
            [104456] = { special_function = SF.IncreaseProgress }
        },
        preparse_callback = function(data)
            local trigger = data.elements[104408]
            for i = 104410, 104428, 1 do
                data.elements[i] = trigger
            end
        end
    },
    deep_12 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100610] = { max = 3, set_color_bad_when_reached = true, class = TT.Achievement.Progress, condition_function = CF.IsLoud, trigger_once = true },
            [EHI:GetInstanceElementID(100225, 9840)] = { special_function = SF.IncreaseProgress }, -- 1st pump used
            [EHI:GetInstanceElementID(100228, 9840)] = { special_function = SF.IncreaseProgress }, -- 2nd pump used
            [EHI:GetInstanceElementID(100229, 9840)] = { special_function = SF.IncreaseProgress }, -- 3rd pump used
            [EHI:GetInstanceElementID(100283, 9840)] = { special_function = SF.SetAchievementFailed }, -- 4th pump used
            [EHI:GetInstanceElementID(100467, 9840)] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_once = true, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ShowAchievementLootCounter({
    achievement = "deep_11",
    job_pass = managers.job:current_job_id() == "deep",
    max = 4,
    silent_max = 8,
    triggers =
    {
        [101084] = EHI:AddCustomCode(function(self)
            self._trackers:IncreaseProgressMax("deep_11", 4)
            self._trackers:CallFunction("deep_11", "SetStarted")
        end),
        [102062] = { special_function = SF.CallCustomFunction, f = "SetFailed2" }
    },
    add_to_counter = true,
    start_silent = true,
    load_sync = function(self)
        if managers.preplanning:IsAssetBought(102474) then
            self:RunTrigger(101084)
        end
        self._loot:SyncSecuredLootInAchievement("deep_11")
    end,
    loot_counter_load_sync = function(self)
        if managers.preplanning:IsAssetBought(102474) then
            self._loot:IncreaseLootCounterProgressMax(4)
        end
        self._loot:SyncSecuredLoot()
    end,
    show_loot_counter = true
})

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:SetMissionDoorData({
    -- Arrival
    [103576] = 104170,

    -- Relax
    [103575] = 104171,

    -- Locker
    [101911] = 104174
})
local total_xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                texas4_found_the_perfect_sample = { min = 0 },
                texas4_found_the_good_sample = { max = 0 }
            },
            loot_all = { max = 8 }
        }
    }
}
EHI:AddXPBreakdown({
    plan =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "texas4_found_server_room" },
                { amount = 1000, name = "texas4_accessed_security_computer" },
                { amount = 1000, name = "pc_hack" },
                { amount = 1000, name = "texas4_updated_docking_schedule" },
                { amount = 3000, name = "texas4_found_the_purest_sample" },
                { amount = 2000, name = "texas4_found_the_good_sample" },
                { amount = 500, name = "texas4_entered_the_processing_area" },
                { amount = 500, name = "texas4_crane_lowered" },
                { amount = 6000, name = "texas4_pipeline_connected" },
                { amount = 6000, name = "texas4_pumping_complete" },
                { amount = 500, name = "texas4_entered_the_drilling_tower" },
                { amount = 500, name = "texas4_lasers_disabled" },
                { amount = 500, name = "texas4_fan_jammed" },
                { amount = 4000, name = "texas4_disabled_gas_can" },
                { amount = 1000, name = "texas4_disabled_blowout_preventor" },
                { amount = 4000, name = "texas4_build_pressure" },
                { amount = 500, name = "texas4_drill_activated" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "texas4_found_server_room" },
                { amount = 1000, name = "texas4_servers_destroyed" },
                { amount = 1000, name = "pc_hack" },
                { amount = 3000, name = "texas4_found_the_purest_sample" },
                { amount = 2000, name = "texas4_found_the_good_sample" },
                { amount = 500, name = "texas4_entered_the_processing_area" },
                { amount = 500, name = "texas4_crane_lowered" },
                { amount = 6000, name = "texas4_pipeline_connected" },
                { amount = 6000, name = "texas4_pumping_complete" },
                { amount = 500, name = "texas4_entered_the_drilling_tower" },
                { amount = 6000, name = "texas4_gabriel_killed" },
                { amount = 1000, name = "texas4_disabled_blowout_preventor" },
                { amount = 4000, name = "texas4_build_pressure" },
                { amount = 500, name = "texas4_drill_activated" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        }
    }
})