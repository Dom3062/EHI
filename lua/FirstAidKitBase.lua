local EHI = EHI
if EHI._hooks.FirstAidKitBase then
	return
else
	EHI._hooks.FirstAidKitBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_firstaidkit") then
    return
end

local UpdateTracker

if EHI:GetOption("show_equipment_aggregate_all") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Deployables") then
            managers.ehi:AddAggregatedDeployablesTracker()
        end
        managers.ehi:CallFunction("Deployables", "UpdateAmount", "first_aid_kit", unit, key, amount)
    end
elseif EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Health") then
            managers.ehi:AddAggregatedHealthTracker()
        end
        managers.ehi:CallFunction("Health", "UpdateAmount", "first_aid_kit", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("FirstAidKits") then
            managers.ehi:AddTracker({
                id = "FirstAidKits",
                icons = { "first_aid_kit" },
                dont_show_placed = true,
                exclude_from_sync = true,
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("FirstAidKits", "UpdateAmount", unit, key, amount)
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