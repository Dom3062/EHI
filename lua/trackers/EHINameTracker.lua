---@class EHINameTracker : EHITracker
---@field super EHITracker
EHINameTracker = class(EHITracker)
EHINameTracker._needs_update = false
function EHINameTracker:pre_init(params)
    self._name = params.name
end

function EHINameTracker:post_init(params)
    if params.double_size then
        self:SetMovement(self._anim_params.PanelSizeIncrease, true)
    elseif params.half_size then
        self:SetMovement(self._anim_params.PanelSizeIncreaseHalf, true)
    end
end

---@param name string?
function EHINameTracker:Format(name)
    return tostring(name or self._name)
end

---@param name string
function EHINameTracker:SetName(name)
    self:SetAndFitTheText(name)
end