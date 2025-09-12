local EHI = EHI
managers.ehi_experience = blt.vm.dofile(EHI.LuaPath .. "EHIExperienceManager.lua")
if EHI:CheckLoadHook("Setup") then
    return
end
managers.ehi_tracker = blt.vm.dofile(EHI.LuaPath .. "EHITrackerManager.lua")
managers.ehi_waypoint = blt.vm.dofile(EHI.LuaPath .. "EHIWaypointManager.lua")
if EHI:GetOption("show_equipment_tracker") and (EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_ammobag") or EHI:GetOption("show_equipment_bodybags") or EHI:GetOption("show_equipment_grenadecases") or EHI:GetOption("show_equipment_firstaidkit")) then
    managers.ehi_deployable = blt.vm.dofile(EHI.LuaPath .. "EHIDeployableManager.lua")
end
if not EHI:IsTradeTrackerDisabled() then
    managers.ehi_trade = blt.vm.dofile(EHI.LuaPath .. "EHITradeManager.lua")
end
if EHI:IsEscapeChanceEnabled() then
    managers.ehi_escape = blt.vm.dofile(EHI.LuaPath .. "EHIEscapeChanceManager.lua")
end
managers.ehi_assault = blt.vm.dofile(EHI.LuaPath .. "EHIAssaultManager.lua")
managers.ehi_unlockable = blt.vm.dofile(EHI.LuaPath .. "EHIUnlockableManager.lua")
managers.ehi_phalanx = blt.vm.dofile(EHI.LuaPath .. "EHIPhalanxManager.lua")
if EHI:GetTrackerOrWaypointOption("show_timers", "show_waypoints_timers") then
    managers.ehi_timer = blt.vm.dofile(EHI.LuaPath .. "EHITimerManager.lua")
end
managers.ehi_loot = blt.vm.dofile(EHI.LuaPath .. "EHILootManager.lua")
managers.ehi_sync = blt.vm.dofile(EHI.LuaPath .. "EHISyncManager.lua")
managers.ehi_hook = blt.vm.dofile(EHI.LuaPath .. "EHIHookManager.lua")
managers.ehi_money = blt.vm.dofile(EHI.LuaPath .. "EHIMoneyManager.lua")
managers.ehi_tracking = blt.vm.dofile(EHI.LuaPath .. "EHITrackingManager.lua")

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize
}

---@param managers managers
function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi_tracker:post_init()
    managers.ehi_waypoint:post_init()
    managers.ehi_assault:post_init(managers.ehi_tracker)
    managers.ehi_unlockable:post_init(managers.ehi_tracker)
    managers.ehi_phalanx:init_finalize(managers.ehi_tracker, managers.ehi_hook, managers.ehi_assault)
    managers.ehi_hook:post_init(managers.ehi_tracker, managers.ehi_loot)
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi_tracker:init_finalize()
    managers.ehi_waypoint:init_finalize()
    managers.ehi_assault:init_finalize()
    managers.ehi_loot:init_finalize()
    managers.ehi_money:init_finalize(managers)
    managers.ehi_sync:init_finalize()
    EHI.Mission:init_finalize()
end