if not EHITracker then
    EHI:LoadTracker("EHITracker")
end

local icons = tweak_data.ehi and tweak_data.ehi.icons or {}
local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

---@param panel Panel
---@param params Panel_Params
---@param config table
local function HUDBGBox_create(panel, params, config) -- Not available when called from menu
    local box_panel = panel:panel(params)
    local corner_visible = config.bg_visible and config.corner_visible

    box_panel:rect({
        blend_mode = "normal",
        name = "bg",
        halign = "grow",
        alpha = 0.25,
        layer = -1,
        valign = "grow",
        color = Color(1, 0, 0, 0),
        visible = config.bg_visible
    })

    local corner_texture_rect = { 80, 150, 8, 8 }
    box_panel:bitmap({
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = corner_texture_rect,
        name = "left_top",
        visible = corner_visible,
        layer = 0,
        y = 0,
        halign = "left",
        x = 0,
        valign = "top",
        color = Color.white,
        blend_mode = "add"
    })
    local left_bottom = box_panel:bitmap({
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = corner_texture_rect,
        name = "left_bottom",
        visible = corner_visible,
        layer = 0,
        x = 0,
        y = 0,
        halign = "left",
        rotation = -90,
        valign = "bottom",
        color = Color.white,
        blend_mode = "add"
    })
    left_bottom:set_bottom(box_panel:h())
    local right_top = box_panel:bitmap({
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = corner_texture_rect,
        name = "right_top",
        visible = corner_visible,
        layer = 0,
        x = 0,
        y = 0,
        halign = "right",
        rotation = 90,
        valign = "top",
        color = Color.white,
        blend_mode = "add"
    })
    right_top:set_right(box_panel:w())
    local right_bottom = box_panel:bitmap({
        texture = "guis/textures/pd2_mod_ehi/menu_atlas",
        texture_rect = corner_texture_rect,
        name = "right_bottom",
        visible = corner_visible,
        layer = 0,
        x = 0,
        y = 0,
        halign = "right",
        rotation = 180,
        valign = "bottom",
        color = Color.white,
        blend_mode = "add"
    })
    right_bottom:set_right(box_panel:w())
    right_bottom:set_bottom(box_panel:h())

    return box_panel
end

---@class FakeEHITracker : EHITracker
---@field _icons PanelBitmap[]
---@field _text_color Color?
---@field _UPDATE_TIME_FORMAT_DISABLED boolean
FakeEHITracker = class()
FakeEHITracker.pre_init = EHITracker.pre_init
FakeEHITracker.post_init = EHITracker.post_init
FakeEHITracker.CreateIcon = EHITracker.CreateIcon
FakeEHITracker.CreateText = EHITracker.CreateText
FakeEHITracker.FitTheText = EHITracker.FitTheText
FakeEHITracker._SetBGSize = EHITracker.SetBGSize
FakeEHITracker.SetIconsX = EHITracker.SetIconsX
FakeEHITracker._gap = tweak_data.ehi.default.tracker.gap
FakeEHITracker._icon_size = tweak_data.ehi.default.tracker.size_h
FakeEHITracker._icon_gap_size = FakeEHITracker._icon_size + FakeEHITracker._gap
FakeEHITracker._selected_color = Color(255, 255, 165, 0) / 255
---@param panel Panel
---@param params EHITracker.params
---@param parent_class FakeEHITrackerManager
function FakeEHITracker:init(panel, params, parent_class)
    self:pre_init(params)
    self._format = params.format
    self._scale = params.scale --[[@as number]]
    self._text_scale = params.text_scale --[[@as number]]
    self._first = params.first
    self._tracker_alignment = params.tracker_alignment
    self._tracker_vertical_anim_left = params.tracker_vertical_anim == 2
    self._corners_visible = params.corners
    self._icons = {}
    self._n_of_icons = 0
    self._bg_box_w = tweak_data.ehi.default.tracker.size_w * self._scale
    self.__icon_pos_left = params.icon_pos == 1
    local gap = 0
    if params.icons then
        self._n_of_icons = #params.icons
        gap = self._gap * self._n_of_icons
    end
    self._n = self._n_of_icons
    self._gap_scaled = self._gap * self._scale -- 5 * self._scale
    self._icon_size_scaled = tweak_data.ehi.default.tracker.size_h * self._scale -- 32 * self._scale
    self._icon_gap_size_scaled = (self._icon_size + self._gap) * self._scale -- (32 + 5) * self._scale
    self._panel = panel:panel({
        x = params.x,
        y = params.y,
        w = (64 + gap + (self._icon_size * self._n_of_icons)) * self._scale,
        h = self._icon_size_scaled,
        alpha = 1,
        visible = true
    })
    self._time = params.time or 0
    self._bg_box = HUDBGBox_create(self._panel, {
        x = self.__icon_pos_left and (self._icon_gap_size_scaled * self._n_of_icons) or 0,
        y = 0,
        w = self._bg_box_w,
        h = self._icon_size_scaled
    }, {
        bg_visible = params.bg,
        corner_visible = self._corners_visible
    })
    self:UpdateCornerVisibility(params.bg and self._corners_visible)
    if params.extend then
        self:SetBGSize()
    elseif params.extend_half then
        self:SetBGSize(self._bg_box:w() / 2)
    end
    self._text = self._bg_box:text({
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = params.extend_half and self._bg_box:w() or (64 * self._scale),
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.text_color or self._text_color or Color.white
    })
    self:FitTheText()
    if self._n_of_icons > 0 then
        local start = self.__icon_pos_left and 0 or self._bg_box:w()
        local icon_gap = self.__icon_pos_left and 0 or self._gap_scaled
        for i, v in ipairs(params.icons) do
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                self:CreateIcon(i, texture, rect, start + icon_gap, true, Color.white, 1)
            else -- table
                local texture, rect = GetIcon(v.icon)
                self:CreateIcon(i, texture, rect, start + icon_gap,
                    v.visible ~= false,
                    v.color,
                    v.alpha or 1)
            end
            start = start + self._icon_size_scaled
            icon_gap = icon_gap + self._gap_scaled
        end
        self:UpdateIcons()
        if params.one_icon then
            self:UpdateIconsVisibility(true)
        end
    end
    self._id = params.ids or params.id
    self._parent_class = parent_class
    self:post_init(params)
end

---`self._bg_box:right() - self._bg_box:x()`
function FakeEHITracker:GetBGBoxRight()
    return self._bg_box:right() - self._bg_box:x()
end

function FakeEHITracker:SetBGSize(w, type, dont_recalculate_panel_w, dont_move_icons)
    if self._tracker_vertical_anim_left or self.__icon_pos_left then
        self._panel:set_x(self._panel:x() - (w or self._bg_box:w()))
    end
    self:_SetBGSize(w, type, dont_recalculate_panel_w, dont_move_icons)
end

---@param previous_icon PanelBitmap?
---@param icon PanelBitmap? Defaults to `self._icons[1]` if not provided
function FakeEHITracker:SetIconX(previous_icon, icon)
    icon = icon or self._icons[1]
    if icon then
        local x = previous_icon and previous_icon:right() or (self.__icon_pos_left and 0 or self._bg_box:w())
        local gap = previous_icon and self._gap_scaled or (self.__icon_pos_left and 0 or self._gap_scaled)
        icon:set_x(x + gap)
    end
end

function FakeEHITracker:UpdateTimeFormat()
    if self._UPDATE_TIME_FORMAT_DISABLED then
        return
    end
    self._text:set_text(self:Format())
    self:FitTheText()
end

---@param format_key string
---@param format any
---@param reposition boolean?
---@param from_init boolean?
function FakeEHITracker:UpdateInternalFormat(format_key, format, reposition, from_init)
end

function FakeEHITracker:Format()
    if self._format.time == 1 then
        return tweak_data.ehi.functions.FormatSecondsOnly(self)
    else
        return tweak_data.ehi.functions.FormatMinutesAndSeconds(self)
    end
end

---@param x number
function FakeEHITracker:SetX(x)
    self._panel:set_x(x)
    if self._tracker_vertical_anim_left then
        if self._bg_box:w() > self._bg_box_w then
            self._panel:set_x(self._panel:x() - (self._bg_box:w() - self._bg_box_w))
        elseif self.__icon_pos_left and self._n_of_icons > 1 and self._n > 1 then
            local n_of_icons = self._n_of_icons - 1
            self._panel:set_x(self._panel:x() - (self._icon_gap_size_scaled * n_of_icons))
        end
    elseif self.__icon_pos_left and self._n_of_icons > 1 and self._n > 1 then
        local n_of_icons = self._n_of_icons - 1
        self._panel:set_x(self._panel:x() - (self._icon_gap_size_scaled * n_of_icons))
    end
end

---@param y number
function FakeEHITracker:SetY(y)
    self._panel:set_y(y)
end

---@param x number
---@param y number
function FakeEHITracker:SetPos(x, y)
    self:SetX(x)
    self:SetY(y)
end

---@param id string
function FakeEHITracker:SetSelected(id)
    local previous = self._selected
    self._selected = self:CompareID(id)
    if previous == self._selected then
        return
    end
    self:SetTextColor()
end

function FakeEHITracker:SetTextColor()
    self._text:set_color(self._selected and self._selected_color or Color.white)
end

---@param visibility boolean
---@param corners boolean
function FakeEHITracker:UpdateBGVisibility(visibility, corners)
    self._bg_box:child("bg"):set_visible(visibility)
    self:UpdateCornerVisibility(visibility and corners)
end

---@param visibility boolean
function FakeEHITracker:UpdateCornerVisibility(visibility)
    self._corners_visible = visibility
    self._bg_box:child("left_top"):set_visible(false)
    self._bg_box:child("left_bottom"):set_visible(false)
    self._bg_box:child("right_top"):set_visible(false)
    self._bg_box:child("right_bottom"):set_visible(false)
    if visibility then
        self._bg_box:child("left_top"):set_visible(true)
        self._bg_box:child("left_bottom"):set_visible(true)
        self._bg_box:child("right_top"):set_visible(true)
        self._bg_box:child("right_bottom"):set_visible(true)
    elseif not self._first then
        return
    elseif self._tracker_alignment == 2 then
        if self._tracker_vertical_anim_left then
            self._bg_box:child("right_bottom"):set_visible(true)
        else
            self._bg_box:child("left_bottom"):set_visible(true)
        end
    elseif self._tracker_alignment <= 2 and self._tracker_vertical_anim_left then
        self._bg_box:child("right_top"):set_visible(true)
    else
        self._bg_box:child("left_top"):set_visible(true)
    end
end

---@param visibility boolean
function FakeEHITracker:UpdateIconsVisibility(visibility)
    local i_start = visibility and 2 or 1
    self._n = visibility and 1 or self._n_of_icons
    for i = i_start, self._n_of_icons, 1 do
        self._icons[i]:set_visible(not visibility)
    end
    if self.__icon_pos_left then
        self._bg_box:set_x(self._icon_gap_size_scaled * self._n)
    end
end

function FakeEHITracker:UpdateIcons()
end

---@param pos number
function FakeEHITracker:UpdateIconsPosition(pos)
    self.__icon_pos_left = pos == 1
end

---@param color Color?
function FakeEHITracker:UpdateIconColor(color)
    if self._icons[1] then
        self._icons[1]:set_color(color or Color.white)
    end
end

---@param scale number
function FakeEHITracker:UpdateTextScale(scale)
    self._text_scale = scale
    self:FitTheText()
end

---@param anim number
function FakeEHITracker:UpdateTrackerVerticalAnim(anim)
    local vertical = anim == 2
    if self._tracker_vertical_anim_left == vertical then
        return
    end
    self._tracker_vertical_anim_left = vertical
    if self._first then
        self._parent_class:_update_border_color(self._bg_box)
    end
    self:UpdateCornerVisibility(self._bg_box:child("bg"):visible() and self._corners_visible)
end

function FakeEHITracker:GetSize()
    if self._n == 1 then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return self._panel:w()
end

function FakeEHITracker:Reposition()
    self._parent_class:ForceReposition()
end

---@param id string
function FakeEHITracker:CompareID(id)
    if type(self._id) == "string" then
        return id == self._id
    end
    return table.contains(self._id, id)
end

function FakeEHITracker:destroy()
    if alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

---@class FakeEHITradeDelayTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHITradeDelayTracker = class(FakeEHITracker)
function FakeEHITradeDelayTracker:pre_init(params)
    self._civilians_killed = math.random(1, 8)
    params.time = 5 + (self._civilians_killed * 30)
end

---@param format boolean
function FakeEHITradeDelayTracker:UpdateInternalFormat(format_key, format)
    if format_key ~= "killed_civilians" then
        return
    elseif format then
        self:SetBGSize(self._bg_box:w() / 2)
    else
        self:SetBGSize(64 * self._scale, "set")
    end
    self._text:set_w(self._bg_box:w())
    self:UpdateTimeFormat()
    self:Reposition()
end

function FakeEHITradeDelayTracker:Format()
    local s = FakeEHITradeDelayTracker.super.Format(self)
    return self._format.killed_civilians and string.format("%s (%d)", s, self._civilians_killed) or s
end

---@class FakeEHIXPTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIXPTracker = class(FakeEHITracker)
function FakeEHIXPTracker:pre_init(...)
    self._xp = math.random(1000, 1000000)
end

function FakeEHIXPTracker:Format()
    return managers.experience:cash_string(self._xp, "+")
end

---@class FakeEHIProgressTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIProgressTracker = class(FakeEHITracker)
function FakeEHIProgressTracker:pre_init(params)
    self._progress = math.random(0, params.progress or 9)
    self._max = params.max or 10
end

function FakeEHIProgressTracker:Format()
    return self._progress .. "/" .. self._max
end

---@class FakeEHIChanceTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIChanceTracker = class(FakeEHITracker)
function FakeEHIChanceTracker:pre_init(params)
    self._chance = params.chance or (math.random(1, 10) * 5)
end

function FakeEHIChanceTracker:Format()
    return self._chance .. "%"
end

---@class FakeEHIEscapeChanceTracker : FakeEHIChanceTracker
---@field super FakeEHIChanceTracker
FakeEHIEscapeChanceTracker = class(FakeEHIChanceTracker)
function FakeEHIEscapeChanceTracker:post_init(params)
    local icon = self._icons[1]
    icon:rotate(180)
    local texture, texture_rect = tweak_data.hud_icons:get_icon_data("pd2_fire")
    self:CreateIcon(2, texture, texture_rect, icon:x(), true, Color("FFA500"), 0.75)
    self._icons[2]:set_layer(-1)
end

---@class FakeEHIEquipmentTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIEquipmentTracker = class(FakeEHITracker)
FakeEHIEquipmentTracker._UPDATE_TIME_FORMAT_DISABLED = true
function FakeEHIEquipmentTracker:pre_init(params)
    self._show_placed = params.show_placed
    self._charges = math.random(params.min or 2, params.charges or 16)
    self._placed = self._charges > 4 and math.ceil(self._charges / 4) or 1
end

function FakeEHIEquipmentTracker:Format()
    if self._format.equipment == 1 then -- Uses (Bags placed)
        if self._show_placed then
            return self._charges .. " (" .. self._placed .. ")"
        else
            return tostring(self._charges)
        end
    elseif self._format.equipment == 2 then -- (Bags placed) Uses
        if self._show_placed then
            return "(" .. self._placed .. ") " .. self._charges
        else
            return tostring(self._charges)
        end
    elseif self._format.equipment == 3 then -- (Uses) Bags placed
        if self._show_placed then
            return "(" .. self._charges .. ") " .. self._placed
        else
            return tostring(self._charges)
        end
    elseif self._format.equipment == 4 then -- Bags placed (Uses)
        if self._show_placed then
            return self._placed .. " (" .. self._charges .. ")"
        else
            return tostring(self._charges)
        end
    elseif self._format.equipment == 5 then -- Uses
        return tostring(self._charges)
    elseif self._show_placed then -- Bags placed
        return tostring(self._placed)
    else
        return tostring(self._charges)
    end
end

function FakeEHIEquipmentTracker:UpdateEquipmentFormat()
    self._text:set_font_size(self._panel:h() * self._text_scale)
    self._text:set_text(self:Format())
    self:FitTheText()
end

---@class FakeEHIMinionTracker : FakeEHIEquipmentTracker
---@field super FakeEHIEquipmentTracker
FakeEHIMinionTracker = class(FakeEHIEquipmentTracker)
function FakeEHIMinionTracker:post_init(params)
    self._charges_second_player = math.random(params.min, params.charges)
    self._color_second_player = self._parent_class:GetOtherPeerColor()
    self._text_second_player = self:CreateText({
        text = tostring(self._charges_second_player),
        w = self._bg_box:w() / 2,
        color = self._color_second_player,
        FitTheText = true
    })
    self._text_second_player:set_right(self:GetBGBoxRight())
    self._first_minion_health = self:CreateText({
        text = string.format("%d%%", math.random(0, 100)),
        w = self._bg_box:w(),
        visible = false
    })
    self._second_minion_health = self:CreateText({
        text = string.format("%d%%", math.random(0, 100)),
        w = self._bg_box:w(),
        visible = false
    })
    self:UpdateInternalFormat("minion", self._format.minion, false, true)
    self:SetMinionHealth(EHI:GetOption("show_minion_health"), true)
end

---@param format number
function FakeEHIMinionTracker:UpdateInternalFormat(format_key, format, reposition, from_init)
    if format_key ~= "minion" then
        return
    end
    self._icons[1]:set_color(format == 1 and self._parent_class:GetLocalPeerColor() or Color.white)
    self._text_second_player:set_visible(format == 3)
    self._text:set_text(tostring(format == 2 and (self._charges + self._charges_second_player) or self._charges))
    self._text:set_color(format == 3 and self._parent_class:GetLocalPeerColor() or Color.white)
    if format == 3 then
        self._text:set_w(self._bg_box_w / 2)
    else
        self._text:set_w(self._bg_box:w())
    end
    self:FitTheText()
    if from_init then
        return
    end
    if format == 1 and self._show_minion_health then
        if self._size_increased then
            self._size_increased = nil
            self:SetBGSize(self._bg_box_w, "set")
            self:Reposition()
        end
        local w = self._bg_box_w / 2
        local right = self:GetBGBoxRight()
        self._first_minion_health:set_w(w)
        self._first_minion_health:set_right(right)
        self:FitTheText(self._first_minion_health)
        self._first_minion_health:set_color(self._selected_color)
        self._first_minion_health:set_visible(true)
        self._second_minion_health:set_w(w)
        self._second_minion_health:set_right(right - w)
        self:FitTheText(self._second_minion_health)
        self._second_minion_health:set_color(self._selected_color)
        self._second_minion_health:set_visible(true)
        self._text:set_visible(false)
        self._minion_health_repositioned = true
    elseif format == 2 and self._show_minion_health and self._minion_health_repositioned then
        self._minion_health_repositioned = nil
        self._text:set_visible(true)
        self._first_minion_health:set_color(Color.white)
        self._second_minion_health:set_color(Color.white)
        if not self._size_increased then
            self:SetMinionHealth(self._show_minion_health)
        end
    else
        self._text:set_visible(true)
    end
end

function FakeEHIMinionTracker:SetTextColor()
    self._text:set_color(self._selected and self._selected_color or (self._format.minion == 3 and self._parent_class:GetLocalPeerColor() or Color.white))
    self._text_second_player:set_color(self._selected and self._selected_color or self._color_second_player)
    if self._minion_health_repositioned then
        self._first_minion_health:set_color(self._selected and self._selected_color or Color.white)
        self._second_minion_health:set_color(self._selected and self._selected_color or Color.white)
    end
end

---@param health boolean
---@param from_init boolean?
function FakeEHIMinionTracker:SetMinionHealth(health, from_init)
    self._show_minion_health = health
    if health then
        if self._format.minion >= 2 then
            self._size_increased = true
            self:SetBGSize()
        else
            self._text:set_visible(false)
            self._minion_health_repositioned = true
        end
        local w = self._bg_box_w / 2
        local right = self:GetBGBoxRight()
        self._first_minion_health:set_w(w)
        self._first_minion_health:set_right(right)
        self:FitTheText(self._first_minion_health)
        self._first_minion_health:set_visible(true)
        self._second_minion_health:set_w(w)
        self._second_minion_health:set_right(right - w)
        self:FitTheText(self._second_minion_health)
        self._second_minion_health:set_visible(true)
    elseif not from_init and self._size_increased then
        self._size_increased = nil
        self._minion_health_repositioned = nil
        self:SetBGSize(self._bg_box_w, "set")
        self._first_minion_health:set_visible(false)
        self._second_minion_health:set_visible(false)
    elseif self._minion_health_repositioned then
        self._minion_health_repositioned = nil
        self._first_minion_health:set_visible(false)
        self._second_minion_health:set_visible(false)
        self._text:set_w(self._bg_box:w())
        self._text:set_right(self:GetBGBoxRight())
        self._text:set_visible(true)
    end
    if not from_init then
        self:Reposition()
    end
end

---@class FakeEHICountTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHICountTracker = class(FakeEHITracker)
function FakeEHICountTracker:pre_init(params)
    self._count = params.count
end

function FakeEHICountTracker:Format()
    return tostring(self._count)
end

---@class FakeEHIEnemyCountTracker : FakeEHICountTracker
---@field super FakeEHICountTracker
FakeEHIEnemyCountTracker = class(FakeEHICountTracker)
function FakeEHIEnemyCountTracker:init(...)
    self._alarm_count = math.random(0, 10)
    FakeEHIEnemyCountTracker.super.init(self, ...)
end

function FakeEHIEnemyCountTracker:GetSize()
    if self._n >= 2 and not self._format.show_alarm_enemies then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return FakeEHIEnemyCountTracker.super.GetSize(self)
end

function FakeEHIEnemyCountTracker:Format()
    if self._format.show_alarm_enemies then
        return self._alarm_count .. "|" .. self._count
    end
    return FakeEHIEnemyCountTracker.super.Format(self)
end

function FakeEHIEnemyCountTracker:UpdateInternalFormat(format_key, format)
    if format_key ~= "show_alarm_enemies" then
        return
    end
    self._text:set_text(self:Format())
    self:FitTheText()
    self:UpdateIconPos(true)
end

---@param reposition boolean?
function FakeEHIEnemyCountTracker:UpdateIconPos(reposition)
    if self._n == 1 then -- 1 icon
        self._icons[1]:set_visible(self._format.show_alarm_enemies)
        self._icons[2]:set_visible(not self._format.show_alarm_enemies)
        self._icons[2]:set_x(self._icons[1]:x())
    else
        self._icons[1]:set_visible(self._format.show_alarm_enemies)
        self._icons[2]:set_visible(true)
        if self._format.show_alarm_enemies then
            self._icons[2]:set_x(self._icons[1]:x() + self._icon_gap_size_scaled)
        else
            self._icons[2]:set_x(self._icons[1]:x())
        end
    end
    if reposition then
        self:Reposition()
    end
end

---@param visibility boolean
function FakeEHIEnemyCountTracker:UpdateIconsVisibility(visibility)
    FakeEHIEnemyCountTracker.super.UpdateIconsVisibility(self, visibility)
    self:UpdateIconPos()
end
FakeEHIEnemyCountTracker.UpdateIcons = FakeEHIEnemyCountTracker.UpdateIconPos

---@class FakeEHITimerTracker : FakeEHITracker, FakeEHIProgressTracker
---@field super FakeEHITracker
FakeEHITimerTracker = class(FakeEHITracker)
FakeEHITimerTracker.FormatProgress = FakeEHIProgressTracker.Format
function FakeEHITimerTracker:init(...)
    self._max = 3
    self._progress = math.random(0, 2)
    FakeEHITimerTracker.super.init(self, ...)
    self._text:set_left(0)
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = self._text:right(),
        FitTheText = true
    })
end

function FakeEHITimerTracker:SetTextColor()
    FakeEHITimerTracker.super.SetTextColor(self)
    self._progress_text:set_color(self._selected and self._selected_color or Color.white)
end

function FakeEHITimerTracker:UpdateTextScale(...)
    FakeEHITimerTracker.super.UpdateTextScale(self, ...)
    self:FitTheText(self._progress_text)
end

---@class FakeEHICivilianCountTracker : FakeEHICountTracker
---@field super FakeEHICountTracker
FakeEHICivilianCountTracker = class(FakeEHICountTracker)
FakeEHICivilianCountTracker._UPDATE_TIME_FORMAT_DISABLED = true
function FakeEHICivilianCountTracker:pre_init(...)
    FakeEHICivilianCountTracker.super.pre_init(self, ...)
    self._tied_count = math.random(0, self._count)
end

function FakeEHICivilianCountTracker:GetSize()
    if self._n >= 2 and self._format.civilian_count == 1 then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return FakeEHICivilianCountTracker.super.GetSize(self)
end

function FakeEHICivilianCountTracker:UpdateInternalFormat(format_key, format)
    if format_key ~= "civilian_count" then
        return
    end
    self._text:set_text(self:Format())
    self:FitTheText()
    self:UpdateIconPos(true)
end

function FakeEHICivilianCountTracker:Format()
    if self._format.civilian_count == 1 then
        return tostring(self._count)
    else
        local untied = self._count - self._tied_count
        if self._format.civilian_count == 2 then
            return self._tied_count .. "|" .. untied
        else
            return untied .. "|" .. self._tied_count
        end
    end
end

---@param reposition boolean?
function FakeEHICivilianCountTracker:UpdateIconPos(reposition)
    if self._n == 1 then -- 1 icon
        self:SetIconX()
        self._icons[2]:set_visible(false)
    else
        self._icons[2]:set_visible(self._format.civilian_count >= 2)
        if self._format.civilian_count == 2 then
            self:SetIconX(nil, self._icons[2])
            self:SetIconX(self._icons[2])
        else
            self:SetIconsX()
        end
    end
    if reposition then
        self:Reposition()
    end
end

function FakeEHICivilianCountTracker:UpdateIcons()
    self._icons[2]:set_visible(self._format.civilian_count >= 2)
end

function FakeEHICivilianCountTracker:UpdateIconsVisibility(...)
    FakeEHICivilianCountTracker.super.UpdateIconsVisibility(self, ...)
    self:UpdateIconPos()
end

---@class FakeEHIHostageCountTracker : FakeEHICivilianCountTracker
---@field super FakeEHICivilianCountTracker
FakeEHIHostageCountTracker = class(FakeEHICivilianCountTracker)
function FakeEHIHostageCountTracker:pre_init(...)
    FakeEHIHostageCountTracker.super.pre_init(self, ...)
    self._tied_count = math.random(0, math.floor(self._count / 2))
end

function FakeEHIHostageCountTracker:Format()
    if self._format.hostage_count == 1 then
        return tostring(self._count)
    else
        local civilian_hostages = self._count - self._tied_count
        if self._format.hostage_count == 2 then
            return self._count .. "|" .. self._tied_count
        elseif self._format.hostage_count == 3 then
            return self._tied_count .. "|" .. self._count
        elseif self._format.hostage_count == 4 then
            return civilian_hostages .. "|" .. self._tied_count
        else
            return self._tied_count .. "|" .. civilian_hostages
        end
    end
end

function FakeEHIHostageCountTracker:UpdateIconPos(...)
    local original_format = self._format.hostage_count
    if self._format.hostage_count == 2 then
        self._format.hostage_count = 3
    elseif self._format.hostage_count == 3 or self._format.hostage_count == 5 then
        self._format.hostage_count = 2
    end
    FakeEHIHostageCountTracker.super.UpdateIconPos(self, ...)
    self._format.hostage_count = original_format
end

---@class FakeEHIAssaultTimeTracker : FakeEHITracker, FakeEHIChanceTracker, FakeEHICountTracker
---@field super FakeEHITracker
FakeEHIAssaultTimeTracker = class(FakeEHITracker)
FakeEHIAssaultTimeTracker.FormatChance = FakeEHIChanceTracker.Format
FakeEHIAssaultTimeTracker.FormatCount = FakeEHICountTracker.Format
function FakeEHIAssaultTimeTracker:post_init(params)
    if params.control then
        self._icons[1]:set_color(Color.white)
    elseif self._time <= 5 then -- Fade
        self._icons[1]:set_color(Color(255, 0, 255, 255) / 255)
    elseif self._time >= 205 then -- Build
        self._icons[1]:set_color(Color.yellow)
    else
        self._icons[1]:set_color(Color(255, 237, 127, 127) / 255)
    end
    self._bg_size = self._bg_box:w()
    self._chance = params.diff
    self._diff_chance_text = self:CreateText({
        text = self:FormatChance(),
        left = self._text:right()
    })
    self._count = params.count
    self._enemy_count_text = self:CreateText({
        text = self:FormatCount()
    })
    self:UpdateInternalFormat(EHI:GetOption("show_assault_diff_in_assault_trackers"), false, true)
    self:UpdateInternalFormat2(EHI:GetOption("show_assault_enemy_count"), false, true)
end

---@param format boolean
function FakeEHIAssaultTimeTracker:UpdateInternalFormat(format, reposition, from_init)
    if self._show_diff == format then
        return
    end
    self._show_diff = format
    self._diff_chance_text:set_visible(format)
    if from_init and not format then
        return
    elseif format then
        self:SetBGSize(self._bg_box_w)
        if self._show_enemy_count then
            self._enemy_count_text:set_left(self._diff_chance_text:right())
        end
    elseif self._show_enemy_count then
        self:SetBGSize(self._bg_size, "short")
        self._enemy_count_text:set_left(self._text:right())
    else
        self:SetBGSize(self._bg_size, "set")
    end
    if reposition then
        self:Reposition()
    end
end

---@param format boolean
---@param reposition boolean?
---@param from_init boolean?
function FakeEHIAssaultTimeTracker:UpdateInternalFormat2(format, reposition, from_init)
    if self._show_enemy_count == format then
        return
    end
    self._show_enemy_count = format
    self._enemy_count_text:set_visible(format)
    if from_init and not format then
        return
    elseif format then
        self:SetBGSize(self._bg_box_w)
        self._enemy_count_text:set_left(self._show_diff and self._diff_chance_text:right() or self._text:right())
    elseif self._show_diff then
        self:SetBGSize(self._bg_size, "short")
    else
        self:SetBGSize(self._bg_size, "set")
    end
    if reposition then
        self:Reposition()
    end
end

function FakeEHIAssaultTimeTracker:SetTextColor()
    FakeEHIAssaultTimeTracker.super.SetTextColor(self)
    self._diff_chance_text:set_color(self._selected and self._selected_color or Color.white)
    self._enemy_count_text:set_color(self._selected and self._selected_color or Color.white)
end

---@class FakeEHISniperTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHISniperTracker = class(FakeEHITracker)
FakeEHISniperTracker._UPDATE_TIME_FORMAT_DISABLED = true
function FakeEHISniperTracker:post_init(params)
    self._text:set_text(tostring(math.random(1, 4)))
    self._text:set_w(self._bg_box:w() / 2)
    self._chance_text = self:CreateText({
        text = string.format("%d%%", math.random(0, 100)),
        color = EHI:GetColorFromOption("tracker_waypoint", "sniper_chance"),
        x = 0,
        w = self._bg_box:w() / 2,
        FitTheText = true
    })
    self._text:set_right(self:GetBGBoxRight())
    self._text:set_color(EHI:GetColorFromOption("tracker_waypoint", "sniper_count"))
end

function FakeEHISniperTracker:SetTextColor()
    self._icons[1]:set_color(self._selected and self._text_color or Color.white)
end

---@param color Color
function FakeEHISniperTracker:UpdateSniperCountColor(color)
    self._text:set_color(color)
end

---@param color Color
function FakeEHISniperTracker:UpdateSniperChanceColor(color)
    self._chance_text:set_color(color)
end

---@class FakeEHIPhalanxChanceTracker : FakeEHITimerTracker
---@field super FakeEHITimerTracker
FakeEHIPhalanxChanceTracker = class(FakeEHITimerTracker)
FakeEHIPhalanxChanceTracker.FormatProgress = FakeEHIChanceTracker.Format
function FakeEHIPhalanxChanceTracker:init(...)
    self._chance = 5 + (9 * math.random(0, 5))
    FakeEHIPhalanxChanceTracker.super.init(self, ...)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
end