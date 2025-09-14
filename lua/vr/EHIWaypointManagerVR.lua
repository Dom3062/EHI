---@class EHIWaypointManager
local EHIWaypointManagerVR = ...
local original = EHIWaypointManagerVR.SetPlayerHUD
function EHIWaypointManagerVR:SetPlayerHUD(hud, ...)
    original(self, hud, ...)
    self._gui = hud._gui
end

function EHIWaypointManagerVR:_create_waypoint_data(data)
    local ws = self._gui:create_world_workspace(128, 64, (data.position or data.unit:position()) + Vector3(40, 0, 20), Vector3(-80, 0, 0), Vector3(0, 0, -40))
    ws:set_billboard(Workspace.BILLBOARD_Y)
    local waypoint_panel = self._panel
    local icon, texture_rect = self:_unpack_icon(data)
    local bitmap = waypoint_panel:bitmap({
        layer = 0,
        visible = false,
        rotation = 360,
        texture = icon,
        texture_rect = texture_rect,
        w = self._bitmap_w,
        h = self._bitmap_h,
        blend_mode = data.blend_mode
    })
    local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("wp_arrow")
    local arrow = waypoint_panel:bitmap({
        layer = 0,
        visible = false,
        rotation = 360,
        texture = arrow_icon,
        texture_rect = arrow_texture_rect,
        color = (data.color or Color.white):with_alpha(0.75),
        w = arrow_texture_rect[3],
        h = arrow_texture_rect[4],
        blend_mode = data.blend_mode
    })
    local bitmap_world = ws:panel():bitmap({
        layer = 0,
        render_template = "OverlayText",
        depth_mode = "disabled",
        rotation = 360,
        texture = icon,
        texture_rect = texture_rect,
        w = self._bitmap_w,
        h = self._bitmap_h,
        blend_mode = data.blend_mode
    })

    bitmap_world:set_center_x(ws:panel():w() / 2)

    local distance = nil

    if data.distance then
        distance = ws:panel():text({
            vertical = "center",
            h = 24,
            w = 128,
            align = "center",
            render_template = "OverlayText",
            text = "16.5",
            depth_mode = "disabled",
            rotation = 360,
            layer = 0,
            color = data.color or Color.white,
            font = tweak_data.hud.medium_font_noshadow,
            font_size = tweak_data.hud.default_font_size,
            blend_mode = data.blend_mode
        })

        distance:set_bottom(ws:panel():h())
        distance:set_center_x(ws:panel():w() / 2)
        distance:set_visible(false)
    end

    local timer = data.timer and ws:panel():text({
        font_size = 32,
        h = 32,
        vertical = "center",
        w = 32,
        align = "center",
        render_template = "OverlayText",
        depth_mode = "disabled",
        rotation = 360,
        layer = 0,
        text = (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer),
        font = tweak_data.hud.medium_font_noshadow
    })

    if timer then
        timer:set_bottom(ws:panel():h())
        timer:set_center_x(ws:panel():w() / 2)
    end

    local text = ws:panel():text({
        h = 24,
        vertical = "center",
        w = 512,
        align = "center",
        rotation = 360,
        layer = 0,
        text = utf8.to_upper(" "),
        font = tweak_data.hud.small_font,
        font_size = tweak_data.hud.small_font_size
    })
    local _, _, w, _ = text:text_rect()

    text:set_w(w)
    text:set_bottom(ws:panel():h())
    text:set_center_x(ws:panel():w() / 2)

    local w, h = bitmap:size()
    local wp = {
        move_speed = 1,
        init_data = data,
        state = data.state or "present",
        present_timer = data.present_timer or 2,
        bitmap = bitmap,
        arrow = arrow,
        size = Vector3(w, h, 0),
        text = text,
        distance = distance,
        timer_gui = timer,
        timer = data.timer,
        pause_timer = data.pause_timer or data.timer and 0,
        position = data.position,
        unit = data.unit,
        no_sync = data.no_sync,
        radius = data.radius or 160,
        ws = ws,
        bitmap_world = bitmap_world
    } ---@cast wp Waypoint
    self._waypoints_data[data.id] = wp
    wp.init_data.position = data.position or data.unit and data.unit:position()
    if not wp.init_data.position then
        EHI:Log("[EHIWaypointManagerVR] Custom waypoint does not have position defined! Added default position to avoid crashing")
        EHI:LogTraceback()
        wp.init_data.position = Vector3()
    end

    local t = {}
    for _, w_data in pairs(self._waypoints_data) do
        if w_data.slot then
            t[w_data.slot] = w_data.text:w()
        end
    end
    wp.slot_x = 0
    for i = 1, 10, 1 do
        if not t[i] then
            wp.slot = i
            break
        end
    end

    if wp.slot == 2 then
        wp.slot_x = t[1] / 2 + wp.text:w() / 2 + 10
    elseif wp.slot == 3 then
        wp.slot_x = -t[1] / 2 - wp.text:w() / 2 - 10
    elseif wp.slot == 4 then
        wp.slot_x = t[1] / 2 + t[2] + wp.text:w() / 2 + 20
    elseif wp.slot == 5 then
        wp.slot_x = -t[1] / 2 - t[3] - wp.text:w() / 2 - 20
    end

    return wp
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()
function EHIWaypointManagerVR:update_position(t, dt)
    local cam = managers.viewport:get_current_camera()

    if not cam then
        return
    end

    local cam_pos = managers.viewport:get_current_camera_position()
    local cam_rot = managers.viewport:get_current_camera_rotation()

    mrotation.y(cam_rot, wp_cam_forward)

    for id, data in pairs(self._waypoints_data) do
        local panel = data.bitmap:parent()
        if data.state == "sneak_present" then
            data.current_position = Vector3(panel:center_x(), panel:center_y())
            data.state = "present_ended"
            data.text_alpha = 0.5
            data.in_timer = 0
            data.current_scale = 1
            data.target_scale = 1

            if data.distance then
                data.distance:set_visible(true)
            end
        elseif data.state == "present" then
            data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)
            data.present_timer = data.present_timer - dt

            if data.present_timer <= 0 then
                data.state = "present_ended"
                data.text_alpha = 0.5
                data.in_timer = 0
                data.current_scale = 1
                data.target_scale = 1

                if data.distance then
                    data.distance:set_visible(true)
                end
            end
        else
            if data.text_alpha ~= 0 then
                data.text_alpha = math.clamp(data.text_alpha - dt, 0, 1)

                data.text:set_alpha(data.text_alpha)
            end

            data.position = data.unit and data.unit:position() or data.position

            mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
            mvector3.set(wp_dir, data.position)
            mvector3.subtract(wp_dir, cam_pos)
            mvector3.set(wp_dir_normalized, wp_dir)
            mvector3.normalize(wp_dir_normalized)

            local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

            if dot < 0 or panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
                if data.state ~= "offscreen" then
                    data.state = "offscreen"

                    data.arrow:set_visible(true)
                    data.bitmap_world:set_visible(false)
                    data.bitmap:set_visible(true)
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

                mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
                mvector3.normalize(direction)

                local distance = data.radius * tweak_data.scale.hud_crosshair_offset_multiplier
                local target_pos = wp_onscreen_target_pos

                mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

                data.off_timer = math.clamp(data.off_timer + dt / data.move_speed, 0, 1)

                if data.off_timer ~= 1 then
                    mvector3.set(data.current_position, math.bezier({
                        data.current_position,
                        data.current_position,
                        target_pos,
                        target_pos
                    }, data.off_timer))

                    data.current_scale = math.bezier({
                        data.current_scale,
                        data.current_scale,
                        data.target_scale,
                        data.target_scale
                    }, data.off_timer)

                    data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
                else
                    mvector3.set(data.current_position, target_pos)
                end

                data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

                local offset = 24

                data.arrow:set_center(mvector3.x(data.current_position) + direction.x * offset, mvector3.y(data.current_position) + direction.y * offset)

                local angle = math.X:angle(direction) * math.sign(direction.y)

                data.arrow:set_rotation(angle)

                if data.text_alpha ~= 0 then
                    data.text:set_center_x(data.bitmap:center_x())
                    data.text:set_top(data.bitmap:bottom())
                end
            else
                if data.state == "offscreen" then
                    data.state = "onscreen"

                    data.arrow:set_visible(false)
                    data.bitmap:set_visible(false)
                    data.bitmap_world:set_visible(true)
                    data.bitmap_world:set_alpha(1)

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
                    alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
                end

                if data.bitmap_world:alpha() ~= alpha then
                    data.bitmap_world:set_alpha(alpha)

                    if data.distance then
                        data.distance:set_alpha(alpha)
                    end

                    if data.timer_gui then
                        data.timer_gui:set_alpha(alpha)
                    end
                end

                if data.in_timer ~= 1 then
                    data.in_timer = math.clamp(data.in_timer + dt / data.move_speed, 0, 1)

                    mvector3.set(data.current_position, math.bezier({
                        data.current_position,
                        data.current_position,
                        wp_pos,
                        wp_pos
                    }, data.in_timer))

                    data.current_scale = math.bezier({
                        data.current_scale,
                        data.current_scale,
                        data.target_scale,
                        data.target_scale
                    }, data.in_timer)

                    data.bitmap_world:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
                else
                    mvector3.set(data.current_position, wp_pos)
                end

                if data.text_alpha ~= 0 then
                    data.text:set_center_x(data.bitmap:center_x())
                    data.text:set_top(data.bitmap:bottom())
                end

                local length = wp_dir:length()

                if data.distance then
                    data.distance:set_text(string.format("%.0f", length / 100) .. "m")
                end

                local w = length * -0.2
                local h = length * -0.1

                data.ws:set_world(128, 64, data.position + Vector3(-w / 2, 0, -h / 2), Vector3(w, 0, 0), Vector3(0, 0, h))
            end
        end
    end
end

return EHIWaypointManagerVR