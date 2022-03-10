function EHIMenu:SetOption(value, option)
    EHI.settings[option] = value
end

function EHIMenu:SetEquipmentColor(color, option)
    local c = EHI.settings.equipment_color[option]
    c.r = color.red
    c.g = color.green
    c.b = color.blue
end

function EHIMenu:UpdateXOffset(x)
    self._preview_panel:UpdateXOffset(x)
end

function EHIMenu:UpdateYOffset(y)
    self._preview_panel:UpdateYOffset(y)
end

function EHIMenu:UpdateTextScale(scale)
    self._preview_panel:UpdateTextScale(scale)
end

function EHIMenu:UpdateScale(scale)
    self._preview_panel:UpdateScale(scale)
end

function EHIMenu:UpdateFormat(format)
    self._preview_panel:UpdateFormat(format)
end

function EHIMenu:UpdateEquipmentFormat(format)
    self._preview_panel:UpdateEquipmentFormat(format)
end

function EHIMenu:UpdateTrackerVisibility(value, option)
    self._preview_panel:Redraw()
    self:SetFocus(value, option)
end

function EHIMenu:UpdateBGVisibility(visibility)
    self._preview_panel:UpdateBGVisibility(visibility)
end

function EHIMenu:UpdateIconsVisibility(visibility)
    self._preview_panel:UpdateIconsVisibility(visibility)
end

function EHIMenu:UpdateTrackerAlignment(alignment)
    self._preview_panel:UpdateTrackerAlignment(alignment)
end

function EHIMenu:SetFocus(focus, value)
    self._preview_panel:SetSelected(value)
end

function EHIMenu:fcc_equipment_tracker(focus, ...)
    self:SetFocus(focus, focus and "show_equipment_tracker" or "")
end

function EHIMenu:fcc_equipment_tracker_menu(focus, ...)
    local function f()
        self:SetFocus(focus, focus and "show_equipment_tracker" or "")
    end
    EHI:DelayCall("HighlightDelay", 0.5, f)
end

function EHIMenu:UpdateMinionTracker(value)
    self._preview_panel:UpdateMinionTracker(value)
end

function EHIMenu:fcc_show_minion_per_player(focus, ...)
    self:SetFocus(focus, focus and "show_minion_tracker" or "")
end