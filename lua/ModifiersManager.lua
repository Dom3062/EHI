local EHI = EHI
if EHI:CheckLoadHook("ModifiersManager") then
    return
end

---@class ModifiersManager
---@field _modifiers table<string, BaseModifier[]?>
---@field add_modifier fun(self: self, modifier: BaseModifier, category: string?)

---@param modifier string
---@param category string
function ModifiersManager:IsModifierActive(modifier, category)
    local modifiers = self._modifiers[category]
    for _, mod in ipairs(modifiers or {}) do
        if mod._type == modifier then
            return true
        end
    end
end

---@param modifier string
---@param category string
---@return BaseModifier?
function ModifiersManager:GetModifier(modifier, category)
    local modifiers = self._modifiers[category]
    for _, mod in ipairs(modifiers or {}) do
        if mod._type == modifier then
            return mod
        end
    end
end