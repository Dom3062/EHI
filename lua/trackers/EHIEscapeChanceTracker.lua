---@class EHIEscapeChanceTracker : EHIChanceTracker
---@field super EHIChanceTracker
EHIEscapeChanceTracker = class(EHIChanceTracker)
EHIEscapeChanceTracker._forced_icons = { EHI.Icons.Car }
EHIEscapeChanceTracker._forced_hint_text = "van_crash_chance"
function EHIEscapeChanceTracker:OverridePanel()
    local icon = self._icons[1]
    icon:rotate(180)
    local texture, texture_rect = tweak_data.hud_icons:get_icon_data("pd2_fire")
    self:CreateIcon(2, 2, texture, texture_rect, icon:x(), true, Color("FFA500"), 0.75, -1)
end

function EHIEscapeChanceTracker:GetTrackerSize()
    return self._bg_box:w() + self._icon_gap_size_scaled
end