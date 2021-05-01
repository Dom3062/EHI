if true then
    return
end

if core then
    core:module("CoreMissionManager")
    core:import("CoreMissionScriptElement")
    core:import("CoreEvent")
    core:import("CoreClass")
    core:import("CoreDebug")
    core:import("CoreCode")
    core:import("CoreTable")
    return
end

local _f_init = MissionScript.init
function MissionScript:init(data)
    _f_init(self, data)
    _G.PrintTable(data)
    log("elements:")
    _G.PrintTable(data.elements)
    log("instances:")
    _G.PrintTable(data.instances)
end