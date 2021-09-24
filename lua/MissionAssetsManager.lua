if EHI._hooks.MissionAssetsManager then
    return
else
    EHI._hooks.MissionAssetsManager = true
end

function MissionAssetsManager:IsEscapeDriverAssetUnlocked()
    local asset = self:_get_asset_by_id("safe_escape")
    return asset and asset.unlocked
end