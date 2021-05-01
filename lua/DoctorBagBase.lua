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
    UpdateTracker = function(key, amount)
        if managers.hud.ehi then
            if not managers.hud:TrackerExists("Health") then
                managers.hud:AddAggregatedHealthTracker()
            end
            managers.hud.ehi:CallFunction("Health", "UpdateAmount", "doctor_bag", key, amount)
        elseif EHI._cache.Deployables.Health then
            EHI._cache.Deployables.Health.doctor_bag = EHI._cache.Deployables.Health.doctor_bag or {}
            EHI._cache.Deployables.Health.doctor_bag[key] = amount
        end
    end
else
    UpdateTracker = function(key, amount)
        if managers.hud.ehi then
            if not managers.hud:TrackerExists("DoctorBags") then
                managers.hud:AddTracker({
                    id = "DoctorBags",
                    icons = { "doctor_bag" },
                    class = "EHIEquipmentTracker"
                })
            end
            managers.hud.ehi:CallFunction("DoctorBags", "UpdateAmount", key, amount)
        elseif EHI._cache.Deployables.DoctorBags then
            EHI._cache.Deployables.DoctorBags[key] = amount
        end
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
    UpdateTracker(self._ehi_key, self._amount - self._offset)
end

function DoctorBagBase:destroy()
    original.destroy(self)
    UpdateTracker(self._ehi_key, 0)
end