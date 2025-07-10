---@class run_9 : EHIAchievementUnlockTracker
---@field super EHIAchievementUnlockTracker
local run_9 = class(EHIAchievementUnlockTracker)
function run_9:pre_init(params)
    self._refresh_on_delete = true
    run_9.super.pre_init(self, params)
end

function run_9:SetFailed()
    self._refresh_on_delete = nil
    run_9.super.SetFailed(self)
end

function run_9:Refresh()
    self._text:stop()
    self._achieved_popup_showed = true
    self:SetTextColor(Color.green)
    self:SetStatusText("finish")
    self:AnimateBG()
    self:RemoveTrackerFromUpdate()
end

local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
---@class EHIGasTracker : EHITimedProgressTracker
---@field super EHITimedProgressTracker
EHIGasTracker = class(EHITimedProgressTracker)
EHIGasTracker._forced_icons = { Icon.Fire }
EHIGasTracker._forced_hint_text = Hints.run_Gas
function EHIGasTracker:FormatProgress()
    if self._max == 0 then
        return self._progress .. "/?"
    end
    return EHIGasTracker.super.FormatProgress(self)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
---@type ParseTriggerTable
local triggers = {
    [100377] = { time = 90, id = "ClearPickupZone", icons = { Icon.Wait }, class = TT.Warning, waypoint = { position_from_element_and_remove_vanilla_waypoint = 100372 }, hint = Hints.run_FinalZone },
    [101550] = { id = "ClearPickupZone", special_function = SF.RemoveTracker },

    -- Parking lot
    [102543] = { time = 6.5 + 8 + 4, id = "ObjectiveWait", icons = { Icon.Wait }, waypoint = { data_from_element_and_remove_vanilla_waypoint = 101356 }, hint = Hints.Wait },

    [101967] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { Icon.Heli, Icon.Escape }, waypoint = { data_from_element_and_remove_vanilla_waypoint = 100372, restore_on_done = true }, hint = Hints.friend_Heli },

    [102876] = { special_function = SF.Trigger, data = { 1028761, 1 } },
    [1028761] = { time = 60, id = "Gas1", icons = { Icon.Fire }, hint = Hints.Fire, tracker_merge = { id = "GasAmount", start_timer = true }, waypoint = { position_from_element_and_remove_vanilla_waypoint = 101290, restore_on_done = true } },
    [102875] = { special_function = SF.Trigger, data = { 1028751, 1 } },
    [1028751] = { time = 60, id = "Gas2", icons = { Icon.Fire }, hint = Hints.Fire, tracker_merge = { id = "GasAmount", start_timer = true }, waypoint = { position_from_element_and_remove_vanilla_waypoint = 101290, restore_on_done = true } },
    [102874] = { special_function = SF.Trigger, data = { 1028741, 1 } },
    [1028741] = { time = 60, id = "Gas3", icons = { Icon.Fire }, hint = Hints.Fire, tracker_merge = { id = "GasAmount", start_timer = true }, waypoint = { position_from_element_and_remove_vanilla_waypoint = 101290, restore_on_done = true } },
    [102873] = { special_function = SF.Trigger, data = { 1028731, 1 } },
    [1028731] = { time = 80, id = "Gas4", icons = { Icon.Fire, Icon.Escape }, hint = Hints.run_GasFinal, tracker_merge = { id = "GasAmount", start_timer = true }, waypoint = { icon = Icon.Escape, position_from_element_and_remove_vanilla_waypoint = 101290 } }
}
if EHI.Mission._SHOW_MISSION_TRACKERS then
    local SetProgressMax = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        if self._cache.ProgressMaxSet then
            return
        elseif self._trackers:CallFunction2(trigger.id, "SetProgressMax", trigger.max) then
            self._trackers:AddTracker({
                id = trigger.id,
                progress = 1,
                max = trigger.max,
                show_progress_on_finish = true,
                remove_on_max_progress = true,
                class = "EHIGasTracker"
            })
        end
        self._cache.ProgressMaxSet = true
    end)
    triggers[1] = { id = "GasAmount", special_function = SF.IncreaseProgress }
    triggers[2] = { special_function = SF.RemoveTrigger, data = { 102775, 102776, 102868, 2 } } -- Don't blink twice, just set the max once and remove the triggers
    triggers[100144] = { id = "GasAmount", class = "EHIGasTracker", show_progress_on_finish = true, remove_on_max_progress = true, trigger_once = true }
    triggers[100051] = { id = "GasAmount", special_function = SF.RemoveTracker } -- In case the tracker gets stuck for drop-ins
    triggers[102775] = { special_function = SF.Trigger, data = { 1027751, 2 } }
    triggers[1027751] = { max = 4, id = "GasAmount", special_function = SetProgressMax }
    triggers[102776] = { special_function = SF.Trigger, data = { 1027761, 2 } }
    triggers[1027761] = { max = 3, id = "GasAmount", special_function = SetProgressMax }
    triggers[102868] = { special_function = SF.Trigger, data = { 1028681, 2 } }
    triggers[1028681] = { max = 2, id = "GasAmount", special_function = SetProgressMax }
end

---@type ParseAchievementTable
local achievements =
{
    run_8 =
    {
        elements =
        {
            [102426] = { max = 8, class = TT.Achievement.Progress },
            [100658] = { special_function = SF.IncreaseProgress }
        }
    },
    run_9 =
    {
        elements =
        {
            [100120] = { time = 1800, class_table = run_9 },
            [100144] = { special_function = SF.SetAchievementFailed }
        }
    },
    run_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            [102426] = { class = TT.Achievement.Status },
            [100111] = { special_function = SF.SetAchievementFailed },
            [100664] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101486] = EHI:AddAssaultDelay({ trigger_once = true }), -- 30s
    [101406] = EHI:AddSniperSpawnedPopup(true),
    [103455] = EHI:AddSniperSpawnedPopup(true),
    [103575] = EHI:AddSniperSpawnedPopup(),
    [103576] = EHI:AddSniperSpawnedPopup(),
    [103577] = EHI:AddSniperSpawnedPopup(true),
    [100567] = EHI:AddSniperSpawnedPopup(true)
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local SetRespawnTime = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        local t = trigger.time
        if self._trackers:CallFunction2(id, "SetRespawnTime", t) then
            self._trackers:AddTracker({
                id = id,
                time = t,
                count_on_refresh = 1,
                class = TT.Sniper.TimedCount
            })
        end
    end)
    if EHI.IsHost then
        local element = managers.mission:get_element_by_id(103674) --[[@as ElementLogicChance?]]
        if element then
            element:add_trigger("EHITrigger", "success", function()
                managers.ehi_tracker:AddTracker({
                    id = "Snipers",
                    count_on_refresh = 1,
                    snipers_spawned = true,
                    class = TT.Sniper.TimedCount
                })
            end)
        end
    else
        other[103674] = { id = "Snipers", count_on_refresh = 1, class = TT.Sniper.TimedCount, trigger_once = true, snipers_spawned = true }
    end
    other[103671] = { time = 30, id = "Snipers", special_function = SetRespawnTime }
    other[103672] = { time = 45, id = "Snipers", special_function = SetRespawnTime }
    other[103673] = { time = 60, id = "Snipers", special_function = SetRespawnTime }
    other[103670] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local objectives =
{
    { amount = 4000, name = "heat_street_reached_crashsite" },
    { amount = 6000, name = "van_open" },
    { amount = 4000, name = "heat_street_reached_parking" },
    { amount = 6000, name = "heat_street_reached_hill" },
    { escape = 6000 }
}
if table.remove_key(EHI._cache, "street_new") then
    objectives[1].amount = 7500
    objectives[2].amount = 7500
    objectives[3].amount = 7500
    objectives[4].amount = 7500
    objectives[5].escape = 10000
end
EHI:AddXPBreakdown({
    objectives = objectives
})