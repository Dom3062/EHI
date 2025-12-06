local function round(num)
    local res = string.format('%.2g', num)
    return res:find('e') and tostring(math.floor(num)) or res
end

---Optimized version of CircleBitmapGuiObject
---@class EHICircleBitmapGuiObject : CircleBitmapGuiObject
---@field super CircleBitmapGuiObject
---@field new fun(self: self, panel: Panel, config: CircleBitmapGuiObject_params): self
local EHICircleBitmapGuiObject = class(CircleBitmapGuiObject)
function EHICircleBitmapGuiObject:init(...)
    EHICircleBitmapGuiObject.super.init(self, ...)
    self._color = self._circle:color()
end

---@param current number
function EHICircleBitmapGuiObject:set_current(current)
    self._color.red = current
    self._circle:set_color(self._color)
end

---@class EHIHealthFloatPoco
---@field new fun(self: self, key: userdata, unit: UnitObject, t: number): self
EHIHealthFloatPoco = class()
EHIHealthFloatPoco._parent = EHIHealthFloatManager
EHIHealthFloatPoco._size = 16
EHIHealthFloatPoco._margin = 2
EHIHealthFloatPoco._opacity = 0.9
EHIHealthFloatPoco._show_blur = EHI:GetOption("show_floating_health_bar_style_poco_blur")
EHIHealthFloatPoco._color_start = Color("FFA500"):with_alpha(1)
EHIHealthFloatPoco._color_end = Color("FF0000"):with_alpha(1)
EHIHealthFloatPoco._color_friendly = Color("00FF00"):with_alpha(1)
EHIHealthFloatPoco._civilians_disabled = not EHI:GetOption("show_floating_health_bar_civilians") -- Tied civilians share the same slot mask (22) with tied cops, workaround
EHIHealthFloatPoco._regular_disabled = not EHI:GetOption("show_floating_health_bar_regular_enemies")
for _, option in ipairs({ "tank", "shield", "taser", "cloaker", "sniper", "medic", "other" }) do
    EHIHealthFloatPoco[string.format("_special_%s_disabled", option)] = not EHI:GetOption(string.format("show_floating_health_bar_special_enemies_%s", option))
end
---@param key userdata
---@param unit UnitObject
---@param t number
function EHIHealthFloatPoco:init(key, unit, t)
    self._unit = unit
    self._key = key
    self._lastT = t
    local size = self._size
    local m = self._margin
    local pnl = self._parent._pnl:panel({
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
        y = 0,
        visible = self._show_blur
    })
    self.pie = EHICircleBitmapGuiObject:new(pnl, {
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
    local unit = self._unit
    if not alive(unit) then
        return
    end
    if not alive(self._pnl) then
        return
    end
    local pos = self._parent:_pos(unit)
    local nl_dir = pos - self._parent._camPos
    mvector3.normalize(nl_dir)
    local dot_visible = mvector3.dot(self._parent._nl_cam_forward, nl_dir) > 0
    self._pnl:set_visible(dot_visible)
    if dot_visible then
        local d = 1
        local base = unit:base() ---@cast base -PlayerBase|HuskPlayerBase|SentryGunBase|UnitBase
        local character_damage = unit:character_damage()
        local cHealth = character_damage and character_damage._health and character_damage._health * 10 or 0
        local fHealth = cHealth > 0 and (character_damage._HEALTH_INIT * 10) or 1 ---@diagnostic disable-line
        local prog = cHealth / fHealth
        local isEnemy = managers.enemy:is_enemy(unit)
        if managers.enemy:is_civilian(unit) and self._civilians_disabled then
            prog = 0
        elseif isEnemy and base and base.has_tag then
            if base:has_tag("special") then
                ---@diagnostic disable
                if base:has_tag("tank") then
                    if self._special_tank_disabled then
                        prog = 0
                    end
                elseif base:has_tag("shield") then
                    if self._special_shield_disabled then
                        prog = 0
                    end
                elseif base:has_tag("taser") then
                    if self._special_taser_disabled then
                        prog = 0
                    end
                elseif base:has_tag("spook") then
                    if self._special_cloaker_disabled then
                        prog = 0
                    end
                elseif base:has_tag("sniper") then
                    if self._special_sniper_disabled then
                        prog = 0
                    end
                elseif base:has_tag("medic") then
                    if self._special_medic_disabled then
                        prog = 0
                    end
                elseif self._special_other_disabled then
                    prog = 0
                end
                ---@diagnostic enable
            elseif self._regular_disabled then
                prog = 0
            end
        end
        if prog > 0 then
            local size = self._size
            local txts = {}
            local m = self._margin
            local color = isEnemy and math.lerp(self._color_end, self._color_start, prog) or self._color_friendly
            local pPos = self._parent:_v2p(pos) ---@cast pPos -false
            local dx = pPos.x - self._parent._ww / 2
            local dy = pPos.y - self._parent._hh / 2
            local pDist = dx * dx + dy * dy
            if pDist <= 100000 and cHealth > 0 then
                txts[1] = { round(cHealth) .. '/' .. round(fHealth), color }
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
            d = self._parent.ADS and math.clamp((pDist - 1000) / 2000, 0.4, 1) or 1
            d = math.min(d, self._opacity)
            if not (unit and unit:contour() and next(unit:contour()._contour_list or {})) then
                d = math.min(d, self._parent:_visibility(pos))
            end
        else
            self.pie:set_visible(false)
            self.pieBg:set_visible(false)
            self.lbl:set_visible(false)
            self.bg:set_visible(false)
            self.lblShadow1:set_visible(false)
            self.lblShadow2:set_visible(false)
            d = 0
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
        pnl:animate(self._fade, self.lastD or 1, 0.2, self._destroy_callback)
    end
end

---@param finished boolean?
function EHIHealthFloatPoco:force_delete(finished)
    self._dead = true
    self:delete()
end

function EHIHealthFloatPoco:destroy()
    local pnl = self._pnl
    if alive(pnl) then
        pnl:parent():remove(pnl)
    end
    self._parent._floats[self._key] = nil
end

---@param o Panel
---@param lastD number
---@param seconds number
---@param done_cb function?
function EHIHealthFloatPoco._fade(o, lastD, seconds, done_cb)
    if lastD > 0 then
        o:set_visible(true)
        o:set_alpha(lastD)
        local t = seconds
        while t > 0 do
            local dt = coroutine.yield()
            t = t - dt
            o:set_alpha(lastD * t / seconds)
        end
        o:set_visible(false)
    end
    if done_cb then
        done_cb()
    end
end
EHIHealthFloatPoco._destroy_callback = callback(EHIHealthFloatPoco, EHIHealthFloatPoco, "destroy")

---@class EHIReusableHealthFloatPoco : EHIHealthFloatPoco
---@field super EHIHealthFloatPoco
EHIReusableHealthFloatPoco = class(EHIHealthFloatPoco)
EHIReusableHealthFloatPoco._UNIT_DISABLED_CONDITION = true
EHIReusableHealthFloatPoco._UNIT_IS_FRIENDLY = true
function EHIReusableHealthFloatPoco:renew(...)
    self._keep_alive = true
    EHIReusableHealthFloatPoco.super.renew(self, ...)
end

---@param t number
function EHIReusableHealthFloatPoco:draw(t)
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
    local pos = self._parent:_pos(unit)
    local nl_dir = pos - self._parent._camPos
    mvector3.normalize(nl_dir)
    local dot_visible = mvector3.dot(self._parent._nl_cam_forward, nl_dir) > 0
    self._pnl:set_visible(dot_visible)
    if dot_visible then
        local d = 1
        local character_damage = unit:character_damage()
        local cHealth = character_damage and character_damage._health and character_damage._health * 10 or 0
        local fHealth = cHealth > 0 and (character_damage._HEALTH_INIT * 10) or 1 ---@diagnostic disable-line
        local prog = self._UNIT_DISABLED_CONDITION and 0 or cHealth / fHealth
        if prog > 0 then
            local size = self._size
            local txts = {}
            local m = self._margin
            local pPos = self._parent:_v2p(pos) ---@cast pPos -false
            local dx = pPos.x - self._parent._ww / 2
            local dy = pPos.y - self._parent._hh / 2
            local pDist = dx * dx + dy * dy
            if pDist <= 100000 and cHealth > 0 then
                local color = self._UNIT_IS_FRIENDLY and self._color_friendly or math.lerp(self._color_end, self._color_start, prog)
                txts[1] = { round(cHealth) .. '/' .. round(fHealth), color }
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
            d = self._parent.ADS and math.clamp((pDist - 1000) / 2000, 0.4, 1) or 1
            d = math.min(d, self._opacity)
            if not (unit and unit:contour() and next(unit:contour()._contour_list or {})) then
                d = math.min(d, self._parent:_visibility(pos))
            end
        else
            self.pie:set_visible(false)
            self.pieBg:set_visible(false)
            self.lbl:set_visible(false)
            self.bg:set_visible(false)
            self.lblShadow1:set_visible(false)
            self.lblShadow2:set_visible(false)
            d = 0
        end
        if not self._dying then
            self._pnl:set_alpha(d)
            self.lastD = d -- d is for starting alpha
        end
    end
end

function EHIReusableHealthFloatPoco:delete()
    if self._death then
        EHIReusableHealthFloatPoco.super.delete(self)
    elseif self._keep_alive then
        self._keep_alive = false
        local pnl = self._pnl
        if alive(pnl) then
            pnl:stop()
            pnl:animate(self._fade, self.lastD or 1, 0.2)
        end
    end
end

function EHIReusableHealthFloatPoco:force_delete(finished)
    self.lastD = self._pnl:visible() and self._pnl:alpha() or 0
    self._death = finished
    self._keep_alive = not finished
    self._dying = self._keep_alive
    EHIReusableHealthFloatPoco.super.force_delete(self)
end

---@class EHIHealthFloatPocoTeamAI : EHIReusableHealthFloatPoco
EHIHealthFloatPocoTeamAI = class(EHIReusableHealthFloatPoco)
EHIHealthFloatPocoTeamAI._UNIT_DISABLED_CONDITION = not EHI:GetOption("show_floating_health_bar_team_ai") -- Converts share the same slot mask (16) with Team AI, workaround

---@class EHIHealthFloatPocoConvert : EHIReusableHealthFloatPoco
EHIHealthFloatPocoConvert = class(EHIReusableHealthFloatPoco)
EHIHealthFloatPocoConvert._UNIT_DISABLED_CONDITION = not EHI:GetOption("show_floating_health_bar_converts") -- Team AI shares the same slot mask (16) with converts, workaround

---@class EHIHealthFloatPocoTurret : EHIReusableHealthFloatPoco
EHIHealthFloatPocoTurret = class(EHIReusableHealthFloatPoco)
EHIHealthFloatPocoTurret._UNIT_DISABLED_CONDITION = not EHI:GetOption("show_floating_health_bar_special_enemies_turret")
EHIHealthFloatPocoTurret._UNIT_IS_FRIENDLY = false