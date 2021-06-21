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
    local pex_medal = Idstring("units/pd2_dlc_pex/props/pex_props_federali_chief_medal/pex_props_federali_chief_medal")
    local total = 0
    for _, unit in ipairs(World:find_units_quick("all", 1)) do
        if unit and unit:name() == pex_medal then
            EHI:Log("Medal found (" .. tostring(unit:editor_id()) .. "); interactable: " .. tostring(unit:interaction() and unit:interaction():active()) .. "; empty: " .. tostring(unit:base()._empty) .. "; enabled: " .. tostring(unit:enabled()))
            total = total + 1
        end
    end
    EHI:Log("Total medals found: " .. tostring(total))
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
    if Global.statistics_manager.playing_from_start then
        if Network:is_client() then
            managers.ehi:SyncTime(0)
        end
    else
        managers.ehi:RemoveTracker("uno_9")
    end
    AddGageTracker()
    if EHI.debug then
        for _, unit in pairs(managers.interaction._interactive_units or {}) do
            EHI:Log("unit:interaction().tweak_data = " .. tostring(unit:interaction().tweak_data))
        end
        f()
        --EHI:DelayCall("EHIMedals", 60, f)
    end
end