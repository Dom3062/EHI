local Color = Color
---@param o Object
---@param hint Text
---@param end_a number End alpha
local function visibility_hint(o, hint, end_a)
    local t, TOTAL_T = 0, 0.18
    local o_start_a = o:alpha()
    local hint_start_a = hint:alpha()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_alpha(math.lerp(o_start_a, end_a, lerp))
        hint:set_alpha(math.lerp(hint_start_a, end_a, lerp))
    end
end
---@param o Object
---@param end_a number End alpha
local function visibility(o, end_a) -- This is actually faster than manually re-typing optimized "over" function
    local t, TOTAL_T = 0, 0.18
    local start_a = o:alpha()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        o:set_alpha(math.lerp(start_a, end_a, t / TOTAL_T))
    end
end
---@param o Object
---@param t number
---@param self EHITracker
local function hint_wait(o, t, self)
    wait(t)
    visibility(o, 0)
    if not self._hide_on_delete then
        o:parent():remove(o)
        self._hint = nil
        self._hint_pos = nil
        self._parent_class:_hint_removed(self._id)
    end
end
---@param o Object
---@param target_y number
local function top(o, target_y)
    local t, total = 0, 0.18
    local from_y = o:y()
    while t < total do
        t = t + coroutine.yield()
        o:set_y(math.lerp(from_y, target_y, t / total))
    end
    o:set_y(target_y)
end
---@param o Object
---@param target_x number
---@param target_y number
local function top_left(o, target_x, target_y)
    local t, total = 0, 0.18
    local from_x, from_y = o:x(), o:y()
    while t < total do
        t = t + coroutine.yield()
        local lerp = t / total
        o:set_x(math.lerp(from_x, target_x, lerp))
        o:set_y(math.lerp(from_y, target_y, lerp))
    end
    o:set_x(target_x)
    o:set_y(target_y)
end
---@param o Object
---@param target_x number
local function left(o, target_x)
    local t, total = 0, 0.18
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math.lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
local panel_w
if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Horizontal_RightToLeft) or EHI:IsVerticalAlignmentAndOption("tracker_vertical_w_anim") == EHI.Const.Trackers.Vertical.WidthAnim.RightToLeft then -- Horizontal; Right to Left or Panel W anim is Right to Left and Vertical alignment
    if EHI:GetOption("show_tracker_bg") then
        ---@param o Object
        ---@param target_w number
        ---@param self EHITracker
        panel_w = function(o, target_w, self)
            local TOTAL_T = 0.18
            local from_x, from_w = o:x(), o:w()
            local abs = -(from_w - target_w)
            local target_x = from_x + -(target_w - from_w)
            local t = (1 - abs / abs) * TOTAL_T
            while TOTAL_T > t do
                local dt = coroutine.yield()
                t = math.min(t + dt, TOTAL_T)
                local lerp = t / TOTAL_T
                o:set_x(math.lerp(from_x, target_x, lerp))
                o:set_w(math.lerp(from_w, target_w, lerp))
            end
            self:RedrawPanel()
        end
    else -- No need to animate as the background is not visible
        ---@param o Object
        ---@param target_w number
        ---@param self EHITracker
        panel_w = function(o, target_w, self)
            local from_w = o:w()
            o:set_x(o:x() + -(target_w - from_w))
            o:set_w(target_w)
            self:RedrawPanel()
        end
    end
elseif EHI:GetOption("show_tracker_bg") then
    ---@param o Object
    ---@param target_w number
    ---@param self EHITracker
    panel_w = function(o, target_w, self)
        local TOTAL_T = 0.18
        local from_w = o:w()
        local abs = -(from_w - target_w)
        local t = (1 - abs / abs) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math.min(t + dt, TOTAL_T)
            o:set_w(math.lerp(from_w, target_w, t / TOTAL_T))
        end
        self:RedrawPanel()
    end
else -- No need to animate as the background is not visible
    ---@param o Object
    ---@param target_w number
    ---@param self EHITracker
    panel_w = function(o, target_w, self)
        o:set_w(target_w)
        self:RedrawPanel()
    end
end
---@param o Object
---@param target_x number
local function icon_x(o, target_x)
    local TOTAL_T = 0.18
    local from_x = o:x()
    local t = (1 - math.abs(from_x - target_x) / math.abs(from_x - target_x)) * TOTAL_T
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        o:set_x(math.lerp(from_x, target_x, t / TOTAL_T))
    end
end
---@param o Text
---@param target_x number
---@param target_w number
---@param fit_the_text_after_anim boolean?
---@param self EHITracker
local function text_move_x_w(o, target_x, target_w, fit_the_text_after_anim, self)
    local t, TOTAL_T = 0, 0.18
    local from_x, from_w = o:x(), o:w()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math.min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_x(math.lerp(from_x, target_x, lerp))
        o:set_w(math.lerp(from_w, target_w, lerp))
    end
    if fit_the_text_after_anim then
        self:FitTheText(o)
    end
end
---@param o Object
---@param skip_anim boolean
---@param self EHITracker
local function destroy(o, skip_anim, self)
    if not skip_anim then
        if self._hint then
            visibility_hint(o, self._hint, 0)
        else
            visibility(o, 0)
        end
    end
    o:parent():remove(o)
    if self._hint then
        self._hint:parent():remove(self._hint)
    end
end
local GetIcon = tweak_data.ehi.default.tracker.get_icon

local bg_visibility = EHI:GetOption("show_tracker_bg") --[[@as boolean]]
local corner_visibility = EHI:GetOption("show_tracker_corners") --[[@as boolean]]

---@param panel Panel
---@param params Panel_Params
local function CreateHUDBGBox(panel, params)
    local box_panel = panel:panel(params)
	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = bg_visibility
	})
    if bg_visibility and corner_visibility then
        box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            y = 0,
            halign = "left",
            x = 0,
            valign = "top",
            blend_mode = "add"
        })
        local left_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "left",
            rotation = -90,
            valign = "bottom",
            blend_mode = "add"
        })
        left_bottom:set_bottom(box_panel:h())
        local right_top = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 90,
            valign = "top",
            blend_mode = "add"
        })
        right_top:set_right(box_panel:w())
        local right_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 180,
            valign = "bottom",
            blend_mode = "add"
        })
        right_bottom:set_right(box_panel:w())
        right_bottom:set_bottom(box_panel:h())
    end
	return box_panel
end

---@class EHITracker
---@field new fun(self: self, panel: Panel, params: ElementTrigger): self
---@field _parent_class EHITrackerManager Added when `EHITrackerManager` class is created
---@field _forced_icons table? Forces specific icons in the tracker
---@field _forced_time number? Forces specific time in the tracker
---@field _forced_hint_text string? Forces specific hint text in the tracker
---@field _hint_no_localization boolean?
---@field _hint_vanilla_localization boolean?
EHITracker = class()
EHITracker._needs_update = true
EHITracker._fade_time = 5
EHITracker._scale = EHI:GetOption(_G.IS_VR and "vr_scale" or "scale") --[[@as number]]
EHITracker._text_scale = EHI:GetOption("text_scale") --[[@as number]]
-- 32 + 5
EHITracker._icon_gap_size = tweak_data.ehi.default.tracker.size_h + tweak_data.ehi.default.tracker.gap
-- (32 + 5) * self._scale
EHITracker._icon_gap_size_scaled = EHITracker._icon_gap_size * EHITracker._scale
-- 32 * self._scale
EHITracker._icon_size_scaled = tweak_data.ehi.default.tracker.size_h * EHITracker._scale
-- 5 * self._scale
EHITracker._gap_scaled = tweak_data.ehi.default.tracker.gap * EHITracker._scale
EHITracker._default_bg_size = tweak_data.ehi.default.tracker.size_w * EHITracker._scale
EHITracker._default_bg_size_half = EHITracker._default_bg_size / 2
EHITracker._text_color = Color.white
if EHI:GetOption("show_tracker_hint") then
    EHITracker._hint_t = EHI:GetOption("show_tracker_hint_t") --[[@as number]]
else
    EHITracker._hint_disabled = true
end
EHITracker._init_create_text = true
if EHI:GetOption("show_icon_position") == EHI.Const.Trackers.IconStartPosition.Left then
    EHITracker._ICON_LEFT_SIDE_START = true
end
-- Default size is based on default tracker size with one icon
EHITracker.__default_panel_size = EHITracker._default_bg_size + EHITracker._icon_gap_size_scaled
---@enum EHITracker.AnimParams
EHITracker._anim_params = {
    IconCreated = 1,
    IconDeleted = 2,
    PanelSizeIncrease = 3, -- 64 * scale (Same size as default BG size)
    PanelSizeIncreaseHalf = 4, -- 32 * scale (Half size as default BG size)
    PanelSizeDecrease = 5, -- 64 * scale (Same size as default BG size)
    PanelSizeDecreaseHalf = 6 -- 32 * scale (Half size as default BG size)
}
EHITracker._make_fine_text = BlackMarketGui.make_fine_text
---@param panel Panel Main panel provided by `EHITrackerManager`
---@param params EHITracker.params
function EHITracker:init(panel, params)
    self:pre_init(params)
    self._id = params.id
    self._icons = {} ---@type Bitmap[]
    local n_of_icons = 0
    local tracker_icons = self._forced_icons or params.icons
    if type(tracker_icons) == "table" then
        n_of_icons = #tracker_icons
        if self._ONE_ICON and n_of_icons > 1 then
            n_of_icons = 1
        end
        if self._ICON_LEFT_SIDE_START and self._VERTICAL_ANIM_W_LEFT and n_of_icons > 1 and not self._HORIZONTAL_ALIGNMENT then
            self.__vertical_anim_w_left_diff = -(self._icon_gap_size_scaled * (n_of_icons - 1))
        end
    end
    self._time = self._forced_time or params.time or 0
    self._panel = panel:panel({
        x = 0,
        y = 0,
        w = (64 + (self._icon_gap_size * n_of_icons)) * self._scale,
        h = self._icon_size_scaled,
        alpha = 0,
        visible = true
    })
    self._bg_box = CreateHUDBGBox(self._panel, {
        x = self._ICON_LEFT_SIDE_START and (self._icon_gap_size_scaled * n_of_icons) or 0,
        y = 0,
        w = self._default_bg_size,
        h = self._icon_size_scaled
    })
    if self._init_create_text then
        self._text = self._bg_box:text({
            text = self:Format(),
            align = "center",
            vertical = "center",
            w = self._bg_box:w(),
            h = self._icon_size_scaled,
            font = tweak_data.menu.pd2_large_font,
            font_size = self._panel:h() * self._text_scale,
            color = self._text_color
        })
        self:FitTheText()
    end
    if n_of_icons > 0 then
        self:CreateIcons(tracker_icons, params.first_icon_pos) ---@diagnostic disable-line
    end
    self:OverridePanel()
    self._hide_on_delete = params.hide_on_delete
    self._flash_times = params.flash_times or 3
    self._anim_flash = params.flash_bg ~= false
    self._remove_on_alarm = params.remove_on_alarm --Removes tracker when alarm sounds
    self._update_on_alarm = params.update_on_alarm --Calls `OnAlarm` function when alarm sounds
    self:post_init(params)
    self:CreateHint(params.hint, params.delay_popup)
end

---@param params EHITracker.params
function EHITracker:pre_init(params)
end

---@param params EHITracker.params
function EHITracker:post_init(params)
end

function EHITracker:OverridePanel()
end

---@param anim_type EHITracker.AnimParams
function EHITracker:SetMovement(anim_type)
    if anim_type == self._anim_params.IconCreated then
        self:_set_icons_x()
        if self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT then
            self._bg_box:set_x(self._bg_box:x() + self._icon_gap_size_scaled)
            if self._HORIZONTAL_RIGHT_TO_LEFT then
                self._panel:set_x(self._panel:x() - self._icon_gap_size_scaled)
            end
        end
        self:_change_tracker_width(self:GetTrackerSize(), true)
        if self._HORIZONTAL_ALIGNMENT then
            self:_adjust_horizontal_hint_x()
        elseif not self._VERTICAL_ANIM_W_LEFT then
            self:AdjustHintX(self._icon_gap_size_scaled)
        end
    elseif anim_type == self._anim_params.IconDeleted then
    elseif anim_type == self._anim_params.PanelSizeIncrease or anim_type == self._anim_params.PanelSizeIncreaseHalf then
        local size = anim_type == self._anim_params.PanelSizeIncrease and self._default_bg_size or self._default_bg_size_half
        self:SetBGSize(size, "add")
        self:_change_tracker_width()
        if self._VERTICAL_ANIM_W_LEFT or self._HORIZONTAL_RIGHT_TO_LEFT then
            self._panel:set_x(self._panel:x() - size)
        end
        if self._HORIZONTAL_ALIGNMENT then
            self:_adjust_horizontal_hint_x()
        elseif not (self._VERTICAL_ANIM_W_LEFT and self._VERTICAL_HINT_POS_RIGHT) then
            self:AdjustHintX(self._VERTICAL_HINT_POS_LEFT and -size or size)
        end
    elseif anim_type == self._anim_params.PanelSizeDecrease or anim_type == self._anim_params.PanelSizeDecreaseHalf then
        local size = anim_type == self._anim_params.PanelSizeDecrease and self._default_bg_size or self._default_bg_size_half
        self:SetBGSize(size, "sub")
        self:_change_tracker_width()
        if self._VERTICAL_ANIM_W_LEFT or self._HORIZONTAL_RIGHT_TO_LEFT then
            self._panel:set_x(self._panel:x() + size)
        end
        if self._HORIZONTAL_ALIGNMENT then
            self:_adjust_horizontal_hint_x()
        elseif self._VERTICAL_HINT_POS_LEFT then
            self:AdjustHintX(size)
        elseif not (self._VERTICAL_ANIM_W_LEFT and self._VERTICAL_HINT_POS_RIGHT) then
            self:AdjustHintX(self._VERTICAL_HINT_POS_LEFT and size or -size)
        end
    end
end

---@param anim_type EHITracker.AnimParams
function EHITracker:AnimateMovement(anim_type)
    if anim_type == self._anim_params.IconCreated then
        self:_anim_icons_x(self._VERTICAL_ANIM_W_LEFT and 0 or self._icon_gap_size_scaled)
        if self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT then
            self:_animate_bg_left(self._bg_box:x() + self._icon_gap_size_scaled)
        end
        self:_change_tracker_width(self:GetTrackerSize(), true)
        if not self._VERTICAL_ANIM_W_LEFT or (self._VERTICAL_ANIM_W_LEFT and self._ICON_LEFT_SIDE_START) then
            self:_animate_adjust_hint_x(-self._icon_gap_size_scaled)
        end
    elseif anim_type == self._anim_params.IconDeleted then
        self:_anim_icons_x(self._VERTICAL_ANIM_W_LEFT and self._icon_gap_size_scaled or 0)
        if self._ICON_LEFT_SIDE_START and not self._VERTICAL_ANIM_W_LEFT then
            self:_animate_bg_left(self._bg_box:x() - self._icon_gap_size_scaled)
        end
        self:_change_tracker_width(self:GetTrackerSize(), true)
        if not self._VERTICAL_ANIM_W_LEFT or (self._VERTICAL_ANIM_W_LEFT and self._ICON_LEFT_SIDE_START) then
            self:_animate_adjust_hint_x(self._icon_gap_size_scaled)
        end
    elseif anim_type == self._anim_params.PanelSizeIncrease or anim_type == self._anim_params.PanelSizeIncreaseHalf then
        local size = anim_type == self._anim_params.PanelSizeIncrease and self._default_bg_size or self._default_bg_size_half
        self:SetBGSize(size, "add", true)
        local new_panel_w = self:GetTrackerSize()
        if not (self._VERTICAL_ANIM_W_LEFT and self._HORIZONTAL_RIGHT_TO_LEFT) then
            self:_anim_icons_x()
        end
        self:_animate_panel_w(new_panel_w)
        self:_change_tracker_width(new_panel_w)
        self:_animate_adjust_hint_x(-size)
    elseif anim_type == self._anim_params.PanelSizeDecrease or anim_type == self._anim_params.PanelSizeDecreaseHalf then
        local size = anim_type == self._anim_params.PanelSizeDecrease and self._default_bg_size or self._default_bg_size_half
        self:SetBGSize(size, "sub", true)
        local new_panel_w = self:GetTrackerSize()
        if not (self._VERTICAL_ANIM_W_LEFT and self._HORIZONTAL_RIGHT_TO_LEFT) then
            self:_anim_icons_x()
        end
        self:_animate_panel_w(new_panel_w)
        self:_change_tracker_width(new_panel_w)
        self:_animate_adjust_hint_x(size)
    end
end

---@param i number
---@param set_next_icon_visible boolean?
function EHITracker:RemoveIconAndAnimateMovement(i, set_next_icon_visible)
    local icon = table.remove(self._icons, i) ---@cast icon Bitmap?
    if icon then
        self._panel:remove(icon)
        table.remove(self._icon_anims or {}, i)
        if set_next_icon_visible then
            local next_icon = self._icons[i]
            if next_icon then
                next_icon:set_visible(true)
            end
        end
        self:AnimateMovement(self._anim_params.IconDeleted)
    end
end

---@param anim_type EHITracker.AnimParams
---@param set_movement_condition boolean
function EHITracker:AnimateOrSetMovement(anim_type, set_movement_condition)
    if set_movement_condition then
        self:SetMovement(anim_type)
    else
        self:AnimateMovement(anim_type)
    end
end

---@param x number
---@param y number
function EHITracker:PosAndSetVisible(x, y)
    if self.__vertical_anim_w_left_diff then
        x = x + self.__vertical_anim_w_left_diff
        if not self._hide_on_delete then
            self.__vertical_anim_w_left_diff = nil
        end
    end
    self._panel:set_x(x)
    self._panel:set_y(y)
    self:SetPanelAlpha(1)
    self:PositionHint(x, y)
end

---@param alpha number
function EHITracker:SetPanelAlpha(alpha)
    if self._anim_visibility then
        self._panel:stop(self._anim_visibility)
    end
    if self._hint then
        self._hint:stop()
        self._anim_visibility = self._panel:animate(visibility_hint, self._hint, alpha)
    else
        self._anim_visibility = self._panel:animate(visibility, alpha)
    end
end

---@param target_y number
function EHITracker:AnimateTop(target_y)
    if self._anim_move then
        self._panel:stop(self._anim_move)
    end
    self._anim_move = self._panel:animate(top, target_y)
    if self._hint then
        if self._anim_hint_move then
            self._hint:stop(self._anim_hint_move)
        end
        self._anim_hint_move = self._hint:animate(top, target_y - self._hint_pos.y_diff)
    end
end

---@param target_x number
---@param target_y number
---@param panel_width number
function EHITracker:AnimateTopLeft(target_x, target_y, panel_width)
    if self._VERTICAL_ANIM_W_LEFT then
        local diff = panel_width - self.__default_panel_size
        if diff ~= 0 then -- Our panel is smaller or wider than default size, we need to adjust the target_x
            target_x = target_x - diff
        end
    end
    if self._anim_move then
        self._panel:stop(self._anim_move)
    end
    self._anim_move = self._panel:animate(top_left, target_x, target_y)
    if self._hint then
        if self._anim_hint_move then
            self._hint:stop(self._anim_hint_move)
        end
        local target_hint_x, target_hint_y
        if self._VERTICAL_HINT_POS_LEFT then
            target_hint_x = target_x - self._hint:w() - self._gap_scaled
        else
            target_hint_x = target_x + panel_width
        end
        if self._HORIZONTAL_ALIGNMENT then
            if self._HORIZONTAL_HINT_POS_DOWN then
                target_hint_y = target_y + self._icon_gap_size_scaled
            else
                target_hint_y = target_y - self._icon_gap_size_scaled
            end
        else
            target_hint_y = target_y - self._hint_pos.y_diff
        end
        self._anim_hint_move = self._hint:animate(top_left, target_hint_x, target_hint_y)
        self._hint_pos.x = target_hint_x
    end
end

---@param target_x number
function EHITracker:AnimateLeft(target_x)
    if self._anim_move then
        self._panel:stop(self._anim_move)
    end
    self._anim_move = self._panel:animate(left, target_x)
    if self._hint then
        if self._anim_hint_move then
            self._hint:stop(self._anim_hint_move)
        end
        self._anim_hint_move = self._hint:animate(left, target_x)
        self._hint_pos.x = target_x
    end
end

---@param target_w number
function EHITracker:_animate_panel_w(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
    end
    self._anim_set_w = self._panel:animate(panel_w, target_w, self)
end

---@param target_x number
---@param text Text?
function EHITracker:AnimateTextPositionLeft(target_x, text)
    text = text or self._text
    local key = text:key()
    self.__text_anims = self.__text_anims or {}
    if self.__text_anims[key] then
        text:stop(self.__text_anims[key])
    end
    self.__text_anims[key] = text:animate(left, target_x)
end

---@param target_x number
---@param target_w number
---@param text Text?
---@param fit_the_text_after_anim boolean?
function EHITracker:AnimateTextPosition(target_x, target_w, text, fit_the_text_after_anim)
    text = text or self._text
    local key = text:key()
    self.__text_anims = self.__text_anims or {}
    if self.__text_anims[key] then
        text:stop(self.__text_anims[key])
    end
    self.__text_anims[key] = text:animate(text_move_x_w, target_x, target_w, fit_the_text_after_anim, self)
end

---@param previous_icon Bitmap?
---@param icon Bitmap? Defaults to `self._icons[1]` if not provided
function EHITracker:_set_icon_x(previous_icon, icon)
    icon = icon or self._icons[1]
    if icon then
        local x = previous_icon and previous_icon:right() or (self._ICON_LEFT_SIDE_START and 0 or self._bg_box:w())
        local gap = previous_icon and self._gap_scaled or (self._ICON_LEFT_SIDE_START and 0 or self._gap_scaled)
        icon:set_x(x + gap)
    end
end

function EHITracker:_set_icons_x()
    local previous_icon ---@type Bitmap?
    for _, icon in ipairs(self._icons) do
        self:_set_icon_x(previous_icon, icon)
        previous_icon = icon
    end
end

---@param x_offset number?
function EHITracker:_anim_icons_x(x_offset)
    local x = (self._ICON_LEFT_SIDE_START and 0 or self._bg_box:w() + self._gap_scaled) + (x_offset or 0)
    self._icon_anims = self._icon_anims or {}
    for i, icon in ipairs(self._icons) do
        if self._icon_anims[i] then
            icon:stop(self._icon_anims[i])
        end
        local pos = i - 1
        self._icon_anims[i] = icon:animate(icon_x, x + (self._icon_gap_size_scaled * pos))
    end
end

---@param target_x number
function EHITracker:_animate_bg_left(target_x)
    if self._anim_bg_left then
        self._bg_box:stop(self._anim_bg_left)
    end
    self._anim_bg_left = self._bg_box:animate(left, target_x)
end

if EHI:GetOption("time_format") == 1 then
    EHITracker.Format = tweak_data.ehi.functions.FormatSecondsOnly
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnSecondsOnly
    EHITracker.ShortFormat = tweak_data.ehi.functions.ShortFormatSecondsOnly
    EHITracker.ShortFormatTime = tweak_data.ehi.functions.ReturnShortFormatSecondsOnly
    EHITracker._TIME_FORMAT = 1 -- Seconds only
else
    EHITracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
    EHITracker.ShortFormat = tweak_data.ehi.functions.ShortFormatMinutesAndSeconds
    EHITracker.ShortFormatTime = tweak_data.ehi.functions.ReturnShortFormatMinutesAndSeconds
    EHITracker._TIME_FORMAT = 2 -- Minutes and seconds
end

if EHI:GetOption("show_one_icon") then
    EHITracker._ONE_ICON = true
    ---@param tracker_icons table
    ---@param first_icon_pos number?
    function EHITracker:CreateIcons(tracker_icons, first_icon_pos)
        local icon_pos = self._ICON_LEFT_SIDE_START and 0 or (self._bg_box:w() + self._gap_scaled)
        first_icon_pos = first_icon_pos or 1
        local first_icon = tracker_icons[first_icon_pos]
        if type(first_icon) == "string" then
            local texture, rect = GetIcon(first_icon)
            self:CreateIcon(1, first_icon_pos, texture, rect, icon_pos)
        elseif type(first_icon) == "table" then
            local texture, rect = GetIcon(first_icon.icon or "default")
            self:CreateIcon(1, first_icon_pos, texture, rect, icon_pos, first_icon.visible,
            first_icon.peer_id and self._parent_class:GetPeerColorByPeerID(first_icon.peer_id) or first_icon.color, first_icon.alpha)
        end
    end
else
    ---@param tracker_icons table
    ---@param first_icon_pos number?
    function EHITracker:CreateIcons(tracker_icons, first_icon_pos)
        local icon_pos = self._ICON_LEFT_SIDE_START and 0 or (self._bg_box:w() + self._gap_scaled)
        for i, v in ipairs(tracker_icons) do
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                self:CreateIcon(i, i, texture, rect, icon_pos)
            elseif type(v) == "table" then -- table
                local texture, rect = GetIcon(v.icon or "default")
                self:CreateIcon(i, i, texture, rect, icon_pos, v.visible, v.peer_id and self._parent_class:GetPeerColorByPeerID(v.peer_id) or v.color, v.alpha)
            end
            icon_pos = icon_pos + self._icon_gap_size_scaled
        end
    end
end

---@param i number
---@param i_pos number
---@param texture string
---@param texture_rect number[]
---@param x number
---@param visible boolean?
---@param color Color?
---@param alpha number?
---@param layer integer?
function EHITracker:CreateIcon(i, i_pos, texture, texture_rect, x, visible, color, alpha, layer)
    self._icons[i] = self._panel:bitmap({
        texture = texture,
        texture_rect = texture_rect,
        color = color or Color.white,
        alpha = alpha or 1,
        layer = layer or 0,
        visible = visible ~= false,
        x = x,
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
end

---@param params EHITracker.CreateText?
function EHITracker:CreateText(params)
    params = params or {}
    local text = self._bg_box:text({
        text = params.text or "",
        align = "center",
        vertical = "center",
        x = params.x or params.left --[[@as number]],
        w = params.w or self._bg_box:w(),
        h = params.h or self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.color or self._text_color,
        visible = params.visible
    })
    if params.status_text then
        self:SetStatusText(params.status_text, text)
    end
    if params.FitTheText then
        self:FitTheText(text, params.FitTheText_FontSize)
    end
    return text
end

---@param text string
---@param delay_popup boolean?
function EHITracker:CreateHint(text, delay_popup)
    text = self._forced_hint_text or text
    if self._hint_disabled or not text or self._hint then
        return
    end
    local loc
    if self._hint_no_localization then
        loc = text
    else
        loc = managers.localization:text(self._hint_vanilla_localization and text or "ehi_hint_" .. text)
    end
    self._hint = self._panel:parent():text({
        text = loc,
        align = "center",
        vertical = "center",
        w = 18,
        h = 18,
        font = tweak_data.menu.pd2_large_font,
        font_size = 18,
        color = Color.white,
        visible = true,
        alpha = 0
    })
    self:_make_fine_text(self._hint)
    self._hint_pos = { x = self._hint:x(), y_diff = 0 }
    self._delay_hint = delay_popup
end

function EHITracker:ForceShowHint()
    self._delay_hint = nil
    if self._hint and self._hint_t > 0 then
        self._hint:animate(hint_wait, self._hint_t, self)
    end
end

---@param x number
function EHITracker:AdjustHintX(x)
    if not self._hint then
        return
    end
    local new_x = self._hint_pos.x + x
    self._hint:set_x(new_x)
    self._hint_pos.x = new_x
end

---Adjusts hint X position; this function needs to run last after all panel animations are called
---@param x number
function EHITracker:_animate_adjust_hint_x(x)
    if not self._hint or (self._VERTICAL_ANIM_W_LEFT and self._VERTICAL_HINT_POS_RIGHT) then
        return
    end
    if self._HORIZONTAL_ALIGNMENT then
        self:_adjust_horizontal_hint_x()
        return
    end
    if self._anim_hint_x then
        self._hint:stop(self._anim_hint_x)
    end
    local new_x
    if self._VERTICAL_HINT_POS_LEFT then
        new_x = self._hint_pos.x + x
    else
        new_x = self._hint_pos.x - x
    end
    self._anim_hint_x = self._hint:animate(left, new_x)
    self._hint_pos.x = new_x
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Vertical) then
    EHITracker._VERTICAL_ALIGNMENT = true
    EHITracker._VERTICAL_ANIM_W_LEFT = EHI:GetOption("tracker_vertical_w_anim") == EHI.Const.Trackers.Vertical.WidthAnim.RightToLeft
    EHITracker._VERTICAL_HINT_POS_RIGHT = EHI:GetOption("tracker_hint_position") == EHI.Const.Trackers.Hint.v_right_h_down
    EHITracker._VERTICAL_HINT_POS_LEFT = not EHITracker._VERTICAL_HINT_POS_RIGHT
    ---@param x number World X
    ---@param y number World Y
    function EHITracker:PositionHint(x, y)
        if not self._hint then
            return
        end
        self._hint:set_center_y(self._panel:center_y())
        if self._VERTICAL_HINT_POS_RIGHT then
            self._hint:set_x(x + self:GetTrackerSize() + 3)
        else
            self._hint:set_x(x - self._hint:w() - 3)
        end
        self._hint_pos.x = self._hint:x()
        self._hint_pos.y_diff = y - self._hint:y()
        if self._hint_t > 0 and not self._delay_hint then
            self._hint:animate(hint_wait, self._hint_t, self)
        end
    end
else
    EHITracker._HORIZONTAL_RIGHT_TO_LEFT = EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", EHI.Const.Trackers.Alignment.Horizontal_RightToLeft)
    EHITracker._HORIZONTAL_ALIGNMENT = true
    EHITracker._HORIZONTAL_HINT_POS_DOWN = EHI:GetOption("tracker_hint_position") == EHI.Const.Trackers.Hint.v_right_h_down
    ---@param x number World X
    ---@param y number World Y
    function EHITracker:PositionHint(x, y)
        if not self._hint then
            return
        end
        self._hint:set_x(x)
        self._hint_pos.x = x
        if self._HORIZONTAL_HINT_POS_DOWN then
            self._hint:set_y(y + self._icon_size_scaled + 3)
        else
            self._hint:set_y(y - self._icon_size_scaled - 3)
        end
        self._hint:set_w(self:GetTrackerSize())
        self:FitTheText(self._hint, 18)
        if self._hint_t > 0 and not self._delay_hint then
            self._hint:animate(hint_wait, self._hint_t, self)
        end
    end
end

---Adjusts hint X position; this function needs to run last after all panel animations are called
function EHITracker:_adjust_horizontal_hint_x()
    if not self._hint then
        return
    end
    self._hint:set_w(self:GetTrackerSize())
    self:FitTheText(self._hint, 18)
    if self._HORIZONTAL_RIGHT_TO_LEFT then
        self._hint:set_x(self._parent_class._trackers[self._id].x) -- There should be a better way to do this
    else
        self._hint:set_x(self._hint_pos.x)
    end
end

---@param text string
function EHITracker:UpdateHint(text)
    if self._hint_disabled or not text or not self._hint then
        return
    end
    local loc
    if self._hint_no_localization then
        loc = text
    else
        loc = self._hint_vanilla_localization and text or "ehi_hint_" .. text
    end
    self._hint:set_text(managers.localization:text(loc))
    self:_make_fine_text(self._hint)
    if self._VERTICAL_HINT_POS_LEFT then
        local x = self._panel:x() - self._hint:w() - 3
        self._hint:set_x(x)
        self._hint_pos.x = x
    else
        self._hint:set_x(self._hint_pos.x)
    end
    self._parent_class:_hint_updated(self._id, self._hint:w())
end

---@param w number? If not provided, `w` is taken from the BG
---@param type string?
---|"add" # Adds `w` to the BG; default `type` if not provided
---|"sub" # Subs `w` on the BG
---|"set" # Sets `w` on the BG
---@param dont_recalculate_panel_w boolean? Setting this to `true` will not recalculate the total width on the main panel
---@param dont_move_icons boolean? Setting this to `true` will not move icons when size of the panel changes
function EHITracker:SetBGSize(w, type, dont_recalculate_panel_w, dont_move_icons)
    local original_w = self._bg_box:w()
    w = w or original_w
    if not type or type == "add" then
        self._bg_box:set_w(self._bg_box:w() + w)
    elseif type == "sub" then
        self._bg_box:set_w(self._bg_box:w() - w)
    else
        self._bg_box:set_w(w)
    end
    if not dont_recalculate_panel_w then
        self._panel:set_w(self:GetTrackerSize())
        if not dont_move_icons then
            self:_set_icons_x()
        end
    end
    if self._VERTICAL_ANIM_W_LEFT and self._panel:alpha() <= 0 then
        -- Panel is not visible, adjustment will be performed when manager calls the `EHITracker:PosAndSetVisible()` function  
        -- Otherwise you need to adjust panel position via animation
        self.__vertical_anim_w_left_diff = (self.__vertical_anim_w_left_diff or 0) + original_w - self._bg_box:w()
    end
end

---@param dt number
function EHITracker:update(dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

---@param dt number
function EHITracker:update_fade(dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

---@param text Text?
---@param font_size number?
function EHITracker:FitTheText(text, font_size)
    text = text or self._text
    text:set_font_size(font_size or self._panel:h() * self._text_scale)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

---@param ... number
function EHITracker:FitTheTextBasedOnTime(...)
    local time_check = self._TIME_FORMAT == 1 and 100 or 60
    if math.max(self._time, ...) >= time_check then
        local max_refresh_t = math.max(0, ...)
        if max_refresh_t >= time_check then
            local t = self._time
            self._time = max_refresh_t
            self:SetAndFitTheText()
            self._time = t
        else
            self:SetAndFitTheText()
        end
    end
end

---@param t number
---@param default_text string?
function EHITracker:FitTheTime(t, default_text)
    self._text:set_text(self:FormatTime(t))
    self:FitTheText()
    if default_text then
        self._text:set_text(default_text)
    end
end

---@param text_string string? If not provided, `Format` function will be called
---@param text Text?
function EHITracker:SetAndFitTheText(text_string, text)
    text = text or self._text
    text:set_text(text_string or self:Format())
    self:FitTheText(text)
end

---@param time number
function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

---@param time number
function EHITracker:SetTimeNoAnim(time)
    self._time = time
    self:SetAndFitTheText()
end

---@param params ElementTrigger?
function EHITracker:Run(params)
    if not params then
        return
    end
    self:SetTimeNoAnim(params.time or 0)
    self:SetTextColor()
end

if bg_visibility then
    EHITracker._BG_START_COLOR = Color(1, 0, 0, 0)
    ---@param bg Rect
    ---@param total_t number
    ---@param start_color Color
    EHITracker._anim_bg_attention = function(bg, total_t, start_color)
        local color = Color.white
        local t = total_t or 3
        while t > 0 do
            t = t - coroutine.yield()
            local cv = math.abs(math.sin(t * 180 * 1))
            bg:set_color(Color(1, color.r * cv, color.g * cv, color.b * cv))
        end
        bg:set_color(start_color)
    end
    ---@param t number?
    function EHITracker:AnimateBG(t)
        t = t or self._flash_times
        if self._anim_flash and t > 0 then
            local bg = self._bg_box:child("bg") --[[@as Rect]]
            bg:stop()
            bg:set_color(self._BG_START_COLOR)
            bg:animate(self._anim_bg_attention, t, self._BG_START_COLOR)
        end
    end
else
    ---@param t number?
    function EHITracker:AnimateBG(t)
    end
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text Text? Defaults to `self._text` if not provided
function EHITracker:SetTextColor(color, text)
    text = text or self._text
    text:set_color(color or self._text_color)
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text Text? Defaults to `self._text` if not provided
function EHITracker:StopAndSetTextColor(color, text)
    text = text or self._text
    text:stop()
    self:SetTextColor(color, text)
end

---@param new_icon string
---@param icon Bitmap?
function EHITracker:SetIcon(new_icon, icon)
    icon = icon or self._icons[1]
    if icon then
        local texture, texture_rect = GetIcon(new_icon)
        if texture_rect then
            icon:set_image(texture, unpack(texture_rect))
        else
            icon:set_image(texture)
        end
    end
end

---@param color Color
---@param icon Bitmap?
function EHITracker:SetIconColor(color, icon)
    icon = icon or self._icons[1]
    if icon then
        icon:set_color(color)
    end
end

---@param status string
---@param text Text?
function EHITracker:SetStatusText(status, text)
    text = text or self._text
    local txt = "ehi_status_" .. status
    if LocalizationManager._custom_localizations[txt] then
        text:set_text(managers.localization:text(txt))
    else
        text:set_text(string.upper(status))
    end
    self:FitTheText(text)
end

function EHITracker:AddTrackerToUpdate()
    self._parent_class:_add_tracker_to_update(self)
end

function EHITracker:RemoveTrackerFromUpdate()
    self._parent_class:_remove_tracker_from_update(self._id)
end

function EHITracker:DelayForcedDelete()
    self._hide_on_delete = nil
    self._refresh_on_delete = nil
    self:AddTrackerToUpdate()
end

---@param w number? If not provided the width is then called from `EHITracker:GetTrackerSize()`
---@param move_the_tracker boolean? If the tracker should move too, useful if number icons change and tracker needs to be rearranged to fit properly
function EHITracker:_change_tracker_width(w, move_the_tracker)
    self._parent_class:_change_tracker_width(self._id, w or self:GetTrackerSize(), move_the_tracker)
end

function EHITracker:CleanupOnHide()
end

function EHITracker:StopPanelAnims()
    self._panel:stop()
    if self._hint then
        self._hint:stop()
    end
end

function EHITracker:pre_destroy()
end

---@param skip_anim boolean?
function EHITracker:destroy(skip_anim)
    self:pre_destroy()
    if alive(self._panel) then
        for _, icon in ipairs(self._icons) do
            icon:stop()
        end
        self:StopPanelAnims()
        self._panel:animate(destroy, skip_anim, self)
    end
end

function EHITracker:delete()
    if self._hide_on_delete then
        self:StopPanelAnims()
        self:SetPanelAlpha(0)
        self._parent_class:HideTracker(self._id)
        self:CleanupOnHide()
        return
    elseif self._refresh_on_delete then
        self:Refresh()
        return
    end
    self:destroy()
    self._parent_class:_destroy_tracker(self._id)
end

function EHITracker:Refresh()
end

function EHITracker:ForceDelete()
    self._hide_on_delete = nil
    self._refresh_on_delete = nil
    self:delete()
end

function EHITracker:PlayerSpawned()
    self:ForceShowHint()
end

function EHITracker:SwitchToLoudMode()
    if self._remove_on_alarm then
        self:ForceDelete()
    elseif self._update_on_alarm then
        self._update_on_alarm = nil
        self:OnAlarm()
    end
end

function EHITracker:OnAlarm()
end

function EHITracker:MissionEnd()
end

function EHITracker:RedrawPanel()
end

---Returns current real tracker size
function EHITracker:GetTrackerSize()
    local n = 0
    for _, icon in ipairs(self._icons) do
        if icon:visible() then
            n = n + 1
        end
    end
    return self._bg_box:w() + (n * self._icon_gap_size_scaled)
end

---@param create_f fun(panel: Panel, params: table): Panel
---@param animate_f fun(bg: Rect, total_t: number, start_color: Color)
function EHITracker.SetCustomBGFunctions(create_f, animate_f)
    CreateHUDBGBox = create_f
    if EHITracker._anim_bg_attention then
        EHITracker._anim_bg_attention = animate_f
    end
end