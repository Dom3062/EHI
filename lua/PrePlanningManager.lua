local EHI = EHI
if EHI._hooks.PrePlanningManager then
	return
else
	EHI._hooks.PrePlanningManager = true
end

local preplan = nil

local _f_on_execute_preplanning = PrePlanningManager.on_execute_preplanning
function PrePlanningManager:on_execute_preplanning()
    preplan = EHI:DeepClone(self._reserved_mission_elements)
    _f_on_execute_preplanning(self)
end

function PrePlanningManager:IsAssetBought(asset_id)
    if self._finished_preplan then
        local placed = self._finished_preplan[2]
        for _, assets in pairs(placed or {}) do
            if assets[asset_id] then
                return true
            end
        end
    elseif preplan and preplan[asset_id] then
        return true
    end
    return false
end