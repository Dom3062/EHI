---@class EHIXPTracker : EHITracker
---@field super EHITracker
EHIXPTracker = class(EHITracker)
EHIXPTracker._forced_icons = { "xp" }
EHIXPTracker._forced_hint_text = "gained_xp"
EHIXPTracker.update = EHIXPTracker.update_fade
---@param panel Panel
---@param params EHITracker.params
function EHIXPTracker:init(panel, params, ...)
    self._xp = params.amount or 0
    EHIXPTracker.super.init(self, panel, params, ...)
end

function EHIXPTracker:Format() -- Formats the amount of XP in the panel
    return managers.experience:cash_string(self._xp, self._xp >= 0 and "+" or "") -- May show up a negative value because it is called from EHITotalXPTracker (diff)
end

---@param amount number
function EHIXPTracker:AddXP(amount)
    self._fade_time = 5
    self._xp = self._xp + amount
    self:SetAndFitTheText()
    self:AnimateBG()
end

---@class EHIHiddenXPTracker : EHIXPTracker
---@field super EHIXPTracker
EHIHiddenXPTracker = class(EHIXPTracker)
EHIHiddenXPTracker._update = false
EHIHiddenXPTracker._init_create_text = false
---@param params EHITracker.params
function EHIHiddenXPTracker:pre_init(params)
    self._total_xp = 0
    self._refresh_t = params.refresh_t or 1
    self._xp_panel = params.panel or 3
    params.time = self._refresh_t
    self._experience = managers.localization:text("ehi_popup_experience")
    self._experience_total_text = managers.localization:text("ehi_popup_experience_total")
    local gained = params.format == 1 and "ehi_popup_experience_base_gained" or "ehi_popup_experience_gained"
    if self._xp_panel == 3 then
        local xp = managers.localization:text("ehi_experience_xp")
        self._experience_format = "%s%s " .. xp .. "\n%s%s " .. xp
    else
        local xp = managers.localization:text("ehi_experience_xp")
        self._experience_format = "%s%s " .. xp .. ";%s%s " .. xp
        gained = "ehi_popup_experience_gained"
    end
    self._experience_gained_text = managers.localization:text(gained)
    self._xp_class = managers.experience
    if (params.amount or 0) > 0 then
        self:AddTrackerToUpdate()
        self._updating = true
    end
end

---@param dt number
function EHIHiddenXPTracker:update(dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:RemoveTrackerFromUpdate()
        self._updating = false
        local xp_string = string.format(self._experience_format, self._experience_gained_text, self._xp_class:cash_string(self._xp, self._xp >= 0 and "+" or ""), self._experience_total_text, self._xp_class:cash_string(self._total_xp, "+"))
        if self._xp_panel == 3 then
            managers.hud:custom_ingame_popup_text(self._experience, xp_string, "EHI_XP")
        else
            managers.hud:show_hint({ text = xp_string })
        end
        self._xp = 0
    end
end

---@param amount number
function EHIHiddenXPTracker:AddXP(amount)
    self._time = self._refresh_t
    self._xp = self._xp + amount
    self._total_xp = self._total_xp + amount
    if not self._updating then
        self:AddTrackerToUpdate()
        self._updating = true
    end
end

---@class EHITotalXPTracker : EHIXPTracker
---@field super EHIXPTracker
EHITotalXPTracker = class(EHIXPTracker)
EHITotalXPTracker._forced_hint_text = "total_xp"
EHITotalXPTracker._update = false
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
        if self._xp >= self._player_xp_limit then
            self._total_xp = self._player_xp_limit
            self:SetTextColor(Color.green)
            self._player_limit_reached = true
        else
            self._total_xp = self._xp
        end
        self:SetAndFitTheText()
        self:AnimateBG()
    end
end