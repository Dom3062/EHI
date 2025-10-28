---@class EHIBikerBuffTracker : EHIPermanentBuffTracker
---@field super EHIPermanentBuffTracker
EHIBikerBuffTracker = class(EHIPermanentBuffTracker)
EHIBikerBuffTracker.Extend = EHIBikerBuffTracker.super.super.Extend
EHIBikerBuffTracker._max_kills = tweak_data.upgrades.wild_max_triggers_per_time or 4
EHIBikerBuffTracker._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK = true
function EHIBikerBuffTracker:PreUpdate()
    EHIBikerBuffTracker.super.PreUpdate(self)
    local pm = managers.player
    pm._wild_kill_triggers = pm._wild_kill_triggers or {} -- Force creation to not crash if the first kill is a civilian
    self._wild_kill_triggers = pm._wild_kill_triggers -- Cache the table for faster access
    self._hint:set_text("0")
    self._f = function(...)
        -- Old kills were purged here before our post hook is called, no need to purge them again
        local kills = #self._wild_kill_triggers
        self:Trigger(kills)
    end
    self:SetCustodyState(false)
end

function EHIBikerBuffTracker:SetCustodyState(state)
    if state then
        Hooks:RemovePostHook("EHI_BikerBuff_Post")
    else
        Hooks:PostHook(PlayerManager, "chk_wild_kill_counter", "EHI_BikerBuff_Post", self._f)
    end
end

---@param kills number
function EHIBikerBuffTracker:Trigger(kills)
    if kills < 1 then
        if self._running then
            self:Deactivate()
        end
        return
    end
    local t = Application:time()
    local cd
    if kills < self._max_kills then
        cd = self._wild_kill_triggers[kills] - t
        self._icon:set_color(Color.white)
        self._hint:set_text(tostring(kills))
    else
        cd = self._wild_kill_triggers[1] - t
        self._icon:set_color(Color.red)
        self._hint:set_text(tostring(self._max_kills))
        self._retrigger = true
    end
    if self._running then
        self:Extend(cd)
    else
        self:Activate(cd)
    end
end

---@param t number
function EHIBikerBuffTracker:Activate(t)
    self._running = true
    self._time = t
    self._time_set = t
    self:AddBuffToUpdate()
end

function EHIBikerBuffTracker:Deactivate()
    if self._retrigger then
        self._retrigger = nil
        self:Retrigger()
    else
        self._running = false
        self._hint:set_text("0")
        self:RemoveBuffFromUpdate()
    end
end

-- Check again if there are still kills, but first, purge old kills so they don't mess up with the calculation
function EHIBikerBuffTracker:Retrigger()
    local kills = self._wild_kill_triggers -- Optimized for speed access
    local t = Application:time()
    while kills[1] and t >= kills[1] do
        table.remove(kills, 1)
    end
    local n = #kills
    self:Trigger(n)
end