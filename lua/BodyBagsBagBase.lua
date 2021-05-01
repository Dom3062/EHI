if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_bodybags") then
    return
end

local function UpdateTracker(key, amount)
    if managers.hud.ehi then
        if not managers.hud:TrackerExists("BodyBags") and managers.groupai:state():whisper_mode() then
            managers.hud:AddTracker({
                id = "BodyBags",
                icons = { "bodybags_bag" },
                class = "EHIEquipmentTracker"
            })
        end
        managers.hud.ehi:CallFunction("BodyBags", "UpdateAmount", key, amount)
    else
        EHI._cache.Deployables.BodyBags[key] = amount
    end
end

local original =
{
    init = BodyBagsBagBase.init,
    _set_visual_stage = BodyBagsBagBase._set_visual_stage
}

function BodyBagsBagBase:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
end

function BodyBagsBagBase:_set_visual_stage()
    original._set_visual_stage(self)
    UpdateTracker(self._ehi_key, self._bodybag_amount)
end