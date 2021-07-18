local EHI = EHI
if EHI._hooks.IngameWaitingForPlayersState then
	return
else
	EHI._hooks.IngameWaitingForPlayersState = true
end

local function AddGageTracker()
    if EHI:GetOption("show_gage_tracker") and managers.ehi:TrackerDoesNotExist("Gage") and EHI._cache.GagePackages and EHI._cache.GagePackages > 0 then
        local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
        managers.ehi:AddTracker({
            id = "Gage",
            icons = { "gage" },
            progress = EHI._cache.GagePackagesProgress or 0,
            max = max,
            class = "EHIProgressTracker"
        })
    end
end

local function f()
    local idstring = Idstring("units/pd2_dlc_nmh/props/nmh_prop_counter/nmh_prop_counter")
    local units = World:find_units_quick("all", 1)
    for _, unit in pairs(units) do
        if unit and unit:name() == idstring and unit:digital_gui() then
            EHI:Log("Found counter; Timer: " .. tostring(unit:digital_gui()._timer) .. "; Timer Count Down: " .. tostring(unit:digital_gui()._timer_count_down) .. "; Paused: " .. tostring(unit:digital_gui()._timer_paused))
        end
    end
end

local original =
{
    at_exit = IngameWaitingForPlayersState.at_exit
}
function IngameWaitingForPlayersState:at_exit(...)
    original.at_exit(self, ...)
    if not Global.hud_disabled then
        managers.ehi:ShowPanel()
    end
    AddGageTracker()
    if EHI.debug then
        for _, unit in pairs(managers.interaction._interactive_units or {}) do
            EHI:Log("unit:interaction().tweak_data = " .. tostring(unit:interaction().tweak_data))
        end
        EHI:DelayCall("Debug", 5, f)
    end
end