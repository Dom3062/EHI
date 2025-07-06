if not EHIBuffTracker then
    EHI:LoadBuff("EHIBuffTracker")
end

---@class FakeEHIBuffTracker : EHIBuffTracker
FakeEHIBuffTracker = class()
FakeEHIBuffTracker.FitTheText = EHIBuffTracker.FitTheText
FakeEHIBuffTracker._rect_circle = { 128, 0, -128, 128 }
FakeEHIBuffTracker._rect_square = { 32, 0, -32, 32 }
FakeEHIBuffTracker._gap = tweak_data.ehi.default.buff.gap
---@param panel Panel
---@param params table
function FakeEHIBuffTracker:init(panel, params)
    local buff_w = params.w
    local buff_w_half = buff_w / 2
    local buff_h = params.h
    local is_cooldown = params.group == "cooldown"
    self._show_progress = params.show_progress
    self._shape = params.shape
    self._scale = params.scale
    self._panel = panel:panel({
        w = buff_w,
        h = buff_h,
        y = panel:bottom() - buff_h - params.y + (params.saferect_y / 2),
        visible = params.visible
    })
    self._icon = self._panel:bitmap({
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = is_cooldown and Color.red or Color.white,
        x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w
    })
	self._panel:rect({
		blend_mode = "normal",
		name = "bg_square",
        x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w,
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = self._shape == 1
	})
    self._panel:bitmap({
        name = "bg_circle",
        layer = -1,
        x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w,
        texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg",
        color = Color.black:with_alpha(0.2),
        visible = self._shape == 2
    })
    self._panel:bitmap({
        name = "progress_circle",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = self._icon:y(),
        w = self._icon:w(),
        h = self._icon:h(),
        texture = is_cooldown and "guis/textures/pd2_mod_ehi/buffs/buff_cframe_red" or "guis/textures/pd2_mod_ehi/buffs/buff_cframe_white",
        texture_rect = self._rect_circle,
        visible = self._shape == 2 and self._show_progress
    })
    self._panel:bitmap({
        name = "progress_square",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = self._icon:y(),
        w = self._icon:w(),
        h = self._icon:h(),
        texture = is_cooldown and "guis/textures/pd2_mod_ehi/buffs/buff_sframe_red" or "guis/textures/pd2_mod_ehi/buffs/buff_sframe_white",
        texture_rect = self._rect_square,
        visible = self._shape == 1 and self._show_progress
    })
    self._hint = self._panel:text({
        text = params.text_localize and managers.localization:text(params.text_localize) or params.text or "",
        w = self._panel:w(),
        h = buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        x = 0,
        y = 0,
        visible = params.hint_visible
    })
    self:FitTheText(self._hint)
    self._time = math.random(0, 100)
    self._text = self._panel:text({
        text = self:Format(),
        w = self._panel:w(),
        h = self._panel:h() - self._panel:w() - buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        vertical = "center",
        y = self._panel:w() + buff_w_half,
    })
    self:FitTheText(self._text)
    self._panel:set_center_x(panel:center_x())
    self._saferect_x = params.saferect_x / 2
    self._saferect_y = params.saferect_y
    self:SetProgress()
    self:UpdateProgressVisibility(self._show_progress, true)
    self._inverted = false
    if params.invert then
        self:InvertProgress()
    end
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        self._icon:set_size(size, size)
        self._icon:set_x(self._icon:x() + move)
        self._icon:set_y(self._icon:y() + move)
    end
    local panel_w = self._panel:w()
    self._panel_w_gap = panel_w + self._gap
    self._panel_w_move = (panel_w / 2) + 3
end

function FakeEHIBuffTracker:SetProgress()
    local c = Color(1, self:GetProgress(), 1, 1)
    self._panel:child("progress_circle"):set_color(c)
    self._panel:child("progress_square"):set_color(c)
end

---@return number
function FakeEHIBuffTracker:GetProgress()
    return self._time / 100
end

---@param visibility boolean
function FakeEHIBuffTracker:SetVisibility(visibility)
	self._panel:set_visible(visibility)
end

---@param x number
---@param pos number
function FakeEHIBuffTracker:SetLeftPos(x, pos)
    self._panel:set_x(x + self._saferect_x + (self._panel_w_gap * pos))
end

---@param center_x number
---@param pos number
---@param center_pos number
---@param even boolean
function FakeEHIBuffTracker:SetCenterPos(center_x, pos, center_pos, even)
    self._panel:set_center_x(center_x)
    if even then
        local n = math.abs(center_pos - pos)
        local final_x = self._panel_w_move + (self._panel_w_gap * n)
        if pos < center_pos then
            final_x = final_x - self._panel_w_gap
            self._panel:set_x(self._panel:x() - final_x)
        else
            self._panel:set_x(self._panel:x() + final_x)
        end
    elseif pos ~= center_pos then
        local n = math.abs(center_pos - pos)
        local final_x = self._panel_w_gap * n
        if pos < center_pos then
            self._panel:set_x(self._panel:x() - final_x)
        else
            self._panel:set_x(self._panel:x() + final_x)
        end
    end
end

---@param x number
---@param pos number
function FakeEHIBuffTracker:SetRightPos(x, pos)
    self._panel:set_right(self._panel:parent():w() - x - self._saferect_x - (self._panel_w_gap * pos))
end

---@param y number
function FakeEHIBuffTracker:SetY(y)
    local _y = y - (self._saferect_y / 2)
	self._panel:set_y(self._panel:parent():bottom() - self._panel:h() - _y - self._saferect_y)
end

---@param shape number
function FakeEHIBuffTracker:UpdateBuffShape(shape)
    if shape == 1 then -- Square
        self._panel:child("bg_square"):set_visible(true)
        self._panel:child("progress_square"):set_visible(self._show_progress)
        self._panel:child("bg_circle"):set_visible(false)
        self._panel:child("progress_circle"):set_visible(false)
    else -- Circle
        self._panel:child("bg_square"):set_visible(false)
        self._panel:child("progress_square"):set_visible(false)
        self._panel:child("bg_circle"):set_visible(true)
        self._panel:child("progress_circle"):set_visible(self._show_progress)
    end
    self._shape = shape
end

---@param visibility boolean
---@param dont_force boolean
function FakeEHIBuffTracker:UpdateProgressVisibility(visibility, dont_force)
    self._show_progress = visibility
    self:UpdateBuffShape(self._shape)
    if dont_force then
        return
    end
    local icon = self._icon
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    else
        local size = 32 * self._scale
        icon:set_size(size, size)
        icon:set_x(0)
        icon:set_y(self._panel:w() / 2)
    end
end

---@param rect number[]
---@param shape Bitmap
function FakeEHIBuffTracker:_invert(rect, shape)
    local size = self._inverted and 0 or rect[4]
    local size_3 = self._inverted and rect[4] or rect[3]
    shape:set_texture_rect(size, rect[2], size_3, rect[4])
end

function FakeEHIBuffTracker:InvertProgress()
    self._inverted = not self._inverted
    self:_invert(self._rect_square, self._panel:child("progress_square") --[[@as Bitmap]])
    self:_invert(self._rect_circle, self._panel:child("progress_circle") --[[@as Bitmap]])
end

---@param visibility boolean
function FakeEHIBuffTracker:UpdateHintVisibility(visibility)
    self._hint:set_visible(visibility)
end

function FakeEHIBuffTracker:Format()
    return self._time .. "s"
end

function FakeEHIBuffTracker:destroy()
    if alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

---@class FakeEHIGaugeBuffTracker : FakeEHIBuffTracker
---@field super FakeEHIBuffTracker
FakeEHIGaugeBuffTracker = class(FakeEHIBuffTracker)
function FakeEHIGaugeBuffTracker:init(...)
    self._ratio = math.random()
    FakeEHIGaugeBuffTracker.super.init(self, ...)
    self:InvertProgress()
end

---@return number
function FakeEHIGaugeBuffTracker:GetProgress()
    return self._ratio
end

function FakeEHIGaugeBuffTracker:Format()
    return math.floor(self._ratio * 100) .. "%"
end