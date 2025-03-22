local EHI = EHI
if EHI:CheckLoadHook("GageAssignmentManager") or _G.ch_settings then
    return
end

---@class GageAssignmentManager
---@field _progressed_assignments { [string]: number }
---@field _tweak_data GageAssignmentTweakData
---@field count_all_units fun(self: self): number
---@field count_active_units fun(self: self): number

local original =
{
    sync_load = GageAssignmentManager.sync_load,
    present_progress = GageAssignmentManager.present_progress
}

---@param self GageAssignmentManager
---@param picked_up number?
---@param client_sync_load boolean?
local function UpdateTracker(self, picked_up, client_sync_load)
    local max_units = self:count_all_units()
    picked_up = picked_up or self:GetCountOfRemainingPackages()
    if picked_up >= max_units then
        EHI:CallCallbackOnce(EHI.CallbackMessage.SyncGagePackagesCount, picked_up, max_units, client_sync_load)
    else
        EHI:CallCallback(EHI.CallbackMessage.SyncGagePackagesCount, picked_up, max_units, client_sync_load)
    end
end

function GageAssignmentManager:GetCountOfRemainingPackages()
    local max_units = self:count_all_units()
    local remaining = self:count_active_units() - 1
    return max_units - remaining
end

function GageAssignmentManager:present_progress(...)
    original.present_progress(self, ...)
    UpdateTracker(self)
end

function GageAssignmentManager:sync_load(...)
    original.sync_load(self, ...)
    -- Counting secured packages needs to be done manually as the function above is sometimes incorrect during sync for some very weird reason  
    -- Possible theory is that the packages were synced late than data from GageAssignmentManager
    local secured_packages = 0
    for _, secured in pairs(self._progressed_assignments or {}) do
        secured_packages = secured_packages + secured
    end
    UpdateTracker(self, secured_packages, true)
end

if not EHI:GetTrackerOption("show_gage_tracker") then
    return
end

if EHI:GetOption("gage_tracker_panel") == 1 then
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        managers.ehi_tracker:SetTrackerProgress("Gage", picked_up)
    end)
    EHI:AddOnSpawnedCallback(function()
        if managers.ehi_tracker:TrackerDoesNotExist("Gage") and EHI.GagePackagesSpawned then
            local progress = math.max(managers.gage_assignment:GetCountOfRemainingPackages() - 1, 0)
            local max = tweak_data.gage_assignment:get_num_assignment_units()
            if progress < max then
                managers.ehi_tracker:AddTracker({
                    id = "Gage",
                    icons = { "gage" },
                    progress = progress,
                    max = max,
                    hint = "gage",
                    class = EHI.Trackers.Progress
                })
            end
        end
    end)
else
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        if (client_sync_load and Global.statistics_manager.playing_from_start) or not EHI.GagePackagesSpawned then
            return
        end
        managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), tostring(picked_up) .. "/" .. tostring(max_units), "EHI_Gage")
    end)
    EHI:AddOnSpawnedCallback(function()
        if EHI.GagePackagesSpawned and EHI:IsPlayingFromStart() then
            local max = tweak_data.gage_assignment:get_num_assignment_units()
            managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), "0/" .. tostring(max), "EHI_Gage")
        end
    end)
end