---@alias FakeEHIRightItemBase.Item { panel: Panel, progress: Bitmap[][], value: number, text: Text, id: string?, icon_scale: number, visible: boolean, count: integer, enabled: boolean }
---@alias FakeEHIRightItemBase.ItemParams { icon: table, value: number, fake_pos: integer?, id: string?, enabled: boolean }

---@class FakeEHIRightItemBase
---@field new fun(self: self, panel: Panel, params: table): self
FakeEHIRightItemBase = class()
FakeEHIRightItemBase._PROGRESS = Color(1, 1, 1, 1)
FakeEHIRightItemBase._PROGRESS_RECT = {
    { 32, 0, -32, 32 },
    { 128, 0, -128, 128 }
}
FakeEHIRightItemBase._UPDATE_COLOR_APPLIES_TO_ICON = true
---@param panel Panel
---@param params table
function FakeEHIRightItemBase:init(panel, params)
    self._id = params.id
    self._enabled = params.enabled
    self._visible = params.visible
    self._list_enabled = params.list_enabled
    local scale = params.scale or 1
    local bg_alpha = params.bg_alpha or 1
    local progress_alpha = params.progress_alpha or 1
    local color = params.color
    local color_string = params.color_string
    self._params = {
        h = 64,
        bg_color = params.bg_color,
        progress = params.progress or 1,
        progress_visibility = params.progress_visibility,
        right_offset = params.right_offset,
        scale = scale
    }
    self._panel = panel:panel({
        y = 90,
        w = panel:w(),
        h = 64 * scale,
        visible = self._enabled and self._visible and self._list_enabled or false
    })
    self._items = {} ---@type FakeEHIRightItemBase.Item[]
    if params.items then
        for _, data in ipairs(params.items) do
            self:AddItem(data, scale, bg_alpha, progress_alpha, color, color_string)
        end
    end
    self:UpdateDataFromOptions(params)
end

function FakeEHIRightItemBase:UpdateDataFromOptions(params)
end

---@param scale number
function FakeEHIRightItemBase:Rescale(scale)
    self._params.scale = scale
    local w = 32 * scale
    self._panel:set_h(self._params.h * scale)
    local panel_h = self._panel:h()
    for _, item in ipairs(self._items) do
        local panel = item.panel
        panel:set_size(w, panel_h)
        local text = item.text
        text:set_y(w)
        text:set_size(w, w)
        text:set_font_size(24 * scale)
        local icon = panel:child("icon") --[[@as Bitmap]]
        if icon then
            if item.icon_scale == 1 then
                icon:set_size(w, w)
            else
                local w_new = w * item.icon_scale
                local offset = math.abs(w - w_new) / 2
                icon:set_size(w_new, w_new)
                icon:set_position(offset, 0)
            end
        end
        for _, bitmaps in ipairs(item.progress) do
            for _, bitmap in ipairs(bitmaps) do
                bitmap:set_y(w)
                bitmap:set_size(w, w)
            end
        end
    end
end

---@param x number
---@param scale number
function FakeEHIRightItemBase:SetRightOffset(x, scale)
    self._params.right_offset = x
    self:_update_items_right_offset(scale)
end

---@param scale number?
function FakeEHIRightItemBase:_update_items_right_offset(scale)
    scale = scale or self._params.scale
    local pos_offset = 0
    for i, item in ipairs(self._items) do
        if item.count > 0 then
            self:SortAddedItem(item.panel, i - pos_offset, scale)
        else
            pos_offset = pos_offset + 1
        end
    end
end

---@param enabled boolean
function FakeEHIRightItemBase:SetEnabled(enabled)
    self._enabled = enabled
    self._panel:set_visible(self._visible and self._list_enabled and enabled)
end

---@param enabled boolean
function FakeEHIRightItemBase:SetListEnabled(enabled)
    self._list_enabled = enabled
    self._panel:set_visible(self._visible and self._enabled and enabled)
end

---@param visibility boolean
function FakeEHIRightItemBase:SetVisibility(visibility)
    self._visible = visibility
    self._panel:set_visible(self._enabled and self._list_enabled and visibility)
end

function FakeEHIRightItemBase:ItemIsVisible()
    return self._enabled
end

---@param a number
function FakeEHIRightItemBase:UpdateBGAlpha(a)
    for _, item in ipairs(self._items) do
        for _, bitmaps in ipairs(item.progress) do
            bitmaps[2]:set_alpha(a)
        end
    end
end

---@param color { r: number, g: number, b: number }
function FakeEHIRightItemBase:UpdateBGColor(color)
    local c = Color(255, color.r, color.g, color.b) / 255
    for _, item in ipairs(self._items) do
        for _, bitmaps in ipairs(item.progress) do
            for i, obj in ipairs(bitmaps) do
                if i == 1 then
                    obj:set_color(c)
                else
                    obj:set_color(c:with_alpha(0.2))
                end
            end
        end
    end
end

---@param params FakeEHIRightItemBase.ItemParams
---@param scale number
---@param bg_alpha number
---@param progress_alpha number
---@param color Color
---@param color_string string
function FakeEHIRightItemBase:AddItem(params, scale, bg_alpha, progress_alpha, color, color_string)
    local icon_scale = 1
    local value = math.random(1, params.value or 1)
    local w = 32 * scale
    local panel = self._panel:panel({
        w = w,
        h = self._panel:h() -- Scale is already applied here
    })
    local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(params.icon)
    local progress_sframe, progress_cframe = {}, {}
    progress_sframe[1] = panel:bitmap({
        alpha = progress_alpha,
        render_template = "VertexColorTexturedRadial",
        layer = 2,
        y = w,
        w = w,
        h = w,
        texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_sframe_%s", color_string),
        texture_rect = self._PROGRESS_RECT[1],
        color = self._PROGRESS,
        visible = self._params.progress == 1 and self._params.progress_visibility
    })
    progress_sframe[2] = panel:rect({
        blend_mode = "normal",
        halign = "grow",
        alpha = bg_alpha,
        layer = -1,
        valign = "grow",
        y = w,
        w = w,
        h = w,
        color = self._params.bg_color,
        visible = self._params.progress == 1
    })
    progress_cframe[1] = panel:bitmap({
        alpha = progress_alpha,
        render_template = "VertexColorTexturedRadial",
        layer = 2,
        y = w,
        w = w,
        h = w,
        texture = string.format("guis/textures/pd2_mod_ehi/buffs/buff_cframe_%s", color_string),
        texture_rect = self._PROGRESS_RECT[2],
        color = self._PROGRESS,
        visible = self._params.progress == 2 and self._params.progress_visibility
    })
    progress_cframe[2] = panel:bitmap({
        alpha = bg_alpha,
        layer = -1,
        y = w,
        w = w,
        h = w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg_white",
        color = self._params.bg_color:with_alpha(0.2),
        visible = self._params.progress == 2
    })
    local icon = panel:bitmap({
        name = "icon",
        w = w,
        h = w,
        texture = texture,
        texture_rect = texture_rect,
        color = params.icon.color or color
    })
    if params.icon.scale then
        icon_scale = params.icon.scale
        local w_new = w * icon_scale
        local offset = math.abs(w - w_new) / 2
        icon:set_size(w_new, w_new)
        icon:move(offset, 0)
    end
    local text = panel:text({
        name = "count",
        y = w,
        w = w,
        h = w,
        text = tostring(value),
        font = tweak_data.menu.pd2_large_font,
        font_size = 24 * scale,
        align = "center",
        vertical = "center",
        color = color
    })
    local pos = table.size(self._items) + 1
    local item_enabled = params.enabled ~= false
    local data =
    {
        id = params.id,
        panel = panel,
        progress = { progress_sframe, progress_cframe },
        text = text,
        value = value,
        icon_scale = icon_scale,
        count = item_enabled and value or 0,
        enabled = item_enabled,
        visible = true
    }
    self:AddAdditionalItemsOnPanel(panel, params, scale)
    self:SortAddedItem(panel, pos, scale)
    self._items[pos] = data
    if data.count <= 0 then
        panel:hide()
    end
end

---@param panel Panel
---@param params FakeEHIRightItemBase.ItemParams
---@param scale number
function FakeEHIRightItemBase:AddAdditionalItemsOnPanel(panel, params, scale)
end

---Sorts newly added item panel on the HUD, but not in the memory
---@param panel Panel
---@param pos integer
---@param scale number
function FakeEHIRightItemBase:SortAddedItem(panel, pos, scale)
    local x = self._params.right_offset
    if pos <= 1 then
        panel:set_right(x)
    else
        local offset = 5 * scale
        pos = pos - 1
        panel:set_right(x - (panel:w() + offset) * pos)
    end
end

---@param id string
function FakeEHIRightItemBase:_get_item_by_id(id)
    for _, item in ipairs(self._items) do
        if item.id == id then
            return item
        end
    end
end

---@param item FakeEHIRightItemBase.Item
function FakeEHIRightItemBase:_update_item_final_visibility(item)
    local visible = item.enabled and item.visible
    item.panel:set_visible(visible)
    item.count = visible and item.value or 0
end

---@param item FakeEHIRightItemBase.Item
---@param visibility boolean
function FakeEHIRightItemBase:_update_item_visibility(item, visibility)
    item.visible = visibility
    self:_update_item_final_visibility(item)
end

---@param item FakeEHIRightItemBase.Item
---@param enabled boolean
function FakeEHIRightItemBase:_update_item_enabled(item, enabled)
    item.enabled = enabled
    self:_update_item_final_visibility(item)
end

---@param progress integer
function FakeEHIRightItemBase:SetProgress(progress)
    self._params.progress = progress
    for _, item in ipairs(self._items) do
        for i, bitmaps in ipairs(item.progress) do
            for _, obj in ipairs(bitmaps) do
                obj:set_visible(i == progress)
            end
        end
    end
    self:SetProgressVisibility(self._params.progress_visibility, progress)
end

---@param a number
function FakeEHIRightItemBase:UpdateProgressAlpha(a)
    for _, item in ipairs(self._items) do
        for _, bitmaps in ipairs(item.progress) do
            bitmaps[1]:set_alpha(a)
        end
    end
end

---@param visibility boolean
---@param progress integer?
function FakeEHIRightItemBase:SetProgressVisibility(visibility, progress)
    self._params.progress_visibility = visibility
    progress = progress or self._params.progress
    for _, item in ipairs(self._items) do
        for i, bitmaps in ipairs(item.progress) do
            bitmaps[1]:set_visible(i == progress and visibility)
        end
    end
end

---@param color_index integer
function FakeEHIRightItemBase:UpdateItemsColor(color_index)
    local color, color_string = tweak_data.ehi:GetBuffColorFromIndex(color_index)
    for _, item in ipairs(self._items) do
        if self._UPDATE_COLOR_APPLIES_TO_ICON then
            item.panel:child("icon"):set_color(color) ---@diagnostic disable-line
        end
        for i, bitmaps in ipairs(item.progress) do
            bitmaps[1]:set_image(string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", i == 1 and "sframe" or "cframe", color_string))
        end
        item.text:set_color(color)
    end
end

---@class FakeEHIRightUnitItem : FakeEHIRightItemBase
---@field super FakeEHIRightItemBase
FakeEHIRightUnitItem = class(FakeEHIRightItemBase)
FakeEHIRightUnitItem._UPDATE_COLOR_APPLIES_TO_ICON = false
FakeEHIRightUnitItem._ALL_ITEMS = {}
function FakeEHIRightUnitItem:UpdateDataFromOptions(params)
    self._separate_dozers = params.dozer_count_separate
    self:_update_items_right_offset()
end

---@param separate boolean
function FakeEHIRightUnitItem:SetDozerCountSeparate(separate)
    self._separate_dozers = separate
    local separate_dozers = separate
    local one_dozer_item = not separate
    self:_update_item_enabled(self:_get_item_by_id("dozer"), one_dozer_item)
    self:_update_item_enabled(self:_get_item_by_id("dozer_hw"), separate_dozers)
    self:_update_item_enabled(self:_get_item_by_id("dozer_medic"), separate_dozers)
    self:_update_item_enabled(self:_get_item_by_id("dozer_mini"), separate_dozers)
    self:_update_item_enabled(self:_get_item_by_id("dozer_skull"), separate_dozers)
    self:_update_item_enabled(self:_get_item_by_id("dozer_black"), separate_dozers)
    self:_update_item_enabled(self:_get_item_by_id("dozer_green"), separate_dozers)
    self:_update_items_right_offset()
end

---@param enabled boolean
---@param id string
function FakeEHIRightUnitItem:SetItemEnabled(enabled, id)
    self:_update_item_enabled(self:_get_item_by_id(id), enabled)
    self:_update_items_right_offset()
end

---@param enabled boolean
function FakeEHIRightUnitItem:SetDozerItemEnabled(enabled)
    if enabled then
        self:SetDozerCountSeparate(self._separate_dozers)
    else
        self:_update_item_enabled(self:_get_item_by_id("dozer"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_hw"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_medic"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_mini"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_skull"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_black"), false)
        self:_update_item_enabled(self:_get_item_by_id("dozer_green"), false)
        self:_update_items_right_offset()
    end
end

---@param color Color
---@param id string
function FakeEHIRightUnitItem:SetItemColor(color, id)
    self:_get_item_by_id(id).panel:child("icon"):set_color(color) ---@diagnostic disable-line
end

---@class FakeEHIRightLootItem : FakeEHIRightItemBase
---@field super FakeEHIRightItemBase
FakeEHIRightLootItem = class(FakeEHIRightItemBase)
FakeEHIRightLootItem._BAG_ICON = { texture = "guis/textures/pd2/hud_tabs", texture_rect = { 32, 33, 32, 32 } }
FakeEHIRightLootItem._TEXT_COLOR = Color(0.0, 0.5, 0.0)
function FakeEHIRightLootItem:UpdateDataFromOptions(params)
    self:UpdateCrateVisibility(params.potentional_loot)
    self:UpdateTopType(params.top_type)
end

function FakeEHIRightLootItem:Rescale(scale)
    FakeEHIRightLootItem.super.Rescale(self, scale)
    local w = 32 * scale
    for _, item in ipairs(self._items) do
        local panel = item.panel
        local panel_w = panel:w()
        local icon = panel:child("text_bg") --[[@as Bitmap]]
        icon:set_size(w, w)
        icon:set_position(0, 0) -- Reset position to 0 for rescale to work correctly
        local text = panel:child("text_name") --[[@as Text]]
        text:set_size(panel_w, panel_w)
        text:set_font_size(panel_w * 0.45)
        text:set_position(0, 0) -- Reset position to 0 for rescale to work correctly
        local _, _, ww, _ = text:text_rect()
        text:set_font_size(math.min(text:font_size() * (text:w() / ww) * 0.9, text:font_size()))
        text:set_center(icon:center())
        text:set_y(text:y() + text:h() * 0.1)
        local previous_w = icon:w()
        icon:set_w(previous_w * 1.2)
        icon:set_center(text:center())
        text:move(0, 2 * scale)
    end
end

function FakeEHIRightLootItem:AddAdditionalItemsOnPanel(panel, params, scale)
    if params.text then ---@diagnostic disable-line
        local w = 32 * scale
        local def = params.text ---@diagnostic disable-line
        local texture, texture_rect = tweak_data.ehi.default.hudlist.get_icon(self._BAG_ICON)
        local icon = panel:bitmap({
            name = "text_bg",
            w = w,
            h = w,
            texture = texture,
            texture_rect = texture_rect
        })
        local text = panel:text({
            name = "text_name",
            text = def.name:sub(1, 10) or "",
            align = "center",
            vertical = "center",
            w = panel:w(),
            h = panel:w(),
            color = def.color or self._TEXT_COLOR,
            blend_mode = "normal",
            font = tweak_data.hud_corner.assault_font,
            font_size = panel:w() * 0.45,
            layer = 2
        })
        local _, _, ww, _ = text:text_rect()
        text:set_font_size(math.min(text:font_size() * (text:w() / ww) * 0.9, text:font_size()))
        text:set_center(icon:center())
        text:set_y(text:y() + text:h() * 0.1)
        local previous_w = icon:w()
        icon:set_w(previous_w * 1.2)
        icon:set_center(text:center())
        text:move(0, 2 * scale)
    end
end

---@param type integer
function FakeEHIRightLootItem:UpdateTopType(type)
    local loot_icon = type == 1
    local loot_name = type == 2
    for _, item in ipairs(self._items) do
        local panel = item.panel
        panel:child("icon"):set_visible(loot_icon)
        panel:child("text_bg"):set_visible(loot_name)
        panel:child("text_name"):set_visible(loot_name)
    end
end

---@param visibility boolean
function FakeEHIRightLootItem:UpdateCrateVisibility(visibility)
    self:_get_item_by_id("crate").panel:set_visible(visibility)
end

---@class FakeEHIRightStealthItem : FakeEHIRightItemBase
---@field super FakeEHIRightItemBase
FakeEHIRightStealthItem = class(FakeEHIRightItemBase)
function FakeEHIRightStealthItem:UpdateDataFromOptions(params)
    local bodybags = self._items[4]
    local placed = math.random(1, 3)
    if placed == bodybags.value then
        bodybags.placed_bodybags = placed + 1
    else
        bodybags.placed_bodybags = placed
    end
    self:SetBodybagsFormat(params.bodybags_format, bodybags)
end

---@param format integer
---@param item FakeEHIRightItemBase.Item?
function FakeEHIRightStealthItem:SetBodybagsFormat(format, item)
    local str
    if format == 1 then
        str = "$mine;/$placed;"
    elseif format == 2 then
        str = "$placed;/$mine;"
    elseif format == 3 then
        str = "$mine;"
    else -- 4
        str = "$placed;"
    end
    item = item or self._items[4]
    item.text:set_text(managers.localization:_text_macroize(str, { mine = item.value, placed = item.placed_bodybags })) ---@diagnostic disable-line
end