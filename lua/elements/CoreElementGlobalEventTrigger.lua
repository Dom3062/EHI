if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
end

local EHI = rawget(_G, "EHI")
if EHI._hooks.ElementGlobalEventTrigger then
    return
else
    EHI._hooks.ElementGlobalEventTrigger = true
end

if Global.game_settings.level_id ~= "dah" then
    return
end

core:module("CoreElementGlobalEventTrigger")

local triggers = {
    [102261] = { id = "dah_8" }
}

local function Trigger(id)
    if triggers[id] then
        managers.hud:IncreaseProgress(triggers[id].id)
    end
end

local _f_client_on_executed = ElementGlobalEventTrigger.client_on_executed
function ElementGlobalEventTrigger:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementGlobalEventTrigger.on_executed
function ElementGlobalEventTrigger:on_executed(...)
    _f_on_executed(self, ...)
    Trigger(self._id)
end