---@class EHIXPTracker : EHITracker
---@field super EHITracker
EHIXPTracker = class(EHITracker)
EHIXPTracker._forced_icons = { "xp" }
EHIXPTracker._forced_hint_text = "gained_xp"
EHIXPTracker.update = EHIXPTracker.update_fade
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIXPTracker:init(panel, params, parent_class)
    self._xp = params.amount or 0
    EHIXPTracker.super.init(self, panel, params, parent_class)
end

function EHIXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._xp, self._xp >= 0 and "+" or "") -- May show up a negative value because it is called from EHITotalXPTracker (diff)
end

---@param amount number
function EHIXPTracker:AddXP(amount)
    self._fade_time = 5
    self._xp = self._xp + amount
    self._text:set_text(self:Format())
    self:FitTheText()
    self:AnimateBG()
end

---@class EHITotalXPTracker : EHIXPTracker
---@field super EHIXPTracker
EHITotalXPTracker = class(EHIXPTracker)
EHITotalXPTracker._forced_hint_text = "total_xp"
EHITotalXPTracker._update = false
EHITotalXPTracker._show_diff = EHI:GetOption("total_xp_show_difference")
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHITotalXPTracker:init(panel, params, parent_class)
    self._total_xp = params.amount or 0
    self._player_xp_limit = params.xp_limit or 0
    EHITotalXPTracker.super.init(self, panel, params, parent_class)
    if self._player_xp_limit <= 0 then
        self._update = true -- Request deletion next frame
    end
end

---@param dt number
function EHITotalXPTracker:update(dt)
    self:delete()
end

function EHITotalXPTracker:OverridePanel()
    self:SetBGSize(self._bg_box:w() / 2)
    self._text:set_w(self._bg_box:w())
    self:SetIconX()
end

function EHITotalXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._total_xp, "+") -- Will never show a negative value
end

---@param amount number
function EHITotalXPTracker:SetXP(amount)
    self._xp = amount
    if self._total_xp ~= self._xp and not self._player_limit_reached then
        if self._show_diff then
            self._parent_class:AddTracker({
                id = "XP_" .. self._total_xp .. "_" .. self._xp,
                amount = self._xp - self._total_xp,
                class = "EHIXPTracker"
            })
        end
        if self._xp >= self._player_xp_limit then
            self._total_xp = self._player_xp_limit
            self:SetTextColor(Color.green)
            self._player_limit_reached = true
        else
            self._total_xp = self._xp
        end
        self._text:set_text(self:Format())
        self:FitTheText()
        self:AnimateBG()
    end
end