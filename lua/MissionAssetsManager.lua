---@class MissionAssetsManager
---@field _get_asset_by_id fun(self: self, id: string): table?
---@field get_money_spent fun(self: self): number
---@field get_unlocked_asset_ids fun(self: self, only_can_unlock: boolean?): table

if EHI:CheckLoadHook("MissionAssetsManager") then
    return
end

---@return boolean?
function MissionAssetsManager:IsEscapeDriverAssetUnlocked()
    local asset = self:_get_asset_by_id("safe_escape")
    return asset and asset.unlocked
end

local _f_sync_load = MissionAssetsManager.sync_load
function MissionAssetsManager:sync_load(...)
    _f_sync_load(self, ...)
    if self:IsEscapeDriverAssetUnlocked() then
        managers.ehi_tracker:RemoveTracker("EscapeChance")
    end
end