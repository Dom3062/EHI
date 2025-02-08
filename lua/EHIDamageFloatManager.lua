local mvector3 = mvector3

---@class EHIDamageFloatManager
EHIDamageFloatManager = {}
EHIDamageFloatManager._cop_damage_hook = "EHI_EHIDamageFloatManager_CopDamage_on_damage_received"
EHIDamageFloatManager._show_my_damage = EHI:GetOption("show_floating_damage_popup_my_damage")
EHIDamageFloatManager._show_ai_damage = EHI:GetOption("show_floating_damage_popup_ai_damage")
EHIDamageFloatManager._show_crew_damage = EHI:GetOption("show_floating_damage_popup_crew_damage")
---@param hud HUDManager
function EHIDamageFloatManager:new(hud)
    self.pid = EHI.IsHost and 1 or EHI._cache.LocalPeerID
    if not self.pid then
        return
    elseif not (self._show_my_damage or self._show_ai_damage or self._show_crew_damage) then
        return -- Don't hook anything if user is stupid enough to disable all damage
    end
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._panel = self._ws:panel():panel({ layer = 4 })
    self._ww = self._panel:w()
    self._hh = self._panel:h()
    self._resolution_changed_clbk = managers.viewport:add_resolution_changed_func(callback(self, self, "onResolutionChanged"))
    self._special_units_id = StatisticsManager and StatisticsManager.special_unit_ids or {}
    self._damage_decay = EHI:GetOption("show_floating_damage_popup_time_on_screen") --[[@as number]]
    self._damage_crit_decay = self._damage_decay * 1.2
    self.pops = {} ---@type EHIDamageFloat[]
    Hooks:PostHook(CopDamage, "_on_damage_received", self._cop_damage_hook, callback(self, self, "damage_callback"))
    Hooks:PostHook(PlayerMovement, "init", "EHI_PlayerMovement_EHIDamageFloatManager_init", function(base, ...)
        self._player_movement = base
    end)
    Hooks:PostHook(PlayerCamera, "init", "EHI_PlayerCamera_EHIDamageFloatManager_init", function(base, ...)
        self._player_camera = base._camera_object
        hud:AddEHIUpdator("EHIDamageFloatManager", self)
        if not EHI:HookExists(CopDamage, "_on_damage_received", self._cop_damage_hook) then
            Hooks:PostHook(CopDamage, "_on_damage_received", self._cop_damage_hook, callback(self, self, "damage_callback"))
        end
    end)
    Hooks:PreHook(PlayerMovement, "pre_destroy", "EHI_PlayerMovement_EHIDamageFloatManager_pre_destroy", function(...)
        self._player_movement = nil
        self._player_camera = nil
        if self.pops then
            hud:RemoveEHIUpdator("EHIDamageFloatManager")
            self:update_last()
        end
    end)
    if self._post_hook then
        self:_post_hook()
    end
end

if EHI:GetOption("show_floating_damage_popup_accumulate") then
    function EHIDamageFloatManager:_post_hook()
        self._pop_list = HUDManager.PLAYER_PANEL
        for i = 0, self._pop_list, 1 do
            self.pops[i] = {}
        end
    end

    ---@param t number
    ---@param dt number
    function EHIDamageFloatManager:update(t, dt)
        self._camPos = self._player_camera:position()
        local rot = self._player_camera:rotation()
        self._nl_cam_forward = rot:y()

        self.state = self._player_movement:current_state()
        self.ADS = self.state and self.state._state_data.in_steelsight
        for i = 0, self._pop_list, 1 do
            for key, pop in pairs(self.pops[i] or {}) do
                if pop.dead then
                    pop:destroy2(key)
                else
                    pop:draw(dt)
                end
            end
        end
    end

    ---@param finished boolean?
    function EHIDamageFloatManager:update_last(finished)
        Hooks:RemovePostHook(self._cop_damage_hook)
        for i = 0, self._pop_list, 1 do
            for key, pop in pairs(self.pops[i] or {}) do
                pop:destroy2(key)
            end
        end
        self.pops = nil
        if finished then
            managers.viewport:remove_resolution_changed_func(self._resolution_changed_clbk) -- In case stupid player decided after finishing a heist to change resolution
            self._resolution_changed_clbk = nil
        else
            self.pops = {}
            self:_post_hook()
        end
    end

    ---@param c_dmg CopDamage
    ---@param damage_info CopDamage.AttackData
    function EHIDamageFloatManager:damage_callback(c_dmg, damage_info)
        if damage_info.col_ray or damage_info.is_synced or damage_info.variant == "poison" or damage_info.variant == "graze" then
            local hitPos = Vector3()
            local col_ray = damage_info.col_ray or {}
            mvector3.set(hitPos, col_ray.position or damage_info.pos or col_ray.hit_position or self:_pos(c_dmg._unit))
            if hitPos then
                local realAttacker = damage_info.attacker_unit
                if alive(realAttacker) then
                    local base = realAttacker:base()
                    if base then
                        if base.thrower_unit then
                            realAttacker = base.thrower_unit
                        elseif base.sentry_gun then
                            realAttacker = base:get_owner()
                        end
                    end
                end
                local damage = damage_info.damage
                if type(damage) ~= 'number'  -- Dragon's breath crash
                    or damage_info.variant == 'stun'	-- Stun a convert crash with concussion grenade
                    or damage == 0			-- Stun a shield crash with concussion grenade
                    or type(realAttacker) == "function"
                then
                    return
                end
                local pid = self:_pid(realAttacker)
                if pid == self.pid and not self._show_my_damage then
                    return
                elseif pid == 0 and not self._show_ai_damage then
                    return
                elseif not self._show_crew_damage then
                    if pid > 0 and pid ~= self.pid then
                        return
                    end
                end
                local unit = c_dmg._unit
                local key
                local isCrit = damage_info.critical_hit
                local rDamage = damage >= 0 and damage or -damage
                if damage < 0 and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
                    rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100, unit:character_damage()._health)
                end
                local isSpecial = false ---@type boolean|string
                if unit then
                    local unitTweak = alive(unit) and unit:base() and unit:base()._tweak_table
                    local statsTweak = unitTweak and unit:base()._stats_name or ""
                    isSpecial = unitTweak and unit:base().has_tag and unit:base():has_tag("special") or self._special_units_id[statsTweak]
                    key = unit.key and unit:key()
                end
                local death = c_dmg._dead
                local color = (tweak_data.chat_colors[pid] or Color.white):with_alpha(death and 1 or 0.5)
                local texts = {}
                local n = 1
                if isCrit then
                    texts[n] = { '', Color.red }
                    n = n + 1
                end
                if rDamage > 0 then
                    texts[n] = { math.round(rDamage*10), isCrit and Color.yellow or color }
                    n = n + 1
                end
                if damage_info.headshot then
                    texts[n] = { '!', color:with_red(1) }
                    n = n + 1
                end
                if death or isCrit then
                    texts[n] = { '', isCrit and Color.red or isSpecial and Color.yellow or color }
                    n = n + 1
                end

                local pop_list = self.pops[pid or 0]
                if pop_list and key then
                    local healed = damage_info.result.type == "healed"
                    local t = isCrit and self._damage_crit_decay or self._damage_decay
                    local pop = pop_list[key]
                    if pop then
                        pop:update_damage(texts, healed, isCrit, t, hitPos, rDamage)
                    else
                        pop_list[key] = EHIDamageFloat:new(self, { pos = hitPos, text = texts,
                            pid = pid or 0,
                            t = t,
                            damage = healed and 0 or rDamage
                        })
                    end
                end
            end
        end
    end
else
    ---@param t number
    ---@param dt number
    function EHIDamageFloatManager:update(t, dt)
        self._camPos = self._player_camera:position()
        local rot = self._player_camera:rotation()
        self._nl_cam_forward = rot:y()

        self.state = self._player_movement:current_state()
        self.ADS = self.state and self.state._state_data.in_steelsight
        for key, pop in pairs(self.pops) do
            if pop.dead then
                pop:destroy(key)
            else
                pop:draw(dt)
            end
        end
    end

    ---@param finished boolean?
    function EHIDamageFloatManager:update_last(finished)
        Hooks:RemovePostHook(self._cop_damage_hook)
        for key, pop in pairs(self.pops) do
            pop:destroy(key)
        end
        self.pops = nil
        if finished then
            managers.viewport:remove_resolution_changed_func(self._resolution_changed_clbk) -- In case stupid player decided after finishing a heist to change resolution
            self._resolution_changed_clbk = nil
        else
            self.pops = {}
        end
    end

    ---@param c_dmg CopDamage
    ---@param damage_info CopDamage.AttackData
    function EHIDamageFloatManager:damage_callback(c_dmg, damage_info)
        if damage_info.col_ray or damage_info.is_synced or damage_info.variant == "poison" or damage_info.variant == "graze" then
            local hitPos = Vector3()
            local col_ray = damage_info.col_ray or {}
            mvector3.set(hitPos, col_ray.position or damage_info.pos or col_ray.hit_position or self:_pos(c_dmg._unit))
            if hitPos then
                local realAttacker = damage_info.attacker_unit
                if alive(realAttacker) then
                    local base = realAttacker:base()
                    if base then
                        if base.thrower_unit then
                            realAttacker = base.thrower_unit
                        elseif base.sentry_gun then
                            realAttacker = base:get_owner()
                        end
                    end
                end
                local damage = damage_info.damage
                if type(damage) ~= 'number'  -- Dragon's breath crash
                    or damage_info.variant == 'stun'	-- Stun a convert crash with concussion grenade
                    or damage == 0			-- Stun a shield crash with concussion grenade
                    or type(realAttacker) == "function"
                then
                    return
                end
                local pid = self:_pid(realAttacker)
                if pid == self.pid and not self._show_my_damage then
                    return
                elseif pid == 0 and not self._show_ai_damage then
                    return
                elseif not self._show_crew_damage then
                    if pid > 0 and pid ~= self.pid then
                        return
                    end
                end
                local unit = c_dmg._unit
                local isCrit = damage_info.critical_hit
                local rDamage = damage >= 0 and damage or -damage
                if damage < 0 and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
                    rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100, unit:character_damage()._health)
                end
                local isSpecial = false ---@type boolean|string
                if unit then
                    local unitTweak = alive(unit) and unit:base() and unit:base()._tweak_table
                    local statsTweak = unitTweak and unit:base()._stats_name or ""
                    isSpecial = unitTweak and unit:base().has_tag and unit:base():has_tag("special") or self._special_units_id[statsTweak]
                end
                local death = c_dmg._dead
                local color = (tweak_data.chat_colors[pid] or Color.white):with_alpha(death and 1 or 0.5)
                local texts = {}
                local n = 1
                if isCrit then
                    texts[n] = { '', Color.red }
                    n = n + 1
                end
                if rDamage > 0 then
                    texts[n] = { math.round(rDamage*10), isCrit and Color.yellow or color }
                    n = n + 1
                end
                if damage_info.headshot then
                    texts[n] = { '!', color:with_red(1) }
                    n = n + 1
                end
                if death or isCrit then
                    texts[n] = { '', isCrit and Color.red or isSpecial and Color.yellow or color }
                    n = n + 1
                end

                table.insert(self.pops, EHIDamageFloat:new(self, { pos = hitPos, text = texts,
                    crit = isCrit,
                    t = isCrit and self._damage_crit_decay or self._damage_decay
                }))
            end
        end
    end
end

function EHIDamageFloatManager:onResolutionChanged()
    if alive(self._ws) then
        managers.gui_data:layout_fullscreen_workspace(self._ws)
        self._ww = self._panel:w()
        self._hh = self._panel:h()
    end
end

local UnitVector = Vector3()
---@param something number|UnitObject
function EHIDamageFloatManager:_pos(something)
    local t, unit = type(something)
    if t == 'number' then
        unit = managers.network:session():peer(something):unit()
    else
        unit = something
    end
    if not (unit and alive(unit)) then
        return Vector3()
    end
    local pos = UnitVector
    mvector3.set(pos, unit:position())
    local head_pos = unit:movement() and unit:movement():m_head_pos()
    if head_pos then
        mvector3.set_z(pos, head_pos.z)
    end
    return pos
end

function EHIDamageFloatManager:_pid(something)
    local peer = alive(something) and something:network() and something:network():peer()
    return peer and peer:id() or 0
end

---@param pos Vector3
function EHIDamageFloatManager:_v2p(pos)
    return alive(self._ws) and pos and self._ws:world_to_screen(self._player_camera, pos)
end

---@class EHIDamageFloat
---@field new fun(self: self, owner: EHIDamageFloatManager, data: table): self
EHIDamageFloat = class()
EHIDamageFloat._size = EHI:GetOption("show_floating_damage_popup_size") --[[@as number]]
EHIDamageFloat._text_color = Color(1, 43/51, 0)
EHIDamageFloat._bg_color = Color(0, 0, 0)
---@param owner EHIDamageFloatManager
---@param data table
function EHIDamageFloat:init(owner, data)
    self.owner = owner
    self.data = data
    self.data.et = data.t
    self.ppnl = owner._panel
    local size = self._size
    local pnl = self.ppnl:panel({ x = 0, y = 0, w=200, h=100 })
    if data.crit then
        size = size * 1.2
    end
    self.pnl = pnl
    self.lbl = pnl:text{text = '', font = 'fonts/font_medium_mf', font_size = size, color = self._text_color, x=0,y=0, layer=3, blend_mode = "normal"}
    local _txt = self:_lbl(self.lbl,data.text)
    self.lblBg = pnl:text{text=_txt, font = 'fonts/font_medium_mf', font_size = size, color = self._bg_color, x=1,y=1, layer=2, blend_mode = 'normal'}
    local x,y,w,h = self.lblBg:text_rect()
    pnl:set_shape(-100,-100,w,h)
end

---@param text table
---@param healed boolean
---@param t number
---@param pos Vector3
---@param rDamage number
function EHIDamageFloat:update_damage(text, healed, crit, t, pos, rDamage)
    self.data.et = t
    self.data.pos = pos
    self.data.damage = self.data.damage + rDamage
    self.dead = false
    text[crit and 2 or 1][1] = math.round(self.data.damage * 10)
    if healed then
        self.data.damage = 0
    end
    local txt = self:_lbl(self.lbl, text)
    self.lblBg:set_text(txt)
    local x,y,w,h = self.lblBg:text_rect()
    self.pnl:set_shape(-100,-100,w,h)
end

---@param dt number
function EHIDamageFloat:draw(dt)
    if alive(self.pnl) then
        local camPos = self.owner._camPos
        local data = self.data
        data.et = data.et - dt
        local prog = 1 - (data.et / data.t)
        local pos = data.pos + Vector3()
        local nl_dir = pos - camPos
        mvector3.normalize(nl_dir)
        local dot = mvector3.dot(self.owner._nl_cam_forward, nl_dir)
        self.pnl:set_visible(dot > 0)
        if dot > 0 then
            local pPos = self.owner:_v2p(pos) ---@cast pPos -false
            mvector3.set_y(pPos,pPos.y - math.lerp(100,0, math.pow(1-prog,7)))

            if prog >= 1 then
                self.dead = true
            else
                local dx,dy,d,ww,hh = 0,0,1,self.owner._ww,self.owner._hh
                self.pnl:set_center(pPos.x,pPos.y)
                if self.owner.ADS then
                    dx = pPos.x - ww/2
                    dy = pPos.y - hh/2
                    d = math.clamp((dx*dx+dy*dy)/1000,0,1)
                else
                    d = 1-math.pow(prog,5)
                end
                d = math.min(d, 1 - math.min(0.9, managers.environment_controller._current_flashbang))
                self.pnl:set_alpha(math.min(1-prog,d))
            end
        end
    end
end

function EHIDamageFloat:_lbl(lbl, txts)
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

function EHIDamageFloat:destroy(key)
    self.ppnl:remove(self.pnl)
    if key then
        self.owner.pops[key] = nil
    end
end

function EHIDamageFloat:destroy2(key)
    self.ppnl:remove(self.pnl)
    if key then
        self.owner.pops[self.data.pid][key] = nil
    end
end