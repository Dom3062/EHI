local EHI = EHI
if EHI:CheckMenuHook("AchievementListGui") then
    return
end

local tiny_font = tweak_data.menu.pd2_tiny_font
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

local achievements =
{
    xm20_1 = true,
    pent_11 = true,
    lrfo_1 = true
}
local xm20_1 =
{
    { id = "present_mex", heist = "heist_mex" },
    { id = "present_bex", heist = "heist_bex" },
    { id = "present_pex", heist = "heist_pex" },
    { id = "present_fex", heist = "heist_fex" }
}
local pent_11 =
{
    { id = "tea_chas", heist = "heist_chas" },
    { id = "tea_sand", heist = "heist_sand" },
    { id = "tea_chca", heist = "heist_chca" },
    { id = "tea_pent", heist = "heist_pent" }
}
local lrfo_1 =
{
    { id = "LRON_played", heist = "heist_kosugi" },
    { id = "LRTW_played", heist = "heist_mex" },
    { id = "LRTH_played", heist = "heist_dah" },
    { id = "LRFO_played", heist = "heist_hox" }
}
Hooks:PostHook(AchievementListGui, "update_detail", "EHI_AchievementListGui_update_detail", function(self, ...)
    local selected = self._scroll:selected_item()
    if not selected then
        return
    end
    local info = selected._info or {}
    local id = info.id
    if achievements[id] and not info.awarded then
        local canvas = self._detail_scroll:canvas()
        local placer = canvas:placer()
        local pre, table_to_iterate
        if id == "xm20_1" then
            pre = "Missing mask in the following heist(s):"
            table_to_iterate = xm20_1
        elseif id == "pent_11" then
            pre = "Missing teaset in the following heist(s):"
            table_to_iterate = pent_11
        else
            pre = "Missing recording in the following heist(s):"
            table_to_iterate = lrfo_1
        end
        placer:add_row(canvas:fine_text({
            wrap = true,
            word_wrap = true,
            text = pre,
            font = tiny_font,
            font_size = tiny_font_size,
            w = canvas:row_w()
        }))
        for _, value in ipairs(table_to_iterate) do
            if not Global.mission_manager.saved_job_values[value.id] then
                placer:add_row(canvas:fine_text({
                    wrap = true,
                    word_wrap = true,
                    text = managers.localization:text(value.heist),
                    font = tiny_font,
                    font_size = tiny_font_size,
                    w = canvas:row_w()
                }))
            end
        end
        if self._detail_scroll:h() < canvas:h() and canvas:h() < self._detail_scroll:h() + 10 then
            self._detail_scroll:resize_canvas(nil, self._detail_scroll:h())
        end
    end
end)

Hooks:PostHook(AchievementDetailGui, "init", "EHI_AchievementDetailGui_init", function(self, ...)
    if achievements[self._id] and not self._info.awarded then
        local canvas = self._detail:canvas()
        local placer = canvas:placer()
        local pre, table_to_iterate
        if self._id == "xm20_1" then
            pre = "Missing mask in the following heist(s):"
            table_to_iterate = xm20_1
        elseif self._id == "pent_11" then
            pre = "Missing teaset in the following heist(s):"
            table_to_iterate = pent_11
        else
            pre = "Missing recording in the following heist(s):"
            table_to_iterate = lrfo_1
        end
        placer:add_row(canvas:fine_text({
            wrap = true,
            word_wrap = true,
            text = pre,
            font = tiny_font,
            font_size = tiny_font_size,
            w = canvas:row_w()
        }))
        for _, value in ipairs(table_to_iterate) do
            if not Global.mission_manager.saved_job_values[value.id] then
                placer:add_row(canvas:fine_text({
                    wrap = true,
                    word_wrap = true,
                    text = managers.localization:text(value.heist),
                    font = tiny_font,
                    font_size = tiny_font_size,
                    w = canvas:row_w()
                }))
            end
        end
        if self._detail:h() < canvas:h() and canvas:h() < self._detail:h() + 10 then
            self._detail:resize_canvas(nil, self._detail:h())
        end
    end
end)