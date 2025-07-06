---@class EHIEscapeChanceManager
local EHIEscapeChanceManager = {}
---@param ehi_tracker EHITrackerManager
function EHIEscapeChanceManager:post_init(ehi_tracker)
    self._trackers = ehi_tracker
    self._civilians_killed = 0
    self._disabled = false
end

---@param dropin boolean
---@param chance number 0-100
---@param civilian_killed_multiplier number?
function EHIEscapeChanceManager:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
    if (dropin and not self._synced) or managers.assets:IsEscapeDriverAssetUnlocked() then
        return
    end
    self:DisableIncreaseCivilianKilled()
    self._trackers:AddTracker({
        id = "EscapeChance",
        chance = chance + (self._civilians_killed * (civilian_killed_multiplier or 5)),
        class = "EHIEscapeChanceTracker"
    })
end

---@param dropin boolean
---@param chance number 0-100
---@param preplanning_escape_id number
function EHIEscapeChanceManager:AddEscapeChanceTrackerAndCheckPreplanning(dropin, chance, preplanning_escape_id)
    if managers.preplanning:IsAssetBought(preplanning_escape_id) then
        return
    end
    managers.ehi_sync:AddLoadSyncFunction(function()
        if managers.preplanning:IsAssetBought(preplanning_escape_id) then
            self._trackers:RemoveTracker("EscapeChance")
        end
    end)
    self:AddEscapeChanceTracker(dropin, chance)
end

function EHIEscapeChanceManager:IncreaseCivilianKilled()
    if self._disabled then
        return
    end
    self._civilians_killed = self._civilians_killed + 1
end

function EHIEscapeChanceManager:DisableIncreaseCivilianKilled()
    self._disabled = true
end

---@param dropin boolean
---@param chance number 0-100
---@param civilian_killed_multiplier number?
---@param preplanning_escape_id number? In case Escape Driver can be bought in Preplanning
function EHIEscapeChanceManager:AddChanceWhenDoesNotExists(dropin, chance, civilian_killed_multiplier, preplanning_escape_id)
    if self._trackers:DoesNotExist("EscapeChance") then
        if preplanning_escape_id then
            self:AddEscapeChanceTrackerAndCheckPreplanning(dropin, chance, preplanning_escape_id)
        else
            self:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
        end
    end
end

function EHIEscapeChanceManager:load(data)
    local load_data = data.EHIEscapeChanceManager
    if load_data then
        self._disabled = load_data.disabled
        self._civilians_killed = load_data.civilians_killed
        self._synced = true
    end
end

function EHIEscapeChanceManager:save(data)
    local save_data = {}
    save_data.disabled = self._disabled
    save_data.civilians_killed = self._civilians_killed
    data.EHIEscapeChanceManager = save_data
end

return EHIEscapeChanceManager