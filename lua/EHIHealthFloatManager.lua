local EHI = EHI
if EHI:CheckLoadHook("EHIHealthFloatManager") then
    return
end

---@class EHIHealthFloatManager
---@field _ws Workspace Poco style
---@field _pnl Panel Poco style
---@field _float EHIHealthFloatCircle|EHIHealthFloatRect
---@field _floats table<string, EHIHealthFloatPoco?>
---@field _smokes table<string, Vector3>
EHIHealthFloatManager = {}
---@param hud HUDManager
---@param hud_panel Panel
function EHIHealthFloatManager:new(hud, hud_panel)
    self._unit_slot_mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 18, 22, 24, 25, 26, 33, 34, 35)
    if EHI:GetOption("show_floating_health_bar_civilians") then -- +Slot mask 21
        self._unit_slot_mask = self._unit_slot_mask + managers.slot:get_mask("civilians")
    end
    hud:AddEHIUpdator("EHI_HealthFloat_Update", self)
    EHI:CallCallbackOnce("EHIHealthFloatManagerInit", self, hud_panel)
end

if EHI:GetOption("show_floating_health_bar_style") == 1 then -- Poco style
    local mvector3 = mvector3
    dofile(EHI.LuaPath .. "EHIHealthFloatPoco.lua")
    EHI:AddCallback("EHIHealthFloatManagerInit",
    ---@param self EHIHealthFloatManager
    ---@param hud_panel Panel
    function(self, hud_panel)
        self._ws = managers.gui_data:create_fullscreen_workspace()
        self._pnl = self._ws:panel():panel({ layer = 4 })
        self._ww = self._pnl:w()
        self._hh = self._pnl:h()
        managers.viewport:add_resolution_changed_func(callback(self, self, "onResolutionChanged"))
        self._floats = {}
        self._smokes = {}
        Hooks:PostHook(QuickSmokeGrenade, "detonate", "EHI_QuickSmokeGrenade_detonate", function(base, ...)
            local unit = base._unit
            self._smokes[unit:key()] = unit:position()
        end)
        Hooks:PostHook(QuickSmokeGrenade, "destroy", "EHI_QuickSmokeGrenade_destroy", function(base, ...)
            self._smokes[base._unit:key()] = nil
        end)
    end)

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
            self._floats[key] = EHIHealthFloatPoco:new(self, key, unit, t)
        end
    end

    function EHIHealthFloatManager:update_last()
        for _, float in pairs(self._floats) do
            float:force_delete()
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
        return alive(self._ws) and pos and self._ws:world_to_screen(self._cam, pos)
    end

    ---@param t number
    function EHIHealthFloatManager:update(t, dt)
        self._cam = managers.viewport:get_current_camera()
        if not self._cam then return end
        self._camPos = self._cam:position()
        local rot = self._cam:rotation()
        self._nl_cam_forward = rot:y()

        self.state = self.state or self:_tryGetState()
        self.ADS = self.state and self.state._state_data.in_steelsight

        local r = nil
        local from = alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
        if from then
            local to = from + managers.player:player_unit():movement():m_head_rot():y() * 30000
            r = World:raycast("ray", from, to, "slot_mask", self._unit_slot_mask) --[[@as { unit: UnitObject? }]]
        end
        local unit = r and r.unit
        if unit then
            if unit:in_slot(8) and alive(unit:parent()) then
                unit = unit:parent()
            end
            if unit and unit:movement() then
                local cHealth = unit:character_damage() and unit:character_damage()._health
                if cHealth and cHealth > 0 and not Global.hud_disabled then
                    self:Float(unit, t)
                end
            end
        end

        for _, float in pairs(self._floats) do
            float:draw(t)
        end
    end

    function EHIHealthFloatManager:_tryGetState()
        local unit = managers.player:player_unit()
        if unit and unit:movement() then
            return unit:movement():current_state()
        end
        return nil
    end
else
    if EHI:GetOption("show_floating_health_bar_style") == 2 then
        dofile(EHI.LuaPath .. "EHIHealthFloatCircle.lua")
        EHI:AddCallback("EHIHealthFloatManagerInit",
        ---@param self EHIHealthFloatManager
        ---@param hud_panel Panel
        function(self, hud_panel)
            self._float = EHIHealthFloatCircle:new(hud_panel)
            EHI:AddOnCustodyCallback(function(custody_state)
                self._float:SetInCustody(custody_state)
            end)
        end)
    else
        dofile(EHI.LuaPath .. "EHIHealthFloatRect.lua")
        EHI:AddCallback("EHIHealthFloatManagerInit",
        ---@param self EHIHealthFloatManager
        ---@param hud_panel Panel
        function(self, hud_panel)
            self._float = EHIHealthFloatRect:new(hud_panel)
            EHI:AddOnCustodyCallback(function(custody_state)
                self._float:SetInCustody(custody_state)
            end)
        end)
    end

    function EHIHealthFloatManager:update_last()
        self._float:UpdateLast()
    end

    ---@param t number
    function EHIHealthFloatManager:update(t, dt)
        local r = nil
        local from = alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
        if from then
            local to = from + managers.player:player_unit():movement():m_head_rot():y() * 30000
            r = World:raycast("ray", from, to, "slot_mask", self._unit_slot_mask) --[[@as { unit: UnitEnemy? }]]
        end
        local unit = r and r.unit
        if unit then
            if unit:in_slot(8) and alive(unit:parent()) then
                unit = unit:parent() --[[@as UnitEnemy?]]
            end
            if unit and unit:movement() then
                local cHealth = unit:character_damage() and unit:character_damage()._health
                if cHealth and not Global.hud_disabled then
                    self._float:SetUnit(unit, t)
                end
            end
        end
        self._float:Update(t)
    end
end