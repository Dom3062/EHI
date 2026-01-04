local EHI = EHI
if EHI:CheckLoadHook("EHIHealthFloatManager") then
    return
end

---@class EHIHealthFloatManager
EHIHealthFloatManager = {}
---@param hud HUDManager
---@param hud_panel Panel
function EHIHealthFloatManager:new(hud, hud_panel)
    self._unit_slot_mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 22, 24, 25, 26, 33, 34, 35)
    if EHI:GetOption("show_floating_health_bar_civilians") then -- +Slot mask 21
        self._unit_slot_mask = self._unit_slot_mask + managers.slot:get_mask("civilians")
    end
    Hooks:PreHook(PlayerMovement, "pre_destroy", "EHI_PlayerMovement_EHIHealthFloatManager_pre_destroy", function(...)
        hud:RemoveEHIUpdator("EHI_HealthFloat_Update")
        self._player_movement = nil
        self._player_camera = nil
        self:update_last()
    end)
    self:post_init(hud, hud_panel)
end

if EHI:GetOption("show_floating_health_bar_style") == 1 then -- Poco style
    local mvector3 = mvector3
    dofile(EHI.LuaPath .. "manager/health_float/EHIHealthFloatPoco.lua")
    ---@param hud HUDManager
    ---@param hud_panel Panel
    function EHIHealthFloatManager:post_init(hud, hud_panel)
        self._ws = managers.gui_data:create_fullscreen_workspace()
        self._pnl = self._ws:panel():panel({ layer = 4 })
        self._ww = self._pnl:w()
        self._hh = self._pnl:h()
        self._resolution_changed_clbk = managers.viewport:add_resolution_changed_func(callback(self, self, "onResolutionChanged"))
        self._floats = {} ---@type table<userdata, EHIHealthFloatPoco>
        self._smokes = {} ---@type table<userdata, Vector3>
        Hooks:PostHook(QuickSmokeGrenade, "detonate", "EHI_QuickSmokeGrenade_EHIHealthFloatManager_detonate", function(base, ...)
            local unit = base._unit
            self._smokes[unit:key()] = unit:position()
        end)
        Hooks:PostHook(QuickSmokeGrenade, "destroy", "EHI_QuickSmokeGrenade_EHIHealthFloatManager_destroy", function(base, ...)
            self._smokes[base._unit:key()] = nil
        end)
        Hooks:PreHook(TeamAIBase, "_register", "EHI_TeamAIBase_register", function(base, ...)
            if base._registered or not self._floats then
                return
            end
            local key = base._unit.key and base._unit:key()
            if not key then
                return
            elseif self._floats[key] then
                self._floats[key]:destroy()
            end
            self._floats[key] = EHIHealthFloatPocoTeamAI:new(key, base._unit, 0)
        end)
        Hooks:PreHook(TeamAIBase, "unregister", "EHI_TeamAIBase_unregister", function(base, ...)
            if not base._registered or not self._floats then
                return
            end
            local key = base._unit.key and base._unit:key()
            if not key then
                return
            elseif self._floats[key] then
                self._floats[key]:force_delete(true)
            end
        end)
        ---@param base SentryGunMovement
        local function HookEnemyTurret(base)
            if base.__ehi_poco_float or not self._floats then
                return
            end
            local key = base._unit.key and base._unit:key()
            if not key then
                return
            elseif self._floats[key] then
                self._floats[key]:destroy()
            end
            self._floats[key] = EHIHealthFloatPocoTurret:new(key, base._unit, 0)
            base.__ehi_poco_float = true
        end
        ---@param base SentryGunMovement
        local function DestroyEnemyTurret(base)
            if not base.__ehi_poco_float or not self._floats then
                return
            end
            local key = base._unit.key and base._unit:key()
            if not key then
                return
            elseif self._floats[key] then
                self._floats[key]:force_delete(true)
            end
            base.__ehi_poco_float = nil
        end
        Hooks:PostHook(SentryGunMovement, "on_activated", "EHI_SentryGunMovement_EHIHealthFloatManager_on_activated", HookEnemyTurret)
        Hooks:PostHook(SentryGunMovement, "load", "EHI_SentryGunMovement_EHIHealthFloatManager_load", function(base, save_data)
            if not (save_data and save_data.movement) then
                return
            end
            HookEnemyTurret(base)
        end)
        Hooks:PostHook(SentryGunMovement, "on_death", "EHI_SentryGunMovement_EHIHealthFloatManager_on_death", DestroyEnemyTurret)
        Hooks:PostHook(SentryGunMovement, "pre_destroy", "EHI_SentryGunMovement_EHIHealthFloatManager_pre_destroy", DestroyEnemyTurret)
        EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(unit, local_peer, peer_id) ---@param unit UnitEnemy
            local key = unit:key()
            if not self._floats then
                return
            elseif self._floats[key] then
                self._floats[key]:force_delete(true)
            end
            self._floats[key] = EHIHealthFloatPocoConvert:new(key, unit, 0)
        end)
        EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
            if not self._floats then
                return
            elseif self._floats[key] then
                self._floats[key]:force_delete(true)
            end
        end)
        Hooks:PostHook(PlayerMovement, "init", "EHI_PlayerMovement_EHIHealthFloatManager_init", function(base, ...)
            self._player_movement = base
        end)
        Hooks:PostHook(PlayerCamera, "init", "EHI_PlayerCamera_EHIHealthFloatManager_init", function(base, ...)
            self._player_camera = base._camera_object
            hud:AddEHIUpdator("EHI_HealthFloat_Update", self)
        end)
        EHI:AddCallback(EHI.CallbackMessage.HUDVisibilityChanged, function(visibility) ---@param visibility boolean
            if visibility then
                self._ws:show()
            else
                self._ws:hide()
            end
        end)
    end

    function EHIHealthFloatManager:onResolutionChanged()
        if alive(self._ws) then
            managers.gui_data:layout_fullscreen_workspace(self._ws)
            self._ww = self._pnl:w()
            self._hh = self._pnl:h()
        end
    end

    ---@param unit UnitObject
    ---@param t number
    function EHIHealthFloatManager:Float(unit, t)
        local key = unit.key and unit:key()
        if not key then return end
        local float = self._floats[key]
        if float then
            float:renew(t)
        else
            self._floats[key] = EHIHealthFloatPoco:new(key, unit, t)
        end
    end

    ---@param finished boolean?
    function EHIHealthFloatManager:update_last(finished)
        if self._finished then
            return
        end
        for _, float in pairs(self._floats or {}) do
            float:force_delete(finished)
        end
        if self._floats and not next(self._floats) then
            self._floats = nil
        end
        if finished then
            managers.viewport:remove_resolution_changed_func(self._resolution_changed_clbk) -- In case stupid player decided after finishing a heist to change resolution
            self._resolution_changed_clbk = nil
            self._finished = true
        elseif not self._floats then
            self._floats = {}
        end
    end

    local UnitVector = Vector3()
    ---@param something number|UnitObject
    function EHIHealthFloatManager:_pos(something)
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

    ---@param uPos Vector3?
    function EHIHealthFloatManager:_visibility(uPos)
        local result = 1 - math.min(0.9, managers.environment_controller._current_flashbang)
        if uPos then
            local minDis = 9999
            local sRad = 300
            for _, sPos in pairs(self._smokes) do
                local cPos = self._camPos
                local disR, dotR = 1, 1
                local sDir = sPos - cPos
                local uDir = uPos - cPos
                local xDir = sPos - uPos
                minDis = math.min(sDir:length(), xDir:length())
                if minDis <= sRad then
                    disR = math.pow(minDis / sRad, 3)
                elseif sDir:length() < uDir:length() then
                    mvector3.normalize(sDir)
                    mvector3.normalize(uDir)
                    dotR = 1 - math.pow(mvector3.dot(sDir, uDir), 3)
                end
                result = math.min(result, math.min(disR, dotR))
            end
        end
        return result
    end

    ---@param pos Vector3
    function EHIHealthFloatManager:_v2p(pos)
        return alive(self._ws) and pos and self._ws:world_to_screen(self._player_camera, pos)
    end

    ---@param t number
    function EHIHealthFloatManager:update(t, dt)
        self._camPos = self._player_camera:position()
        self._nl_cam_forward = self._player_camera:rotation():y()

        self.state = self._player_movement:current_state()
        self.ADS = self.state and self.state._state_data.in_steelsight

        local r = nil
        local from = self._player_movement:m_head_pos()
        if from then
            local to = from + self._player_movement:m_head_rot():y() * 30000
            r = World:raycast("ray", from, to, "slot_mask", self._unit_slot_mask)
        end
        local unit = r and r.unit
        if type(unit) == "userdata" then
            if unit:in_slot(8) and alive(unit:parent()) then
                unit = unit:parent() --[[@as UnitObject ]]
            end
            if unit and unit:movement() then
                local cHealth = unit:character_damage() and unit:character_damage()._health
                if cHealth and cHealth > 0 then
                    self:Float(unit, t)
                end
            end
        end

        for _, float in pairs(self._floats) do
            float:draw(t)
        end
    end
else
    if EHI:GetOption("show_floating_health_bar_style") == 2 then
        dofile(EHI.LuaPath .. "manager/health_float/EHIHealthFloatCircle.lua")
        ---@param hud HUDManager
        ---@param hud_panel Panel
        function EHIHealthFloatManager:post_init(hud, hud_panel)
            self._float = EHIHealthFloatCircle:new(hud_panel)
            EHI:AddOnCustodyCallback(function(custody_state)
                self._float:SetInCustody(custody_state)
            end)
            Hooks:PostHook(PlayerMovement, "init", "EHI_PlayerMovement_EHIHealthFloatManager_init", function(base, ...)
                self._player_movement = base
                hud:AddEHIUpdator("EHI_HealthFloat_Update", self)
            end)
        end
    else
        dofile(EHI.LuaPath .. "manager/health_float/EHIHealthFloatRect.lua")
        ---@param hud HUDManager
        ---@param hud_panel Panel
        function EHIHealthFloatManager:post_init(hud, hud_panel)
            self._float = EHIHealthFloatRect:new(hud_panel)
            EHI:AddOnCustodyCallback(function(custody_state)
                self._float:SetInCustody(custody_state)
            end)
            Hooks:PostHook(PlayerMovement, "init", "EHI_PlayerMovement_EHIHealthFloatManager_init", function(base, ...)
                self._player_movement = base
                hud:AddEHIUpdator("EHI_HealthFloat_Update", self)
            end)
        end
    end

    ---@param finished boolean?
    function EHIHealthFloatManager:update_last(finished)
        self._float:UpdateLast()
    end

    ---@param t number
    function EHIHealthFloatManager:update(t, dt)
        local r = nil
        local from = self._player_movement:m_head_pos()
        if from then
            local to = from + self._player_movement:m_head_rot():y() * 30000
            r = World:raycast("ray", from, to, "slot_mask", self._unit_slot_mask) --[[@as { unit: UnitObject? }]]
        end
        local unit = r and r.unit
        if type(unit) == "userdata" then
            if unit:in_slot(8) and alive(unit:parent()) then
                unit = unit:parent() --[[@as UnitEnemy?]]
            end
            if unit and unit:movement() then
                local cHealth = unit:character_damage() and unit:character_damage()._health
                if cHealth then
                    self._float:SetUnit(unit, t)
                end
            end
        end
        self._float:Update(t)
    end
end