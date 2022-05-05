local Color = Color
EHIGaugeBuffTracker = class(EHIBuffTracker)
EHIGaugeBuffTracker._inverted_progress = true
function EHIGaugeBuffTracker:init(panel, params)
    self._ratio = 0
    self._max = params.max or 1
    self._format = params.format or "standard"
    EHIGaugeBuffTracker.super.init(self, panel, params)
end

function EHIGaugeBuffTracker:Activate(ratio, pos)
    self._active = true
    self:SetRatio(ratio)
    self._panel:set_visible(true)
    self._pos = pos
end

function EHIGaugeBuffTracker:Deactivate()
    EHIGaugeBuffTracker.super.Deactivate(self)
    self._progress:set_color(Color(1, 0, 1, 1)) -- No need to animate this because the panel is no longer visible
end

local lerp = math.lerp
function EHIGaugeBuffTracker:SetRatio(ratio)
    self._ratio = ratio
    self._text:set_text(self:Format())
    self:FitTheText()
    self._progress:stop()
    self._progress:animate(function(o)
        local r = o:color().red * self._max
        over(0.25, function(p, t)
            local l = lerp(r, self._ratio, p)
            o:set_color(Color(1, l / self._max, 1, 1))
        end)
    end)
end

function EHIGaugeBuffTracker:FitTheText()
    local w = select(3, self._text:text_rect())
    if w > self._text:w() then
        self._text:set_font_size(self._text:font_size() * (self._text:w() / w))
    end
end

function EHIGaugeBuffTracker:Format()
    if self._format == "percent" then
        return tostring(self._ratio * 100) .. "%"
    end
    return tostring(self._ratio)
end