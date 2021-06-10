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
    EHI:Log("[PrePlanningManager] IsAssetBought; asset_id: " .. tostring(asset_id))
    EHI:Log("Preplan dump:")
    if type(self._finished_preplan) == "table" then
        EHI:Log("self._finished_preplan:")
        _G.PrintTable(self._finished_preplan)
        EHI:Log("-----------")
        for key, value in pairs(self._finished_preplan) do
            if type(value) == "table" then
                EHI:Log("key: " .. tostring(key))
                EHI:Log("value: ")
                _G.PrintTable(value)
            else
                EHI:Log(string.format("self._finished_preplan[%s]: %s", tostring(key), tostring(value)))
            end
        end
    else
        EHI:Log("self._finished_preplan: " .. tostring(self._finished_preplan))
    end
    if type(preplan) == "table" then
        EHI:Log("preplan:")
        _G.PrintTable(preplan)
        EHI:Log("-----------")
        for key, value in pairs(preplan) do
            if type(value) == "table" then
                EHI:Log("key: " .. tostring(key))
                EHI:Log("value: ")
                _G.PrintTable(value)
            else
                EHI:Log(string.format("self._finished_preplan[%s]: %s", tostring(key), tostring(value)))
            end
        end
    else
        EHI:Log("preplan: " .. tostring(preplan))
    end
    if self._finished_preplan then
        local placed = self._finished_preplan[2]
        for _, assets in pairs(placed or {}) do
            if assets[asset_id] then
                EHI:Log("Asset is bought")
                return true
            end
        end
    elseif preplan and preplan[asset_id] then
        EHI:Log("Asset is bought")
        return true
    end
    EHI:Log("Asset is not bought")
    return false
end