EHIEquipmentTracker = EHIEquipmentTracker or class(EHITracker)
EHIEquipmentTracker._update = false
function EHIEquipmentTracker:init(panel, params)
    params.update = false
    self._format = params.format or "charges"
    self._dont_show_placed = params.dont_show_placed or false
    self._amount = 0
    self._placed = 0
    self._deployables = {}
    EHIEquipmentTracker.super.init(self, panel, params)
end

function EHIEquipmentTracker:Format()
    if self._format == "percent" then
        return EHI:RoundNumber(self._amount, 0.01) .. " (" .. self._placed .. ")"
    else
        if self._dont_show_placed then
            return self._amount
        else
            return self._amount .. " (" .. self._placed .. ")"
        end
    end
end

function EHIEquipmentTracker:UpdateAmount(key, amount)
    self._deployables[key] = amount
    self._amount = 0
    self._placed = 0
    for _, value in pairs(self._deployables) do
        self._amount = self._amount + value
        if value ~= 0 then
            self._placed = self._placed + 1
        end
    end
    if self._amount <= 0 then
        self:delete()
    else
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
    end
end