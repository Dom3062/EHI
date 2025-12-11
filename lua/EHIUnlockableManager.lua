local EHI = EHI
---@class EHIUnlockableManager
local EHIUnlockableManager = {}
EHIUnlockableManager.GetAchievementIcon = EHI.GetAchievementIcon
---@param achievement_id string
---@param id string
function EHIUnlockableManager:AddTFCallback(achievement_id, id)
    local cleanup_callback = function()
        managers.mission:remove_global_event_listener(id)
    end
    managers.mission:add_global_event_listener(id, { "TheFixes_AchievementFailed" }, function(a_id)
        if a_id == achievement_id then
            self:SetAchievementFailed(achievement_id)
            managers.mission:remove_global_event_listener(id)
        end
    end)
    return cleanup_callback
end

---@param id string
---@param time_max number
function EHIUnlockableManager:AddTimedAchievementTracker(id, time_max)
    local t = time_max - math.max(managers.ehi_tracking._t, managers.ehi_tracker._t)
    if t > 0 then
        managers.ehi_tracker:AddTracker({
            id = id,
            time = t,
            icons = self:GetAchievementIcon(id),
            class = EHI.Trackers.Achievement.Base
        })
    end
end

---@param id string
---@param max number
---@param progress number?
---@param show_finish_after_reaching_target boolean?
---@param class_table EHITracker?
function EHIUnlockableManager:AddAchievementProgressTracker(id, max, progress, show_finish_after_reaching_target, class_table)
    managers.ehi_tracker:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class_table = class_table,
        class = EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param status string?
function EHIUnlockableManager:AddAchievementStatusTracker(id, status)
    managers.ehi_tracker:AddTracker({
        id = id,
        status = status,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Status
    })
end

---@param id string
---@param max number
---@param loot_counter_on_fail boolean?
---@param start_silent boolean?
function EHIUnlockableManager:AddAchievementLootCounter(id, max, loot_counter_on_fail, start_silent)
    managers.ehi_tracker:AddTracker({
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        loot_counter_on_fail = loot_counter_on_fail,
        start_silent = start_silent,
        loot_parent = managers.ehi_loot,
        class = EHI.Trackers.Achievement.LootCounter
    })
end

---@param id string
---@param max number
---@param show_finish_after_reaching_target boolean?
function EHIUnlockableManager:AddAchievementBagValueCounter(id, max, show_finish_after_reaching_target)
    managers.ehi_tracker:AddTracker({ -- `uno_1` achievement gets synced via `EHILootManager:CallSyncListeners()` callback
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = EHI.Trackers.Achievement.BagValue
    })
end

---@param id string
---@param progress number
---@param max number
function EHIUnlockableManager:AddAchievementKillCounter(id, progress, max)
    managers.ehi_tracker:AddTracker({ -- Both `ranc_9` and `ranc_11` achievements are local only, no need to sync
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param force boolean?
function EHIUnlockableManager:SetAchievementComplete(id, force)
    managers.ehi_tracker:CallFunction(id, "SetCompleted", force)
end

---@param id string
---@param silent_fail boolean?
function EHIUnlockableManager:SetAchievementFailed(id, silent_fail)
    managers.ehi_tracker:CallFunction(id, silent_fail and "SetFailedSilent" or "SetFailed")
end

---@param id string
---@param status string
function EHIUnlockableManager:SetAchievementStatus(id, status)
    managers.ehi_tracker:CallFunction(id, "SetStatus", status)
end

---@param id string
---@param max number
---@param progress number?
function EHIUnlockableManager:AddSHDailyProgressTracker(id, max, progress)
    managers.ehi_tracker:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = { EHI.Icons.Trophy },
        class = EHI.Trackers.SideJob.Progress
    })
end

---@param id string
---@param max1 number
---@param stat1 string
---@param progress1 number
---@param max2 number
---@param progress2 number
---@param stat2 string
function EHIUnlockableManager:AddEventTrackerWithBothObjectives(id, max1, progress1, stat1, max2, progress2, stat2)
    managers.ehi_tracker:AddTracker({
        id = id,
        counter =
        {
            { max = max1, progress = progress1, id = stat1 },
            { max = max2, progress = progress2, id = stat2 }
        },
        first_completion = true,
        icons = { EHI.Icons.Trophy },
        class = EHI.Trackers.Event.Group
    })
end

---@param id string
---@param stat string
---@param max number
---@param progress number
function EHIUnlockableManager:AddEventProgressTracker(id, stat, max, progress)
    managers.ehi_tracker:AddTracker({
        id = id,
        progress = progress,
        max = max,
        stat = stat,
        icons = { EHI.Icons.Trophy },
        class = EHI.Trackers.Event.Base
    })
end

return EHIUnlockableManager