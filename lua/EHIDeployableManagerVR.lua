---@class EHIDeployableManager
EHIDeployableManagerVR = EHIDeployableManager
EHIDeployableManagerVR.old_AddToCache = EHIDeployableManager.AddToCache
EHIDeployableManagerVR.old_LoadFromCache = EHIDeployableManager.LoadFromCache
EHIDeployableManagerVR.old_RemoveFromCache = EHIDeployableManager.RemoveFromCache
EHIDeployableManagerVR.old_UpdateAmount = EHIDeployableManager.UpdateAmount

---@param key string
---@param data { f: string, ehi_tracker: string, unit: UnitDeployable, tracker_type: string? }
function EHIDeployableManagerVR:ReturnLoadCall(key, data)
    if data.f then
        self[data.f](self, data.ehi_tracker, key, data.unit, data.tracker_type)
    else
        self:old_RemoveFromCache(key)
    end
end

---@param ehi_tracker string
---@param key string
---@param unit UnitDeployable
---@param tracker_type string?
function EHIDeployableManagerVR:AddToCache(ehi_tracker, key, unit, tracker_type)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { ehi_tracker = ehi_tracker, unit = unit, tracker_type = tracker_type, f = "AddToDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_AddToCache(ehi_tracker, key, unit, tracker_type)
end

---@param ehi_tracker string
---@param key string
function EHIDeployableManagerVR:LoadFromCache(ehi_tracker, key)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { ehi_tracker = ehi_tracker, f = "LoadFromDeployableCache" }, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_LoadFromCache(ehi_tracker, key)
end

---@param key string
function EHIDeployableManagerVR:RemoveFromCache(key)
    if key and self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, {}, callback(self, self, "ReturnLoadCall"), true)
        return
    end
    self:old_RemoveFromCache(key)
end

---@param key string
---@param data { amount: number, id: string, t_id: string }
function EHIDeployableManagerVR:ReloadDeployable(key, data)
    self:old_UpdateAmount(key, data.amount, data.id, data.t_id)
end

---@param key string
---@param amount number
---@param id string
---@param t_id string
function EHIDeployableManagerVR:UpdateAmount(key, amount, id, t_id)
    if self._trackers:IsLoading() then
        self._trackers:AddToLoadQueue(key, { amount = amount, id = id, t_id = t_id }, callback(self, self, "ReloadDeployable"))
        return
    end
    self:old_UpdateAmount(key, amount, id, t_id)
end