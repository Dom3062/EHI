---@class EHIEscapeChanceManager
local EHIEscapeChanceManager = {}
EHIEscapeChanceManager._trigger_data =
{
    id = "EscapeChance",
    SF_increase = EHI.SpecialFunctions.IncreaseChanceFromElement,
    SF_check = EHI.SpecialFunctions.AddTrackerIfDoesNotExist,
    SF_set = EHI.SpecialFunctions.SetChanceFromElement,
    class = "EHIEscapeChanceTracker"
}
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

---@param chance number
---@param check_if_does_not_exist boolean?
---@return ElementTrigger
function EHIEscapeChanceManager:AddTrigger(chance, check_if_does_not_exist)
    return
    {
        id = self._trigger_data.id,
        chance = chance,
        special_function = check_if_does_not_exist and self._trigger_data.SF_check,
        class = self._trigger_data.class
    }
end

---@return ElementTrigger
function EHIEscapeChanceManager:IncreaseChanceFromTrigger()
    return
    {
        id = self._trigger_data.id,
        special_function = self._trigger_data.SF_increase
    }
end

---@return ElementTrigger
function EHIEscapeChanceManager:SetChanceFromTrigger()
    return
    {
        id = self._trigger_data.id,
        special_function = self._trigger_data.SF_set
    }
end

return EHIEscapeChanceManager