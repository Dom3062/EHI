---@class EHIChanceTracker : EHITracker
---@field super EHITracker
EHIChanceTracker = class(EHITracker)
EHIChanceTracker._update = false
---@param params EHITracker.params
function EHIChanceTracker:pre_init(params)
    self._chance = params.chance or 0
end

---@param params EHITracker.params
function EHIChanceTracker:post_init(params)
    self._chance_text = self._text
end

function EHIChanceTracker:Format()
    return self._chance .. "%"
end

---@param amount number
function EHIChanceTracker:IncreaseChance(amount)
    self:SetChance(self._chance + amount)
end

---@param amount number
function EHIChanceTracker:DecreaseChance(amount)
    self:SetChance(self._chance - amount)
end

---@param amount number
function EHIChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    self._chance_text:set_text(self:FormatChance())
    self:FitTheText(self._chance_text)
    self:AnimateBG()
end
EHIChanceTracker.FormatChance = EHIChanceTracker.Format