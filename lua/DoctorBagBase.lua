local EHI = EHI
if EHI:CheckLoadHook("DoctorBagBase")then
    return
end

local UpdateTracker
function DoctorBagBase:GetRealAmount()
    return (self._amount or self._max_amount) - (self._offset or 0)
end

---@param offset number
function DoctorBagBase:SetOffset(offset)
    self._offset = offset
    if self._ehi_key and self._unit:interaction():active() and not self._ignore then
        UpdateTracker(self._ehi_key, self:GetRealAmount())
    end
end

if not EHI:GetEquipmentOption("show_equipment_doctorbag") then
    return
end

if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("Deployables") then
            managers.ehi_deployable:AddAggregatedDeployablesTracker()
        end
        managers.ehi_deployable:CallFunction("Deployables", "UpdateAmount", "doctor_bag", key, amount)
    end
elseif EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("Health") then
            managers.ehi_deployable:AddAggregatedHealthTracker()
        end
        managers.ehi_deployable:CallFunction("Health", "UpdateAmount", "doctor_bag", key, amount)
    end
else
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("DoctorBags") then
            managers.ehi_deployable:CreateDeployableTracker("DoctorBags")
        end
        managers.ehi_deployable:CallFunction("DoctorBags", "UpdateAmount", key, amount)
    end
end

if _G.IS_VR then
    local old_UpdateTracker = UpdateTracker
    local function Reload(key, data)
        old_UpdateTracker(key, data.amount)
    end
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:IsLoading() then
            managers.ehi_tracker:AddToLoadQueue(key, { amount = amount }, Reload)
            return
        end
        old_UpdateTracker(key, amount)
    end
end

local original =
{
    init = DoctorBagBase.init,
    _set_visual_stage = DoctorBagBase._set_visual_stage,
    destroy = DoctorBagBase.destroy,

    custom_set_empty = CustomDoctorBagBase._set_empty
}

function DoctorBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._offset = 0
end

function DoctorBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    UpdateTracker(self._ehi_key, self:GetRealAmount())
end

function DoctorBagBase:destroy(...)
    UpdateTracker(self._ehi_key, 0)
    original.destroy(self, ...)
end

function CustomDoctorBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
    UpdateTracker(self._ehi_key, 0)
end