---@class EHIHealthFloatCircle
EHIHealthFloatCircle = {}
EHIHealthFloatCircle._converts_disabled = not EHI:GetOption("show_floating_health_bar_converts") -- Team AI shares the same slot mask (16) with converts, workaround
EHIHealthFloatCircle._civilians_disabled = not EHI:GetOption("show_floating_health_bar_civilians") -- Tied civilians share the same slot mask (22) with tied cops, workaround
EHIHealthFloatCircle._team_ai_disabled = not EHI:GetOption("show_floating_health_bar_team_ai") -- Converts share the same slot mask (16) with Team AI, workaround
EHIHealthFloatCircle._regular_disabled = not EHI:GetOption("show_floating_health_bar_regular_enemies")
for _, option in ipairs({ "tank", "shield", "taser", "cloaker", "sniper", "medic", "other" }) do
    EHIHealthFloatCircle[string.format("_special_%s_disabled", option)] = not EHI:GetOption(string.format("show_floating_health_bar_special_enemies_%s", option))
end
---@param hud_panel Panel
function EHIHealthFloatCircle:new(hud_panel)
    self._current_health = 0
    self._t = 0
    local scale = 75
    local vertical_offset = 110
    local horizontal_offset = 0

    local main_panel = hud_panel:panel({
        visible = true,
        h = scale + 20,
        y = vertical_offset,
        valign = "top",
        layer = 0
    })
    main_panel:set_x(main_panel:x() + horizontal_offset)

    local enemy_health_circle_panel = main_panel:panel({
        visible = false,
        layer = 1,
        w = scale,
        h = scale,
        x = main_panel:center() - (scale / 2)
    })
    enemy_health_circle_panel:set_bottom(main_panel:h())
    self._circle_health_panel = enemy_health_circle_panel

    self._progress = Color(1, 1, 1, 1)
    self._circle_health = enemy_health_circle_panel:bitmap({
        texture = "guis/textures/pd2/hud_health",
        texture_rect = { 128, 0, -128, 128 },
        render_template = "VertexColorTexturedRadial",
        color = self._progress,
        align = "center",
        blend_mode = "normal",
        alpha = 1,
        w = enemy_health_circle_panel:w(),
        h = enemy_health_circle_panel:h(),
        layer = 2
    })

    self._damage_indicator = enemy_health_circle_panel:bitmap({
        texture = "guis/textures/pd2/hud_radial_rim",
        blend_mode = "add",
        alpha = 0,
        w = enemy_health_circle_panel:w(),
        h = enemy_health_circle_panel:h(),
        layer = 1,
        align = "center",
        color = self._progress
    })

    self._health_num = enemy_health_circle_panel:text({
        text = "",
        layer = 5,
        alpha = 0.9,
        color = Color.white,
        w = enemy_health_circle_panel:w(),
        x = 0,
        y = 0,
        h = enemy_health_circle_panel:h(),
        vertical = "center",
        align = "center",
        font = tweak_data.menu.pd2_large_font
    })

    self._health_num_bg = {} ---@type Text[]
    self._health_num_bg[1] = enemy_health_circle_panel:text({
        text = "",
        layer = 4,
        alpha = 0.9,
        color = Color.black,
        w = enemy_health_circle_panel:w(),
        x = -1,
        y = -1,
        h = enemy_health_circle_panel:h(),
        vertical = "center",
        align = "center",
        font = tweak_data.menu.pd2_large_font
    })
    self._health_num_bg[2] = enemy_health_circle_panel:text({
        text = "",
        layer = 1,
        alpha = 0.9,
        color = Color.black,
        w = enemy_health_circle_panel:w(),
        x = 1,
        y = 1,
        h = enemy_health_circle_panel:h(),
        vertical = "center",
        align = "center",
        font = tweak_data.menu.pd2_large_font
    })
    self._health_num_bg[3] = enemy_health_circle_panel:text({
        text = "",
        layer = 1,
        alpha = 0.9,
        color = Color.black,
        w = enemy_health_circle_panel:w(),
        x = -1,
        y = 1,
        h = enemy_health_circle_panel:h(),
        vertical = "center",
        align = "center",
        font = tweak_data.menu.pd2_large_font
    })
    self._health_num_bg[4] = enemy_health_circle_panel:text({
        text = "",
        layer = 1,
        alpha = 0.9,
        color = Color.black,
        w = enemy_health_circle_panel:w(),
        x = 1,
        y = -1,
        h = enemy_health_circle_panel:h(),
        vertical = "center",
        align = "center",
        font = tweak_data.menu.pd2_large_font
    })
    return self
end

---@param unit UnitEnemy|UnitEnemyTurret
---@param t number
function EHIHealthFloatCircle:SetUnit(unit, t)
    if self._unit == unit then
        self._t = t
        return
    end
    self._t = t
    self._unit = unit
    self._block_update = false
    self._current_health = 0
    local base = unit:base() ---@cast base -SentryGunBase
    if self._converts_disabled and (unit:brain() and unit:brain().converted and unit:brain():converted()) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif self._civilians_disabled and managers.enemy:is_civilian(unit) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif self._team_ai_disabled and managers.groupai:state():is_unit_team_AI(unit) then
        self._block_update = true
        self:set_visible(false)
        return
    elseif base then
        if base.has_tag then
            if base:has_tag("special") then
                ---@diagnostic disable
                if base:has_tag("tank") then
                    if self._special_tank_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("shield") then
                    if self._special_shield_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("taser") then
                    if self._special_taser_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("spook") then
                    if self._special_cloaker_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("sniper") then
                    if self._special_sniper_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif base:has_tag("medic") then
                    if self._special_medic_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                elseif self._special_other_disabled then
                    if self._special_tank_disabled then
                        self._block_update = true
                        self:set_visible(false)
                        return
                    end
                end
                ---@diagnostic enable
            elseif self._regular_disabled then
                self._block_update = true
                self:set_visible(false)
                return
            end
        elseif base.get_type and base:get_type() == "swat_turret" and self._special_turret_disabled then ---@diagnostic disable-line
            self._block_update = true
            self:set_visible(false)
            return
        end
    end
end

function EHIHealthFloatCircle:UpdateLast()
    self._unit = nil
    self:set_visible(false)
end

---@param t number
function EHIHealthFloatCircle:Update(t)
    if self._block_update or not self._unit then
        return
    elseif t - self._t > 0.5 or not alive(self._unit) then
        self._unit = nil
        self:set_visible(false)
        return
    end
    local unit = self._unit
    local current_health = math.max(unit:character_damage()._health * 10, 0)
    if self._current_health == current_health then
        return
    end
    self._current_health = current_health
    local current, data_number, K
    if current_health >= 10^6 then
        current = current_health / 1000000 / 1
        current = string.sub(current,0,string.sub(current,-1) == "0" and -3 or -1)
        self._health_num:set_font_size(24)
        for _, num_bg in ipairs(self._health_num_bg) do
            num_bg:set_font_size(2.5)
        end
        K = "M"
    elseif current_health > 999 then
        current = current_health / 1000
        self._health_num:set_font_size(27.5)
        for _, num_bg in ipairs(self._health_num_bg) do
            num_bg:set_font_size(27)
        end
        K = "K"
    else
        current = current_health
        self._health_num:set_font_size(30)
        for _, num_bg in ipairs(self._health_num_bg) do
            num_bg:set_font_size(30)
        end
        K = ""
    end

    if current_health >= 10^6 then
        data_number = "%.1f%s"
    else
        data_number = "%.0f%s"
    end

    local ratio = unit:character_damage():health_ratio()
    if ratio < self._progress.red then
        self._damage_indicator:stop()
        self._damage_indicator:animate(self._animate_damage_taken, current_health <= 0)
    end

    self._progress.red = ratio
    self._circle_health:set_color(self._progress)
    local current_health_formatted = string.format(data_number, current, K)
    self._health_num:set_text(current_health_formatted)
    for _, num_bg in ipairs(self._health_num_bg) do
        num_bg:set_text(current_health_formatted)
    end
    self:set_visible(current_health > 0)
end

---@param custody_state boolean
function EHIHealthFloatCircle:SetInCustody(custody_state)
    self._block_update = custody_state
    if custody_state then
        self:set_visible(false)
    end
end

---@param visible boolean
function EHIHealthFloatCircle:set_visible(visible)
    if self._no_target then
        if visible then
            self._no_target = false
            self._circle_health_panel:stop()
            self._circle_health_panel:set_visible(true)
            self._circle_health_panel:set_alpha(1)
        end
    elseif not visible then
        self._no_target = true
        self._circle_health_panel:animate(self._animate_hide_decay, self)
    end
end

---@param o Panel
---@param self EHIHealthFloatCircle
function EHIHealthFloatCircle._animate_hide_decay(o, self)
    local fadeout = 1.5
    local t = fadeout
    while t > 0 and self._no_target do
        local dt = coroutine.yield()
        t = t - dt
        o:set_alpha(t / fadeout)
    end
    if self._no_target then
        o:set_visible(false)
    end
    o:set_alpha(1)
end

---@param o Bitmap
---@param killershot boolean
function EHIHealthFloatCircle._animate_damage_taken(o, killershot)
    o:set_alpha(1)
    local st = 1.5
    local t = st
    local st_red_t = 0.5
    local red_t = st_red_t
    local killcolor = Color.red
    local hurtcolor = Color("FFA500")
    while t > 0 do
        local dt = coroutine.yield()
        t = t - dt
        red_t = math.clamp(red_t - dt, 0, 1)
        local c = red_t / st_red_t
        local setcolor = killershot and Color(c + killcolor.r, c + killcolor.g, c + killcolor.b) or Color(c + hurtcolor.r, c + hurtcolor.g, c + hurtcolor.b)
        o:set_color(setcolor)
        o:set_alpha(t / st)
    end
    o:set_alpha(0)
end