local EHI = EHI
managers.ehi_experience = EHIExperienceManager
if EHI:CheckLoadHook("Setup") then
    EHI:Hook(Setup, "init_managers", function(self, managers, ...) ---@param managers managers
        local achievements = tweak_data.achievement
        if achievements and achievements._check_uno then
            local check_uno = callback(achievements, achievements, "_check_uno")
            managers.savefile:add_load_done_callback(check_uno)
            managers.savefile:add_load_sequence_done_callback_handler(check_uno)
        end
    end)
    return
end
dofile(EHI.LuaPath .. "EHICarryData.lua")
dofile(EHI.LuaPath .. "EHIBaseManager.lua")
dofile(EHI.LuaPath .. "EHITrackerManager.lua")
dofile(EHI.LuaPath .. "EHIWaypointManager.lua")
dofile(EHI.LuaPath .. "EHIBuffManager.lua")
dofile(EHI.LuaPath .. "EHIDeployableManager.lua")
dofile(EHI.LuaPath .. "EHITradeManager.lua")
dofile(EHI.LuaPath .. "EHIEscapeChanceManager.lua")
dofile(EHI.LuaPath .. "EHIAssaultManager.lua")
dofile(EHI.LuaPath .. "EHIUnlockableManager.lua")
dofile(EHI.LuaPath .. "EHIPhalanxManager.lua")
dofile(EHI.LuaPath .. "EHITimerManager.lua")
dofile(EHI.LuaPath .. "EHILootManager.lua")
dofile(EHI.LuaPath .. "EHISyncManager.lua")
dofile(EHI.LuaPath .. "EHIHookManager.lua")
dofile(EHI.LuaPath .. "EHIMoneyManager.lua")
dofile(EHI.LuaPath .. "EHIManager.lua")

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize
}

---@param managers managers
function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi_tracker = EHITrackerManager:new()
    managers.ehi_waypoint = EHIWaypointManager:new()
    managers.ehi_buff = EHIBuffManager:new()
    managers.ehi_trade = EHITradeManager:new(managers.ehi_tracker)
    managers.ehi_escape = EHIEscapeChanceManager:new(managers.ehi_tracker)
    managers.ehi_deployable = EHIDeployableManager:new(managers.ehi_tracker)
    managers.ehi_assault = EHIAssaultManager:new(managers.ehi_tracker)
    managers.ehi_experience:TrackersInit(managers.ehi_tracker)
    managers.ehi_unlockable = EHIUnlockableManager:new(managers.ehi_tracker)
    managers.ehi_phalanx = EHIPhalanxManager
    managers.ehi_timer = EHITimerManager:new(managers.ehi_tracker)
    managers.ehi_loot = EHILootManager:new()
    managers.ehi_sync = EHISyncManager
    managers.ehi_hook = EHIHookManager:new(managers.ehi_tracker, managers.ehi_loot)
    managers.ehi_money = EHIMoneyManager
    managers.ehi_manager = EHIManager:new(managers)
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi_manager:init_finalize()
end