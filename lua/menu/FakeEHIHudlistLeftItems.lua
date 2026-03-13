---@alias FakeEHILeftItemBase.Item { panel: Panel, progress: Bitmap[][], progress_to_update: Bitmap[], progress_bg: Bitmap[], progress_only: Bitmap[], pos: integer, fake_pos: integer?, progress_value: number, progress_raw_value: number, progress_bar: Color }

---@class FakeEHILeftItemBase
---@field new fun(self: self, panel: Panel, params: table, texture: string, texture_rect: TextureRect): self
FakeEHILeftItemBase = class()
FakeEHILeftItemBase._COLOR_CHANGE_AFFECTS_WHOLE_ITEM = true
FakeEHILeftItemBase._PROGRESS_RECT = {
    { 32, 0, -32, 32 },
    { 128, 0, -128, 128 }
}
---@param panel Panel
---@param params table
---@param texture string
---@param texture_rect TextureRect
function FakeEHILeftItemBase:init(panel, params, texture, texture_rect)
    self._id = params.id
    self._enabled = params.enabled
    self._visible = params.visible
    self._list_enabled = params.list_enabled
    local scale = params.scale or 1
    self._params = {
        progress = params.progress or 1,
        bg_alpha = params.bg_alpha or 1,
        bg_color = params.bg_color,
        progress_visibility = params.progress_visibility,
        scale = scale,
        top_text_enabled = params.top_text,
        bottom_text_enabled = params.bottom_text
    }
    local top_text, bottom_text = 0, 0
    if params.items then
        for _, data in ipairs(params.items) do
            if data.top_text then
                top_text = top_text + 1
            end
            if data.bottom_text then
                bottom_text = bottom_text + 1
            end
        end
    end
    self._params.top_text = top_text
    self._params.bottom_text = bottom_text
    self._params.top_offset = 16 --top_text > 0 and 16 or 0
    self._params.bottom_offset = 16 --bottom_text > 0 and 16 or 0
    self._panel = panel:panel({
        y = 80,
        w = panel:w(),
        h = 64 * scale, -- 32 is base, 32 is for top and bottom text
        visible = self._enabled and self._visible and self._list_enabled or false
    })
    local icon_size = 32 * scale
    self._panel:bitmap({
        name = "icon",
        x = 0,
        y = 16 * scale,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect
    })
    self._list = {} ---@type FakeEHILeftItemBase.Item[]
    if params.items then
        for i, data in ipairs(params.items) do
            self:AddItem(i, data, scale)
        end
    end
end

---@param scale number
function FakeEHILeftItemBase:Rescale(scale)
    self._params.scale = scale
    local w = 32 * scale
    local h = 16 * scale
    local icon_offset = 4 * scale
    local icon_size = 24 * scale
    self._panel:set_h(64 * scale)
    self._panel:child("icon"):set_y(h)
    self._panel:child("icon"):set_size(w, w)
    local panel_h = self._panel:h()
    local icon_y = self._panel:child("icon"):y()
    for _, item in ipairs(self._list) do
        local panel = item.panel
        panel:set_size(w, panel_h)
        local top_text = panel:child("top_text") --[[@as Text?]]
        if top_text then
            top_text:set_size(w, h)
            top_text:set_font_size(h)
            self:FitTheText(top_text)
        end
        local bottom_text = panel:child("bottom_text") --[[@as Text?]]
        if bottom_text then
            bottom_text:set_y(icon_y + w)
            bottom_text:set_size(w, h)
            bottom_text:set_font_size(h)
            self:FitTheText(bottom_text)
        end
        local icon = panel:child("icon") ---@cast icon -?
        icon:set_position(icon_offset, icon_y + icon_offset)
        icon:set_size(icon_size, icon_size)
        for _, bitmaps in ipairs(item.progress) do
            for _, bitmap in ipairs(bitmaps) do
                bitmap:set_y(icon_y)
                bitmap:set_size(w, w)
            end
        end
        self:SortAddedItem(panel, item.fake_pos or item.pos, scale)
    end
end

---@param scale number
function FakeEHILeftItemBase:GetFirstItemStartX(scale)
    return self._panel:child("icon"):x() + self._panel:child("icon"):w() + (10 * scale)
end

---@param text Text
function FakeEHILeftItemBase:FitTheText(text)
    text:set_font_size(text:h())
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

---@param t number
---@param i integer
function FakeEHILeftItemBase:Format(t, i)
    if self._parent._format.time == 1 then
        return tweak_data.ehi.functions:ReturnSecondsOnly(t)
    else
        return tweak_data.ehi.functions:ReturnMinutesAndSeconds(t)
    end
end

---@param enabled boolean
function FakeEHILeftItemBase:SetEnabled(enabled)
    self._enabled = enabled
    self._panel:set_visible(self._visible and self._list_enabled and enabled)
end

---@param enabled boolean
function FakeEHILeftItemBase:SetListEnabled(enabled)
    self._list_enabled = enabled
    self._panel:set_visible(self._visible and self._enabled and enabled)
end

---@param visibility boolean
function FakeEHILeftItemBase:SetVisibility(visibility)
    self._visible = visibility
    self._panel:set_visible(self._enabled and self._list_enabled and visibility)
end

function FakeEHILeftItemBase:ItemIsVisible()
    return self._enabled
end

function FakeEHILeftItemBase:GetRealHeight()
    local h = 64 --32 + self._params.top_offset + self._params.bottom_offset
    if self._params.top_text <= 0 or not self._params.top_text_enabled then
        h = h - self._params.top_offset
    end
    if self._params.bottom_text <= 0 or not self._params.bottom_text_enabled then
        h = h - self._params.bottom_offset
    end
    return h * self._params.scale
end

function FakeEHILeftItemBase:GetOffset()
    local offset = 0
    if self._params.top_text <= 0 or not self._params.top_text_enabled then
        offset = offset + self._params.top_offset
    end
    return offset * self._params.scale
end

---@param x number
---@param y number
function FakeEHILeftItemBase:SetPosition(x, y)
    self._panel:set_position(x, y - self:GetOffset())
end

---@param i integer
---@param params { icon: table, progress: number?, progress_between: number[]?, color: integer?, icon_color: Color?, top_text: table, bottom_text: table, fake_pos: integer? }
---@param scale number
function FakeEHILeftItemBase:AddItem(i, params, scale)
    local progress, max_progress
    if params.progress_between then
        max_progress = params.progress_between[2]
        progress = math.rand(params.progress_between[1], params.progress_between[2])
    else
        max_progress = params.progress
        progress = math.rand(params.progress)
    end
    local value = progress / max_progress
    local w = 32 * scale
    local h = 16 * scale
    local progress_bar = Color(1, value, 0.125, 1)
    local y = self._panel:child("icon"):y()
    local panel = self._panel:panel({
        w = w,
        h = self._panel:h() -- Scale is already applied here
    })
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(params.icon)
    local color_value, color_string = tweak_data.ehi:GetBuffColorFromIndex(params.color)
    local icon_color = params.icon_color or color_value
    local progress_sframe, progress_cframe = {}, {}
    progress_sframe[1] = panel:bitmap({
        render_template = "VertexColorTexturedRadialFlex",
        layer = 10,
        y = y,
        w = w,
        h = w,
        texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", color_string),
        texture_rect = self._PROGRESS_RECT[1],
        color = progress_bar,
        visible = self._params.progress == 1 and self._params.progress_visibility
    })
    progress_sframe[2] = panel:rect({
        blend_mode = "normal",
        halign = "grow",
        alpha = self._params.bg_alpha,
        layer = -1,
        valign = "grow",
        y = y,
        w = w,
        h = w,
        color = self._params.bg_color,
        visible = self._params.progress == 1
    })
    progress_cframe[1] = panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 10,
        y = y,
        w = w,
        h = w,
        texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", color_string),
        texture_rect = self._PROGRESS_RECT[2],
        color = progress_bar,
        visible = self._params.progress == 2 and self._params.progress_visibility
    })
    progress_cframe[2] = panel:bitmap({
        alpha = self._params.bg_alpha,
        layer = -1,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg_white",
        color = self._params.bg_color:with_alpha(0.2),
        visible = self._params.progress == 2
    })
    local icon_offset = 4 * scale
    local icon_size = 24 * scale
    panel:bitmap({
        name = "icon",
        x = icon_offset,
        y = y + icon_offset,
        w = icon_size,
        h = icon_size,
        texture = texture,
        texture_rect = texture_rect,
        color = icon_color
    })
    if params.top_text then
        local text = params.top_text.text or ""
        if params.top_text.localize then
            text = managers.localization:text(text)
        end
        self:FitTheText(panel:text({
            name = "top_text",
            w = w,
            h = h,
            text = text,
            font = tweak_data.menu.pd2_large_font,
            font_size = h,
            align = "center",
            vertical = "center",
            color = color_value,
            visible = self._params.top_text_enabled
        }))
    end
    if params.bottom_text then
        self:FitTheText(panel:text({
            name = "bottom_text",
            y = y + w,
            w = w,
            h = h,
            text = self:Format(progress, i),
            font = tweak_data.menu.pd2_large_font,
            font_size = h,
            align = "center",
            vertical = "center",
            color = color_value
        }))
    end
    local pos = table.size(self._list) + 1
    local fake_pos = params.fake_pos
    local data =
    {
        pos = pos,
        fake_pos = fake_pos,
        panel = panel,
        progress = { progress_sframe, progress_cframe },
        progress_to_update = { progress_sframe[1], progress_cframe[1] },
        progress_bg = { progress_sframe[2], progress_cframe[2] },
        progress_only = { progress_sframe[1], progress_cframe[1] },
        progress_raw_value = progress,
        progress_value = value,
        progress_bar = progress_bar
    }
    self:_AddItem(data, panel, y, progress_bar, scale)
    self:SortAddedItem(panel, fake_pos or pos, scale)
    self._list[pos] = data
end

---@param data FakeEHILeftItemBase.Item
---@param panel Panel
---@param y number
---@param progress_bar Color
---@param scale number
function FakeEHILeftItemBase:_AddItem(data, panel, y, progress_bar, scale)
end

---Sorts newly added item panel on the HUD, but not in the memory
---@param panel Panel
---@param pos integer
---@param scale number
function FakeEHILeftItemBase:SortAddedItem(panel, pos, scale)
    local x = self:GetFirstItemStartX(scale)
    if pos <= 1 then
        panel:set_x(x)
    else
        local offset = 5 * scale
        pos = pos - 1
        panel:set_x(x + (panel:w() + offset) * pos)
    end
end

---@param static boolean
function FakeEHILeftItemBase:SetProgressStatic(static)
    local template1 = Idstring("VertexColorTexturedRadial")
    local template2 = Idstring("VertexColorTexturedRadialFlex")
    for _, item in ipairs(self._list) do
        item.progress_bar.r = static and 1 or item.progress_value
        for _, bitmap in ipairs(item.progress_only) do
            local render_template = bitmap:render_template()
            if render_template == template1 or render_template == template2 then
                bitmap:set_color(item.progress_bar)
            end
        end
    end
end

---@param progress integer
---@param from_visibility boolean?
function FakeEHILeftItemBase:SetProgress(progress, from_visibility)
    self._params.progress = progress
    for _, item in ipairs(self._list) do
        for i, bitmaps in ipairs(item.progress) do
            for _, obj in ipairs(bitmaps) do
                obj:set_visible(i == progress)
            end
        end
    end
    self:_SetProgress(progress)
    if not from_visibility then
        self:SetProgressVisibility(self._params.progress_visibility, true)
    end
end

---@param progress integer
function FakeEHILeftItemBase:_SetProgress(progress)
end

---@param visibility boolean
---@param from_progress boolean?
function FakeEHILeftItemBase:SetProgressVisibility(visibility, from_progress)
    self._params.progress_visibility = visibility
    for _, item in ipairs(self._list) do
        for i, bitmap in ipairs(item.progress_only) do
            bitmap:set_visible(i == self._params.progress and visibility)
        end
    end
end

---@param pos integer
---@param clr integer Gets converted to color and string
function FakeEHILeftItemBase:SetItemProgressColor(pos, clr)
    local item = self._list[pos]
    local color, color_string = tweak_data.ehi:GetBuffColorFromIndex(clr)
    if self._COLOR_CHANGE_AFFECTS_WHOLE_ITEM then
        local top_text = item.panel:child("top_text") --[[@as Text?]]
        if top_text then
            top_text:set_color(color)
        end
        local bottom_text = item.panel:child("bottom_text") --[[@as Text?]]
        if bottom_text then
            bottom_text:set_color(color)
        end
        item.panel:child("icon"):set_color(color) ---@diagnostic disable-line
    end
    for i, obj in ipairs(item.progress_to_update) do
        obj:set_image(string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", i == 1 and "sframe" or "cframe", color_string), unpack(self._PROGRESS_RECT[i]))
    end
end

function FakeEHILeftItemBase:SetTimeFormat()
    for _, item in ipairs(self._list) do
        local bottom_text = item.panel:child("bottom_text") --[[@as Text?]]
        if bottom_text then
            bottom_text:set_text(self:Format(item.progress_raw_value, item.pos))
        end
    end
end

---@param a number
function FakeEHILeftItemBase:UpdateBGAlpha(a)
    for _, item in ipairs(self._list) do
        for _, bitmap in ipairs(item.progress_bg) do
            bitmap:set_alpha(a)
        end
    end
end

---@param color { r: number, g: number, b: number }
function FakeEHILeftItemBase:UpdateBGColor(color)
    local c = Color(255, color.r, color.g, color.b) / 255
    for _, item in ipairs(self._list) do
        for i, bitmap in ipairs(item.progress_bg) do
            if i == 1 then
                bitmap:set_color(c)
            elseif i == 2 then
                bitmap:set_color(c:with_alpha(0.2))
            else
                self:_UpdateBGColor(i, bitmap, c)
            end
        end
    end
end

---@param i integer
---@param bitmap Bitmap
---@param color Color
function FakeEHILeftItemBase:_UpdateBGColor(i, bitmap, color)
end

---@param visible boolean
function FakeEHILeftItemBase:UpdateTopText(visible)
    if self._params.top_offset <= 0 then
        return
    end
    self._params.top_text_enabled = visible
    for _, item in ipairs(self._list) do
        local top_text = item.panel:child("top_text")
        if top_text then
            top_text:set_visible(visible)
        end
    end
    self:_UpdateTopText(visible)
end

---@param visible boolean
function FakeEHILeftItemBase:_UpdateTopText(visible)
end

---@class FakeEHILeftDeployableItem : FakeEHILeftItemBase
---@field super FakeEHILeftItemBase
FakeEHILeftDeployableItem = class(FakeEHILeftItemBase)
function FakeEHILeftDeployableItem:init(panel, params, ...)
    FakeEHILeftDeployableItem.super.init(self, panel, params, ...)
    self._peer_color = self._list[3].panel:child("icon"):color():with_alpha(1) ---@diagnostic disable-line
    self:UpdateFormat(params.format)
    self:SetAggregateDeployables(params.aggregate)
end

---@param aggregate boolean
function FakeEHILeftDeployableItem:SetAggregateDeployables(aggregate)
    self._list[1].panel:set_visible(not aggregate)
    self._list[2].panel:set_visible(aggregate)
    self._list[3].panel:child("icon"):set_color(aggregate and Color.white or self._peer_color) ---@diagnostic disable-line
end

---@param t number
---@param i integer
function FakeEHILeftDeployableItem:Format(t, i)
    if not self._params.format then
        return FakeEHILeftDeployableItem.super.Format(self, t, 0)
    elseif self._params.format == 1 then -- Multiplier
        return string.format(i == 3 and "%.2fx" or "%dx", t)
    else -- Percent
        return string.format("%d%%", t * 100)
    end
end

---@param format integer
function FakeEHILeftDeployableItem:UpdateFormat(format)
    if self._params.format == format then
        return
    end
    self._params.format = format
    for _, item in ipairs(self._list) do
        item.panel:child("bottom_text"):set_text(self:Format(item.progress_raw_value, item.pos)) ---@diagnostic disable-line
    end
end

function FakeEHILeftDeployableItem:SetTimeFormat()
end

---@class FakeEHILeftMinionItem : FakeEHILeftItemBase
---@field super FakeEHILeftItemBase
FakeEHILeftMinionItem = class(FakeEHILeftItemBase)
FakeEHILeftMinionItem._ICON_SKULL = { ehi = EHI:GetAchievementIconString("trk_a_0") }
function FakeEHILeftMinionItem:init(panel, params, ...)
    FakeEHILeftMinionItem.super.init(self, panel, params, ...)
    self:SetOtherMinionsVisible(params.minion_option)
    if self._params.progress == 3 then
        self:_SetProgress(3)
    end
end

function FakeEHILeftMinionItem:_AddItem(data, panel, y, progress_bar, scale)
    local w = 32 * scale
    local progress = {} ---@type Bitmap[]
    local is_health_circle = self._params.progress == 3
    progress[1] = panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 10,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2/hud_health",
        texture_rect = self._PROGRESS_RECT[2],
        color = progress_bar,
        visible = is_health_circle
    })
    progress[2] = panel:bitmap({
        layer = 11,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_white",
        texture_rect = self._PROGRESS_RECT[2],
        visible = is_health_circle and self._params.progress_visibility
    })
    progress[3] = panel:bitmap({
        alpha = self._params.bg_alpha,
        layer = -1,
        y = y,
        w = w,
        h = w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg_white",
        color = self._params.bg_color:with_alpha(0.2),
        visible = is_health_circle
    })
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._ICON_SKULL)
    local skull = panel:bitmap({
        name = "skull",
        layer = 12,
        w = 16 * scale,
        h = 16 * scale,
        texture = texture,
        texture_rect = texture_rect,
        visible = is_health_circle and not self._params.top_text_enabled
    })
    skull:set_center(progress[1]:center())
    table.insert(data.progress, progress)
    table.insert(data.progress_bg, progress[3])
    table.insert(data.progress_only, progress[2])
end

function FakeEHILeftMinionItem:_SetProgress(progress)
    for _, item in ipairs(self._list) do
        local icon = item.panel:child("icon") --[[@as Bitmap]]
        local skull = item.panel:child("skull") --[[@as Bitmap]]
        icon:set_visible(progress ~= 3)
        skull:set_visible(progress == 3 and not self._params.top_text_enabled)
        item.panel:child("top_text"):set_color(progress == 3 and icon:color():with_alpha(1) or Color.white) ---@diagnostic disable-line
        skull:set_color(progress == 3 and icon:color():with_alpha(1) or Color.white)
    end
end

---@param option integer
function FakeEHILeftMinionItem:SetOtherMinionsVisible(option)
    self._list[2].panel:set_visible(option == 1)
end

---@param i integer
---@param bitmap Bitmap
---@param color Color
function FakeEHILeftMinionItem:_UpdateBGColor(i, bitmap, color)
    bitmap:set_color(color:with_alpha(0.2))
end

---@param visible boolean
function FakeEHILeftMinionItem:_UpdateTopText(visible)
    for _, item in ipairs(self._list) do
        item.panel:child("skull"):set_visible(self._params.progress == 3 and not visible)
    end
end

---@class FakeEHILeftJammerItem : FakeEHILeftItemBase
---@field super FakeEHILeftItemBase
FakeEHILeftJammerItem = class(FakeEHILeftItemBase)
FakeEHILeftJammerItem._COLOR_CHANGE_AFFECTS_WHOLE_ITEM = false
function FakeEHILeftJammerItem:init(panel, params, ...)
    FakeEHILeftJammerItem.super.init(self, panel, params, ...)
    if self._params.progress_visibility then
        self:SetItemProgressColor(2, params.affects_pager_color_index)
    else
        self._affects_pager_color = tweak_data.ehi:GetBuffColorFromIndex(params.affects_pager_color_index)
        self._list[2].panel:child("bottom_text"):set_color(self._affects_pager_color) ---@diagnostic disable-line
    end
end

function FakeEHILeftJammerItem:SetProgressVisibility(visibility, ...)
    local color = visibility and Color.white or self._affects_pager_color
    self._list[2].panel:child("bottom_text"):set_color(color) ---@diagnostic disable-line
    FakeEHILeftJammerItem.super.SetProgressVisibility(self, visibility, ...)
end

function FakeEHILeftJammerItem:SetItemProgressColor(pos, clr)
    FakeEHILeftJammerItem.super.SetItemProgressColor(self, pos, clr)
    if pos == 2 then
        local color, _ = tweak_data.ehi:GetBuffColorFromIndex(clr)
        self._affects_pager_color = color
        if not self._params.progress_visibility then
            self._list[pos].panel:child("bottom_text"):set_color(color) ---@diagnostic disable-line
        end
    end
end