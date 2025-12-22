local progress = EHI:GetOption("buffs_show_progress") --[[@as boolean]]
local circle_shape = EHI:GetOption("buffs_shape") == 2
local invert = EHI:GetOption("buffs_invert_progress") --[[@as boolean]]
local show_hint = EHI:GetOption("buffs_show_upper_text") --[[@as boolean]]
local color_buff_text = EHI:GetOption("buffs_group_text_color") --[[@as boolean]]
local rect =  circle_shape and { 128, 0, -128, 128 } or { 32, 0, -32, 32 }
local frame = circle_shape and "cframe" or "sframe"
if invert then
    rect[1] = 0
    rect[3] = -rect[3]
end
local textures = {}
for group, entry in pairs(tweak_data.ehi:GetSelectedBuffColors()) do
    textures[group] = {
        path = string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", frame, entry.texture_color),
        color = entry.icon_color
    }
end
local Color = Color
---@param o Panel
---@param target_x number
local function set_x(o, target_x)
    local t = 0
    local total = 0.15
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math.lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
---@param o Panel
---@param x number
local function set_right(o, x)
    local t = 0
    local total = 0.15
    local from_right = o:right()
    local target_right = o:parent():w() - x
    while t < total do
        t = t + coroutine.yield()
        o:set_right(math.lerp(from_right, target_right, t / total))
    end
    o:set_right(target_right)
end
---@class EHIBuffTracker
---@field new fun(self: self, panel: Panel, params: table): self
---@field _parent_class EHIBuffManager Added when `EHIBuffManager` class is created
---@field _inverted_progress boolean
---@field _DELETE_BUFF_ON_FALSE_SKILL_CHECK boolean
---@field _DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK boolean
---@field _UNHOOK_BUFF boolean
EHIBuffTracker = class()
---@param o Panel
EHIBuffTracker._show = function(o)
    local t, total = 0, 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
---@param o Panel
EHIBuffTracker._hide = function(o)
    local t, total = 0.15, 0.15
    while t > 0 do
        t = t - coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(0)
end
---@param panel Panel
---@param params table
function EHIBuffTracker:init(panel, params)
    local w_half = params.w / 2
    local progress_visible = progress and not params.no_progress
    local texture = textures[params.group or "default"]
    self._id = params.id --[[@as string]]
    self._panel = panel:panel({
        x = params.x,
        y = panel:bottom() - params.h - params.y,
        w = params.w,
        h = params.h,
        alpha = 0,
        visible = true
    })
    self._icon = self._panel:bitmap({
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = params.icon_color or texture.color,
        x = 0,
        y = w_half,
        w = params.w,
        h = params.w
    })
    if circle_shape then
        self._panel:bitmap({
            layer = -1,
            x = 0,
            y = w_half,
            w = params.w,
            h = params.w,
            texture = "guis/textures/pd2_mod_ehi/buffs/buff_cframe_bg",
            color = Color.black:with_alpha(0.2)
        })
    else
        self._panel:rect({
            blend_mode = "normal",
            halign = "grow",
            alpha = 0.25,
            layer = -1,
            valign = "grow",
            x = 0,
            y = w_half,
            w = params.w,
            h = params.w,
            color = Color(1, 0, 0, 0),
            visible = true
        })
    end
    self._hint = self._panel:text({
        text = params.text_localize and managers.localization:text(params.text_localize) or params.text or "",
        x = 0,
        y = 0,
        w = params.w,
        h = w_half,
        font = tweak_data.menu.pd2_large_font,
        font_size = w_half,
        color = color_buff_text and texture.color or Color.white,
        align = "center",
        alpha = show_hint and 1 or 0
    })
    self:FitTheText(self._hint)
    self._text = self._panel:text({
        text = "100s",
        y = self._panel:w() + w_half,
        w = params.w,
        h = params.h - params.w - w_half,
        font = tweak_data.menu.pd2_large_font,
        font_size = w_half,
        color = color_buff_text and texture.color or Color.white,
        align = "center",
        vertical = "center",
        visible = not params.no_progress
    })
    self._progress_bar = Color(1, 0, 1, 1)
    self._progress = self._panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = w_half,
        w = params.w,
        h = params.w,
        texture = texture.path,
        texture_rect = rect,
        color = self._progress_bar,
        visible = progress_visible
    })
    if progress_visible then
        local size = 24 * params.scale
        local move = 4 * params.scale
        self._icon:set_size(size, size)
        self._icon:move(move, move)
    end
    self._panel:set_center_x(panel:center_x())
    self._active = false
    self._time = 0
    if self._inverted_progress then
        self._progress:set_texture_rect(invert and rect[4] or 0, rect[2], -rect[3], rect[4])
    end
    local panel_w = self._panel:w()
    self._panel_w_gap = panel_w + 6
    self._panel_move_gap = (panel_w / 2) + 3 -- add only half of the gap
    self._remove_on_alarm = params.remove_on_alarm
    self:post_init(params)
end

---@param params table
function EHIBuffTracker:post_init(params)
end

---@param text Text
function EHIBuffTracker:FitTheText(text)
    text:set_font_size(self._panel:w() / 2)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

function EHIBuffTracker:SetPersistent()
    self._persistent = true
    self:Activate()
end

---@param texture string
---@param texture_rect number[]?
function EHIBuffTracker:UpdateIcon(texture, texture_rect)
    if texture_rect then
        self._icon:set_image(texture, unpack(texture_rect))
    else
        self._icon:set_image(texture)
    end
end

---@param t number? Required
---@param pos number? Required
function EHIBuffTracker:Activate(t, pos)
    self._active = true
    self._time = t
    self._time_set = t
    self:AddBuffToUpdate()
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

---@param pos number
function EHIBuffTracker:ActivateNoUpdate(pos)
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIBuffTracker:ActivateSoft()
    if self._visible then
        return
    end
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
    self._visible = true
end

---@param t number
function EHIBuffTracker:Extend(t)
    self._time = t
    self._time_set = t
end

function EHIBuffTracker:Deactivate()
    self._parent_class:_remove_buff_from_update(self._id)
    self._parent_class:_remove_visible_buff(self)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
    self._pos = nil
end

function EHIBuffTracker:DeactivateSoft()
    if not self._visible then
        return
    end
    self._parent_class:_remove_visible_buff(self)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._visible = false
end

---@param localize boolean?
function EHIBuffTracker:SetHintText(text, localize)
    self._hint:set_text(localize and managers.localization:text(text) or tostring(text))
    self:FitTheText(self._hint)
end

---@param x number
---@param pos number
function EHIBuffTracker:SetLeftXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_x, x + (self._panel_w_gap * self._pos))
end

---@param center_x number
function EHIBuffTracker:SetCenterDefaultX(center_x)
    self._panel:set_center_x(center_x)
    self._pos = 0
end

---@param center_x number
---@param pos number
---@param center_pos number
---@param even boolean
function EHIBuffTracker:SetCenterXByPos(center_x, pos, center_pos, even)
    self._panel:set_center_x(center_x)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    if even then
        local n = math.abs(center_pos - self._pos)
        local final_x = self._panel_move_gap + (self._panel_w_gap * n)
        if self._pos < center_pos then -- Left side
            final_x = final_x - self._panel_w_gap
            self._panel:move(-final_x, 0)
        else -- Right side
            self._panel:move(final_x, 0)
        end
    elseif self._pos ~= center_pos then -- Not center
        local n = math.abs(center_pos - self._pos)
        local final_x = self._panel_w_gap * n
        if self._pos < center_pos then -- Left side
            self._panel:move(-final_x, 0)
        else -- Right side
            self._panel:move(final_x, 0)
        end
    end
end

---@param x number
---@param pos number
function EHIBuffTracker:SetRightXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_right, x + (self._panel_w_gap * self._pos))
end

function EHIBuffTracker:AddBuffToUpdate()
    self._parent_class:_add_buff_to_update(self)
end

function EHIBuffTracker:RemoveBuffFromUpdate()
    self._parent_class:_remove_buff_from_update(self._id)
end

function EHIBuffTracker:AddVisibleBuff()
    self._parent_class:_add_visible_buff(self)
end

function EHIBuffTracker:RemoveVisibleBuff()
    self._parent_class:_remove_visible_buff(self)
end

function EHIBuffTracker:PreUpdate()
end

function EHIBuffTracker:SkillCheck()
    return true
end

function EHIBuffTracker:CanDeleteOnFalseSkillCheck()
    return self._DELETE_BUFF_ON_FALSE_SKILL_CHECK or self._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK or self._UNHOOK_BUFF
end

---@param state boolean
function EHIBuffTracker:SetCustodyState(state)
end

function EHIBuffTracker:SwitchToLoudMode()
    if self._remove_on_alarm then
        self:Remove()
    end
end

---@param dt number
function EHIBuffTracker:update(dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    self._progress_bar.red = self._time / self._time_set
    self._progress:set_color(self._progress_bar)
    if self._time <= 0 then
        self:Deactivate()
    end
end

if EHI:GetOption("time_format") == 1 then
    EHIBuffTracker.Format = tweak_data.ehi.functions.FormatSecondsOnly
else
    EHIBuffTracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

---@param color string
function EHIBuffTracker._get_texture(color)
    return string.format("guis/textures/pd2_mod_ehi/buffs/buff_%s_%s", frame, color)
end

function EHIBuffTracker:_get_texture_rect()
    local new_rect = deep_clone(rect)
    if self._inverted_progress then
        new_rect[1] = invert and rect[4] or 0
        new_rect[3] = -rect[3]
    end
    return new_rect
end

---@param id string
function EHIBuffTracker:SetGroup(id)
    local group = textures[id]
    if group then
        local clr = color_buff_text and group.color or Color.white
        self._progress:set_image(group.path, unpack(rect))
        self._icon:set_color(group.color)
        self._text:set_color(clr)
        self._hint:set_color(clr)
    end
end

---@param id1 string
---@param id2 string
function EHIBuffTracker:SetMultiGroup(id1, id2)
    local first = math.random() > 0.5 and id2 or id1
    local group = textures[first]
    local group2 = textures[first == id2 and id1 or id2]
    if group and group2 then
        self._icon:set_color(group.color)
        self._progress:set_image(group2.path, unpack(rect))
        local clr = color_buff_text and group.color or Color.white
        self._text:set_color(clr)
        self._hint:set_color(clr)
    end
end

function EHIBuffTracker:Remove()
    self:RemoveBuffFromUpdate()
    self._panel:stop()
    if self._active or self._panel:alpha() > 0 then
        self._panel:animate(function(o) ---@param o Panel
            self._hide(o)
            self:delete()
        end)
    else
        self:delete()
    end
end

function EHIBuffTracker:delete()
    self:RemoveBuffFromUpdate()
    if alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
    if self._pos then
        self:RemoveVisibleBuff()
    end
    self._parent_class._buffs[self._id] = nil
end

function EHIBuffTracker:delete_with_class()
    self:delete()
    local buff = tweak_data.ehi.buff[self._id]
    _G[buff.class_to_load and buff.class_to_load.class or buff.class] = nil
end

function EHIBuffTracker:unhook()
end

EHIBuffTracker.DeactivateAndReset = EHIBuffTracker.Deactivate