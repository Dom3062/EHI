local EHI = EHI
---@class EHIWaypointManager
local EHIWaypointManager = {}
EHIWaypointManager._id = "EHIWaypointManager"
EHIWaypointManager._font = tweak_data.menu.pd2_large_font -- Large font
EHIWaypointManager._font_id = tweak_data.menu.pd2_large_font_id -- Large font
EHIWaypointManager._timer_font_size = 32
EHIWaypointManager._distance_font_size = tweak_data.hud.default_font_size
EHIWaypointManager._bitmap_w = 32
EHIWaypointManager._bitmap_h = 32
EHIWaypointManager._vanilla_waypoint_show_distance = false
function EHIWaypointManager:post_init()
    EHIWaypoint._parent_class = self
    self._t = 0
    self._enabled = EHI:GetOption("show_waypoints") --[[@as boolean]]
    self._present_timer = EHI:GetOption("show_waypoints_present_timer") --[[@as number]]
    self._stored_waypoints = {} ---@type table<string, AddWaypointTable|ElementWaypointTrigger>
    self._n_of_waypoints = 0
    self._waypoints = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIWaypoint?>
    self._waypoints_data = {} ---@type table<string, Waypoint>
    self._waypoints_to_update = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIWaypoint?>
    self._base_waypoint_class = EHI.Waypoints.Base
    self._get_icon = tweak_data.ehi.default.tracker.get_icon
end

function EHIWaypointManager:init_finalize()
    if self._enabled then
        self._scale_offset_multiplier = EHI:GetOption("show_waypoints_offset_multiplier")
        self._update_waypoint_position_callback = callback(self, self, "update_position")
        EHI:AddOnAlarmCallback(function(dropin)
            for _, waypoint in pairs(self._waypoints) do
                waypoint:SwitchToLoudMode()
            end
        end)
    end
end

---@param panel Panel
---@param saferect Workspace
function EHIWaypointManager:SetPlayerHUD(panel, saferect)
    self._panel = panel
    self._saferect = saferect
    for id, params in pairs(self._stored_waypoints) do
        self:AddWaypoint(id, params)
    end
    self._stored_waypoints = {}
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    elseif not self._panel then
        self._stored_waypoints[id] = params
        return
    elseif self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    local waypoint = self:_create_waypoint_data(params)
    local w = (params.class_table or _G[params.class or self._base_waypoint_class]):new(waypoint, params)
    if w._needs_update then
        self._waypoints_to_update[id] = w
    end
    self._waypoints[id] = w
    if params.remove_vanilla_waypoint then
        managers.hud:SoftRemoveWaypoint2(params.remove_vanilla_waypoint)
    end
    if self._n_of_waypoints <= 0 then
        managers.hud:add_updator(self._id, self._update_waypoint_position_callback)
    end
    self._n_of_waypoints = self._n_of_waypoints + 1
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypointlessWaypoint(id, params)
    if not self._enabled then
        return
    elseif self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    self._waypoints[id] = (params.class_table or _G[params.class or self._base_waypoint_class]):new(nil, params)
end

---Only Waypoints should call this. This function creates the waypoint on the HUD  
---Created waypoint is added to `self._waypoints_data` as it is EHI Waypoint
---@param id number
---@param icon string
---@param position Vector3
---@param present_timer number?
function EHIWaypointManager:_create_waypoint(id, icon, position, present_timer)
    local params = {} ---@type WaypointInitData
    params.id = id
    params.icon = icon or "pd2_lootdrop"
    params.present_timer = present_timer or self._present_timer
    params.position = position
    if self._n_of_waypoints <= 0 then
        managers.hud:add_updator(self._id, self._update_waypoint_position_callback)
    end
    self._n_of_waypoints = self._n_of_waypoints + 1
    return self:_create_waypoint_data(params)
end

---Only Waypoints should call this. This function creates the waypoint on the HUD  
---However it is not added to `self._waypoints_data` as it is not EHI Waypoint but rather Vanilla Waypoint
---@param id number
---@param icon string
---@param position Vector3
---@param present_timer number?
---@return Waypoint?
function EHIWaypointManager:_create_vanilla_waypoint(id, icon, position, present_timer)
    if not (self._enabled and self._panel) then
        return
    end
    local params = {} ---@type WaypointInitData
    params.id = id
    params.icon = icon or "pd2_lootdrop"
    params.timer = 0
    params.pause_timer = 1
    params.present_timer = present_timer or self._present_timer
    params.position = position
    params.distance = self._vanilla_waypoint_show_distance
    local waypoint = managers.hud:AddEHIWaypoint(id, params)
    if not waypoint then
        return
    elseif not (waypoint.bitmap and waypoint.timer_gui) then
        managers.hud:remove_waypoint(id)
        return
    end
    self:_set_waypoint_initial_icon(waypoint, params) ---@diagnostic disable-line
    if waypoint.distance then
        waypoint.distance:set_font(self._font_id)
        waypoint.distance:set_font_size(self._distance_font_size)
    end
    waypoint.timer_gui:set_font(self._font_id)
    waypoint.timer_gui:set_font_size(self._timer_font_size)
    return waypoint
end

---@param id string
function EHIWaypointManager:RemoveWaypoint(id)
    local wp = table.remove_key(self._waypoints, id)
    if wp then
        wp:destroy()
        self._waypoints_to_update[id] = nil
    end
    local wp_data = table.remove_key(self._waypoints_data, id)
    if wp_data then
        self:_remove_waypoint_data(wp_data)
        self._n_of_waypoints = self._n_of_waypoints - 1
        if self._n_of_waypoints <= 0 then
            managers.hud:remove_updator(self._id)
        end
    end
end

---@param id number
function EHIWaypointManager:RestoreVanillaWaypoint(id)
    if id then
        managers.hud:RestoreWaypoint2(id)
    end
end

---@param data AddWaypointTable|ElementWaypointTrigger|WaypointInitData
function EHIWaypointManager:_unpack_icon(data)
    if data.texture then
        return data.texture, data.texture_rect
    end
    return self._get_icon(type(data.icon) == "table" and data.icon[1] or data.icon --[[@as string]])
end

---@param data AddWaypointTable|ElementWaypointTrigger|WaypointInitData
function EHIWaypointManager:_create_waypoint_data(data)
    local waypoint_panel = self._panel
    local icon, texture_rect = self:_unpack_icon(data)
    local bitmap = waypoint_panel:bitmap({
        layer = 0,
        rotation = 360,
        texture = icon,
        texture_rect = texture_rect,
        w = self._bitmap_w,
        h = self._bitmap_h,
        blend_mode = data.blend_mode,
        color = data.color
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
    local distance = nil

    if data.distance or self._vanilla_waypoint_show_distance then
        distance = waypoint_panel:text({
            vertical = "center",
            h = 24,
            w = 128,
            align = "center",
            text = "16.5",
            rotation = 360,
            layer = 0,
            color = data.color or Color.white,
            font = self._font,
            font_size = self._distance_font_size,
            blend_mode = data.blend_mode
        })
        distance:hide()
    end

    local timer = waypoint_panel:text({
        font_size = 32,
        h = 32,
        vertical = "center",
        w = 32,
        align = "center",
        rotation = 360,
        layer = 0,
        text = "0",
        font = self._font,
        color = data.color
    })
    local text = waypoint_panel:text({
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

    local w, h = bitmap:size()
    local wp = {
        move_speed = 1,
        init_data = data,
        state = data.state or "present",
        present_timer = data.present_timer or self._present_timer,
        bitmap = bitmap,
        arrow = arrow,
        size = Vector3(w, h, 0),
        text = text,
        distance = distance,
        timer_gui = timer,
        position = data.position,
        unit = data.unit,
        radius = data.radius or 160
    } ---@cast wp Waypoint
    self._waypoints_data[data.id] = wp
    wp.init_data.position = data.position or data.unit and data.unit:position()
    if not wp.init_data.position then
        EHI:Log("[EHIWaypointManager] Custom waypoint does not have position defined! Added default position to avoid crashing")
        EHI:LogTraceback()
        wp.init_data.position = Vector3()
        wp.position = Vector3()
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

---@param wp Waypoint
function EHIWaypointManager:_remove_waypoint_data(wp)
    self._panel:remove(wp.arrow)
    self._panel:remove(wp.bitmap)
    if wp.distance then
        self._panel:remove(wp.distance)
    end
    self._panel:remove(wp.timer_gui)
    self._panel:remove(wp.text)
end

---@param id string
---@param new_id string
function EHIWaypointManager:UpdateWaypointID(id, new_id)
    local wp = self._waypoints[id]
    if self._waypoints[new_id] or not wp then
        return
    end
    wp._id = new_id
    self._waypoints[new_id] = table.remove_key(self._waypoints, id)
    self._waypoints_to_update[new_id] = table.remove_key(self._waypoints_to_update, id)
    self._waypoints_data[new_id] = table.remove_key(self._waypoints_data, id)
end

---@param bitmap Bitmap?
---@param icon string
---@param texture_rect TextureRect
function EHIWaypointManager:_set_bitmap_image(bitmap, icon, texture_rect)
    if bitmap then
        if texture_rect then
            bitmap:set_image(icon, unpack(texture_rect))
        else
            bitmap:set_image(icon)
        end
        bitmap:set_size(self._bitmap_w, self._bitmap_h)
    end
end

---@param wp Waypoint
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:_set_waypoint_initial_icon(wp, params)
    local icon, texture_rect = self:_unpack_icon(params)
    self:_set_bitmap_image(wp.bitmap, icon, texture_rect)
    wp.size = Vector3(self._bitmap_w, self._bitmap_h, 0)
    self:_set_bitmap_image(wp.bitmap_world, icon, texture_rect)
end

---@param id string
---@param new_icon string
function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    if id and self._waypoints[id] then
        local wp = self._waypoints_data[id] or managers.hud:get_waypoint_data(id)
        if wp then
            self:_set_waypoint_initial_icon(wp, { icon = new_icon })
        end
    end
end

---@param id string
---@param pos Vector3
function EHIWaypointManager:SetWaypointPosition(id, pos)
    if self:WaypointExists(id) then
        local wp = self._waypoints_data[id] or managers.hud:get_waypoint_data(id)
        if wp and pos then
            wp.position = pos
            wp.init_data.position = pos
        end
    end
end

---@param id string
function EHIWaypointManager:WaypointExists(id)
    return id and self._waypoints[id] ~= nil or false
end

---@param id string
function EHIWaypointManager:WaypointDoesNotExist(id)
    return not self:WaypointExists(id)
end

---@param id string
---@param time number
function EHIWaypointManager:SetTime(id, time)
    local wp = self._waypoints[id]
    if wp then
        wp:SetTime(time)
    end
end

---@param id string
---@param pause boolean
function EHIWaypointManager:SetPaused(id, pause)
    local wp = self._waypoints[id] --[[@as EHIPausableWaypoint]]
    if wp and wp.SetPause then
        wp:SetPause(pause)
    end
end

---@param id string
---@param t number
function EHIWaypointManager:SetAccurate(id, t)
    local wp = id and self._waypoints[id] --[[@as EHIInaccurateWaypoint]]
    if wp and wp.SetAccurate then
        wp:SetAccurate(t)
    end
end

---@param id string
---@param progress number
function EHIWaypointManager:SetProgress(id, progress)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.SetProgress then
        wp:SetProgress(progress)
    end
end

---@param id string
function EHIWaypointManager:IncreaseProgress(id)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.IncreaseProgress then
        wp:IncreaseProgress()
    end
end

---@param id string
---@param max number?
function EHIWaypointManager:IncreaseProgressMax(id, max)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.IncreaseProgressMax then
        wp:IncreaseProgressMax(max)
    end
end

---@param id string
---@param max number?
function EHIWaypointManager:DecreaseProgressMax(id, max)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.DecreaseProgressMax then
        wp:DecreaseProgressMax(max)
    end
end

---@param id string
---@param amount number
function EHIWaypointManager:IncreaseChance(id, amount)
    local wp = id and self._waypoints[id] --[[@as EHIChanceWaypoint]]
    if wp and wp.IncreaseChance then
        wp:IncreaseChance(amount)
    end
end

function EHIWaypointManager:SwitchToLoudMode()
    for _, waypoint in pairs(self._waypoints) do
        waypoint:SwitchToLoudMode()
    end
end

---@param wp EHIWaypoint
function EHIWaypointManager:_add_waypoint_to_update(wp)
    self._waypoints_to_update[wp._id] = wp
end

---@param id string
function EHIWaypointManager:_remove_waypoint_from_update(id)
    self._waypoints_to_update[id] = nil
end

---@param dt number
function EHIWaypointManager:update(dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(dt)
    end
end

---@param dt number
function EHIWaypointManager:update2(t, dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(dt)
    end
end

---@param t number
function EHIWaypointManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(dt)
end

local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()
---@param t number
---@param dt number
function EHIWaypointManager:update_position(t, dt)
    local cam = managers.viewport:get_current_camera()

    if not cam then
        return
    end

    local cam_pos = managers.viewport:get_current_camera_position()
    local cam_rot = managers.viewport:get_current_camera_rotation()

    mrotation.y(cam_rot, wp_cam_forward)

    local panel = self._panel

    for _, data in pairs(self._waypoints_data) do
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
                data.distance:show()
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
                    data.distance:show()
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

                    data.arrow:show()
                    data.bitmap:set_alpha(0.75)

                    data.off_timer = 0 - (1 - data.in_timer)
                    data.target_scale = 0.75

                    if data.distance then
                        data.distance:hide()
                    end

                    if data.timer_gui then
                        data.timer_gui:hide()
                    end
                end

                local direction = wp_onscreen_direction
                local panel_center_x, panel_center_y = panel:center()

                mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
                mvector3.normalize(direction)

                local distance = data.radius * self._scale_offset_multiplier
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
                data.arrow:set_center(mvector3.x(data.current_position) + direction.x * 24, mvector3.y(data.current_position) + direction.y * 24)

                local angle = math.X:angle(direction) * math.sign(direction.y)

                data.arrow:set_rotation(angle)

                if data.text_alpha ~= 0 then
                    data.text:set_center_x(data.bitmap:center_x())
                    data.text:set_top(data.bitmap:bottom())
                end
            else
                if data.state == "offscreen" then
                    data.state = "onscreen"

                    data.arrow:hide()
                    data.bitmap:set_alpha(1)

                    data.in_timer = 0 - (1 - data.off_timer)
                    data.target_scale = 1

                    if data.distance then
                        data.distance:show()
                    end

                    if data.timer_gui then
                        data.timer_gui:show()
                    end
                end

                local alpha = 0.8

                if dot > 0.99 then
                    alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
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

                    data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
                else
                    mvector3.set(data.current_position, wp_pos)
                end

                data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

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
        end
    end
end

function EHIWaypointManager:destroy()
    for key, _ in pairs(self._waypoints) do
        self._waypoints[key] = nil
    end
end

---@param id string
---@param f string
---@param ... any
function EHIWaypointManager:CallFunction(id, f, ...)
    local wp = self._waypoints[id]
    if wp and wp[f] then
        wp[f](wp, ...)
    end
end

---Returns `true` if the waypoint does not exist
---@param id string
---@param f string
---@param ... any
function EHIWaypointManager:CallFunction2(id, f, ...)
    local wp = id and self._waypoints[id]
    if not wp then
        return true
    elseif wp[f] then
        wp[f](wp, ...)
    end
end

function EHIWaypointManager:ReturnValue2(id, f, ...)
    local wp = id and self._waypoints[id]
    if not (wp and wp[f]) then
        return true
    end
    return wp[f](wp, ...)
end

do
    local path = EHI.LuaPath .. "waypoints/"
    dofile(path .. "EHIWaypoint.lua")
    dofile(path .. "EHIWarningWaypoint.lua")
    dofile(path .. "EHIPausableWaypoint.lua")
    dofile(path .. "EHIProgressWaypoint.lua")
    dofile(path .. "EHIChanceWaypoint.lua")
    dofile(path .. "EHIInaccurateWaypoints.lua")
end

if _G.IS_VR then
    return blt.vm.loadfile(EHI.LuaPath .. "vr/EHIWaypointManagerVR.lua")(EHIWaypointManager)
elseif restoration and restoration.Options and restoration.Options:GetValue("HUD/Waypoints") then
    return blt.vm.loadfile(EHI.LuaPath .. "hud/waypoint/restoration_mod.lua")(EHIWaypointManager)
end
return EHIWaypointManager