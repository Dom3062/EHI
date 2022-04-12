local icons = tweak_data.ehi.icons

local EHI = EHI
EHIWaypointManager = EHIWaypointManager or class()
function EHIWaypointManager:init()
    self._enabled = EHI:GetOption("show_waypoints")
    self._present_timer = EHI:GetOption("show_waypoints_present_timer")
    self._scale = 1
    self._stored_waypoints = {}
    self._waypoints = {}
    self._t = 0
    self._dt = 0
end

function EHIWaypointManager:init_finalize()
    EHI:AddOnAlarmCallback(callback(self, self, "RemoveAllPagerWaypoints"))
end

do
    local math_floor = math.floor
    local string_format = string.format
    local function SecondsOnly(self, time)
        local t = math_floor(time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", time)
        elseif t < 10 then
            return string_format("%.1f", t)
        else
            return string_format("%d", t)
        end
    end

    local function MinutesAndSeconds(self, time)
        local t = math_floor(time * 10) / 10

        if t < 0 then
            return string_format("%d", 0)
        elseif t < 1 then
            return string_format("%.2f", time)
        elseif t < 10 then
            return string_format("%.1f", t)
        elseif t < 60 then
            return string_format("%d", t)
        else
            return string_format("%d:%02d", t / 60, t % 60)
        end
    end

    if EHI:GetOption("time_format") == 1 then
        EHIWaypointManager.WaypointFormat = SecondsOnly
    else
        EHIWaypointManager.WaypointFormat = MinutesAndSeconds
    end
end

function EHIWaypointManager:LoadTime(t)
    self._t = t
end

function EHIWaypointManager:SetPlayerHUD(hud, saferect, gui)
    self._hud = hud
    self._hud_panel = hud.panel
    self._saferect = saferect
    for id, params in pairs(self._stored_waypoints) do
        self:AddWaypoint(id, params)
    end
    self._stored_waypoints = {}
end

function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    end
    if not self._hud then
        self._stored_waypoints[id] = params
        return
    end
    if self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    local waypoint_panel = self._hud_panel
    local text = ""
    local icon, texture_rect
    local wp_color = params.color or Color.white
    if params.texture then
        icon = params.texture
        texture_rect = params.text_rect
    else
        local _icon = type(params.icon) == "table" and params.icon[1] or params.icon
        if icons[_icon] then
            icon = icons[_icon].texture
            texture_rect = icons[_icon].texture_rect
        else
            icon, texture_rect = tweak_data.hud_icons:get_icon_or(_icon, icons.default.texture, icons.default.texture_rect)
        end
    end
    local bitmap = waypoint_panel:bitmap({
        layer = 0,
        rotation = 360,
        name = "bitmap" .. id,
        texture = icon,
        texture_rect = texture_rect,
        w = 32 * self._scale,
        h = 32 * self._scale,
        blend_mode = params.blend_mode,
        color = wp_color
    })
    local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("wp_arrow")
    local arrow = waypoint_panel:bitmap({
        layer = 0,
        visible = false,
        rotation = 360,
        name = "arrow" .. id,
        texture = arrow_icon,
        texture_rect = arrow_texture_rect,
        color = wp_color:with_alpha(0.75),
        w = arrow_texture_rect[3] * self._scale,
        h = arrow_texture_rect[4] * self._scale,
        blend_mode = params.blend_mode
    })
    local distance = nil

    if params.distance then
        distance = waypoint_panel:text({
            vertical = "center",
            h = 24 * self._scale,
            w = 128 * self._scale,
            align = "center",
            text = "16.5",
            rotation = 360,
            layer = 0,
            name = "distance" .. id,
            color = wp_color,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.hud.default_font_size,
            blend_mode = params.blend_mode
        })

        distance:set_visible(false)
    end

    local timer = params.time and waypoint_panel:text({
        font_size = 32,
        h = 32 * self._scale,
        vertical = "center",
        w = 32 * self._scale,
        align = "center",
        rotation = 360,
        layer = 0,
        name = "timer" .. id,
        text = self:WaypointFormat(params.time),
        font = tweak_data.menu.pd2_large_font,
        color = wp_color
    })
    text = waypoint_panel:text({
        h = 24 * self._scale,
        vertical = "center",
        w = 512 * self._scale,
        align = "center",
        rotation = 360,
        layer = 0,
        name = "text" .. id,
        text = utf8.to_upper(" " .. text),
        font = tweak_data.hud.small_font,
        font_size = tweak_data.hud.small_font_size,
        color = wp_color
    })
    local _, _, w, _ = text:text_rect()

    text:set_w(w)

    local w, h = bitmap:size()
    self._waypoints[id] = {
        move_speed = 1,
        init_data = params,
        state = params.state or "present",
        present_timer = params.present_timer or self._present_timer,
        bitmap = bitmap,
        arrow = arrow,
        size = Vector3(w, h, 0),
        text = text,
        distance = distance,
        timer_gui = timer,
        timer = params.time,
        pause_timer = params.pause_timer or params.time and 0,
        position = params.position,
        unit = params.unit,
        radius = (params.radius or 160) * self._scale,
        type = params.type or "standard_timer",
        color = wp_color
    }
    self._waypoints[id].init_data.position = params.position or params.unit:position()
    local t = {}

    for _, data in pairs(self._waypoints) do
        if params.slot then
            t[params.slot] = params.text:w()
        end
    end

    for i = 1, 10 do
        if not t[i] then
            self._waypoints[id].slot = i

            break
        end
    end

    self._waypoints[id].slot_x = 0

    if self._waypoints[id].slot == 2 then
        self._waypoints[id].slot_x = t[1] / 2 + self._waypoints[id].text:w() / 2 + 10
    elseif self._waypoints[id].slot == 3 then
        self._waypoints[id].slot_x = -t[1] / 2 - self._waypoints[id].text:w() / 2 - 10
    elseif self._waypoints[id].slot == 4 then
        self._waypoints[id].slot_x = t[1] / 2 + t[2] + self._waypoints[id].text:w() / 2 + 20
    elseif self._waypoints[id].slot == 5 then
        self._waypoints[id].slot_x = -t[1] / 2 - t[3] - self._waypoints[id].text:w() / 2 - 20
    end
end

function EHIWaypointManager:RemoveWaypoint(id)
    if not self._waypoints[id] then
        return
    end

    local waypoint_panel = self._hud_panel

    waypoint_panel:remove(self._waypoints[id].bitmap)
    waypoint_panel:remove(self._waypoints[id].text)
    waypoint_panel:remove(self._waypoints[id].arrow)

    if self._waypoints[id].timer_gui then
        if self._waypoints[id].init_data.warning_started then
            self._waypoints[id].timer_gui:stop()
        end
        waypoint_panel:remove(self._waypoints[id].timer_gui)
    end

    if self._waypoints[id].distance then
        waypoint_panel:remove(self._waypoints[id].distance)
    end

    self._waypoints[id] = nil
end

function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    if id and self._waypoints[id] then
        local icon, texture_rect
        if icons[new_icon] then
            icon = icons[new_icon].texture
            texture_rect = icons[new_icon].texture_rect
        else
            icon, texture_rect = tweak_data.hud_icons:get_icon_or(new_icon, icons.default.texture, icons.default.texture_rect)
        end
        self._waypoints[id].bitmap:set_image(icon, texture_rect)
    end
end

function EHIWaypointManager:WaypointExists(id)
    return id and self._waypoints[id] or false
end

function EHIWaypointManager:WaypointDoesNotExist(id)
    return not self:WaypointExists(id)
end

function EHIWaypointManager:WaypointExistsAndType(id, type)
    return id and self._waypoints[id] and self._waypoints[id].type == type
end

function EHIWaypointManager:SetWaypointTime(id, time)
    if self:WaypointExistsAndType(id, "standard_timer") then
        self._waypoints[id].timer_gui:set_text(self:WaypointFormat(time))
    end
end

function EHIWaypointManager:SetTimerWaypointTime(id, time)
    if self:WaypointExistsAndType(id, "timer") then
        local wp = self._waypoints[id]
        wp.timer_gui:set_text(self:WaypointFormat(time))
        if time <= 10 and wp.init_data.warning and not wp.init_data.warning_started then
            wp.init_data.warning_started = true
            self:AnimateWarning(wp)
        end
    end
end

function EHIWaypointManager:SetTimerVaultWaypointTime(id, time)
    if self:WaypointExistsAndType(id, "timer") then
        local wp = self._waypoints[id]
        if wp.init_data.synced_time == 0 then
            wp.timer = (50 - time) * 10
        else
            local new_tick = time - wp.init_data.synced_time
            if new_tick ~= wp.init_data.tick then
                wp.timer = ((50 - time) / (new_tick * 10)) * 10
                wp.init_data.tick = new_tick
            end
        end
        wp.init_data.synced_time = time
    end
end

function EHIWaypointManager:SetTimerWaypointJammed(id, jammed)
    if not self:WaypointExistsAndType(id, "timer") then
        return
    end
    local wp = self._waypoints[id]
    if wp.init_data.warning_started then
        wp.timer_gui:stop()
        wp.init_data.warning_started = false
    end
    wp._jammed = jammed
    self:SetTimerWaypointColor(id)
end

function EHIWaypointManager:SetTimerWaypointPowered(id, powered)
    if not self:WaypointExistsAndType(id, "timer") then
        return
    end
    self._waypoints[id]._not_powered = not powered
    self:SetTimerWaypointColor(id)
end

function EHIWaypointManager:SetTimerWaypointColor(id)
    if not self:WaypointExistsAndType(id, "timer") then
        return
    end
    local wp = self._waypoints[id]
    local final_color = wp.color
    if wp._jammed or wp._not_powered then
        final_color = Color.red
    end
    self:SetWaypointColor(id, final_color)
end

function EHIWaypointManager:SetWaypointPause(id, pause)
    if not self:WaypointExistsAndType(id, "pausauble_waypoint") then
        return
    end
    local wp = self._waypoints[id]
    local final_color = Color.white
    if pause then
        final_color = Color.red
    end
    wp.pause_timer = pause and 1 or 0
    self:SetWaypointColor(id, final_color)
end

function EHIWaypointManager:PauseWaypoint(id)
    self:SetWaypointPause(id, true)
end

function EHIWaypointManager:UnpauseWaypoint(id)
    self:SetWaypointPause(id, false)
end

function EHIWaypointManager:SetWaypointColor(id, color, override_base_color)
    if not (id and self._waypoints[id]) then
        return
    end
    local wp = self._waypoints[id]
    if override_base_color then
        wp.color = color
    end
    wp.bitmap:set_color(color)
    wp.timer_gui:set_color(color)
    wp.arrow:set_color(color)
end

function EHIWaypointManager:SetPagerWaypointAnswered(id)
    if not self:WaypointExistsAndType(id, "pager_timer") then
        return
    end
    local wp = self._waypoints[id]
    wp.pause_timer = 1
    wp.timer_gui:stop()
    self:SetWaypointColor(id, Color.green)
end

function EHIWaypointManager:RemoveAllPagerWaypoints()
    for key, wp in pairs(self._waypoints) do
        if wp.type == "pager_timer" then
            self:RemoveWaypoint(key)
        end
    end
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()
local mvector3 = mvector3
local mvector3_x = mvector3.x
local mvector3_y = mvector3.y
local mvector3_dot = mvector3.dot
local mvector3_set = mvector3.set
local mvector3_subtract = mvector3.subtract
local mvector3_normalize = mvector3.normalize
local mvector3_set_static = mvector3.set_static
local mrotation = mrotation
local mrotation_y = mrotation.y
local math = math
local math_sign = math.sign
local math_clamp = math.clamp
local math_bezier = math.bezier
local tweak_data = tweak_data
local tweak_data_scale = tweak_data.scale
function EHIWaypointManager:update(t, dt, dt_actual)
    local cam = managers.viewport:get_current_camera()

    if not cam then
        return
    end

    local cam_pos = managers.viewport:get_current_camera_position()
    local cam_rot = managers.viewport:get_current_camera_rotation()

    mrotation_y(cam_rot, wp_cam_forward)

    for id, data in pairs(self._waypoints) do
        local panel = self._hud_panel

        if data.state == "sneak_present" then
            data.current_position = Vector3(panel:center_x(), panel:center_y())

            data.bitmap:set_center_x(data.current_position.x)
            data.bitmap:set_center_y(data.current_position.y)

            data.slot = nil
            data.current_scale = 1
            data.state = "present_ended"
            data.text_alpha = 0.5
            data.in_timer = 0
            data.target_scale = 1

            if data.distance then
                data.distance:set_visible(true)
            end
        elseif data.state == "present" then
            data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)

            data.bitmap:set_center_x(data.current_position.x)
            data.bitmap:set_center_y(data.current_position.y)
            data.text:set_center_x(data.bitmap:center_x())
            data.text:set_top(data.bitmap:bottom())

            data.present_timer = data.present_timer - dt

            if data.present_timer <= 0 then
                data.slot = nil
                data.current_scale = 1
                data.state = "present_ended"
                data.text_alpha = 0.5
                data.in_timer = 0
                data.target_scale = 1

                if data.distance then
                    data.distance:set_visible(true)
                end
            end
        else
            if data.text_alpha ~= 0 then
                data.text_alpha = math_clamp(data.text_alpha - dt, 0, 1)

                data.text:set_alpha(data.text_alpha)
            end

            data.position = data.unit and data.unit:position() or data.position

            mvector3_set(wp_pos, self._saferect:world_to_screen(cam, data.position))
            mvector3_set(wp_dir, data.position)
            mvector3_subtract(wp_dir, cam_pos)
            mvector3_set(wp_dir_normalized, wp_dir)
            mvector3_normalize(wp_dir_normalized)

            local dot = mvector3_dot(wp_cam_forward, wp_dir_normalized)

            if dot < 0 or panel:outside(mvector3_x(wp_pos), mvector3_y(wp_pos)) then
                if data.state ~= "offscreen" then
                    data.state = "offscreen"

                    data.arrow:set_visible(true)
                    data.bitmap:set_alpha(0.75)

                    data.off_timer = 0 - (1 - data.in_timer)
                    data.target_scale = 0.75

                    if data.distance then
                        data.distance:set_visible(false)
                    end

                    if data.timer_gui then
                        data.timer_gui:set_visible(false)
                    end
                end

                local direction = wp_onscreen_direction
                local panel_center_x, panel_center_y = panel:center()

                mvector3_set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
                mvector3_normalize(direction)

                local distance = data.radius * tweak_data_scale.hud_crosshair_offset_multiplier
                local target_pos = wp_onscreen_target_pos

                mvector3_set_static(target_pos, panel_center_x + mvector3_x(direction) * distance, panel_center_y + mvector3_y(direction) * distance, 0)

                data.off_timer = math_clamp(data.off_timer + dt / data.move_speed, 0, 1)

                if data.off_timer ~= 1 then
                    mvector3_set(data.current_position, math_bezier({
                        data.current_position,
                        data.current_position,
                        target_pos,
                        target_pos
                    }, data.off_timer))

                    data.current_scale = math_bezier({
                        data.current_scale,
                        data.current_scale,
                        data.target_scale,
                        data.target_scale
                    }, data.off_timer)

                    data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
                else
                    mvector3_set(data.current_position, target_pos)
                end

                data.bitmap:set_center(mvector3_x(data.current_position), mvector3_y(data.current_position))
                data.arrow:set_center(mvector3_x(data.current_position) + direction.x * 24, mvector3_y(data.current_position) + direction.y * 24)

                local angle = math.X:angle(direction) * math_sign(direction.y)

                data.arrow:set_rotation(angle)

                if data.text_alpha ~= 0 then
                    data.text:set_center_x(data.bitmap:center_x())
                    data.text:set_top(data.bitmap:bottom())
                end
            else
                if data.state == "offscreen" then
                    data.state = "onscreen"

                    data.arrow:set_visible(false)
                    data.bitmap:set_alpha(1)

                    data.in_timer = 0 - (1 - data.off_timer)
                    data.target_scale = 1

                    if data.distance then
                        data.distance:set_visible(true)
                    end

                    if data.timer_gui then
                        data.timer_gui:set_visible(true)
                    end
                end

                local alpha = 0.8

                if dot > 0.99 then
                    alpha = math_clamp((1 - dot) / 0.01, 0.4, alpha)
                end

                if data.bitmap:alpha() ~= alpha then
                    data.bitmap:set_alpha(alpha)

                    if data.distance then
                        data.distance:set_alpha(alpha)
                    end

                    if data.timer_gui then
                        data.timer_gui:set_alpha(alpha)
                    end
                end

                if data.in_timer ~= 1 then
                    data.in_timer = math_clamp(data.in_timer + dt / data.move_speed, 0, 1)

                    mvector3_set(data.current_position, math_bezier({
                        data.current_position,
                        data.current_position,
                        wp_pos,
                        wp_pos
                    }, data.in_timer))

                    data.current_scale = math_bezier({
                        data.current_scale,
                        data.current_scale,
                        data.target_scale,
                        data.target_scale
                    }, data.in_timer)

                    data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
                else
                    mvector3_set(data.current_position, wp_pos)
                end

                data.bitmap:set_center(mvector3_x(data.current_position), mvector3_y(data.current_position))

                if data.text_alpha ~= 0 then
                    data.text:set_center_x(data.bitmap:center_x())
                    data.text:set_top(data.bitmap:bottom())
                end

                if data.distance then
                    local length = wp_dir:length()

                    data.distance:set_text(string.format("%.0f", length / 100) .. "m")
                    data.distance:set_center_x(data.bitmap:center_x())
                    data.distance:set_top(data.bitmap:bottom())
                end
            end
        end

        if data.timer_gui then
            data.timer_gui:set_center_x(data.bitmap:center_x())
            data.timer_gui:set_bottom(data.bitmap:top())

            if data.pause_timer == 0 then
                data.timer = data.timer - (dt_actual or dt)
                if data.timer > 0 then
                    data.timer_gui:set_text(self:WaypointFormat(data.timer))
                    if data.timer <= 10 and data.init_data.warning and not data.init_data.warning_started then
                        data.init_data.warning_started = true
                        self:AnimateWarning(data)
                    end
                else
                    self:RemoveWaypoint(id)
                end
            end
        end
    end
end

function EHIWaypointManager:update_dt(t, dt)
    self._dt = dt
end

function EHIWaypointManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(self._t, self._dt, dt)
end

function EHIWaypointManager:AnimateWarning(waypoint)
    local icon = waypoint.bitmap
    local arrow = waypoint.arrow
    waypoint.timer_gui:animate(function(o)
        while true do
            local t = 0
            while t < 1 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                --local r = math.lerp(1, 0, n)
                local g = math.lerp(1, 0, n)
                local c = Color(1, g, g)
                o:set_color(c)
                icon:set_color(c)
                arrow:set_color(c)
            end
        end
    end)
end

function EHIWaypointManager:destroy()
    for key, _ in pairs(self._waypoints) do
        self._waypoints[key] = nil
    end
end

if _G.IS_VR then
    return
end

if VoidUI and VoidUI.options.enable_waypoints then
    dofile(EHI.LuaPath .. "hud/waypoint/void_ui.lua")
end