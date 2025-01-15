---@class EHIEscapeChanceTracker : EHIChanceTracker
---@field super EHIChanceTracker
EHIEscapeChanceTracker = class(EHIChanceTracker)
EHIEscapeChanceTracker._forced_icons = { EHI.Icons.Car }
EHIEscapeChanceTracker._forced_hint_text = "van_crash_chance"
function EHIEscapeChanceTracker:OverridePanel()
    local icon = self._icons[1]
    if not icon then
        return
    end
    icon:rotate(180)
    local texture, texture_rect = tweak_data.hud_icons:get_icon_data("pd2_fire")
    self:CreateIcon(2, texture, texture_rect, icon:x(), true, Color("FFA500"), 0.75)
    self._icons[2]:set_layer(-1)
end