if EHI.PlayerUtils then
    return
end
EHI.PlayerUtils =
{
    super = EHI
}
local camera_pos = Vector3()

---@param id string
---@param f fun(movement: PlayerMovement)
function EHI.PlayerUtils:AddPlayerMovementCreatedCallback(id, f)
    if not self._player_movement_spawned_callback then
        self._player_movement_spawned_callback = ListenerHolder:new()
    end
end

---@param f fun(t: number, dt: number, camera_pos: Vector3, nl_cam_forward: Vector3)
function EHI.PlayerUtils:AddPlayerCameraRefresh(f)
    if not self._player_camera_refresh_callback then
        self._player_camera_refresh_callback = CallbackEventHandler:new()
        Hooks:PostHook(PlayerCamera, "init", "EHI_EHI.PlayerUtils_PlayerCamera_init", function(base, ...)
            if not self.__player_camera then
                self.__player_camera = base._camera_object
                managers.hud:add_updator("EHI.PlayerUtils.Camera", callback(self, self, "_player_camera_refresh"))
            end
        end)
        Hooks:PreHook(PlayerCamera, "destroy", "EHI_EHI.PlayerUtils_PlayerCamera_destroy", function(...)
            managers.hud:remove_updator("EHI.PlayerUtils.Camera")
            self.__player_camera = nil
        end)
    end
    self._player_camera_refresh_callback:add(f)
end

---@param t number
---@param dt number
function EHI.PlayerUtils:_player_camera_refresh(t, dt)
    self.__player_camera:m_position(camera_pos)
    local nl_cam_forward = self.__player_camera:rotation():y()
    self._player_camera_refresh_callback:dispatch(t, dt, camera_pos, nl_cam_forward)
end

---@param f fun()
function EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(f)
    if self._grenade_callback_executed then
        if not managers.blackmarket:equipped_grenade_allows_pickups() then
            f()
        end
    elseif not self._grenade_does_not_allow_pickups_callback then
        self._grenade_does_not_allow_pickups_callback = CallbackEventHandler:new()
        self.super:AddOnSpawnedCallback(function()
            if not managers.blackmarket:equipped_grenade_allows_pickups() then
                self._grenade_does_not_allow_pickups_callback:dispatch()
            end
            self._grenade_does_not_allow_pickups_callback:clear()
            self._grenade_does_not_allow_pickups_callback = nil
            self._grenade_callback_executed = true
        end)
    end
    self._grenade_does_not_allow_pickups_callback:add(f)
end