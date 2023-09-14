---@class MissionAssetsManager
---@field _get_asset_by_id fun(self: self, id: string): table?

if EHI:CheckLoadHook("MissionAssetsManager") then
    return
end

---@return boolean?
function MissionAssetsManager:IsEscapeDriverAssetUnlocked()
    local asset = self:_get_asset_by_id("safe_escape")
    return asset and asset.unlocked
end