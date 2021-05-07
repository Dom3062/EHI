local EHI = EHI

local function AddGageTracker()
    if EHI:GetOption("show_gage_tracker") and not managers.hud:TrackerExists("Gage") and EHI._cache.GagePackages and EHI._cache.GagePackages > 0 then
        local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
        managers.hud:AddTracker({
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
        managers.hud.ehi:ShowPanel()
    end
    if Global.statistics_manager.playing_from_start then
        if Network:is_client() then
            managers.hud.ehi:SyncTime(0)
        end
    else
        managers.hud:RemoveTracker("uno_9")
        managers.hud:RemoveTracker("cane_3")
    end
    AddGageTracker()
end