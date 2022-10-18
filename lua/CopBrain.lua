local EHI = EHI
if EHI._hooks.CopBrain then
    return
else
    EHI._hooks.CopBrain = true
end

if not (EHI:GetOption("show_pager_callback") and Global.load_level) then
    return
end

EHIPagerTracker = class(EHIWarningTracker)
EHIPagerTracker._forced_icons = { "pager_icon" }
function EHIPagerTracker:init(panel, params)
    params.time = 12
    EHIPagerTracker.super.init(self, panel, params)
end

function EHIPagerTracker:SetAnswered()
    self:RemoveTrackerFromUpdate()
    self._text:stop()
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIPagerTracker:delete()
    self._parent_class:RemovePager(self._id)
    EHIPagerTracker.super.delete(self)
end

local original =
{
    on_alarm_pager_interaction = CopBrain.on_alarm_pager_interaction
}

function CopBrain:on_alarm_pager_interaction(status, ...)
    original.on_alarm_pager_interaction(self, status, ...)
    local id = "pager_" .. tostring(self._unit:key())
    if status == "started" then
        managers.ehi:CallFunction(id, "SetAnswered")
        managers.ehi_waypoint:SetPagerWaypointAnswered(id)
    else
        managers.ehi:RemoveTracker(id)
        managers.ehi_waypoint:RemoveWaypoint(id)
    end
end