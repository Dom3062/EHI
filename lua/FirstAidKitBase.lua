local EHI = EHI
if EHI:CheckLoadHook("FirstAidKitBase") or not EHI:GetEquipmentOption("show_equipment_firstaidkit") then
    return
end

local UpdateTracker

if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("Deployables") then
            managers.ehi_tracker:AddAggregatedDeployablesTracker()
        end
        managers.ehi_tracker:CallFunction("Deployables", "UpdateAmount", "first_aid_kit", unit, key, amount)
    end
elseif EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("Health") then
            managers.ehi_tracker:AddAggregatedHealthTracker()
        end
        managers.ehi_tracker:CallFunction("Health", "UpdateAmount", "first_aid_kit", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("FirstAidKits") then
            managers.ehi_tracker:CreateDeployableTracker("FirstAidKits")
        end
        managers.ehi_tracker:CallFunction("FirstAidKits", "UpdateAmount", unit, key, amount)
    end
end

if EHI:IsVR() then
    local old_UpdateTracker = UpdateTracker
    local function Reload(key, data)
        old_UpdateTracker(data.unit, key, data.amount)
    end
    UpdateTracker = function(unit, key, amount)
        if managers.ehi_tracker:IsLoading() then
            managers.ehi_tracker:AddToLoadQueue(key, { unit = unit, amount = amount }, Reload)
            return
        end
        old_UpdateTracker(unit, key, amount)
    end
end

local original =
{
    init = FirstAidKitBase.init,
    destroy = FirstAidKitBase.destroy
}

function FirstAidKitBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    UpdateTracker(self._unit, self._ehi_key, 1)
end

function FirstAidKitBase:GetEHIKey()
    return self._ehi_key
end

function FirstAidKitBase:GetRealAmount()
    return self._empty and 0 or 1
end

function FirstAidKitBase:destroy(...)
    UpdateTracker(self._unit, self._ehi_key, 0)
    original.destroy(self, ...)
end