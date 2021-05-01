function PrePlanningManager:IsAssetBought(asset_id)
    EHI:Log("[PrePlanningManager] IsAssetBought; asset_id: " .. tostring(asset_id))
    if self._finished_preplan then
        local placed = self._finished_preplan[2]
        for _, assets in pairs(placed) do
            if assets[asset_id] then
                EHI:Log("Asset is bought")
                return true
            end
        end
    end
    EHI:Log("Asset is not bought")
    return false
end