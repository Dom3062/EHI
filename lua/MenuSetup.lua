local EHI = EHI
if EHI:CheckMenuHook("MenuSetup") then
    return
end

local init_managers = MenuSetup.init_managers
---@param managers managers
function MenuSetup:init_managers(managers, ...)
    init_managers(self, managers, ...)
    local achievements = tweak_data.achievement
    if achievements and achievements._check_uno then
        local callback = callback(achievements, achievements, "_check_uno")
        managers.savefile:add_load_sequence_done_callback_handler(callback)
        managers.savefile:add_load_done_callback(callback)
    end
end