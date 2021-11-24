EHIXPTracker = EHIXPTracker or class(EHITracker)
function EHIXPTracker:init(panel, params)
    params.icons = { "xp" }
    self._xp = params.amount or 0
    EHIXPTracker.super.init(self, panel, params)
    self._time = 5
end

function EHIXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._xp, "+")
end

function EHIXPTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:delete()
    end
end

function EHIXPTracker:AddXP(amount)
    self._time = 5
    self._xp = self._xp + amount
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
end

EHITotalXPTracker = EHITotalXPTracker or class(EHIXPTracker)
EHITotalXPTracker._update = false
EHITotalXPTracker._show_diff = EHI:GetOption("total_xp_show_difference")
function EHITotalXPTracker:init(panel, params)
    self._gage_ratio = 1
    self._heat = params.heat or 1
    self._total_xp = params.amount or 0
    EHITotalXPTracker.super.init(self, panel, params)
end

function EHITotalXPTracker:SetGageBonusRatio(ratio)
    self._gage_ratio = ratio * self._heat
    self:UpdateTotalXP()
end

function EHITotalXPTracker:UpdateTotalXP()
    local new_xp = self._xp * self._gage_ratio
    if self._total_xp ~= new_xp then
        if self._show_diff then
            self._parent_class:AddTracker({
                id = "XP_" .. self._total_xp .. "_" .. new_xp,
                amount = new_xp - self._total_xp,
                class = "EHIXPTracker"
            })
        end
        self._total_xp = new_xp
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
    end
end

function EHITotalXPTracker:AddXP(amount)
    self._xp = self._xp + amount
    self:UpdateTotalXP()
end

function EHITotalXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._total_xp, "+")
end