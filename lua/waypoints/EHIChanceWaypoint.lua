---@class EHIChanceWaypoint : EHIWaypoint, EHIChanceTracker
---@field super EHIWaypoint
EHIChanceWaypoint = class(EHIWaypoint)
EHIChanceWaypoint._needs_update = false
EHIChanceWaypoint._force_format = true
EHIChanceWaypoint.pre_init = EHIChanceTracker.pre_init
EHIChanceWaypoint.Format = EHIChanceTracker.Format
EHIChanceWaypoint.FormatChance = EHIChanceTracker.FormatChance
EHIChanceWaypoint.DecreaseChance = EHIChanceTracker.DecreaseChance
EHIChanceWaypoint.IncreaseChance = EHIChanceTracker.IncreaseChance
EHIChanceWaypoint.IncreaseChanceIndex = EHIChanceTracker.IncreaseChanceIndex
---@param o PanelText
---@param self EHIChanceTracker
EHIChanceWaypoint._anim_chance = function(o, self)
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
    end
end
---@param amount number
function EHIChanceWaypoint:SetChance(amount)
    self._chance = math.max(0, amount)
    if self._anim_static_chance then
        self._gui:stop()
        self._gui:animate(self._anim_chance, self)
    else
        self._gui:set_text(self:FormatChance())
    end
end