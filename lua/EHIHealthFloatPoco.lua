local function round(num, dec)
    local res = string.format('%.' .. (dec or 0) .. 'g', num)
    return res:find('e') and tostring(math.floor(num)) or res
end

---@class EHIHealthFloatPoco
---@field new fun(self: self, owner: EHIHealthFloatManager, key: string, unit: UnitObject, t: number): self
EHIHealthFloatPoco = class()
EHIHealthFloatPoco._size = 16
EHIHealthFloatPoco._margin = 2
EHIHealthFloatPoco._opacity = 0.9
EHIHealthFloatPoco._color_start = Color("FFA500"):with_alpha(1)
EHIHealthFloatPoco._color_end = Color("FF0000"):with_alpha(1)
EHIHealthFloatPoco._color_friendly = Color("00FF00"):with_alpha(1)
EHIHealthFloatPoco._converts_disabled = not EHI:GetOption("show_floating_health_bar_converts") -- Team AI shares the same slot mask (16) with converts, workaround
EHIHealthFloatPoco._civilians_disabled = not EHI:GetOption("show_floating_health_bar_civilians") -- Tied civilians share the same slot mask (22) with tied cops, workaround
EHIHealthFloatPoco._team_ai_disabled = not EHI:GetOption("show_floating_health_bar_team_ai") -- Converts share the same slot mask (16) with Team AI, workaround
---@param owner EHIHealthFloatManager
---@param key string
---@param unit UnitObject
---@param t number
function EHIHealthFloatPoco:init(owner, key, unit, t)
    self._parent = owner
    self._unit = unit
    self._key = key
    self._lastT = t
    local size = self._size
    local m = self._margin
    local pnl = owner._pnl:panel({
        x = 0,
        y = -size,
        w = 300,
        h = 100
    })
    self._pnl = pnl
    self.bg = pnl:bitmap({
        name = 'blur',
        texture = 'guis/textures/test_blur_df',
        render_template = 'VertexColorTexturedBlur3D',
        layer = -1,
        x = 0,
        y = 0
    })
    self.pie = CircleBitmapGuiObject:new(pnl, {
        use_bg = false,
        x = m,
        y = m,
        image = "guis/textures/pd2/hud_health",
        radius = size / 2,
        sides = 64,
        current = 20,
        total = 64,
        blend_mode = "normal",
        layer = 4
    })
    self.pie._circle:set_texture_rect(128, 0, -128, 128)
    self.pieBg = pnl:bitmap({
        name = "pieBg",
        texture = "guis/textures/pd2/hud_progress_active",
        w = size,
        h = size,
        layer = 3,
        x = m,
        y = m,
        color = Color.black:with_alpha(0.5)
    })
    self.lbl = pnl:text{
        text = "text",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.white,
        x = size + m * 2,
        y = m,
        layer = 3,
        blend_mode = 'normal'
    }
    self.lblShadow1 = pnl:text{
        text = "shadow",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.black:with_alpha(0.3),
        x = 1 + size + m * 2,
        y = 1 + m,
        layer = 2,
        blend_mode = 'normal'
    }
    self.lblShadow2 = pnl:text{
        text = "shadow",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.black:with_alpha(0.3),
        x = size + m * 2 - 1,
        y = 1 + m,
        layer = 2,
        blend_mode = "normal"
    }
end

---@param x number?
function EHIHealthFloatPoco:__shadow(x)
    if x then
        self.lblShadow1:set_x(x + 1)
        self.lblShadow2:set_x(x - 1)
    else
        self.lblShadow1:set_text(self._txts)
        self.lblShadow2:set_text(self._txts)
    end
end

function EHIHealthFloatPoco:_lbl(lbl, txts)
    local result = ''
    if alive(lbl) then
        if type(txts) == 'table' then
            local pos = 0
            local posEnd = 0
            local ranges = {}
            for i, txtObj in ipairs(txts) do
                txtObj[1] = tostring(txtObj[1])
                result = result .. txtObj[1]
                local _, count = txtObj[1]:gsub('[^\128-\193]', '')
                posEnd = pos + count
                ranges[i] = { pos, posEnd, txtObj[2] or Color.white }
                pos = posEnd
            end
            lbl:set_text(result)
            for _, range in ipairs(ranges) do
                lbl:set_range_color(range[1], range[2], range[3] or Color.green)
            end
        elseif type(txts) == 'string' then
            result = txts
            lbl:set_text(txts)
        end
    elseif type(txts) == 'table' then
        for _, t in ipairs(txts) do
            result = result .. tostring(t[1])
        end
    else
        result = txts
    end
    return result
end

---@param t number
function EHIHealthFloatPoco:draw(t)
    if not alive(self._unit) or (t - self._lastT > 0.5) and not self._dead then
        self._dead = true
    end
    if self._dead and not self._dying then
        self:delete()
        return
    end
    if not alive(self._pnl) then
        return
    end
    local unit = self._unit
    if not alive(unit) then
        return
    end
    local dx, dy, d, pDist, ww, hh = 0, 0, 1, 0, self._parent._ww, self._parent._hh
    local pos = self._parent:_pos(unit)
    local nl_dir = pos - self._parent._camPos
    mvector3.normalize(nl_dir)
    local dot_visible = mvector3.dot(self._parent._nl_cam_forward, nl_dir) > 0
    local pPos = self._parent:_v2p(pos) ---@cast pPos -false
    dx = pPos.x - ww / 2
    dy = pPos.y - hh / 2
    pDist = dx * dx + dy * dy
    self._pnl:set_visible(dot_visible)
    if dot_visible then
        local isADS = self._parent.ADS
        local cHealth = unit:character_damage() and unit:character_damage()._health and unit:character_damage()._health * 10 or 0
        local fHealth = cHealth > 0 and (unit:character_damage()._HEALTH_INIT and unit:character_damage()._HEALTH_INIT * 10 or unit:character_damage()._health_max and unit:character_damage()._health_max * 10) or 1
        local prog = cHealth / fHealth
        local isConverted = unit:brain() and unit:brain().converted and unit:brain():converted()
        local isEnemy = managers.enemy:is_enemy(unit)
        if (isConverted and self._converts_disabled) or (managers.enemy:is_civilian(unit) and self._civilians_disabled) or (self._team_ai_disabled and managers.groupai:state():is_unit_team_AI(unit)) then
            prog = 0
        end
        if prog > 0 then
            local size = self._size
            local txts = {}
            local m = self._margin
            local isTurret = unit:base() and unit:base().get_type and unit:base():get_type() == "swat_turret" ---@diagnostic disable-line
            local color = ((isEnemy and not isConverted) or isTurret) and math.lerp(self._color_end, self._color_start, prog) or self._color_friendly
            if pDist <= 100000 and cHealth > 0 then
                txts[1] = { round(cHealth, 2) .. '/' .. round(fHealth, 2), color }
            end
            pPos = pPos:with_y(pPos.y - size * 2)
            self.pie:set_current(prog)
            self.pieBg:set_visible(true)
            local x = 2 * m + size
            self.lbl:set_x(x)
            self:__shadow(x)
            if self._txts ~= self:_lbl(nil, txts) then
                self._txts = self:_lbl(self.lbl, txts)
                self:__shadow()
            end
            local _, _, w, h = self.lbl:text_rect()
            h = math.max(h, size)
            self._pnl:set_size(m * 2 + (w > 0 and w + m + 1 or 0) + size, h + 2 * m)
            self.bg:set_size(self._pnl:size())
            self._pnl:set_center(pPos.x, pPos.y)
        else
            self.pie:set_visible(false)
            self.pieBg:set_visible(false)
            self.lbl:set_visible(false)
            self.lblShadow1:set_visible(false)
            self.lblShadow2:set_visible(false)
        end
        d = isADS and math.clamp((pDist - 1000) / 2000, 0.4, 1) or 1
        d = math.min(d, self._opacity)
        if not (unit and unit:contour() and next(unit:contour()._contour_list or {})) then
            d = math.min(d, self._parent:_visibility(pos))
        end
        if not self._dying then
            self._pnl:set_alpha(d)
            self.lastD = d -- d is for starting alpha
        end
    end
end

---@param t number
function EHIHealthFloatPoco:renew(t)
    self._lastT = math.max(self._lastT, t)
    self._dead = false
    self._dying = false
    self._pnl:stop()
end

function EHIHealthFloatPoco:delete()
    local pnl = self._pnl
    if alive(pnl) and not self._dying then
        self._dying = true
        pnl:stop()
        pnl:animate(self._fade, self.lastD or 1, self._destroy_callback, 0.2)
    end
end

function EHIHealthFloatPoco:force_delete()
    self._dead = true
    self:delete()
end

function EHIHealthFloatPoco:destroy()
    local pnl = self._pnl
    if alive(pnl) then
        pnl:stop()
        pnl:parent():remove(pnl)
    end
    self._parent._floats[self._key] = nil
end

function EHIHealthFloatPoco._fade(o, lastD, done_cb, seconds)
    o:set_visible(true)
    o:set_alpha(1)
    local t = seconds
    while alive(o) and t > 0 do
        local dt = coroutine.yield()
        t = t - dt
        o:set_alpha(lastD * t / seconds)
    end
    o:set_visible(false)
    done_cb()
end
EHIHealthFloatPoco._destroy_callback = callback(EHIHealthFloatPoco, EHIHealthFloatPoco, "destroy")