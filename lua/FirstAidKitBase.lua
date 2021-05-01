if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_firstaidkit") then
    return
end

local UpdateTracker

if EHI:GetOption("show_equipment_aggregate_health") then
    UpdateTracker = function(key, amount)
        if not managers.hud:TrackerExists("Health") then
            managers.hud:AddAggregatedHealthTracker()
        end
        managers.hud.ehi:CallFunction("Health", "UpdateAmount", "first_aid_kit", key, amount)
    end
else
    UpdateTracker = function(key, amount)
        if not managers.hud:TrackerExists("FirstAidKits") then
            managers.hud:AddTracker({
                id = "FirstAidKits",
                icons = { "first_aid_kit" },
                dont_show_placed = true,
                class = "EHIEquipmentTracker"
            })
        end
        managers.hud.ehi:CallFunction("FirstAidKits", "UpdateAmount", key, amount)
    end
end

local original =
{
    init = FirstAidKitBase.init,
    destroy = FirstAidKitBase.destroy
}

function FirstAidKitBase:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
    UpdateTracker(self._ehi_key, 1)
end

function FirstAidKitBase:destroy()
    original.destroy(self)
    if managers.hud.ehi then
        UpdateTracker(self._ehi_key, 0)
    end
end