local EHI = EHI
if EHI._hooks.PrePlanningManager then
	return
else
	EHI._hooks.PrePlanningManager = true
end

local preplan_reserved = nil
local preplan_voted = nil

local _f_on_execute_preplanning = PrePlanningManager.on_execute_preplanning
function PrePlanningManager:on_execute_preplanning(...)
    if self:has_current_level_preplanning() then
        preplan_reserved = EHI:DeepClone(self._reserved_mission_elements)
        local winners = self:get_current_majority_votes()
        if winners then
            preplan_voted = {}
            for _, data in pairs(winners) do
                local type, index = unpack(data)
                preplan_voted[self:get_mission_element_id(type, index)] = true
            end
        end
    end
    _f_on_execute_preplanning(self, ...)
end

function PrePlanningManager:IsAssetBought(asset_id)
    if self._finished_preplan then
        local voted = self._finished_preplan[1]
        for _, assets in pairs(voted or {}) do
            if assets[asset_id] then
                return true
            end
        end
        local reserved = self._finished_preplan[2]
        for _, assets in pairs(reserved or {}) do
            if assets[asset_id] then
                return true
            end
        end
    elseif preplan_reserved and preplan_reserved[asset_id] then
        return true
    elseif preplan_voted and preplan_voted[asset_id] then
        return true
    end
    return false
end