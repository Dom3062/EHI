---@class EHIDeployableManager
EHIDeployableManagerVR = EHIDeployableManager
EHIDeployableManagerVR.old_AddToDeployableCache = EHIDeployableManager.AddToDeployableCache
EHIDeployableManagerVR.old_LoadFromDeployableCache = EHIDeployableManager.LoadFromDeployableCache
EHIDeployableManagerVR.old_RemoveFromDeployableCache = EHIDeployableManager.RemoveFromDeployableCache
EHIDeployableManagerVR.old_UpdateDeployableAmount = EHIDeployableManager.UpdateDeployableAmount

---@param key string
---@param data { f: string, type: string, unit: UnitDeployable, tracker_type: string? }
function EHIDeployableManagerVR:ReturnLoadCall(key, data)
    if data.f then
        self[data.f](self, data.type, key, data.unit, data.tracker_type)
    else
        self:old_RemoveFromDeployableCache(key)
    end
end

---@param type string
---@param key string
---@param unit UnitDeployable
---@param tracker_type string?
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

---@param key string
function EHIDeployableManagerVR:RemoveFromDeployableCache(key)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, {}, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_RemoveFromDeployableCache(key)
end

---@param key string
---@param data { amount: number, id: string, t_id: string }
function EHIDeployableManagerVR:ReloadDeployable(key, data)
    self:old_UpdateDeployableAmount(key, data.amount, data.id, data.t_id)
end

---@param key string
---@param amount number
---@param id string
---@param t_id string
function EHIDeployableManagerVR:UpdateDeployableAmount(key, amount, id, t_id)
    if self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { amount = amount, id = id, t_id = t_id }, callback(self, self, "ReloadDeployable"))
        return
    end
    self:old_UpdateDeployableAmount(key, amount, id, t_id)
end