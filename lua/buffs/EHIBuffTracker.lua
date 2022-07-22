local progress = EHI:GetOption("buffs_show_progress")
local circle_shape = EHI:GetOption("buffs_shape") == 2
local invert = EHI:GetOption("buffs_invert_progress")
local Color = Color
local lerp = math.lerp
local function show(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
local function hide(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(1 - (t / total))
    end
    o:set_alpha(0)
end
local function set_x(o, target_x)
    local t = 0
    local total = 0.15
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
local function set_right(o, x)
    local t = 0
    local total = 0.15
    local from_right = o:right()
    local target_right = o:parent():w() - x
    while t < total do
        t = t + coroutine.yield()
        o:set_right(lerp(from_right, target_right, t / total))
    end
    o:set_right(target_right)
end
EHIBuffTracker = class()
EHIBuffTracker._inverted_progress = false
function EHIBuffTracker:init(panel, params)
    local w_half = params.w / 2
    local color = params.icon_color or params.good and Color.white or Color.red
    self._id = params.id
    self._parent_class = params.parent_class
    self._panel = panel:panel({
        name = self._id,
        w = params.w,
        h = params.h,
        x = params.x,
        y = panel:bottom() - params.h - params.y,
        alpha = 0,
        visible = true
    })
    local icon = self._panel:bitmap({
        name = "icon",
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = color,
        x = 0,
        y = w_half,
        w = params.w,
        h = params.w
    })
    self._time_bg_box = self._panel:panel({
		name = "time_bg_box",
		x = 0,
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
	})
    if circle_shape then
        self._time_bg_box:bitmap({
            name = "bg",
            layer = -1,
            w = self._time_bg_box:w(),
            h = self._time_bg_box:h(),
            texture = "guis/textures/pd2/hud_tabs",
            texture_rect = {105, 34, 19, 19},
            color = Color.black:with_alpha(0.2)
        })
    else
        self._time_bg_box:rect({
            blend_mode = "normal",
            name = "bg",
            halign = "grow",
            alpha = 0.25,
            layer = -1,
            valign = "grow",
            color = Color(1, 0, 0, 0),
            visible = true
        })
    end
    self._hint = self._panel:text({
        name = "hint",
        text = params.text or "",
        w = self._panel:w(),
        h = w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = w_half,
        color = Color.white,
        align = "center",
        x = 0,
        y = 0
    })
    self._text = self._panel:text({
        name = "text",
        text = "100s",
        w = self._panel:w(),
        h = self._panel:h() - self._time_bg_box:h() - w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = w_half,
        color = Color.white,
        align = "center",
        vertical = "center",
        y = self._panel:w() + w_half,
    })
    if circle_shape then
        local rect = {128, 0, -128, 128}
        if invert then
            rect[1] = 0
            rect[3] = -rect[3]
        end
        local texture = params.good and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2/hud_progress_invalid"
        self._progress = self._panel:bitmap({
            name = "progress_circle",
            render_template = "VertexColorTexturedRadial",
            layer = 5,
            y = icon:y(),
            w = icon:w(),
            h = icon:h(),
            texture = texture,
            texture_rect = rect,
            color = Color(1, 0, 1, 1),
            visible = progress
        })
    else
        local rect = {32, 0, -32, 32}
        if invert then
            rect[1] = 0
            rect[3] = -rect[3]
        end
        local texture = params.good and "guis/textures/pd2_mod_ehi/buff_frame" or "guis/textures/pd2_mod_ehi/buff_frame_debuff"
        self._progress = self._panel:bitmap({
            name = "progress_square",
            render_template = "VertexColorTexturedRadial",
            layer = 5,
            y = icon:y(),
            w = icon:w(),
            h = icon:h(),
            texture = texture,
            texture_rect = rect,
            color = Color(1, 0, 1, 1),
            visible = progress
        })
    end
    if progress then
        local size = 24 * params.scale
        local move = 4 * params.scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    end
    self._panel:set_center_x(panel:center_x())
    self._active = false
    self._time = 0
    if self._inverted_progress then
        self:InvertProgress()
    end
    self:CalculateMoveOffset()
end

function EHIBuffTracker:InvertProgress()
    local rect
    if circle_shape then
        if invert then
            rect = {128, 0, -128, 128}
        else
            rect = {0, 0, 128, 128}
        end
    else
        if invert then
            rect = {32, 0, -32, 32}
        else
            rect = {0, 0, 32, 32}
        end
    end
    self._progress:set_texture_rect(unpack(rect))
end

function EHIBuffTracker:CalculateMoveOffset()
    self._panel_w = self._panel:w()
    self._panel_w_gap = self._panel_w + 6
    self._panel_move_gap = (self._panel_w / 2) + 3 -- add only half of the gap
end

function EHIBuffTracker:UpdateIcon(texture, texture_rect)
    self._panel:child("icon"):set_image(texture, unpack(texture_rect))
end

function EHIBuffTracker:SetCenterX(center_x)
    self._panel:set_center_x(center_x)
end

function EHIBuffTracker:MovePanelLeft(x)
    self._panel:set_x(self._panel:x() - x)
end

function EHIBuffTracker:MovePanelRight(x)
    self._panel:set_x(self._panel:x() + x)
end

function EHIBuffTracker:SetX(x)
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_x, x)
end

function EHIBuffTracker:SetRight(x)
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_right, x)
end

function EHIBuffTracker:IsActive()
    return self._active
end

function EHIBuffTracker:Activate(t, pos)
    self._active = true
    self._time = t
    self._time_set = t
    self._parent_class:AddBuffToUpdate(self._id, self)
    self._panel:stop()
    self._panel:animate(show)
    self._pos = pos
end

function EHIBuffTracker:Extend(t)
    self._time = t
    self._time_set = t
end

function EHIBuffTracker:Append(t)
    self._time = self._time + t
    self._time_set = self._time
end

function EHIBuffTracker:AppendCeil(t, max)
    self._time = math.min(self._time + t, max)
    self._time_set = self._time
end

function EHIBuffTracker:Deactivate()
    self._parent_class:RemoveBuffFromUpdate(self._id)
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(hide)
    self._active = false
end

function EHIBuffTracker:Shorten(t)
    self._time = self._time - t
end

function EHIBuffTracker:SetPos(pos)
    self._pos = pos
end

function EHIBuffTracker:SetLeftXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    self:SetX(x + (self._panel_w_gap * self._pos))
end

local abs = math.abs
function EHIBuffTracker:SetCenterXByPos(pos, center_pos, even)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    if even then
        local n = abs(center_pos - self._pos)
        local final_x = self._panel_move_gap + (self._panel_w_gap * n)
        if self._pos < center_pos then -- Left side
            final_x = final_x - self._panel_w_gap
            self:MovePanelLeft(final_x)
        else -- Right side
            self:MovePanelRight(final_x)
        end
    elseif self._pos ~= center_pos then -- Not center
        local n = abs(center_pos - self._pos)
        local final_x = self._panel_w_gap * n
        if self._pos < center_pos then -- Left side
            self:MovePanelLeft(final_x)
        else -- Right side
            self:MovePanelRight(final_x)
        end
    end
end

function EHIBuffTracker:SetRightXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    self:SetRight(x + (self._panel_w_gap * self._pos))
end

function EHIBuffTracker:PreUpdate()
end

function EHIBuffTracker:PreUpdateCheck()
    return true
end

if progress then
    function EHIBuffTracker:update(t, dt)
        self._time = self._time - dt
        self._text:set_text(self:Format())
        self._progress:set_color(Color(1, self._time / self._time_set, 1, 1))
        if self._time <= 0 then
            self:Deactivate()
        end
    end
else
    function EHIBuffTracker:update(t, dt)
        self._time = self._time - dt
        self._text:set_text(self:Format())
        if self._time <= 0 then
            self:Deactivate()
        end
    end
end

do
    local math_floor = math.floor
    local string_format = string.format
    local function SecondsOnly(self)
        local t = math_floor(self._time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", self._time)
        elseif t < 10 then
            return string_format("%.1f", t)
        else
            return string_format("%d", t)
        end
    end

    local function MinutesAndSeconds(self)
        local t = math_floor(self._time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", self._time)
        elseif t < 10 then
            return string_format("%.1f", t)
        elseif t < 60 then
            return string_format("%d", t)
        else
            return string_format("%d:%02d", t / 60, t % 60)
        end
    end

    if EHI:GetOption("time_format") == 1 then
        EHIBuffTracker.Format = SecondsOnly
    else
        EHIBuffTracker.Format = MinutesAndSeconds
    end
end