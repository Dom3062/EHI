---@class EHIEquipmentTracker : EHITracker
---@field super EHITracker
EHIEquipmentTracker = class(EHITracker)
EHIEquipmentTracker._needs_update = false
function EHIEquipmentTracker:pre_init(params)
    self._format = params.format or "charges"
    self._dont_show_placed = params.dont_show_placed
    self._amount = 0
    self._placed = 0
    self._deployables = {}
end

function EHIEquipmentTracker:post_init(params)
    self._hide_on_delete = true
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("%g (%d)", self._parent_class.RoundNumber(self._amount, 0.01), self._placed)
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("%d (%d)", self._amount, self._placed)
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%d) %g", self._placed, self._parent_class.RoundNumber(self._amount, 0.01))
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._placed, self._amount)
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%g) %d", self._parent_class.RoundNumber(self._amount, 0.01), self._placed)
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._amount, self._placed)
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%d) %g", self._placed, self._parent_class.RoundNumber(self._amount, 0.01))
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._placed, self._amount)
        end
    elseif format == 5 then -- Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return tostring(self._parent_class.RoundNumber(self._amount, 0.01))
            end
            return tostring(self._amount)
        end
    else -- Bags placed
        function EHIEquipmentTracker:Format()
            if self._dont_show_placed then
                if self._format == "percent" then
                    return tostring(self._parent_class.RoundNumber(self._amount, 0.01))
                end
                return tostring(self._amount)
            end
            return tostring(self._placed)
        end
    end
end

---@param key string
---@param amount number
function EHIEquipmentTracker:UpdateAmount(key, amount)
    if not key then
        return
    end
    if self._restore_after_cleanup then
        self._restore_after_cleanup = nil
        self._parent_class:RunTracker(self._id)
        self._deployables = {}
    end
    self._deployables[key] = amount
    self._amount = 0
    self._placed = 0
    for _, value in pairs(self._deployables) do
        if value > 0 then
            self._amount = self._amount + value
            self._placed = self._placed + 1
        end
    end
    if self._amount <= 0 then
        self:delete()
    else
        self:SetAndFitTheText()
        self:AnimateBG()
    end
end

function EHIEquipmentTracker:CleanupOnHide()
    if self._restore_after_cleanup then -- No need to clean up again if the tracker is pending restoration
        return
    end
    self._deployables = nil
    self._restore_after_cleanup = true
end