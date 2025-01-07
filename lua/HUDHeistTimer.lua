if EHI:CheckLoadHook("HUDHeistTimer") or not EHI:GetOption("show_real_time_ingame") then
    return
end

local original =
{
    init = HUDHeistTimer.init,
    set_time = HUDHeistTimer.set_time
}

function HUDHeistTimer:init(...)
    original.init(self, ...)
    local _, _, _, th = self._timer_text:text_rect() -- TODO: Figure out how to actually move the system time above heist time
    self._ehi_system_time_text = self._heist_timer_panel:text({
        text = "00:00",
        align = "center",
        vertical = "top",
        y = th,
        font = tweak_data.hud.medium_font_noshadow,
        font_size = 18,
        color = Color.white:with_alpha(0.8),
        layer = 1,
        visible = self._enabled
    })
    local _, _, _, eh = self._ehi_system_time_text:text_rect()
    self._heist_timer_panel:set_h(self._heist_timer_panel:h() + eh)
end

---@param time number
function HUDHeistTimer:set_time(time, ...)
    original.set_time(self, time, ...)
    if self._last_time == time then
        self._ehi_system_time_text:set_text(os.date("%H:%M") --[[@as string]])
    end
end