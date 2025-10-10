---@class EHIPresentChance : EHITimedWarningChanceTracker
---@field super EHITimedWarningChanceTracker
local EHIPresentChance = class(EHITimedWarningChanceTracker)
function EHIPresentChance:SetChance(amount)
    EHIPresentChance.super.SetChance(self, amount)
    if amount <= 20 then
        self:StopTimer()
    end
end
local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local SetChanceWhenTrackerExists = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementLogicChanceOperator
    if self._trackers:Exists(trigger.merge_id) then
        self._trackers:SetChance(trigger.merge_id, element._values.chance)
    elseif self._trackers:Exists(trigger.id) then
        self._trackers:SetChance(trigger.id, element._values.chance)
    else
        trigger.chance = element._values.chance
        self:CreateTracking()
    end
end)
local chance = { id = "PresentDropChance", merge_id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class = TT.Chance, special_function = SetChanceWhenTrackerExists, hint = Hints.pines_Chance }
local PresentDropTimer = { "C_Vlad_H_XMas_Impossible", Icon.Wait }
local preload = {}
---@type ParseTriggerTable
local triggers = {
    [100109] = EHI:AddEndlessAssault(25),
    [100021] = EHI:AddEndlessAssault(180, "EndlessAssault2"),
    [101001] = { time = 1200, chance = 100, id = "PresentDrop", icons = { "C_Vlad_H_XMas_Impossible" }, class_table = EHIPresentChance, start_opened = true, hint = Hints.pines_ChanceReduction },
    [101002] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = {} },
    [101003] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = {} },
    [101004] = { time = 600, id = "PresentDrop", icons = PresentDropTimer, class = TT.Warning, hint = Hints.pines_ChanceReduction, special_function = SF.SetTimeOrCreateTracker, tracker_merge = {} },
    [101045] = { additional_time = 50, random_time = 10, id = "WaitTime", icons = { Icon.Heli, Icon.Wait }, hint = Hints.Wait },
    [100024] = { time = 23, id = "HeliSanta", icons = { Icon.Heli, "Other_H_None_Merry" }, trigger_once = true, hint = Hints.pines_Santa },
    [105102] = { time = 30, id = "HeliLoot", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootEscape },

    [101005] = chance,
    [101006] = chance,
    [101007] = chance,
    [101008] = chance
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    triggers[103707] = { time = 1800, id = "BulldozerSpawn", icons = { "heavy" }, class = TT.Warning, special_function = SF.SetTimeOrCreateTracker, hint = Hints.ScriptedBulldozer }
end
---@type ParseAchievementTable
local achievements =
{
    uno_9 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101471] = { max = 40, class = TT.Achievement.Progress },
            [104385] = { special_function = SF.IncreaseProgress }
        }
    }
}
if EHI.ModUtils:SWAYRMod_EscapeVehicleWillReturn() then
    table.insert(preload, { id = "HeliLootTakeOff", icons = Icon.HeliWait, class = TT.Warning, hint = Hints.LootTimed, hide_on_delete = true })
    ---@param self EHIMissionElementTrigger
    ---@param trigger ElementTrigger
    local function Waypoint(self, trigger)
        if self._waypoints:ReturnValue2(self._loot._id, "StartTimer", trigger.run.time, true) then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.run.time,
                icon = Icon.LootDrop,
                position = self._mission:GetElementPositionOrDefault(trigger.waypoint_id),
                remove_vanilla_waypoint = trigger.waypoint_id,
                restore_on_done = true,
                class = self.Waypoints.Warning
            })
        end
    end
    for i = 75, 675, 200 do
        local id = EHI:GetInstanceElementID(100042, i)
        triggers[id] = { id = "HeliLootTakeOff", run = { time = 80 + 2 }, waypoint_f = Waypoint, waypoint_id = id }
    end
end

local other = {}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    preload = preload
})
local waypoint_elements = {}
for i = 75, 675, 200 do
    table.insert(waypoint_elements, EHI:GetInstanceElementID(100028, i))
end
EHI:ShowLootCounter({ max_bags_for_level = { mission_xp = 8000, xp_per_bag_all = 2000 }, no_max = true }, { element = waypoint_elements, class = EHI.Waypoints.LootCounter.Timed })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    loot_all = 2000,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objective = true
            },
            max_level = true,
            max_level_bags_with_objective = true
        }
    }
})