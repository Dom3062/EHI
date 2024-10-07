---@class EHIDeployableManager
EHIDeployableManagerVR = EHIDeployableManager
EHIDeployableManagerVR.old_AddToDeployableCache = EHIDeployableManager.AddToDeployableCache
EHIDeployableManagerVR.old_LoadFromDeployableCache = EHIDeployableManager.LoadFromDeployableCache
EHIDeployableManagerVR.old_RemoveFromDeployableCache = EHIDeployableManager.RemoveFromDeployableCache

---@param key string
---@param data table
function EHIDeployableManagerVR:ReturnLoadCall(key, data)
    self[data.f](self, data.type, key, data.unit, data.tracker_type)
end

---@param type string
---@param key string
---@param unit Unit
---@param tracker_type string
function EHIDeployableManagerVR:AddToDeployableCache(type, key, unit, tracker_type)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { type = type, unit = unit, tracker_type = tracker_type, f = "AddToDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_AddToDeployableCache(type, key, unit, tracker_type)
end

---@param type string
---@param key string
function EHIDeployableManagerVR:LoadFromDeployableCache(type, key)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { type = type, f = "LoadFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_LoadFromDeployableCache(type, key)
end

---@param type string
---@param key string
function EHIDeployableManagerVR:RemoveFromDeployableCache(type, key)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { type = type, f = "RemoveFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_RemoveFromDeployableCache(type, key)
end