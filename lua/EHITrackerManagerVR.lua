local EHI = EHI
---@class EHITrackerManager
EHITrackerManagerVR = EHITrackerManager
EHITrackerManagerVR.old_PreloadTracker = EHITrackerManager.PreloadTracker
EHITrackerManagerVR.old_AddLaserTracker = EHITrackerManager.AddLaserTracker
EHITrackerManagerVR.old_RemoveLaserTracker = EHITrackerManager.RemoveLaserTracker
function EHITrackerManagerVR:CreateWorkspace()
    self._x, self._y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
    self._scale = EHI:GetOption("vr_scale") --[[@as number]]
    self._is_loading = true
    self._load_callback = {}
end

function EHITrackerManagerVR:SetPanel(panel)
    self._panel = panel
    self._is_loading = false
    for key, queue in pairs(self._load_callback) do
        if queue.table then
            for _, q in ipairs(queue.table) do
                q.f(key, q.data)
            end
        else
            queue.f(key, queue.data)
        end
    end
    self._load_callback = nil
end

function EHITrackerManagerVR:IsLoading()
    return self._is_loading
end

---@param key string
---@param data table
---@param f function
---@param add boolean?
function EHITrackerManagerVR:AddToLoadQueue(key, data, f, add)
    local load_cbk = self._load_callback[key]
    local new_cbk = { data = data, f = f }
    if add then
        if load_cbk then
            if load_cbk.table then
                table.insert(load_cbk.table, new_cbk)
            else
                self._load_callback[key] = { table = {
                    load_cbk,
                    new_cbk
                }}
            end
        else
            self._load_callback[key] = { table = { new_cbk } }
        end
    elseif load_cbk then -- Update the existing data when it already exists
        load_cbk.data = data
        load_cbk.f = f
    else
        self._load_callback[key] = new_cbk
    end
end

---@param params ElementTrigger
function EHITrackerManagerVR:PreloadTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_PreloadTracker"))
        return
    end
    self:old_PreloadTracker(params)
end

---@param key string
---@param data ElementTrigger
function EHITrackerManagerVR:_PreloadTracker(key, data)
    self:old_PreloadTracker(data)
end

---@param params ElementTrigger
function EHITrackerManagerVR:AddLaserTracker(params)
    if self:IsLoading() then
        self:AddToLoadQueue(params.id, params, callback(self, self, "_AddLaserTracker"))
        return
    end
    self:old_AddLaserTracker(params)
end

---@param key string
---@param params ElementTrigger
function EHITrackerManagerVR:_AddLaserTracker(key, params)
    self:old_AddLaserTracker(params)
end

---@param id string
---@param t number
function EHITrackerManagerVR:RemoveLaserTracker(id, t)
    if self:IsLoading() then
        self._load_callback[id] = nil
        return
    end
    self:old_RemoveLaserTracker(id, t)
end