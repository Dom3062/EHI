local EHI = EHI
if EHI:CheckLoadHook("BodyBagsBagBase") or not EHI:GetEquipmentOption("show_equipment_bodybags") then
    return
end

local UpdateTracker
if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("Deployables") and amount ~= 0 then
            managers.ehi_deployable:AddAggregatedDeployablesTracker("bodybags_bag")
        end
        managers.ehi_deployable:CallFunction("Deployables", "UpdateAmount", "bodybags_bag", key, amount)
    end
else
    UpdateTracker = function(key, amount)
        if managers.ehi_tracker:TrackerDoesNotExist("BodyBags") and amount ~= 0 then
            managers.ehi_deployable:CreateDeployableTracker("BodyBags")
        end
        managers.ehi_deployable:CallFunction("BodyBags", "UpdateAmount", key, amount)
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
    init = BodyBagsBagBase.init,
    _set_visual_stage = BodyBagsBagBase._set_visual_stage,

    custom_set_empty = CustomBodyBagsBagBase._set_empty
}

function BodyBagsBagBase:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

function BodyBagsBagBase:GetEHIKey()
    return self._ehi_key
end

function BodyBagsBagBase:GetRealAmount()
    return self._bodybag_amount or self._max_bodybag_amount
end

function BodyBagsBagBase:_set_visual_stage(...)
    original._set_visual_stage(self, ...)
    UpdateTracker(self._ehi_key, self._bodybag_amount)
end

function CustomBodyBagsBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
	UpdateTracker(self._ehi_key, 0)
end