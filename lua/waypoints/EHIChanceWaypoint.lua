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
---@param o Text
---@param self EHIChanceTracker
EHIChanceWaypoint._anim_chance = function(o, self)
    local chance_to_anim = self._anim_static_chance
    if chance_to_anim ~= self._chance then
        local t = 0
        while t < 1 do
            t = t + coroutine.yield()
            local n = math.floor(math.lerp(chance_to_anim, self._chance, t))
            o:set_text(self:FormatChance(n))
            self._anim_static_chance = n
        end
        o:set_text(self:FormatChance())
        self._anim_static_chance = self._chance
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

---@class EHIWaypointLessChanceWaypoint : EHIWaypointLessWaypoint, EHIChanceWaypoint
---@field super EHIWaypointLessWaypoint
EHIWaypointLessChanceWaypoint = class(EHIWaypointLessWaypoint)
EHIWaypointLessChanceWaypoint._needs_update = false
EHIWaypointLessChanceWaypoint._anim_chance = EHIChanceWaypoint._anim_chance
EHIWaypointLessChanceWaypoint.pre_init = EHIChanceWaypoint.pre_init
EHIWaypointLessChanceWaypoint.Format = EHIChanceWaypoint.Format
EHIWaypointLessChanceWaypoint.FormatChance = EHIChanceWaypoint.FormatChance
EHIWaypointLessChanceWaypoint.DecreaseChance = EHIChanceWaypoint.DecreaseChance
EHIWaypointLessChanceWaypoint.IncreaseChance = EHIChanceWaypoint.IncreaseChance
EHIWaypointLessChanceWaypoint.IncreaseChanceIndex = EHIChanceWaypoint.IncreaseChanceIndex
EHIWaypointLessChanceWaypoint._SetChance = EHIChanceWaypoint.SetChance
function EHIWaypointLessChanceWaypoint:SetChance(amount)
    if not self._gui then
        self._chance = math.max(0, amount)
        return
    end
    self:_SetChance(amount)
end