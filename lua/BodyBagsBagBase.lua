if EHI._hooks.BodyBagsBagBase then
    return
else
    EHI._hooks.BodyBagsBagBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

if not EHI:GetOption("show_equipment_bodybags") then
    return
end

local function UpdateTracker(unit, key, amount)
    if managers.ehi:TrackerDoesNotExist("BodyBags") and managers.groupai:state():whisper_mode() then
        managers.ehi:AddTracker({
            id = "BodyBags",
            icons = { "bodybags_bag" },
            class = "EHIEquipmentTracker"
        })
    end
    managers.ehi:CallFunction("BodyBags", "UpdateAmount", unit, key, amount)
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
    UpdateTracker(self._unit, self._ehi_key, self._bodybag_amount)
end

function CustomBodyBagsBagBase:_set_empty(...)
    original.custom_set_empty(self, ...)
	UpdateTracker(self._unit, self._ehi_key, 0)
end