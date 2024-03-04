local lerp = math.lerp
---@class EHIGaugeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIGaugeBuffTracker = class(EHIBuffTracker)
---@param o PanelBitmap
---@param ratio number
---@param progress Color
EHIGaugeBuffTracker._anim = function(o, ratio, progress)
    local r = progress.red
    over(0.25, function(p, t)
        progress.red = lerp(r, ratio, p) --[[@as number]]
        o:set_color(progress)
    end)
end
EHIGaugeBuffTracker._inverted_progress = true
---@param panel Panel
---@param params table
---@param parent_class EHIBuffManager
function EHIGaugeBuffTracker:init(panel, params, parent_class)
    self._ratio = 0
    self._format = params.format or "standard"
    self._init_text = self:Format()
    EHIGaugeBuffTracker.super.init(self, panel, params, parent_class)
end

---@param ratio number
---@param custom_value number?
---@param pos number
function EHIGaugeBuffTracker:Activate(ratio, custom_value, pos)
    self._active = true
    self:SetRatio(ratio, custom_value)
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIGaugeBuffTracker:Deactivate()
    EHIGaugeBuffTracker.super.Deactivate(self)
    self._progress:stop()
    self._progress_bar.red = 0 -- No need to animate this because the panel is no longer visible
    self._progress:set_color(self._progress_bar)
    self._ratio = 0
end

---@param ratio number
---@param custom_value number?
function EHIGaugeBuffTracker:SetRatio(ratio, custom_value)
    if self._ratio == ratio then
        return
    end
    self._ratio = ratio
    self._text:set_text(self:Format(custom_value))
    self:FitTheText(self._text)
    self._progress:stop()
    self._progress:animate(self._anim, ratio, self._progress_bar)
end

---@param value number?
---@return string
function EHIGaugeBuffTracker:Format(value)
    value = value or self._ratio
    if self._format == "percent" then
        return tostring(value * 100) .. "%"
    elseif self._format == "multiplier" then
        return value .. "x"
    elseif self._format == "damage" then
        return tostring(value * 10)
    end
    return tostring(value)
end