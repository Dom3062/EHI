if EHI._hooks.DoctorBagBase then
	return
else
	EHI._hooks.DoctorBagBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_doctorbag") then
    return
end

local correction =
{
    [tostring(Idstring("units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box"))] = 1,	--CustomDoctorBagBase / cabinet 1
	[tostring(Idstring("units/pd2_dlc_casino/props/cas_prop_medic_firstaid_box/cas_prop_medic_firstaid_box"))] = 1,	--CustomDoctorBagBase / cabinet 2
}

local UpdateTracker

if EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("Health") then
            managers.ehi:AddAggregatedHealthTracker()
        end
        managers.ehi:CallFunction("Health", "UpdateAmount", "doctor_bag", unit, key, amount)
    end
else
    UpdateTracker = function(unit, key, amount)
        if managers.ehi:TrackerDoesNotExist("DoctorBags") then
            managers.ehi:AddTracker({
                id = "DoctorBags",
                icons = { "doctor_bag" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.ehi:CallFunction("DoctorBags", "UpdateAmount", unit, key, amount)
    end
end

local original =
{
    init = DoctorBagBase.init,
    _set_visual_stage = DoctorBagBase._set_visual_stage,
    destroy = DoctorBagBase.destroy
}

function DoctorBagBase:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
    self._offset = correction[tostring(unit:name())] or 0
end

function DoctorBagBase:_set_visual_stage()
    original._set_visual_stage(self)
    UpdateTracker(self._unit, self._ehi_key, self._amount - self._offset)
end

function DoctorBagBase:destroy()
    original.destroy(self)
    UpdateTracker(self._unit, self._ehi_key, 0)
end