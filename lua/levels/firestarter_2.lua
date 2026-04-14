local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
if EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission") then
    local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_mission_trackers", "show_waypoints_mission")
    for _, pc_id in ipairs({ 104170, 104175, 104349, 104350, 104351, 104352, 104354, 101455 }) do
        managers.mission:add_runned_unit_sequence_trigger(pc_id, "interact", function(unit)
            if show_tracker then
                managers.ehi_tracker:AddTracker({
                    id = tostring(pc_id),
                    time = 13,
                    icons = { Icon.PCHack },
                    remove_on_alarm = true,
                    hint = Hints.Hack
                })
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(tostring(pc_id), {
                    time = 13,
                    icon = Icon.PCHack,
                    position = EHI.Mission:GetUnitPositionOrDefault(pc_id),
                    remove_on_alarm = true
                })
            end
        end)
    end
end
EHI:SetMissionDoorData({
    -- Security doors
    [101671] = 101899,
    [101855] = 101834,
    [101867] = 101782,
    [102199] = 101783
})

---@type ParseAchievementTable
local achievement =
{
    the_wire =
    {
        elements =
        {
            [107124] = { max = 2, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, status_is_overridable = true },
            [104392] = { special_function = SF.IncreaseProgress },
            [107411] = { special_function = SF.SetAchievementFailed },
            [102355] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [104618] = EHI:AddAssaultDelay({ control = 30 + 1 + 5 + 30 })
}
if EHI:IsLootCounterVisible() then
    local Weapons = { 101473, 102717, 102718, 102720 }
    local OtherLoot = { 100739, 101779, 101804, 102711, 102712, 102713, 102714, 102715, 102716, 102721, 102723, 102725 }
    local FilterIsOk = { special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementFilter
        if element:_check_difficulty() then
            self._loot:IncreaseLootCounterProgress() -- Server secured
        end
    end) }
    local max = EHI:IsMayhemOrAbove() and 2 or 1
    local goat = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) and 1 or 0
    other[107124] = EHI:AddLootCounter2(function()
        local ef = tweak_data.ehi.functions
        local random_loot = ef.GetNumberOfVisibleWeapons(Weapons) + ef.GetNumberOfVisibleOtherLoot(OtherLoot)
        EHI:ShowLootCounterNoChecks({
            max = max + random_loot + goat,
            triggers =
            {
                [100249] = FilterIsOk, -- N-OVK
                [100251] = FilterIsOk -- MH+
            },
            hook_triggers = true
        })
    end, { element = { 105191, 102971 } }, function(self)
        local fence_door = managers.worlddefinition:get_unit(102077)
        if fence_door and fence_door:body("hitbox"):enabled() then -- If the metal fence in the evidence room is not opened, show loot counter
            self:Trigger()
        end
    end)
end
if EHI:GetLoadSniperTrackers() then
    other[102321] = { time = 30 + 1 + 5 + 30 + 45 + 45 + 120, id = "Snipers", class = TT.Sniper.TimedCountOnce }
    other[105713] = { time = 60, id = "Snipers", class = TT.Sniper.TimedCountOnce, special_function = SF.SetTimeOrCreateTracker }
    other[105716] = { time = 90, id = "Snipers", class = TT.Sniper.TimedCountOnce, special_function = SF.SetTimeOrCreateTracker }
    other[105717] = { time = 30, id = "Snipers", class = TT.Sniper.TimedCountOnce, special_function = SF.SetTimeOrCreateTracker }
    if EHI.IsClient then
        other[102177] = EHI:ClientCopyTrigger(other[102321], { time = 1 + 5 + 30 + 45 + 45 + 120, trigger_once = true })
        other[100973] = EHI:ClientCopyTrigger(other[102321], { time = 5 + 30 + 45 + 45 + 120 })
        other[101190] = EHI:ClientCopyTrigger(other[102321], { time = 30 + 45 + 45 + 120 })
        other[102078] = EHI:ClientCopyTrigger(other[102321], { time = 45 + 45 + 120 })
        other[102079] = EHI:ClientCopyTrigger(other[102321], { time = 45 + 120 })
        other[105718] = EHI:ClientCopyTrigger(other[105717], { time = 120 }, true)
    end
end
managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")
EHI.Unit:IgnoreInteractInHudlist(107208) -- Keycard out of the playable area, near main room area (with a lot of displays)

EHI.Mission:ParseTriggers({
    achievement = achievement,
    other = other,
    assault =
    {
        diff_load_sync = function(self, assault_number, in_assault)
            if self.ConditionFunctions.IsStealth() then
                return
            elseif assault_number <= 0 or (assault_number == 1 and in_assault) then
                self._assault:SetDiff(0.5)
            elseif (assault_number == 1 and not in_assault) or (assault_number == 2 and in_assault) then
                self._assault:SetDiff(0.75)
            else
                self._assault:SetDiff(1)
            end
        end
    }
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 6000, stealth = true, timer = 180 },
            { amount = 12000, stealth = true },
            { amount = 6000, loud = true, timer = 180 },
            { amount = 10000, loud = true }
        }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            escape =
            {
                loot_all = { max = 16 }
            }
        }
    }
})