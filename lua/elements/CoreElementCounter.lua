if core then
    core:module("CoreElementCounter")
    core:import("CoreMissionScriptElement")
    core:import("CoreClass")
end

if not (Global and Global.game_settings and Global.game_settings.level_id) then
    return
else
    return
end

local level_id = Global.game_settings.level_id
local triggers = {}
if level_id == "mallcrasher" then
    triggers = {
        [300842] = { id = "MallDestruction", class = "ExtraHUDMoneyTracker", icon = "achievement" }
    }
    return
else
    return
end

local function Trigger(id)
    managers.hud:Debug(id, "ElementCounter")
    if triggers[id] then
        managers.hud:Debug(id, "ElementCounter Add Tracker")
        managers.hud:AddTracker({
            id = triggers[id].id,
            class = triggers[id].class,
            icon = triggers[id].icon
        })
    end
end

local _f_client_on_executed = ElementCounter.client_on_executed
function ElementCounter:client_on_executed(...)
    _f_client_on_executed(self, ...)
    Trigger(self._id)
end

local _f_on_executed = ElementCounter.on_executed
function ElementCounter:on_executed(instigator)
    _f_on_executed(self, instigator)
    Trigger(self._id)
end