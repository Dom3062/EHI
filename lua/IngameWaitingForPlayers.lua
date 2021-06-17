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

local original =
{
    at_exit = IngameWaitingForPlayersState.at_exit
}
function IngameWaitingForPlayersState:at_exit(next_state)
    original.at_exit(self, next_state)
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
        EHI:DelayCall("Test", 10, function()
            managers.preplanning:IsAssetBought(101854)
        end)
    end
end