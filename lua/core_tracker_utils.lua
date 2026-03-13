if EHI.TrackerUtils then
    return
end
EHI.TrackerUtils =
{
    super = EHI
}

---@param all_icons table
---@param one_icon table
function EHI.TrackerUtils:GetTrackerIcons(all_icons, one_icon)
    return self.super:GetOption("show_one_icon") and one_icon or all_icons
end

---@param enabled_class string
---@param disabled_class string
function EHI.TrackerUtils:EnableSniperClassTracking(enabled_class, disabled_class)
    if EHISniperBase then
        EHISniperBase._enabled = true
        return enabled_class
    end
    return disabled_class
end

function EHI.TrackerUtils:GetColorCodesMap()
    return {
        red = Color.red,
        green = Color.green,
        blue = tweak_data.ehi:ColorRedirect(Color.blue)
    }
end

---@param colored_codes EHI.ColorTable
---@return { string: Idstring[] }
function EHI.TrackerUtils:CacheColorCodesNumbers(colored_codes)
    local codes = {}
    for color, _ in pairs(colored_codes) do
        local c = {}
        for i = 0, 9, 1 do
            c[i] = Idstring(string.format("g_number_%s_0%d", color, i))
        end
        codes[color] = c
    end
    return codes
end

---@param codes { string: Idstring[] }
---@param bg Idstring
---@param unit Unit?
---@param color string
---@return number?
function EHI.TrackerUtils:CheckIfCodeIsVisible(codes, bg, unit, color)
    if not unit then
        return nil
    end
    local color_codes = codes[color]
    if unit:get_object(bg):visibility() then
        for i = 0, 9, 1 do
            if unit:get_object(color_codes[i]):visibility() then
                return i
            end
        end
    end
    return nil -- Has not been interacted yet
end

---@param wp_params WaypointLootCounterTable?
---@param max_offset_f? fun(n_of_loot: integer): integer
function EHI.TrackerUtils:IsLootCounterVisible(wp_params, max_offset_f)
    if managers.job:IsAnyDayAnyHeistModActive() then
        return true
    elseif self.super:IsPlayingCrimeSpree() then
        return false
    elseif self.super:IsLootCounterVisible() and managers.job:get_memory("EHI_SavedLoot") then
        local max = managers.job:get_memory("EHI_SavedLoot")
        if max > 0 then
            self.super:ShowLootCounter({
                max = max + (max_offset_f and max_offset_f(max) or 0)
            }, wp_params)
            return false
        end
    end
    return true
end

-- Lua Linter is drunk and is unable to show functions if the table is created with super
EHI.TrackerUtils.Deployables =
{
    super = EHI
}
-----@param params { shapes: { pos: Vector3, rot: Rotation, width: number, depth: number, height: number }[], element_area_id: number }
---@param params { shapes: number[], element_area_id: number }
---@param load_sync_f fun(self: EHIMissionElementTrigger)?
---@return ElementTrigger?
function EHI.TrackerUtils.Deployables:AddDeployablesIgnoreCheck(params, load_sync_f)
    if not params then
        return nil
    end
    self._shapes = self._shapes or {} ---@type CoreShapeManager.ShapeBoxMiddle[]
    for i, shape_id in ipairs(params.shapes) do
        local element = managers.mission:get_element_by_id(shape_id) --[[@as ElementAreaTrigger?]]
        if element then
            self._shapes[i] = CoreShapeManager.ShapeBoxMiddle:new({
                position = element._values.position,
                rotation = element._values.rotation,
                width = element._values.width,
                depth = element._values.depth,
                height = element._values.height
            })
        end
    end
    return { special_function = self.super.SpecialFunctions.CustomCode, f = function()
        self:RunPositionShapeChecks()
    end, load_sync = load_sync_f or function(element) ---@param element EHIMissionElementTrigger
        local despawn_area = managers.mission:get_element_by_id(params.element_area_id) --[[@as ElementAreaTrigger?]]
        if despawn_area and despawn_area:enabled() then
            element:Trigger()
        end
    end }
end

function EHI.TrackerUtils.Deployables:RunPositionShapeChecks()
    if self._ignore_shape_check_run then
        return
    end
    self._ignore_shape_check_run = true
    if self._units then
        for key, unit in pairs(clone(self._units)) do
            self:_deployable_ignored(key, unit)
        end
        self._units = nil
    end
end

---@param id string
---@param f fun(key: userdata, base: AmmoBagBase|FirstAidKitBase|GrenadeCrateBase)
function EHI.TrackerUtils.Deployables:AddIgnoreListener(id, f)
    self._callback_listener = self._callback_listener or ListenerHolder:new()
    self._callback_listener:add(id, f)
end

---@param id string
function EHI.TrackerUtils.Deployables:RemoveIgnoreListener(id)
    if self._callback_listener then
        self._callback_listener:remove(id)
    end
end

---@overload fun(self: self, key: userdata, nil, base: AmmoBagBase|FirstAidKitBase|GrenadeCrateBase)
---@param key userdata
---@param unit UnitAmmoDeployable|UnitFAKDeployable|UnitGrenadeDeployable
---@param base AmmoBagBase|FirstAidKitBase|GrenadeCrateBase?
function EHI.TrackerUtils.Deployables:_deployable_ignored(key, unit, base)
    base = base or unit:base()
    if base and base.SetIgnore then
        base:SetIgnore()
    end
    if self._callback_listener then
        self._callback_listener:call(key, base)
    end
end

---@param unit UnitAmmoDeployable|UnitFAKDeployable|UnitGrenadeDeployable
function EHI.TrackerUtils.Deployables:OnDeployablePlaced(unit)
    if not self._shapes then
        return
    end
    local pos = unit:position()
    local key = unit:key()
    for _, shape in ipairs(self._shapes) do
        if shape:is_inside(pos) then
            if self._ignore_shape_check_run then
                self:_deployable_ignored(key, unit)
            else
                self._units = self._units or {} ---@type table<userdata, UnitAmmoDeployable|UnitFAKDeployable|UnitGrenadeDeployable>
                self._units[key] = unit
            end
            break
        end
    end
end

---@param key userdata
function EHI.TrackerUtils.Deployables:OnDeployableConsumed(key)
    if self._units then
        self._units[key] = nil
    end
end