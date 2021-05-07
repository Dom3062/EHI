function EHIMenu:SetOption(value, option)
    EHI.settings[option] = value
end

function EHIMenu:UpdateXOffset(x)
    self._preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateYOffset(y)
    self._preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateScale(scale)
    self._preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateFormat(format)
    self._preview_panel:UpdateFormat(format)
end

function EHIMenu:UpdateTrackerVisibility(value, option)
    self._preview_panel:Redraw()
    self:SetFocus(value, option)
end

function EHIMenu:SetFocus(focus, value)
    self._preview_panel:SetSelected(value)
end