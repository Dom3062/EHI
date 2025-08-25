---@class EHIEscapeChanceManager
local EHIEscapeChanceManager = {}
EHIEscapeChanceManager._civilians_killed = 0
EHIEscapeChanceManager._disabled = false
---@param dropin boolean
---@param chance number 0-100
---@param civilian_killed_multiplier number?
function EHIEscapeChanceManager:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
    if dropin or managers.assets:IsEscapeDriverAssetUnlocked() then
        return
    end
    self:DisableIncreaseCivilianKilled()
    managers.ehi_tracker:AddTracker({
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
            managers.ehi_tracker:RemoveTracker("EscapeChance")
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
    if managers.ehi_tracker:DoesNotExist("EscapeChance") then
        if preplanning_escape_id then
            self:AddEscapeChanceTrackerAndCheckPreplanning(dropin, chance, preplanning_escape_id)
        else
            self:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
        end
    end
end

return EHIEscapeChanceManager