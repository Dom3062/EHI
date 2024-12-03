---@class EHIChanceTracker : EHITracker
---@field super EHITracker
---@field _anim_flash_set_chance number?
---@field _custom_chance_anim function?
EHIChanceTracker = class(EHITracker)
EHIChanceTracker._update = false
---@param o PanelText
---@param self EHIChanceTracker
EHIChanceTracker._anim_chance = function(o, self)
    local chance_to_anim = self._anim_static_chance
    self._anim_static_chance = self._chance
    if chance_to_anim ~= self._chance then
        local t = 0
        while t < 1 do
            t = t + coroutine.yield()
            local n = math.floor(math.lerp(chance_to_anim, self._chance, t))
            o:set_text(self:FormatChance(n))
        end
        o:set_text(self:FormatChance())
        self:FitTheText(o)
    end
end

function EHIChanceTracker:pre_init(params)
    if params.chances then
        self._current_chance_index = 1
        self._chances = params.chances
        self._chance = self._chances[1] or 0
    else
        self._chance = params.chance or 0
    end
    self._anim_static_chance = self._chance
    if params.disable_anim then
        self._anim_static_chance = nil
    end
end

function EHIChanceTracker:post_init(params)
    self._chance_text = self._text
end

---@param chance number?
function EHIChanceTracker:Format(chance)
    return string.format("%g%%", chance or self._chance)
end

---@param amount number
function EHIChanceTracker:IncreaseChance(amount)
    self:SetChance(self._chance + amount)
end

function EHIChanceTracker:IncreaseChance2()
    self._current_chance_index = self._current_chance_index + 1
    self:SetChance(self._chances[self._current_chance_index] or 0)
end

---@param amount number
function EHIChanceTracker:DecreaseChance(amount)
    self:SetChance(self._chance - amount)
end

---@param amount number
function EHIChanceTracker:SetChance(amount)
    self._chance = math.max(0, amount)
    if self._anim_static_chance then
        self._chance_text:stop()
        self._chance_text:animate(self._anim_chance, self)
    else
        self._chance_text:set_text(self:FormatChance())
        self:FitTheText(self._chance_text)
    end
    self:AnimateBG(self._anim_flash_set_chance)
end
EHIChanceTracker.FormatChance = EHIChanceTracker.Format