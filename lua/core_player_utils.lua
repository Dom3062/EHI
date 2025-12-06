if EHI.PlayerUtils then
    return
end
EHI.PlayerUtils =
{
    super = EHI
}

---@param f fun()
function EHI.PlayerUtils:AddGrenadeDoesNotAllowPickupsCallback(f)
    if not self._grenade_does_not_allow_pickups_callback then
        self._grenade_does_not_allow_pickups_callback = CallbackEventHandler:new()
        self.super:AddOnSpawnedCallback(function()
            if not managers.blackmarket:equipped_grenade_allows_pickups() then
                self._grenade_does_not_allow_pickups_callback:dispatch()
            end
            self._grenade_does_not_allow_pickups_callback:clear()
            self._grenade_does_not_allow_pickups_callback = nil
        end)
    end
    self._grenade_does_not_allow_pickups_callback:add(f)
end