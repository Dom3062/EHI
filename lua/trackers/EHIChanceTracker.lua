local floor = math.floor
local lerp = math.lerp
---@class EHIChanceTracker : EHITracker
---@field super EHITracker
---@field _anim_flash_set_chance number?
EHIChanceTracker = class(EHITracker)
EHIChanceTracker._update = false
---@param o PanelText
---@param self EHIChanceTracker
EHIChanceTracker._anim = function(o, self)
    local chance_to_anim = self._anim_chance
    self._anim_chance = self._chance
    if chance_to_anim ~= self._chance then
        local t = 0
        while t < 1 do
            t = t + coroutine.yield()
            local n = floor(lerp(chance_to_anim, self._chance, t) --[[@as number]])
            o:set_text(self:FormatChance(n))
        end
        o:set_text(self:FormatChance())
    end
end
---@param params EHITracker.params
function EHIChanceTracker:pre_init(params)
    self._chance = params.chance or 0
    self._anim_chance = self._chance
    if params.disable_anim then
        self._anim_chance = nil
    end
end

---@param params EHITracker.params
function EHIChanceTracker:post_init(params)
    self._chance_text = self._text
end

---@param chance number?
function EHIChanceTracker:Format(chance)
    return (chance or self._chance) .. "%"
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
    if self._anim_chance then
        self._chance_text:stop()
        self._chance_text:animate(self._anim, self)
    else
        self._chance_text:set_text(self:FormatChance())
        self:FitTheText(self._chance_text)
    end
    self:AnimateBG(self._anim_flash_set_chance)
end

function EHIChanceTracker:delete()
    if self._anim_chance and self._chance_text and alive(self._chance_text) then
        self._chance_text:stop()
    end
    EHIChanceTracker.super.delete(self)
end
EHIChanceTracker.FormatChance = EHIChanceTracker.Format