if not _G.IS_VR then
    return
end

local available_trackers =
{
    Deployables = true,
    Health = true
}

EHIManagerVR = EHIManager
EHIManagerVR.old_init = EHIManager.init
EHIManagerVR.old_AddTracker = EHIManager.AddTracker

function EHIManagerVR:init()
    self._cached_trackers = {}
    self._cached_deployable_trackers = {}
    self:old_init()
end

function EHIManagerVR:AddTracker(params, pos)
    if not self._hud_created then
        if available_trackers[params.id] then
        else
            self._cached_trackers[params.id] =
            {
                params = params,
                pos = pos
            }
        end
        return
    end
    self:old_AddTracker(params, pos)
end

function EHIManagerVR:SetPlayerHUD(hud)
    self._hud = hud
    self._hud_panel = hud.panel
    self._hud_created = true
    --[[for _, tracker in pairs(self._cached_trackers) do
        self:AddTracker(tracker.params, tracker.pos)
    end]]
    for _, tracker in pairs(self._cached_trackers) do
        self:AddTracker(tracker.params, tracker.pos)
    end
    self._cached_trackers = {}
end

function EHIManagerVR:ShowPanel()
end

function EHIManagerVR:HidePanel()
end